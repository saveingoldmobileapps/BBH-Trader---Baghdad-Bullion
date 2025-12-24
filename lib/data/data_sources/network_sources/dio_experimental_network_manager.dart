// Created by Tayyab Mughal on 30/10/2023.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'api_url.dart';

/// HTTP Method
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
  final ServerResponseType responseType;
  final String? message;
  final T? resultData;

  ServerResponse({
    required this.responseType,
    this.resultData,
    this.message,
  });
}

/// Dio Network Errors
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

class DioNetworkManager {
  DioNetworkManager._internal() {
    _initialize();
    _dio = _createDio(); // single, reusable instance
  }

  static final DioNetworkManager _instance = DioNetworkManager._internal();

  factory DioNetworkManager() => _instance;

  late final Dio _dio;

  Future<void> _initialize() async {
    getLocator<Logger>().i("Dio Network Manager Initialized");
  }

  /// Build one Dio with BaseOptions & adapter
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      // trust all for now (pin in prod)
      createHttpClient: () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          getLocator<Logger>().i(
            "→ ${options.method} ${options.baseUrl}${options.path}\n"
            "   headers: ${options.headers}\n"
            "   query: ${options.queryParameters}\n"
            "   body: ${options.data}",
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          getLocator<Logger>().i(
            "← [${response.statusCode}] ${response.requestOptions.uri}\n"
            "   data: ${response.data}",
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          getLocator<Logger>().e("⚠️ DioException: $error");
          await Sentry.captureException(
            error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Core request logic with cancel, retries, connectivity
  Future<Response?> _performRequest({
    required String url,
    required HttpMethod httpMethod,
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
    CancelToken? cancelToken,
    int retries = 2,
  }) async {
    /// 1) Check network
    final conn = await Connectivity().checkConnectivity();
    if (conn.contains(ConnectivityResult.none)) {
      throw DioConnectionError();
    }

    /// 2) Merge headers
    final headers = {
      "Content-Type": "application/json",
      ...?myHeaders,
    };

    /// 3) Attempt request with simple retry
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await _dio.request(
          url,
          data: body,
          queryParameters: parameters,
          cancelToken: cancelToken,
          options: Options(
            method: httpMethod.name,
            headers: headers,
          ),
        );
      } on DioException catch (e) {
        /// retry on timeouts or socket errors
        if (attempt < retries &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.error is SocketException)) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        rethrow;
      }
    }
    return null;
  }

  /// Public API
  Future<ServerResponse<dynamic>> callAPI({
    required String url,
    required HttpMethod httpMethod,
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _performRequest(
        url: url,
        httpMethod: httpMethod,
        body: body,
        parameters: parameters,
        myHeaders: headers,
        cancelToken: cancelToken,
      );

      if (response == null) {
        return ServerResponse(
          responseType: ServerResponseType.exception,
          message: "No response",
        );
      }

      final code = response.statusCode ?? -1;
      final data = response.data;

      switch (code) {
        case 200:
        case 201:
        case 202:
        case 204:
          return ServerResponse(
            responseType: ServerResponseType.success,
            resultData: data,
            message: 'Success',
          );
        case 400:
            return ServerResponse(
              responseType: ServerResponseType.error,
              message: 'Bad Request',
              resultData: response.data,
            );
        case 401:
          return ServerResponse(
            responseType: ServerResponseType.error,
            resultData: data,
            message: 'User Token Expired',
          );
        case 403:
        case 404:
        case 500:
          return ServerResponse(
            responseType: ServerResponseType.error,
            resultData: data,
            message: 'HTTP Error: $code',
          );
        case 429:
          return ServerResponse(
            responseType: ServerResponseType.error,
            resultData: data,
            message: 'Too Many Requests',
          );
        default:
          return ServerResponse(
            responseType: ServerResponseType.error,
            resultData: data,
            message: 'Unknown HTTP error: $code',
          );
      }
    } on DioConnectionError catch (e) {
      return ServerResponse(
        responseType: ServerResponseType.exception,
        message: e.message,
      );
    } on DioException catch (e) {
      final msg = e.error is DioNetworkError
          ? (e.error as DioNetworkError).message
          : e.message;
      return ServerResponse(
        responseType: ServerResponseType.error,
        resultData: e.response?.data,
        message: msg,
      );
    } catch (exception) {
      return ServerResponse(
        responseType: ServerResponseType.exception,
        message: 'Unexpected: $exception',
      );
    }
  }
}
