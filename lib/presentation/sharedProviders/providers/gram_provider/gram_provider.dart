import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:baghdad_bullion_house/core/enums/loading_state.dart';
import 'package:baghdad_bullion_house/core/sound_services.dart';
import 'package:baghdad_bullion_house/core/sounds/app_sounds.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/data/models/gram_balance/GramApiResponseModel.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/theme/const_toasts.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../../../data/models/ErrorResponse.dart';
import '../../../feature_injection.dart';
import '../states/gram_states/gram_states.dart';

part 'gram_provider.g.dart';

@riverpod
class Gram extends _$Gram {
  @override
  GramState build() {
    return GramState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("HomeProvider Initialized");
  }

  /// set button state
  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  /// set upload image state
  void setUploadImageState(bool imageState) {
    state = state.copyWith(isImageState: imageState);
  }

  /// set loading state
  void setLoadingState(LoadingState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  /// fetch gram list
  Future<void> getUserGramBalance() async {
    try {
      setLoadingState(LoadingState.loading);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      /// server response
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getUserGramStatementsApiUrl,
        // body: requestBody,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;
          GramApiResponseModel gramApiResponseModel =
              GramApiResponseModel.fromJson(
                responseData,
              );

          state = state.copyWith(
            gramApiResponseModel: gramApiResponseModel,
          );
          setLoadingState(LoadingState.data);
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
          setLoadingState(LoadingState.error);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          setLoadingState(LoadingState.error);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch User Statements Error: $e");
      setLoadingState(LoadingState.error);
    }
  }

  /// cancel order
  Future<bool> cancelTradeOrder({
    required String orderId,

    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "_id": orderId,
      };

      /// server response
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.tradeDeleteApiUrl,
        body: body,
        httpMethod: HttpMethod.delete,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;

          SuccessResponse successResponse = SuccessResponse.fromJson(
            responseData,
          );

          if (!context.mounted) return false;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          setButtonState(false);
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          setButtonState(false);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          setButtonState(false);
          return false;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch User Statements Error: $e");
      setButtonState(false);
      return false;
    }
  }

  Future<bool> updateBuyOrder({
    required BuildContext context,
    required num dealId,
    required String tradeMoney,
    required String tradeMetal,
    required String buyAtPrice,
    required String buyingPrice,
  }) async {
    try {
      setButtonState(true);

      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "dealId": dealId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "buyAtPrice": buyAtPrice,
        "buyingPrice": buyingPrice,
      };

      /// server response
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateByOrderApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;

          SuccessResponse successResponse = SuccessResponse.fromJson(
            responseData,
          );

          getLocator<Logger>().i("Sending body to server: $body");

          if (!context.mounted) return false;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          return false;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Update Buy Order Error: $e");
      return false;
    } finally {
      setButtonState(false);
    }
  }

  Future<bool> updateSellOrder({
    required BuildContext context,

    required String tradeId,
    required num dealId,
    required String tradeMoney,
    required String tradeMetal,
    required String sellAtProfit,
    required String sellingPrice,
  }) async {
    try {
      setButtonState(true);

      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "tradeId": tradeId,
        "dealId": dealId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "sellAtProfit": sellAtProfit,
        "sellingPrice": sellingPrice,
      };

      /// server response
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateSellOrderApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;

          SuccessResponse successResponse = SuccessResponse.fromJson(
            responseData,
          );
          getLocator<Logger>().i("Sending sell body to server: $body");

          if (!context.mounted) return false;

          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );

          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          return false;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Update Sell Order Error: $e");
      return false;
    } finally {
      setButtonState(false);
    }
  }
}
