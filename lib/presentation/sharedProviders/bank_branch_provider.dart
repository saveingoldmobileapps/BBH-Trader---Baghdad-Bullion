import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/data/models/bank_models/BankBranchResponse.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/loan_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/states/bank_branch_state.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/theme/const_toasts.dart';
import '../../data/data_sources/local_database/secure_database.dart';
import '../../data/data_sources/network_sources/api_url.dart';
import '../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../data/models/ErrorResponse.dart';
import '../feature_injection.dart';

part 'bank_branch_provider.g.dart';

@riverpod
class BankBranch extends _$BankBranch {
  @override
  BankBranchState build() {
    init();
    return BankBranchState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("BankProvider Initialized");
  }

  void setLoadingState(LoadingState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  void setSelectedBranch({
    required String branchName,
    required String branchId,
  }) {
    debugPrint("setSelectedBranch: $branchName | brandId: $branchId");
    state = state.copyWith(
      selectedBranch: branchName,
      selectedBranchId: branchId,
    );
  }

  /// unique branch names
  List<String> get uniqueBranchNames {
    return state.getAllBranchesResponse.payload != null
        ? state.getAllBranchesResponse.payload!
              .map((branch) => branch.branchName)
              .where((name) => name != null)
              .map((name) => name!) // Ensures no null values
              // .toSet()
              .toList()
        : [];
  }

  /// List of branch names with their locations
  List<String> get uniqueBranchNamesWithLocation {
    return state.getAllBranchesResponse.payload != null
        ? state.getAllBranchesResponse.payload!
              .map((branch) {
                // Combine branch name and location (adjust field names as per your model)
                return branch.branchName != null &&
                        branch.branchLocation != null
                    ? '${branch.branchName} - ${branch.branchLocation}'
                    : branch.branchName ?? 'Unknown Branch';
              })
              .where((name) => name.isNotEmpty)
              .toList()
        : [];
  }

  /// fetch bank branches
  Future<void> fetchBankBranches() async {
    try {
      getLocator<Logger>().i("Starting fetchBankBranches...");
      setLoadingState(LoadingState.loading);
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      getLocator<Logger>().i("Refresh token: $refreshToken");

      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found");
        setLoadingState(LoadingState.error);
        return;
      }

      final headers = {
        "authorization": "Bearer $refreshToken",
      };
      getLocator<Logger>().i(
        "Calling API: ${ApiEndpoints.getAllBranchesApiUrl}",
      );

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllBranchesApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      getLocator<Logger>().i(
        "API Response: ${serverResponse.responseType}, Data: ${serverResponse.resultData}",
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          BankBranchesApiResponseModel getAllBranchesResponse =
              BankBranchesApiResponseModel.fromJson(serverResponse.resultData);
          getLocator<Logger>().i(
            "Parsed branches: ${getAllBranchesResponse.payload!.length} branches",
          );
          setLoadingState(LoadingState.data);
          state = state.copyWith(
            getAllBranchesResponse: getAllBranchesResponse,
            loadingState: LoadingState.data,
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          getLocator<Logger>().e(
            "Error Response: ${errorResponse.payload?.message}",
          );
          setLoadingState(LoadingState.error);
          state = state.copyWith(
            errorResponse: errorResponse,
            loadingState: LoadingState.error,
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception while loading bank branch: ${serverResponse.resultData}");
          setLoadingState(LoadingState.error);
          state = state.copyWith(
            loadingState: LoadingState.error,
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Fetch Branch Error: $e, StackTrace: $stackTrace");
      await Sentry.captureException(e, stackTrace: stackTrace);
      setLoadingState(LoadingState.error);
      state = state.copyWith(
        loadingState: LoadingState.error,
      );
    }
  }
  // Future<void> fetchBankBranches() async {
  //   try {
  //     setLoadingState(LoadingState.loading);
  //     // String? refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken = await SecureStorageService.instance
  //         .getRefreshToken();
  //     final headers = {
  //       "authorization": "Bearer $refreshToken",
  //     };
  //
  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.getAllBranchesApiUrl,
  //       httpMethod: HttpMethod.get,
  //       headers: headers,
  //     );
  //
  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         BankBranchesApiResponseModel getAllBranchesResponse =
  //             BankBranchesApiResponseModel.fromJson(
  //               serverResponse.resultData,
  //             );
  //
  //         state = state.copyWith(
  //           getAllBranchesResponse: getAllBranchesResponse,
  //         );
  //         getLocator<Logger>().i(
  //           "Fetched ${getAllBranchesResponse.payload?.length} branches successfully.",
  //         );
  //
  //         setLoadingState(LoadingState.data);
  //
  //         break;
  //
  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(
  //           errorResponse: errorResponse,
  //         );
  //         getLocator<Logger>().e(
  //           "Error: ${errorResponse.payload?.message}",
  //         );
  //         setLoadingState(LoadingState.error);
  //
  //         break;
  //
  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "Exception: ${serverResponse.resultData}",
  //         );
  //
  //         setLoadingState(LoadingState.error);
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     getLocator<Logger>().e("Fetch Branch Error: $e");
  //     setLoadingState(LoadingState.error);
  //   }
  // }

  /// Submit Loan Request
  Future<void> submitLoanRequest({
    required String branchId,
    required String comment,
    required String amount,
    required String metalFroze,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      /// refresh token
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// refresh token
      if (refreshToken == null) {
        setButtonState(false);
        getLocator<Logger>().e("No refresh token found!");
        return;
      }

      /// headers
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      /// body
      final body = {
        "branchId": branchId, //selectedBranch.sId,
        "loanAmount": amount,
        "loanComment": comment,
        "metalFroze" : metalFroze
      };

      getLocator<Logger>().d("loanBody: $body");

      /// API Request
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        headers: headers,
        body: body,
        url: ApiEndpoints.submitLoanRequestUrl,
        httpMethod: HttpMethod.post,
      );

      /// Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:

        debugPrint(" Request for advance $body");
          getLocator<Logger>().i(
            "Advance request submitted successfully!",
          );
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "Advance request submitted successfully!",
          );

          if (!context.mounted) return;
          await ref
              .read(loanProvider.notifier)
              .fetchAllLoans(showLoading: true);
          if (!context.mounted) return;
          Navigator.pop(context);
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );
          setButtonState(false);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: errorResponse.payload?.message ?? "",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      setButtonState(false);
      getLocator<Logger>().e("Loan Request Error: $e");
    }
  }
}
