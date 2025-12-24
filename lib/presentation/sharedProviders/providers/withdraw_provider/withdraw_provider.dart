import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/data/models/withdrawal_models/GetAllWithdrawalFundsResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../../../core/common_service.dart';
import '../../../../core/theme/const_toasts.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../../../data/models/ErrorResponse.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/bank_models/BankCardReponse.dart';
import '../../../feature_injection.dart';
import '../states/withdraw_state/widthdraw_states.dart';

part 'withdraw_provider.g.dart';

@riverpod
class Withdraw extends _$Withdraw {
  @override
  WithdrawalState build() {
    init();
    return WithdrawalState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("WithdrawalProvider Initialized");
  }

  /// set loading state
  void setLoadingState(LoadingWithdrawalState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  void setCardLoadingState(LoadingWithdrawalState loadingState) {
    state = state.copyWith(cardLoadingState: loadingState);
  }

  /// create withdraw request
  Future<void> createWithdrawRequest({
    required Map<String, dynamic> json,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.withdrawApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: json,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          if (context.mounted) {
            SoundPlayer().playSound(AppSounds.depositSounmd);
            // Navigator.of(context)
            //   ..pop()
            //   ..pop();
            // final InAppReview inAppReview = InAppReview.instance;

            // if (await inAppReview.isAvailable()) {
            //   inAppReview.requestReview();
            // }
            Navigator.of(context)..pop()..pop()..pop();

            Future.delayed(Duration(milliseconds: 300), () async {
              final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
            }
          });

          }

        // if (!context.mounted) return;
        // SoundPlayer().playSound(AppSounds.depositSounmd);
        // break;

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

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          if (errorResponse.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(context: context);
            return;
          }

          if (!context.mounted) return;
          Navigator.of(context)
            ..pop()
            ..pop();

          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e) {
      getLocator<Logger>().e("Withdraw Request Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchAllCards({
    required BuildContext context,
  }) async {
    try {
      setCardLoadingState(LoadingWithdrawalState.loading);
      state = state.copyWith(getAllCardsResponse: BankCardReponse());
      final refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllCardUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          final getAllCardsResponse =
              BankCardReponse.fromJson(response.resultData);

          state = state.copyWith(getAllCardsResponse: getAllCardsResponse);

          getLocator<Logger>().i(
            "Cards fetched: ${getAllCardsResponse.payload?.cardsList ?? 0}",
          );

          setCardLoadingState(LoadingWithdrawalState.data);
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          state = state.copyWith(errorResponse: error);
          // Toasts.getErrorToast(
          //   gravity: ToastGravity.TOP,
          //   text: error.payload?.message ?? "Failed to fetch cards",
          // );
          setCardLoadingState(LoadingWithdrawalState.error);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${response.resultData}");
          setCardLoadingState(LoadingWithdrawalState.error);
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Fetch cards error: $e", stackTrace: stackTrace);
      Toasts.getErrorToast(
        gravity: ToastGravity.TOP,
        text: "Unexpected error occurred.",
      );
      setCardLoadingState(LoadingWithdrawalState.error);
    }
  }

  /// Create a new bank card
  Future<void> createCard({
    required BuildContext context,
    required Map<String, dynamic> body,
  }) async {
    try {
      state = state.copyWith(
          cardCreateLoadingState: LoadingWithdrawalState.loading);

      final String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }
      final Map<String, dynamic> filteredBody = {
        "bankName": body["bankName"],
        "beneficiaryName": body["beneficiaryName"],
        "ibanNumber": body["iban"],
      };
      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };
      print("filter body=$filteredBody");
      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.createCardUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: filteredBody,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          Toasts.getSuccessToast(
            text: AppLocalizations.of(context)!.card_created_successfully,//"Card created successfully",
            gravity: ToastGravity.TOP,
          );

          getLocator<Logger>().i("Card Created: ${response.resultData}");
          if (!context.mounted) return;
          fetchAllCards(context: context);

          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: error.payload?.message ?? AppLocalizations.of(context)!.failed_to_create_card,//"Failed to create card",
          );
          getLocator<Logger>()
              .e("Card create error: ${error.payload?.message}");
          break;

