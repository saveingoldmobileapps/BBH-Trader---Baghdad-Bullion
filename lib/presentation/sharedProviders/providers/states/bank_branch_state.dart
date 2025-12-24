import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/bank_models/BankBranchResponse.dart';


class BankBranchState {
  final BankBranchesApiResponseModel getAllBranchesResponse;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final LoadingState loadingState;
  final bool isLoading;
  final bool isButtonState;
  String? selectedBranch;
  String? selectedBranchId;

  /// Constructor with default values
  BankBranchState({
    BankBranchesApiResponseModel? getAllBranchesResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.isButtonState = false,
    this.selectedBranch,
    this.selectedBranchId,
    this.loadingState = LoadingState.loading,
    this.isLoading = false,
  }) : getAllBranchesResponse =
           getAllBranchesResponse ?? BankBranchesApiResponseModel(),
       errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  /// Copy method for updating state
  BankBranchState copyWith({
    BankBranchesApiResponseModel? getAllBranchesResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    LoadingState? loadingState,
    bool? isButtonState,
    String? selectedBranch,
    String? selectedBranchId,
    bool? isLoading,
  }) {
    return BankBranchState(
      getAllBranchesResponse:
          getAllBranchesResponse ?? this.getAllBranchesResponse,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isLoading: isLoading ?? this.isLoading,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
    );
  }
}
