import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/models/notificationModels/GetAllNotificationsResponse.dart';
import '../../../feature_injection.dart';
import '../states/notification_state/notification_states.dart';

part 'notificationProvider.g.dart';

@riverpod
class Notification extends _$Notification {
  @override
  NotificationState build() {
    init();
    return NotificationState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("NotificationProvider Initialized");
  }

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    try {
      state = state.copyWith(isLoading: true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getNotificationsApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          NotificationApiResponseModel allNotificationApiResponse =
              NotificationApiResponseModel.fromJson(
                serverResponse.resultData,
              );
          List<NotificationList> notifications =
              allNotificationApiResponse.payload ?? [];
          state = state.copyWith(notifications: notifications);
          getLocator<Logger>().i(
            "Fetched ${notifications.length} notifications successfully.",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
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
}