        case ServerResponseType.exception:
          getLocator<Logger>()
              .e("Card create exception: ${response.resultData}");
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "Something went wrong. Please try again.",
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Create card error: $e", stackTrace: stackTrace);
      Toasts.getErrorToast(
        gravity: ToastGravity.TOP,
        text: "Unexpected error occurred.",
      );
    } finally {
      state =
          state.copyWith(cardCreateLoadingState: LoadingWithdrawalState.data);
    }
  }

  Future<void> editCard({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> body,
  }) async {
    try {
      state = state.copyWith(
          cardCreateLoadingState: LoadingWithdrawalState.loading);

      final String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }
      final Map<String, dynamic> filteredBody = {
        "_id": id,
        "bankName": body["bankName"],
        "beneficiaryName": body["beneficiaryName"],
        "ibanNumber": body["iban"],
      };
      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };
      print("filter body=$filteredBody");
      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.editCardUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: filteredBody,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
        final successResponse = ErrorResponse.fromJson(response.resultData);
          Toasts.getSuccessToast(
            text: successResponse.payload!.message?? AppLocalizations.of(context)!.card_updated_successfully,//"Card created successfully",
            gravity: ToastGravity.TOP,
          );

          getLocator<Logger>().i("Card Created: ${response.resultData}");
          if (!context.mounted) return;
          fetchAllCards(context: context);
          Navigator.pop(context);
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: error.payload?.message ?? AppLocalizations.of(context)!.failed_to_update_card,//"Failed to create card",
          );
          getLocator<Logger>()
              .e("Card create error: ${error.payload?.message}");
          break;

        case ServerResponseType.exception:
          getLocator<Logger>()
              .e("Card create exception: ${response.resultData}");
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "Something went wrong. Please try again.",
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Create card error: $e", stackTrace: stackTrace);
      Toasts.getErrorToast(
        gravity: ToastGravity.TOP,
        text: "Unexpected error occurred.",
      );
    } finally {
      state =
          state.copyWith(cardCreateLoadingState: LoadingWithdrawalState.data);
    }
  }

  /// get withdrawal funds requests
  /// Fetches withdrawal funds requests
  Future<void> fetchWithdrawalFundsRequests({
    required BuildContext context,
  }) async {
    try {
      debugPrint("fetchWithdrawalFundsRequests called");

      setLoadingState(LoadingWithdrawalState.loading);

      // final refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllWithdrawalApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          final withdrawalResponse = GetAllWithdrawalFundsResponse.fromJson(
            response.resultData,
          );

          state = state.copyWith(
            getAllWithdrawalFundsResponse: withdrawalResponse,
          );

          getLocator<Logger>().i(
            "Withdrawals Fetched: ${withdrawalResponse.payload?.toJson()} length: [${withdrawalResponse.payload?.kAllWithdraws?.length}]",
          );

          // Update state with actual data here if needed
          setLoadingState(LoadingWithdrawalState.data);
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          getLocator<Logger>().e("Error: ${error.payload?.message}");
          // Toasts.getErrorToast(
          //   gravity: ToastGravity.TOP,
          //   text: error.payload?.message ?? "Unknown error");
          state = state.copyWith(errorResponse: error);
          setLoadingState(LoadingWithdrawalState.error);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${response.resultData}");
          setLoadingState(LoadingWithdrawalState.error);
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e(
        "Withdraw Request Error: $e",
        stackTrace: stackTrace,
      );
      setLoadingState(LoadingWithdrawalState.error);
    }
  }

  /// Delete a bank card
  Future<void> deleteCard({
    required BuildContext context,
    required String cardId,
  }) async {
    try {
      state = state.copyWith(
          cardDeleteLoadingState: LoadingWithdrawalState.loading);

      final String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      final body = {"_id": cardId};

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.deleteCardUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          Toasts.getSuccessToast(
            text: AppLocalizations.of(context)!.card_deleted_successfully,//"Card deleted successfully",
            gravity: ToastGravity.TOP,
          );

          getLocator<Logger>().i("Card Deleted: ${response.resultData}");
          if (!context.mounted) return;
          fetchAllCards(context: context); // refresh card list
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: error.payload?.message ?? "Failed to delete card",
          );
          getLocator<Logger>()
              .e("Card delete error: ${error.payload?.message}");
          break;

        case ServerResponseType.exception:
          getLocator<Logger>()
              .e("Card delete exception: ${response.resultData}");
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "Something went wrong. Please try again.",
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Delete card error: $e", stackTrace: stackTrace);
      Toasts.getErrorToast(
        gravity: ToastGravity.TOP,
        text: "Unexpected error occurred.",
      );
    } finally {
      state =
          state.copyWith(cardDeleteLoadingState: LoadingWithdrawalState.data);
    }
  }

  /// Cancel a withdrawal request
  Future<void> cancelWithdrawRequest({
    required String withdrawalId,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Missing refresh token");
      }

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      final body = {
        "_id": withdrawalId,
      };

      final response = await DioNetworkManager().callAPI(
        url: ApiEndpoints.cancelWithdrawApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      switch (response.responseType) {
        case ServerResponseType.success:
          final success = SuccessResponse.fromJson(response.resultData);
          Toasts.getSuccessToast(
              text: success.payload?.message ??
                  AppLocalizations.of(context)!.card_with_draw_cancelled,//"Withdrawal cancelled successfully",
              gravity: ToastGravity.TOP);

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.depositSounmd);

          if (!context.mounted) return;
          fetchWithdrawalFundsRequests(context: context);

          getLocator<Logger>().i(
            "Withdrawal cancelled: ${success.payload?.message}",
          );
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: error.payload?.message ?? "Failed to cancel withdrawal",
          );
          state = state.copyWith(errorResponse: error);

          if (error.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(context: context);
          }

          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception during cancel request: ${response.resultData}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "Something went wrong. Please try again.",
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e(
        "Cancel Withdraw Request Error: $e",
        stackTrace: stackTrace,
      );
      Toasts.getErrorToast(
        gravity: ToastGravity.TOP,
        text: "Unexpected error occurred.",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
