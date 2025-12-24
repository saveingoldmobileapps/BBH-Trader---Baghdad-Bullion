import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/history_model/GetMetalStatementsResponse.dart';

import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/history_model/NewMoneyApiResponseModel.dart';

class HistoryState {
  final List<MetalHistoryList> metalStatements;
  final List<MoneyHistoryList> moneyStatements;
  final GetMetalStatementsResponse getMetalStatementsResponse;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final bool isLoading;
  final bool isDownloading;
  final LoadingState loadingState;
  final LoadingMetalHistoryState loadingMetalHistoryState;
  final LoadingMoneyHistoryState loadingMoneyHistoryState;

  HistoryState({
    this.metalStatements = const [],
    this.moneyStatements = const [],
    GetMetalStatementsResponse? getMetalStatementsResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.isLoading = false,
    this.isDownloading = false,
    this.loadingState = LoadingState.loading,
    this.loadingMetalHistoryState = LoadingMetalHistoryState.loading,
    this.loadingMoneyHistoryState = LoadingMoneyHistoryState.loading,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse(),
       getMetalStatementsResponse =
           getMetalStatementsResponse ?? GetMetalStatementsResponse();

  HistoryState copyWith({
    List<MetalHistoryList>? metalStatements,
    List<MoneyHistoryList>? moneyStatements,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetMetalStatementsResponse? getMetalStatementsResponse,
    bool? isLoading,
    LoadingState? loadingState,
    LoadingMetalHistoryState? loadingMetalHistoryState,
    LoadingMoneyHistoryState? loadingMoneyHistoryState,
    bool? isDownloading,
  }) {
    return HistoryState(
      metalStatements: metalStatements ?? this.metalStatements,
      moneyStatements: moneyStatements ?? this.moneyStatements,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      getMetalStatementsResponse:
          getMetalStatementsResponse ?? this.getMetalStatementsResponse,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      loadingState: loadingState ?? this.loadingState,
      loadingMetalHistoryState:
          loadingMetalHistoryState ?? this.loadingMetalHistoryState,
      loadingMoneyHistoryState:
          loadingMoneyHistoryState ?? this.loadingMoneyHistoryState,
    );
  }
}
