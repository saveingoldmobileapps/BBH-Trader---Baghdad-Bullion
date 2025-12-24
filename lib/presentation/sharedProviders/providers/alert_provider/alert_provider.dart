import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/enums/loading_state.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/alert_model/AlertModelResponse.dart';
import '../../../feature_injection.dart';
import '../states/alert_states/alert_state.dart';

part 'alert_provider.g.dart';

@riverpod
class AlertAll extends _$AlertAll {
  @override
  AlertState build() {
    init();
    return AlertState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("AlertProvider Initialized");
  }

  /// Get all alerts
  Future<void> fetchAlerts() async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);

      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllAlert,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          AlertModelResponse alertData = AlertModelResponse.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(
            alerts: alertData.payload,
            loadingState: LoadingState.data,
          );

          getLocator<Logger>()
              .i("Fetched ${alertData.payload!.length} alerts successfully.");
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse =
              ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(
            errorResponse: errorResponse,
            loadingState: LoadingState.error,
          );
          break;

        case ServerResponseType.exception:
          state = state.copyWith(
            loadingState: LoadingState.error,
          );
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      state = state.copyWith(loadingState: LoadingState.error);
    }
  }

  /// Create new alert
  Future<void> createAlert({
    required String script,
    required String alertType,
    required String condition,
    required double price,
  }) async {
    try {
      state = state.copyWith(isCreatingAlert: true);

      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      final body = {
        "script": script,
        "alertType": alertType,
        "condition": condition,
        "price": price,
      };
      print(" Sending Create Alert Payload: ${body.toString()}");
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.createAlert,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse success =
              SuccessResponse.fromJson(serverResponse.resultData);
              SoundPlayer().playSound(AppSounds.buySellSound);
          state = state.copyWith(successResponse: success);
          await fetchAlerts(); // refresh list
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse =
              ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(errorResponse: errorResponse);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      state = state.copyWith(isCreatingAlert: false);
    }
  }

  /// update  alert
  Future<void> UpdateAlert({
    required String script,
    required String id,
    required String alertType,
    required String condition,
    required double price,
  }) async {
    try {
      state = state.copyWith(isCreatingAlert: true);

      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      final body = {
        "script": script,
        "alertId": id,
        "alertType": alertType,
        "condition": condition,
        "price": price,
      };
      print(" Sending Create Alert Payload: ${body.toString()}");
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateAlert,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse success =
              SuccessResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(successResponse: success);
          await fetchAlerts(); // refresh list
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse =
              ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(errorResponse: errorResponse);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      state = state.copyWith(isCreatingAlert: false);
    }
  }

  /// Delete alert
  Future<void> deleteAlert({required String alertId}) async {
    try {
      state = state.copyWith(isDeletingAlert: true);

      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      final body = {
        "alertId": alertId,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.deleteAlert,
        httpMethod: HttpMethod.delete,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse success =
              SuccessResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(successResponse: success);
          await fetchAlerts(); // refresh list
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse =
              ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(errorResponse: errorResponse);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      state = state.copyWith(isDeletingAlert: false);
    }
  }
}
