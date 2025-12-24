// Created by Tayyab Mughal on 30/10/2023.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/main.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/get_started_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_url.dart';

///Http Method
enum ServerResponseType { error, success, exception }

enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  @override
  String toString() {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }
}

class ServerResponse<T> {
  /// response Type: 0: Error, 1: Success, -1: Exception
  // final int responseType;
  final ServerResponseType responseType;
  final String? message;
  final T? resultData;

  ServerResponse({
    required this.responseType,
    required this.resultData,
    required this.message,
  });
}

/// Dio Network Error
class DioNetworkError extends Error {
  final String message;

  DioNetworkError(this.message);

  @override
  String toString() => message;
}

class DioRequestError extends DioNetworkError {
  DioRequestError(super.message);
}

class DioConnectionError extends DioNetworkError {
  DioConnectionError() : super('No Internet Connection Available');
}

class DioHttpError extends DioNetworkError {
  final int statusCode;

  DioHttpError(this.statusCode) : super('HTTP Error: $statusCode');
}

/// Experimental Dio Network Manager
class DioNetworkManager {
  DioNetworkManager._internal() {
    initialize();
  }

  static final DioNetworkManager _instance = DioNetworkManager._internal();

  factory DioNetworkManager() => _instance;

  /// Initialize
  Future<void> initialize() async {
    getLocator<Logger>().i(
      "Dio Network Manager Initialized",
    );
  }

  /// Create Dio Adapter
  Dio _createDio() {
    final dio = Dio();
    dio.httpClientAdapter = _createHttpClientAdapter();

    dio.interceptors.add(
      _createInterceptor(baseUrl: ApiEndpoints.baseUrl),
    );

    return dio;
  }

  /// create http client adapter
  HttpClientAdapter _createHttpClientAdapter() {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
  }

  /// create interceptor
  Interceptor _createInterceptor({required String baseUrl}) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // set baseUrl
        options.baseUrl = baseUrl;

        // common header
        options.headers.addAll({
          "Content-Type": "application/json",
        });

        // Add authorization token to headers
        /// options.headers['Authorization'] = 'Bearer YOUR_TOKEN';

        // Add request-specific headers
        // options.headers.addAll(myHeaders);

