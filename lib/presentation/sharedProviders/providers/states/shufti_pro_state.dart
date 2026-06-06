import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';

class ShuftiProState {
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final bool isLoading;

  /// Constructor with default values
  ShuftiProState({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.isLoading = false,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  /// Copy method for updating state
  ShuftiProState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    bool? isLoading,
  }) {
    return ShuftiProState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
