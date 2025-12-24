import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/common_service.dart';
import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/core/theme/const_toasts.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'payment_option_provider.g.dart';

class PaymentOptionState {
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;

  /// variable and enum
  final LoadingState loadingState;
  final bool isButtonState;
  final bool isImageState;

  // Constructor with optional named parameters and default values using null-aware operators.
  PaymentOptionState({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,

    /// variables and enums
    this.loadingState = LoadingState.loading,
    this.isButtonState = false,
    this.isImageState = false,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  // copyWith method to create a new instance with updated values
  PaymentOptionState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,

    /// variables and enums
    LoadingState? loadingState,
    bool? isButtonState,
    bool? isImageState,
  }) {
    return PaymentOptionState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,

      ///variables and enums
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isImageState: isImageState ?? this.isImageState,
    );
  }
}

@riverpod
class PaymentOption extends _$PaymentOption {
  @override
  PaymentOptionState build() {
    init();
    return PaymentOptionState();
  }

  /// init
  Future<void> init() async {
    getLocator<Logger>().i("PaymentOption Initialized");
  }

  /// set button state
  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  /// add cc-Avenue transaction
  Future<void> savePaymentTransaction({
    required String orderAmount,
    required String paymentMethod,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final token = await LocalDatabase.instance.getLoginToken();
      getLocator<Logger>().i("token: $token");

      final userId = await LocalDatabase.instance.getUserId();
      getLocator<Logger>().i("userId: $userId");

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final body = {
        "userId": userId,
        "trackingId": "TRK123456789",
        "orderId": "ORD987654321",
        "orderStatus": "Completed",
        "orderDate": "2025-03-04T12:30:00Z",
        "paymentMethod": paymentMethod,
        "orderAmount": orderAmount,
        "currency": "AED",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.addCCAvenueTransactionApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          Toasts.getSuccessToast(text: "${successResponse.payload?.message}");

          /// get user profile
          await ref.read(homeProvider.notifier).getUserProfile();
          if (!context.mounted) return;

          ///get home feed
          await ref
              .read(homeProvider.notifier)
              .getHomeFeed(
                context: context,
                showLoading: true,
              );

          if (!context.mounted) return;
          Navigator.pop(context);

          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      // Set up the payment intent request
      // Apple Pay uses 'card' as the underlying method
      //"payment_method_types": ['card'], //payment_method_types: ['card', 'apple_pay'],

      Map<String, dynamic> body = {
        'amount': CommonService.calculateAmount(amount: amount),
        'currency': currency,
        'customer': customerId,
        'payment_method_types[]': 'card',
      };

      // Make the request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Check response status
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("createPaymentIntentError: $exception");
      throw Exception(exception.toString());
    }
  }

  /// create stripe customer
  Future<Map<String, dynamic>> createStripeCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String countryCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': '$firstName $lastName',
          'email': email,
          'address[country]': countryCode,
        },
      );

      if (response.statusCode == 200) {
        getLocator<Logger>().i("jsonDecode: ${json.decode(response.body)}");
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create customer');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Exception(e.toString());
    }
  }
}
