import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/data/models/history_model/GetMetalStatementsResponse.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/local_database.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../../../data/models/ErrorResponse.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/history_model/NewMoneyApiResponseModel.dart';
import '../../../feature_injection.dart';
import '../states/history_states/history_states.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  @override
  HistoryState build() {
    init();
    return HistoryState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("HistoryProvider Initialized");
  }

  /// fetch user money statements
  Future<void> fetchUserMoneyStatements({
    String? dateFrom,
    String? dateTo,
    bool reset = true,
  }) async {
    try {
      if (state.isLoading) return; // Prevent multiple simultaneous fetches

      state = state.copyWith(
        isLoading: true,
        loadingState: LoadingState.loading,
      );

      /// Reset statements list if reset is true
      if (reset) {
        state = state.copyWith(
          metalStatements: [],
          moneyStatements: [],
        );
      }

      /// Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      /// Get user id
      String? userid = await LocalDatabase.instance.getUserId();
      String? accountID = await LocalDatabase.instance.getUserAccountId();

      /// Get user statements
      final requestBody = {
        "userId": userid,
        "accountId": int.tryParse(accountID ?? ''),
      };

      /// Add date range if provided
      if (dateFrom != null && dateTo != null) {
        requestBody["dateFrom"] = dateFrom;
        requestBody["dateTo"] = dateTo;
      }

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getUserMoneyStatementsApiUrl,
        body: requestBody,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;

          final List<MoneyHistoryList> moneyStatement =
              (responseData['payload'] as List)
                  .map((item) => MoneyHistoryList.fromJson(item))
                  .toList();

          state = state.copyWith(
            moneyStatements: moneyStatement,
            isLoading: false,
            loadingState: LoadingState.data,
          );

          getLocator<Logger>().i(
            "moneyStatementResponse: ${moneyStatement.length}",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isLoading: false,
            loadingState: LoadingState.error,
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            isLoading: false,
            loadingState: LoadingState.error,
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e(
        "Fetch User Statements Error: $e",
      );
      state = state.copyWith(
        isLoading: false,
        loadingState: LoadingState.error,
      );
    }
  }

  /// fetch user metal statements
  Future<void> fetchUserMetalStatements({
    String? dateFrom,
    String? dateTo,
    bool reset = true,
  }) async {
    try {
      state = state.copyWith(
        loadingState: LoadingState.loading,
      );

      /// Reset statements list if reset is true
      if (reset) {
        state = state.copyWith(
          metalStatements: [],
          moneyStatements: [],
        );
      }

      /// Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isLoading: false);
        return;
      }

      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };
      String? userid = await LocalDatabase.instance.getUserId();
      String? accountID = await LocalDatabase.instance.getUserAccountId();

      /// request body
      final requestBody = {
        "userId": userid,
        "accountId": int.tryParse(accountID ?? ''),
      };

      if (dateFrom != null && dateTo != null) {
        requestBody["dateFrom"] = dateFrom;
        requestBody["dateTo"] = dateTo;
      }

      getLocator<Logger>().d("RequestBody: $requestBody");

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getUserMetalStatementsApiUrl,
        body: requestBody,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;
          GetMetalStatementsResponse getMetalStatementsResponse =
              GetMetalStatementsResponse.fromJson(
                responseData,
              );
          state = state.copyWith(
            getMetalStatementsResponse: getMetalStatementsResponse,
            metalStatements: getMetalStatementsResponse.payload!,
            loadingState: LoadingState.data,
          );

          getLocator<Logger>().d(
            "getMetalStatementsResponse:${getMetalStatementsResponse.toJson()}",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            loadingState: LoadingState.error,
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            loadingState: LoadingState.error,
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch User Statements Error: $e");
      state = state.copyWith(
        loadingState: LoadingState.error,
      );
    }
  }

  /// Export User Statements
  Future<void> exportUserStatements({
    required String statementType,
    required List<dynamic> statementData,
  }) async {
    try {
      state = state.copyWith(isDownloading: true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      statementData.sort((a, b) {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateA.compareTo(dateB);
      });

      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        return;
      }
      final requestBody = {
        "statementType": statementType,
        "statementData": statementData,
      };
      final headers = {
        "authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.downloadStatementApiUrl,
        body: requestBody,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          SoundPlayer().playSound(AppSounds.depositSounmd);

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          state = state.copyWith(isDownloading: false);
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message}",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          getLocator<Logger>().e(
            "Export error: ${errorResponse.message}",
          );
          state = state.copyWith(isDownloading: false);
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Export exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(isDownloading: false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Export User Statements Error: $e");
      state = state.copyWith(isDownloading: false);
    }
  }
}
