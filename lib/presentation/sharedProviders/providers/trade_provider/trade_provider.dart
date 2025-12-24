import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/animated_overlay_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/sound_services.dart';
import '../../../../core/sounds/app_sounds.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../feature_injection.dart';
import '../../../widgets/pop_up_widget.dart';
import '../gram_provider/gram_provider.dart';
import '../states/trade_state/trade_state.dart';

part 'trade_provider.g.dart';

@riverpod
class Trade extends _$Trade {
  @override
  TradeState build() {
    init();
    return TradeState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("TradeProvider Initialized");
  }

  /// Create a trade
  Future<void> createTrade({
    required Map<String, dynamic> tradeData,
    required BuildContext context,
  }) async {
    try {
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      // Set button loading state
      state = state.copyWith(isButtonState: true);
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.createTradeApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: tradeData,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Trade created successfully!");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          await genericPopUpWidget(
            context: context,
            heading: successResponse.status != null
                ? "${successResponse.status![0].toUpperCase()}${successResponse.status!.substring(1)}"
                : "Success",
            subtitle: successResponse.payload!.message ?? "",
            yesButtonTitle: AppLocalizations.of(context)!.close,//"Close",
            isLoadingState: false,
            onYesPress: () async {
              Navigator.pop(context);
            },
            onNoPress: () async {},
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");

          if (!context.mounted) return;
          await genericPopUpWidget(
            context: context,
            heading: errorResponse.status != null
                ? "${errorResponse.status![0].toUpperCase()}${errorResponse.status!.substring(1)}"
                : "Success",
            subtitle: errorResponse.message ?? "",
            yesButtonTitle: AppLocalizations.of(context)!.close,//"Close",
            isLoadingState: false,
            onYesPress: () async {
              Navigator.pop(context);
            },
            onNoPress: () async {},
          );
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
      getLocator<Logger>().e("Create Trade Error: $e");
    } finally {
      // Reset button loading state
      state = state.copyWith(isButtonState: false);
    }
  }

  /// buy gold
  Future<void> userCanBuyGold({
    required num tradeMoney,
    required num tradeMetal,
    required bool buyAtPriceStatus,
    required dynamic buyAtPrice,
    required num buyingPrice,
    required BuildContext context,
  }) async {
    try {
      /// Get user id from storage
      final userId = await LocalDatabase.instance.getUserId();
      // final refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// Set button loading state
      state = state.copyWith(isButtonState: true);
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      /// Get refresh token from storage
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isButtonState: false);
        return;
      }

      final body = {
        "userId": userId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "buyAtPriceStatus": buyAtPriceStatus, //optional
        "buyAtPrice": buyAtPrice, //optional
        "buyingPrice": buyAtPriceStatus
            ? buyAtPrice
            : buyingPrice, // newly added
      };

      getLocator<Logger>().i("buyGoldBody: $body");

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.buyGoldApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Trade created successfully!");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.buySellSound);
          await genericPopUpWidget(
            context: context,
            heading: buyAtPriceStatus
                ? "${AppLocalizations.of(context)!.invest_order_placed}"
                : "${AppLocalizations.of(context)!.invest_filled_oreder}", //"Buy Order Placed" : "Buy Order Filled",
            subtitle:
                successResponse.payload!.message ??
                AppLocalizations.of(
                  context,
                )!.invest_successfully_submitted, //"Your buy order has been successfully submitted for processing.",
            yesButtonTitle: AppLocalizations.of(context)!.close, //"Close",
            isLoadingState: false,
            onYesPress: () async {
              Navigator.pop(context);
            },
            onNoPress: () async {},
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
          Toasts.getErrorToast(
            duration: Duration(seconds: 10),
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
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
      getLocator<Logger>().e("Create Trade Error: $e");
    } finally {
      // Reset button loading state
      state = state.copyWith(isButtonState: false);
    }
  }

