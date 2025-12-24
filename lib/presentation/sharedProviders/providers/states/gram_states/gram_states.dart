import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/gram_balance/GramApiResponseModel.dart';

import '../../../../../data/models/ErrorResponse.dart';

class GramState {
  final GramApiResponseModel gramApiResponseModel;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;

  /// variable and enum
  final LoadingState loadingState;
  final bool isButtonState;
  final bool isImageState;

  GramState({
    GramApiResponseModel? gramApiResponseModel,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,

    /// variables and enums
    this.loadingState = LoadingState.loading,
    this.isButtonState = false,
    this.isImageState = false,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse(),
       gramApiResponseModel = gramApiResponseModel ?? GramApiResponseModel();

  GramState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GramApiResponseModel? gramApiResponseModel,

    /// variables and enums
    LoadingState? loadingState,
    bool? isButtonState,
    bool? isImageState,
  }) {
    return GramState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      gramApiResponseModel: gramApiResponseModel ?? this.gramApiResponseModel,

      ///variables and enums
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isImageState: isImageState ?? this.isImageState,
    );
  }
}
