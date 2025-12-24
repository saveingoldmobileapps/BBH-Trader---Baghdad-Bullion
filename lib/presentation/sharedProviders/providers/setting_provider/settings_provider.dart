import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/theme/const_toasts.dart';
import '../../../../core/theme/constant_strings.dart';
import '../../../../data/data_sources/local_database/local_database.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../../../data/models/ErrorResponse.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/time_zone/time_zone_model.dart';
import '../../../feature_injection.dart';
import '../states/setting_state/settings_state.dart';

part 'settingsProvider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    init();
    return SettingsState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("SettingsProvider Initialized");
  }

  //Update the selected time from drop down
  Future<void> updateTimeZone(String timezone, String country) async {
    try {
      state = state.copyWith(isLoading: true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      final data = {
        "timezone": timezone,
      };

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateTimeZoneApiUrl,
        httpMethod: HttpMethod.patch,
        body: data,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          await LocalDatabase.instance.write(
            key: Strings.userTimezone,
            value: timezone,
          );
          await LocalDatabase.instance.write(
            key: Strings.userTimezoneCountry,
            value: country,
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );

          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Notifications Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Fetch all the time zone in setting screen
  Future<void> fetchAllTimezones() async {
    try {
      state = state.copyWith(isTimeZoneLoading: true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isTimeZoneLoading: false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllTimeZoneApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          TimeZoneApiModel response = TimeZoneApiModel.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(
            timeZoneList: response.payload?.kAllTimezones!,
            errorResponse: null,
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          Toasts.getErrorToast(
            text: errorResponse.payload?.message ?? "Something went wrong",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Timezone Fetch Error: $e");
    } finally {
      state = state.copyWith(isTimeZoneLoading: false);
    }
  }
}
