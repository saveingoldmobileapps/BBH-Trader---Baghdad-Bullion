import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/bank_models/GetAllLoanResponse.dart';

class LoanState {
  final List<UserAllLoanRequests> loans;
  final LoadingLoanState loadingState;
  final LoadingState payingLoanState;
  final bool isButtonLoading;
  final ErrorResponse? errorResponse;
  final SuccessResponse? successResponse;

  LoanState({
    this.loans = const [],
    this.loadingState = LoadingLoanState.initial,
    this.payingLoanState = LoadingState.data,
    this.isButtonLoading = false,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  LoanState copyWith({
    List<UserAllLoanRequests>? loans,
    LoadingLoanState? loadingState,
    LoadingState? payingLoanState,
    bool? isButtonLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) {
    return LoanState(
      loans: loans ?? this.loans,
      loadingState: loadingState ?? this.loadingState,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      payingLoanState: payingLoanState ?? this.payingLoanState,
    );
  }
}