        getLocator<Logger>().i(
          "InterceptorOnRequest: ${options.baseUrl}, ${options.headers}",
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        getLocator<Logger>().i(
          "InterceptorOnResponse: ${response.statusCode}, ${response.data}",
        );
        return handler.next(response);
      },
      onError: (error, handler) async {
        getLocator<Logger>().e("InterceptorOnError: $error");
        //(exception, stackTrace)

        await Sentry.captureException(
          error,
          stackTrace: handler,
        );

        return handler.next(error);
      },
    );
  }

  bool isDialogShowing = false;

  /// Perform Http Request
  Future<Response?> _performRequest({
    required String url,
    required HttpMethod httpMethod, // Use the HttpMethod enum
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
  }) async {
    /// Create Dio Object
    final dio = _createDio();

    /// check connectivity status
    List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();

    /// Common headers
    final commonHeaders = {
      "Content-Type": "application/json",
    };

    /// Header
    final header = {
      ...commonHeaders, // Merge common headers
      ...?myHeaders, // Merge request-specific headers
    };

    // perform request header
    getLocator<Logger>().i("performRequestHeader: $header");

    ///Check Connectivity Result
    if (connectivityResult != [ConnectivityResult.none]) {
      try {
        /// Make Dio Request
        final response = await dio.request(
          url,
          data: body,
          queryParameters: parameters,
          options: Options(
            method: httpMethod.name,
            headers: header, //myHeaders,
          ),
        );
        getLocator<Logger>().i(
          "dioSuccess: -> ${response.statusCode} | $response ",
        );
        return response;
      } on DioException catch (exception, stackTrace) {
        getLocator<Logger>().e(
          "dioError: -> StatusCode: ${exception.response?.statusCode} | Error: ${exception.error.toString()} | Response: ${exception.response}",
        );

        await Sentry.captureException(
          exception.response,
          stackTrace: stackTrace,
        );
        return exception.response;
      }
    } else {
      Toasts.getErrorToast(text: "No Internet Connection Available");
      getLocator<Logger>().e("No Internet Connection Available");
      return null;
    }
  }

  /// Make API Call
  /// [If need to add some more headers we can simple pass them using headers parameters]
  Future<ServerResponse<dynamic>> callAPI({
    required String url,
    required HttpMethod httpMethod, // Use the HttpMethod enum
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      //logger
      getLocator<Logger>().i(
        "Url: $url, body: $body, httpMethod: $httpMethod, Parameters: $parameters, myHeaders: $headers",
      );

      /// Make API Call
      Response? response = await _performRequest(
        url: url,
        body: body,
        httpMethod: httpMethod,
        parameters: parameters,
        myHeaders: headers,
      );
      getLocator<Logger>().i(
        "performRequestResponse: statusCode: ${response!.statusCode}, ${response.data}",
      );

      /// Check Response data not null
      if (response.data != null) {
        /// Check the status Code

        switch (response.statusCode) {
          case 200:
          case 201:
          case 202:
          case 204:
            return ServerResponse(
              responseType: ServerResponseType.success,
              message: 'Success',
              resultData: response.data,
            );
          case 400:
            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'Bad Request',
              resultData: response.data,
            );
          case 401:
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => GetStartedScreen()),
              (route) => false,
            );
            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'User Token Expired',
              resultData: response.data,
            );

          case 403:
          case 404:
          case 500:
            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'HTTP Error: ${response.statusCode}',
              resultData: response.data,
            );

          case 503:
            if (!CommonService.isMaintenancePopupVisible &&
                navigatorKey.currentContext != null) {
              CommonService.isMaintenancePopupVisible = true;

              showMaintenancePopup(
                context: navigatorKey.currentContext!,
                heading: Directionality.of(navigatorKey.currentContext!) == TextDirection.rtl? 
                AppLocalizations.of(navigatorKey.currentContext!)!.server_under_maintainance:"App Under Scheduled Maintenance",
                subtitle:Directionality.of(navigatorKey.currentContext!) == TextDirection.rtl?
                AppLocalizations.of(navigatorKey.currentContext!)!.maintainance_description:
                    """Save In Gold is currently undergoing a scheduled system upgrade  
to enhance security, stability, and real-time gold trading performance.
""",
                onExitPress: () {
                  CommonService.isMaintenancePopupVisible =
                      false;
                  SystemNavigator.pop();
                }, 
                onWebsitePress: () {
                  launchUrl(Uri.parse("https://saveingold.ae"));
                },
              ).then((_) {
                // 🔓 Unlock popup if user closes it using back or outside tap
                CommonService.isMaintenancePopupVisible = false;
              });
            }

            return ServerResponse(
              responseType: ServerResponseType.error,
              message: Directionality.of(navigatorKey.currentContext!) ==
                      TextDirection.rtl
                  ? AppLocalizations.of(navigatorKey.currentContext!)!
                      .server_under_maintainance
                  : 'Server Under Maintenance',
              resultData: response.data,
            );

          case 429:
            if (response.statusCode == 429) {
              await genericPopUpWidget(
                context: navigatorKey.currentContext!,
                heading: "Limit Exceeded",
                subtitle:
                    "Sorry you reached max limit of api call please try again after some time",
                noButtonTitle: "",
                isLoadingState: false,
                onNoPress: () => Navigator.pop(navigatorKey.currentContext!),
                yesButtonTitle: 'Close',
                onYesPress: () async {
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => GetStartedScreen()),
                    (route) => false,
                  );
                },

                // Navigator.pop(navigatorKey.currentContext!),
              );
            }

            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'HTTP Error: : ${response.statusCode}',
              resultData: response.data,
            );
          default:
            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'Unknown HTTP error',
              resultData: response.data,
            );
        }
      } else {
        return ServerResponse(
          responseType: ServerResponseType.exception,
          resultData: null,
          message: "Error is null: $response",
        );
      }
    // ignore: avoid_catching_errors
    } on DioConnectionError catch (exception, stackTrace) {
      // Handle connectivity error
      getLocator<Logger>().e(exception.message);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.exception,
        resultData: null,
        message: "Connection error: ${exception.message}",
      );
    // ignore: avoid_catching_errors
    } on DioHttpError catch (exception, stackTrace) {
      // Handle HTTP error with status code e.statusCode
      getLocator<Logger>().e(exception.message);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.error,
        resultData: null,
        message: "HTTP error with status code ${exception.statusCode}",
      );
    // ignore: avoid_catching_errors
    } on DioRequestError catch (exception, stackTrace) {
      // Handle request-specific error
      getLocator<Logger>().e(exception.message);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.error,
        resultData: null,
        message: "Request-specific error: ${exception.message}",
      );
    // ignore: avoid_catching_errors
    } on DioNetworkError catch (exception, stackTrace) {
      // Handle other custom network errors
      getLocator<Logger>().e(exception.message);

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.exception,
        resultData: null,
        message: "Custom network error: ${exception.message}",
      );
    } on FormatException catch (exception, stackTrace) {
      getLocator<Logger>().e("JSON decoding error: ${exception.message}");

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.exception,
        resultData: null,
        message: "JSON Decoding error: ${exception.message}",
      );
    } catch (exception, stackTrace) {
      // Handle unexpected errors
      getLocator<Logger>().e('Unexpected error: $exception');

      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      return ServerResponse(
        responseType: ServerResponseType.exception,
        resultData: null,
        message: "Unexpected error: $exception",
      );
    }
  }
}
