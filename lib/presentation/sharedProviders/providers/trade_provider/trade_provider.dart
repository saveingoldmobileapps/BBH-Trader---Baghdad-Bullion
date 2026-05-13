import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/sound_services.dart';
import '../../../../core/sounds/app_sounds.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../feature_injection.dart';
import '../../../screens/trade_screens/order_placed.dart';
import '../../../widgets/pop_up_widget.dart';
import '../gram_provider/gram_provider.dart';
import '../sseGoldPriceProvider/sse_gold_price_provider.dart';
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
                : AppLocalizations.of(context)!.success,//"Success",
            subtitle: successResponse.payload!.message ?? "",
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

          if (!context.mounted) return;
          await genericPopUpWidget(
            context: context,
            heading: errorResponse.status != null
                ? "${errorResponse.status![0].toUpperCase()}${errorResponse.status!.substring(1)}"
                : AppLocalizations.of(context)!.success,//"Success",
            subtitle: errorResponse.message ?? "",
            yesButtonTitle: AppLocalizations.of(context)!.close, //"Close",
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
      final liveBuyingIqd =
          ref.read(goldPriceProvider).value?.oneGramBuyingPriceInIQD ?? 0.0;
      if (liveBuyingIqd <= 0) {
        if (context.mounted) {
          Toasts.getErrorToast(
            text: AppLocalizations.of(context)!.error_loading_price,
            gravity: ToastGravity.TOP,
          );
        }
        return;
      }

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
          final tradeTypeTitle = buyAtPriceStatus
              ? AppLocalizations.of(context)!.limit_order_title
              : AppLocalizations.of(context)!.inves_market_order;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) {
                final amountFormatted =
                    CommonService.formatGramForDisplay(tradeMetal);
                final targetPriceValue = buyAtPriceStatus
                    ? (num.tryParse('$buyAtPrice') ?? 0)
                    : buyingPrice;
                final targetPriceFormatted =
                    CommonService.formatIQDForDisplay(targetPriceValue);
                final totalFormatted =
                    CommonService.formatIQDForDisplay(tradeMoney);
                    final amountValue = double.tryParse(amountFormatted) ?? 0;

                return OrderPlacedScreen(
                  orderId: "xyz",
                  dateTime: DateTime.now().toLocal().toString().split('.')[0],
                  tradeType: tradeTypeTitle,
                  amount:
    "$amountFormatted ${amountValue > 1
        ? AppLocalizations.of(context)!.grams_plural_lowercase
        : AppLocalizations.of(context)!.grams_unit_lowercase}",
                   // "$amountFormatted ${AppLocalizations.of(context)!.grams_unit_lowercase}",
                  targetPrice:
                      "${AppLocalizations.of(context)!.idq} $targetPriceFormatted ${AppLocalizations.of(context)!.trade_gram}",
                  total:
                      "${AppLocalizations.of(context)!.idq} $totalFormatted",
                );
              },
            ),
          );

          // await genericPopUpWidget(
          //   context: context,
          //   heading: buyAtPriceStatus
          //       ? "${AppLocalizations.of(context)!.invest_order_placed}"
          //       : "${AppLocalizations.of(context)!.invest_filled_oreder}", //"Buy Order Placed" : "Buy Order Filled",
          //   subtitle:
          //       successResponse.payload!.message ??
          //       AppLocalizations.of(
          //         context,
          //       )!.invest_successfully_submitted, //"Your buy order has been successfully submitted for processing.",
          //   yesButtonTitle: AppLocalizations.of(context)!.close, //"Close",
          //   isLoadingState: false,
          //   onYesPress: () async {
          //     Navigator.pop(context);
          //   },
          //   onNoPress: () async {},
          // );

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
      final liveSellingIqd =
          ref.read(goldPriceProvider).value?.oneGramSellingPriceInIQD ?? 0.0;
      if (liveSellingIqd <= 0) {
        if (context.mounted) {
          Toasts.getErrorToast(
            text: AppLocalizations.of(context)!.error_loading_price,
            gravity: ToastGravity.TOP,
          );
        }
        return;
      }

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
                ? AppLocalizations.of(context)!.invest_sell_order_placed//"Sell Order Placed"
                : AppLocalizations.of(context)!.invest_sell_order_filled,//"Sell Order Filled",
            subtitle:
                successResponse.payload!.message ??
                AppLocalizations.of(context)!.invest_sell_order_submitted_success,//"Your sell order has been successfully submitted for processing.",
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
  Future<bool> updateTradeDealPosition({
    required num dealId,
    required num tradeMoney,
    required num tradeMetal,
    required bool sellAtProfitStatus,
    required num sellAtProfit,
    required num sellingPrice,
    bool saveProfit = false,
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

      if (!ref.mounted) return false;

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
        return false;
      }

      final body = {
        "userId": userId,
        "dealId": dealId,
        "tradeMoney": tradeMoney,
        "tradeMetal": tradeMetal,
        "sellAtProfitStatus": sellAtProfitStatus,
        "sellAtProfit": sellAtProfit,
        "sellingPrice": sellAtProfitStatus ? sellAtProfit : sellingPrice,
        "saveProfit": saveProfit,
      };

      getLocator<Logger>().i("updateTradeDealPositionBody: $body");

      // API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.closeTradeDealApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: body,
      );

      if (!ref.mounted) return false;

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted || !ref.mounted) return false;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          state = state.copyWith(
            isButtonState: false,
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "updateTradeDealPositionSuccess: ${successResponse.payload?.message}",
          );
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          if (ref.mounted) {
            state = state.copyWith(
              errorResponse: errorResponse,
            );
          }
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
          getLocator<Logger>().e(
            "updateTradeDealPositionError: ${errorResponse.payload?.message}",
          );
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          return false;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Create Trade Error: $e");
      return false;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isButtonState: false);
      }
    }
  }

  /// close trade deal
  Future<bool> closeTradeDeal({
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

      if (!ref.mounted) return false;

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      // Get refresh token from storage
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isButtonState: false);
        return false;
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

      if (!ref.mounted) return false;

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted || !ref.mounted) return false;
          SoundPlayer().playSound(AppSounds.pendinOrderSound);

          /// reload fetch gram balance list
          await ref.read(gramProvider.notifier).getUserGramBalance();

          if (!ref.mounted) return false;

          getLocator<Logger>().i(
            "closeTradeDeal: ${successResponse.payload?.message}",
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message}",
          );
          state = state.copyWith(isButtonState: false);
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          if (ref.mounted) {
            state = state.copyWith(
              errorResponse: errorResponse,
              isButtonState: false,
            );
          }
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message}",
          );
          getLocator<Logger>().e(
            "closeTradeDealError: ${errorResponse.payload?.message}",
          );
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          if (ref.mounted) {
            state = state.copyWith(isButtonState: false);
          }
          return false;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Create Trade Error: $e");
      return false;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isButtonState: false);
      }
    }
  }
}
