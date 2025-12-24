import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/enums/loading_state.dart';
import '../../core/theme/const_toasts.dart';
import '../../data/data_sources/local_database/secure_database.dart';
import '../../data/models/bank_models/GetAllLoanResponse.dart';
import 'providers/states/loan_state.dart';

part 'loan_provider.g.dart';

@riverpod
class Loan extends _$Loan {
  @override
  LoanState build() {
    init();
    return LoanState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("InitProvider Initialized");
  }

  void _setButtonLoading(bool isButtonLoading) {
    state = state.copyWith(isButtonLoading: isButtonLoading);
  }

  void _setPayLoanLoadingSate(LoadingState loadingState) {
    state = state.copyWith(payingLoanState: loadingState);
  }

  /// Fetch all loans
  Future<void> fetchAllLoans({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(loadingState: LoadingLoanState.loading);
    }

    try {
      state = state.copyWith(loans: []);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "authorization": "Bearer $refreshToken",
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllLoanApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          final responseData = response.resultData;
          final loanResponse = GetAllLoanResponse.fromJson(responseData);
          final loans = loanResponse.payload?.allLoanRequests ?? [];
          state = state.copyWith(
            loans: loans,
            loadingState: loans.isEmpty
                ? LoadingLoanState.empty
                : LoadingLoanState.data,
            errorResponse: null,
          );
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          state = state.copyWith(
            loadingState: LoadingLoanState.error,
            errorResponse: error,
          );

          break;

        case ServerResponseType.exception:
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Loans Error: $e");
      state = state.copyWith(
        loadingState: LoadingLoanState.error,
      );
    }
  }

  /// Delete loan
  Future<void> deleteLoan({
    required String loanId,
  }) async {
    _setButtonLoading(true);

    try {
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        _setButtonLoading(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "loanRequestId": loanId,
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.deleteLoanApiUrl,
        httpMethod: HttpMethod.delete,
        headers: headers,
        body: body,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          state = state.copyWith(loans: []);
          await fetchAllLoans(showLoading: false);
          _setButtonLoading(false);
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          getLocator<Logger>().e("Delete Loan Error: $error");
          _setButtonLoading(false);
          break;

        case ServerResponseType.exception:
          _setButtonLoading(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Delete Loan Error: $e");
      _setButtonLoading(false);
    }
  }

  /// pay loan
  Future<void> payLoan({
    required String loanId,
    required String userId,
    required num returningAmount,
    required num metalReleased,
  }) async {
    _setPayLoanLoadingSate(LoadingState.loading);

    try {
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        _setButtonLoading(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "loanId": loanId,
        "userId": userId,
        "returningAmount": returningAmount,
        "metalReleased": metalReleased,
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.payLoanBack,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
        debugPrint(" pay Request Advance $body");

        
          await fetchAllLoans(showLoading: false);
          _setPayLoanLoadingSate(LoadingState.data);
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "Your advance successfully paid",
          );
          debugPrint("PayResponse $body");
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          getLocator<Logger>().e("Pay Loan Error: $error");
          Toasts.getErrorToast(
            text: "${error.payload?.message.toString()}",
          );
          _setPayLoanLoadingSate(LoadingState.error);
          break;

        case ServerResponseType.exception:
          _setPayLoanLoadingSate(LoadingState.error);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Delete Loan Error: $e");
      Toasts.getErrorToast(
        text: "$e",
      );
      _setPayLoanLoadingSate(LoadingState.error);
    }
  }

  /// Update loan
  Future<void> updateLoan({
    required Map<String, dynamic> loanData,
  }) async {
    _setButtonLoading(true);

    try {
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        _setButtonLoading(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateLoanApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: loanData,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          // Refresh the loan list after successful update
          
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "Advance request updated successfully!",
          );
          await fetchAllLoans(showLoading: false);
          _setButtonLoading(false);
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          state = state.copyWith(errorResponse: error);
          getLocator<Logger>().e("Update Loan Error: $error");
          _setButtonLoading(false);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: error.payload?.message ?? "",
          );
          break;

        case ServerResponseType.exception:
          _setButtonLoading(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Update Loan Error: $e");
      _setButtonLoading(false);
    }
  }
}
