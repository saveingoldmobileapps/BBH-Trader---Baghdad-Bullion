import '../../../../../core/enums/loading_state.dart';
import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/SuccessResponse.dart';
import '../../../../../data/models/alert_model/AlertModelResponse.dart';

class AlertState {
  final List<AlertListData> alerts;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final LoadingState loadingState;
  final bool isCreatingAlert;
  final bool isDeletingAlert;

  AlertState({
    this.alerts = const [],
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.loadingState = LoadingState.loading,
    this.isCreatingAlert = false,
    this.isDeletingAlert = false,
  })  : errorResponse = errorResponse ?? ErrorResponse(),
        successResponse = successResponse ?? SuccessResponse();

  AlertState copyWith({
    List<AlertListData>? alerts,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    LoadingState? loadingState,
    bool? isCreatingAlert,
    bool? isDeletingAlert,
  }) {
    return AlertState(
      alerts: alerts ?? this.alerts,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      loadingState: loadingState ?? this.loadingState,
      isCreatingAlert: isCreatingAlert ?? this.isCreatingAlert,
      isDeletingAlert: isDeletingAlert ?? this.isDeletingAlert,
    );
  }
}
