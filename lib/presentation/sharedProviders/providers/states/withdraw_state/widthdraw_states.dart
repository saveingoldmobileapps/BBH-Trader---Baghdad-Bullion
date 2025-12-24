import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/withdrawal_models/GetAllWithdrawalFundsResponse.dart';

import '../../../../../data/models/bank_models/BankCardReponse.dart';

class WithdrawalState {
  final bool isLoading;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final GetAllWithdrawalFundsResponse getAllWithdrawalFundsResponse;
  final BankCardReponse getAllCardsResponse;

  /// Loading states
  final LoadingWithdrawalState loadingState;
  final LoadingWithdrawalState cardLoadingState;
  final LoadingWithdrawalState cardDeleteLoadingState;
  final LoadingWithdrawalState cardCreateLoadingState;

  WithdrawalState({
    this.isLoading = false,
    SuccessResponse? successResponse,
    ErrorResponse? errorResponse,
    GetAllWithdrawalFundsResponse? getAllWithdrawalFundsResponse,
    BankCardReponse? getAllCardsResponse,
    this.loadingState = LoadingWithdrawalState.loading,
    this.cardLoadingState = LoadingWithdrawalState.loading,
    this.cardDeleteLoadingState = LoadingWithdrawalState.loading,
    this.cardCreateLoadingState = LoadingWithdrawalState.data,
  })  : errorResponse = errorResponse ?? ErrorResponse(),
        successResponse = successResponse ?? SuccessResponse(),
        getAllWithdrawalFundsResponse =
            getAllWithdrawalFundsResponse ?? GetAllWithdrawalFundsResponse(),
        getAllCardsResponse = getAllCardsResponse ?? BankCardReponse();

  WithdrawalState copyWith({
    bool? isLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetAllWithdrawalFundsResponse? getAllWithdrawalFundsResponse,
    BankCardReponse? getAllCardsResponse,
    LoadingWithdrawalState? loadingState,
    LoadingWithdrawalState? cardLoadingState,
    LoadingWithdrawalState? cardDeleteLoadingState,
    LoadingWithdrawalState? cardCreateLoadingState, // ✅ Added to copyWith
  }) {
    return WithdrawalState(
      isLoading: isLoading ?? this.isLoading,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      getAllWithdrawalFundsResponse:
          getAllWithdrawalFundsResponse ?? this.getAllWithdrawalFundsResponse,
      getAllCardsResponse: getAllCardsResponse ?? this.getAllCardsResponse,
      loadingState: loadingState ?? this.loadingState,
      cardLoadingState: cardLoadingState ?? this.cardLoadingState,
      cardDeleteLoadingState:
          cardDeleteLoadingState ?? this.cardDeleteLoadingState,
      cardCreateLoadingState:
          cardCreateLoadingState ?? this.cardCreateLoadingState, // ✅ Added
    );
  }
}

// class WithdrawalState {
//   final bool isLoading;
//   final ErrorResponse errorResponse;
//   final SuccessResponse successResponse;
//   final GetAllWithdrawalFundsResponse getAllWithdrawalFundsResponse;

//   /// variable and enum
//   final LoadingWithdrawalState loadingState;

//   WithdrawalState({
//     this.isLoading = false,
//     SuccessResponse? successResponse,
//     ErrorResponse? errorResponse,
//     GetAllWithdrawalFundsResponse? getAllWithdrawalFundsResponse,
//     this.loadingState = LoadingWithdrawalState.loading,
//   }) : errorResponse = errorResponse ?? ErrorResponse(),
//        successResponse = successResponse ?? SuccessResponse(),
//        getAllWithdrawalFundsResponse =
//            getAllWithdrawalFundsResponse ?? GetAllWithdrawalFundsResponse();

//   WithdrawalState copyWith({
//     bool? isLoading,
//     ErrorResponse? errorResponse,
//     SuccessResponse? successResponse,
//     GetAllWithdrawalFundsResponse? getAllWithdrawalFundsResponse,

//     /// variables and enums
//     LoadingWithdrawalState? loadingState,
//   }) {
//     return WithdrawalState(
//       isLoading: isLoading ?? this.isLoading,
//       errorResponse: errorResponse ?? this.errorResponse,
//       successResponse: successResponse ?? this.successResponse,
//       getAllWithdrawalFundsResponse:
//           getAllWithdrawalFundsResponse ?? this.getAllWithdrawalFundsResponse,
//       loadingState: loadingState ?? this.loadingState,
//     );
//   }
// }
