import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/direct_transfer/DirectTransferBankResponse.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/models/direct_transfer/BankDetailResponse.dart';
import '../../../feature_injection.dart';
import '../states/direct_transfer/direct_transfer_states.dart';

part 'direct_transfer_provider.g.dart';

@riverpod
class DirectTransfer extends _$DirectTransfer {
  @override
  DirectTransferState build() {
    return DirectTransferState();
  }
  /// fetch all banks
  Future<void> fetchAllBanks() async {
    try {
      state = state.copyWith(isLoading: true);

      // String? token = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? token = await SecureStorageService.instance.getRefreshToken();
      if (token == null) {
        getLocator<Logger>().e("No token found!");
        state = state.copyWith(isLoading: false);
        return;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllBanksApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final response = DirectTransferbankResponse.fromJson(
            serverResponse.resultData,
          );
          final banks = response.payload?.allBanks ?? [];

          state = state.copyWith(allBanks: banks);
          getLocator<Logger>().i("Fetched ${banks.length} banks successfully.");
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(errorResponse: error);
          getLocator<Logger>().e("Error: ${error.payload?.message}");
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch All Banks Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// get bank detail by id
  Future<void> getBankDetailById(String bankId) async {
    try {
      state = state.copyWith(isDetailsLoading: true);

      // String? token = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? token = await SecureStorageService.instance.getRefreshToken();
      if (token == null) {
        getLocator<Logger>().e("No token found for fetching bank details.");
        state = state.copyWith(isDetailsLoading: false);
        return;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final body = {
        "bankId": bankId,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getBankDetailApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final data = serverResponse.resultData;

          final response = BankDetailResponse.fromJson(data);

          state = state.copyWith(
            bankDetailResponse: response,
          );
          getLocator<Logger>().i("Fetched bank details successfully.");
          break;

        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(serverResponse.resultData);
          state = state.copyWith(errorResponse: error);
          getLocator<Logger>().e(
            "Error in bank detail fetch: ${error.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception in bank detail fetch: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("getBankDetailById error: $e");
    } finally {
      state = state.copyWith(isDetailsLoading: false);
    }
  }
}
