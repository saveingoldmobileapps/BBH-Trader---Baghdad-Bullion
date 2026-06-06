import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/SuccessResponse.dart';

class TradeState {
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final bool isButtonState; // For button loading state

  TradeState({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.isButtonState = false,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  TradeState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    bool? isButtonState,
  }) {
    return TradeState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      isButtonState: isButtonState ?? this.isButtonState,
    );
  }
}
