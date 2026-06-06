import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/data/models/direct_transfer/BankDetailResponse.dart';
import 'package:baghdad_bullion_house/data/models/direct_transfer/DirectTransferBankResponse.dart';

class DirectTransferState {
  final List<AllBanks> allBanks;
  final bool isLoading;
  final bool isDetailsLoading;
  final ErrorResponse? errorResponse;
  final SuccessResponse? successResponse;
  final BankDetailResponse? bankDetailResponse;

  DirectTransferState({
    this.allBanks = const [],
    this.isLoading = false,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.isDetailsLoading = false,
    BankDetailResponse? bankDetailResponse,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse(),
       bankDetailResponse = bankDetailResponse ?? BankDetailResponse();

  DirectTransferState copyWith({
    List<AllBanks>? allBanks,
    bool? isLoading,
    bool? isDetailsLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    BankDetailResponse? bankDetailResponse,
  }) {
    return DirectTransferState(
      allBanks: allBanks ?? this.allBanks,
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      bankDetailResponse: bankDetailResponse ?? this.bankDetailResponse,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
    );
  }
}