  /// sell gold
  Future<void> userCanSellGold({
    required num tradeMoney,
    required num tradeMetal,
    required bool sellAtProfitStatus,
    required dynamic sellAtProfit,
    required num sellingPrice,
    required BuildContext context,
  }) async {
    try {
      /// Get user id from storage
      final userId = await LocalDatabase.instance.getUserId();
      // final refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      // Set button loading state
      state = state.copyWith(isButtonState: true);
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      // Get refresh token from storage
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isButtonState: false);
        return;
      }

      final body = {
        "userId": userId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "sellAtProfitStatus": sellAtProfitStatus,
        "sellAtProfit": sellAtProfit,
        "sellingPrice": sellAtProfitStatus ? sellAtProfit : sellingPrice,
      };

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.sellGoldApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Trade created successfully!");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.buySellSound);
          await genericPopUpWidget(
            context: context,
            heading: sellAtProfitStatus
                ? "Sell Order Placed"
                : "Sell Order Filled",
            subtitle:
                successResponse.payload!.message ??
                "Your sell order has been successfully submitted for processing.",
            yesButtonTitle: "Close",
            isLoadingState: false,
            onYesPress: () async {
              Navigator.pop(context);
            },
            onNoPress: () async {},
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
          Toasts.getErrorToast(
            duration: Duration(seconds: 10),
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
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
      getLocator<Logger>().e("Create Trade Error: $e");
    } finally {
      // Reset button loading state
      state = state.copyWith(isButtonState: false);
    }
  }

  /// update trade deal position
  Future<void> updateTradeDealPosition({
    required num dealId,
    required num tradeMoney,
    required num tradeMetal,
    required bool sellAtProfitStatus,
    required num sellAtProfit,
    required num sellingPrice,
    required BuildContext context,
  }) async {
    try {
      /// Get user id from storage
      final userId = await LocalDatabase.instance.getUserId();
      // final refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      // Set button loading state
      state = state.copyWith(isButtonState: true);
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      /// Get refresh token from storage
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isButtonState: false);
        return;
      }

      final body = {
        "userId": userId,
        "dealId": dealId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "sellAtProfitStatus": sellAtProfitStatus,
        "sellAtProfit": sellAtProfit,
        "sellingPrice": sellAtProfitStatus ? sellAtProfit : sellingPrice,
      };

      getLocator<Logger>().i("updateTradeDealPositionBody: $body");

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.closeTradeDealApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          state = state.copyWith(
            isButtonState: false,
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "updateTradeDealPositionSuccess: ${successResponse.payload?.message}",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
          getLocator<Logger>().e(
            "updateTradeDealPositionError: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Create Trade Error: $e");
    } finally {
      // Reset button loading state
      state = state.copyWith(isButtonState: false);
    }
  }

  /// close trade deal
  Future<void> closeTradeDeal({
    required num dealId,
    required num tradeMoney,
    required num tradeMetal,
    required num sellingPrice,
    required BuildContext context,
  }) async {
    try {
      /// Set button loading state
      state = state.copyWith(isButtonState: true);

      /// Get user id from storage
      final userId = await LocalDatabase.instance.getUserId();
      // final refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      // Get refresh token from storage
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isButtonState: false);
        return;
      }

      final body = {
        "userId": userId,
        "dealId": dealId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "sellAtProfitStatus": false,
        "sellAtProfit": null,
        "sellingPrice": sellingPrice,
      };

      getLocator<Logger>().i("closeTradeDealBody: $body");

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.closeTradeDealApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          /// reload fetch gram balance list
          await ref.read(gramProvider.notifier).getUserGramBalance();

          getLocator<Logger>().i(
            "closeTradeDeal: ${successResponse.payload?.message}",
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message}",
          );
          ref.read(gramProvider.notifier).getUserGramBalance();
          state = state.copyWith(isButtonState: false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isButtonState: false,
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
          getLocator<Logger>().e(
            "closeTradeDealError: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(isButtonState: false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Create Trade Error: $e");
    } finally {
      // Reset button loading state
      state = state.copyWith(isButtonState: false);
    }
  }
}
