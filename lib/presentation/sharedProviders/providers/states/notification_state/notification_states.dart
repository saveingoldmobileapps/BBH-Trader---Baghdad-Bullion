import 'package:saveingold_fzco/data/models/SuccessResponse.dart';

import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/notificationModels/GetAllNotificationsResponse.dart';

class NotificationState {
  final List<NotificationList> notifications;
  final bool isLoading;
  final ErrorResponse? errorResponse;
  final SuccessResponse? successResponse;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  NotificationState copyWith({
    List<NotificationList>? notifications,
    bool? isLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
    );
  }
}
