import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/core/theme/const_toasts.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';

import '../../../../core/common_service.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/models/SSEGetPriceResponse.dart';
import '../../../../data/models/gold_price_model/CurrentGoldPriceModel.dart';
import '../../../feature_injection.dart';

part 'sse_gold_price_provider.g.dart';

/// State class for managing gold price data
class SSEGoldPriceState {
  final CurrentGoldPriceModel currentGoldPriceModel;
  final SSEGetGoldPriceResponse getGoldPriceResponse;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final LoadingState loadingState;

  final double currentGoldPrice;
  final bool isLoading;
  final bool isButtonState;

  final double oneOunceDollarSellingPrice;
  final double oneOunceDollarBuyingPrice;

  final double lastLowSellingPrice;
  final double lastHighBuyingPrice;

  final double oneGramBuyingPriceInAED;
  final double oneGramSellingPriceInAED;

  /// Constructor with optional and default values for state
  SSEGoldPriceState({
    CurrentGoldPriceModel? currentGoldPriceModel,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    SSEGetGoldPriceResponse? getGoldPriceResponse,
    this.currentGoldPrice = 0.0,
    this.isButtonState = false,
    this.oneGramBuyingPriceInAED = 0.0,
    this.oneGramSellingPriceInAED = 0.0,
    this.oneOunceDollarSellingPrice = 0.0,
    this.oneOunceDollarBuyingPrice = 0.0,
    this.lastHighBuyingPrice = 0.0,
    this.lastLowSellingPrice = 0.0,
    this.loadingState = LoadingState.loading,
    this.isLoading = false,
  }) : currentGoldPriceModel = currentGoldPriceModel ?? CurrentGoldPriceModel(),
       getGoldPriceResponse = getGoldPriceResponse ?? SSEGetGoldPriceResponse(),
       errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  /// Creates a copy of the current state with the option to override fields
  SSEGoldPriceState copyWith({
    CurrentGoldPriceModel? currentGoldPriceModel,
    SSEGetGoldPriceResponse? getGoldPriceResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    double? currentGoldPrice,
    LoadingState? loadingState,
    bool? isButtonState,
    double? oneGramBuyingPriceInAED,
    double? oneGramSellingPriceInAED,
    double? oneOunceDollarSellingPrice,
    double? oneOunceDollarBuyingPrice,
    bool? isLoading,
  }) {
    return SSEGoldPriceState(
      currentGoldPriceModel:
          currentGoldPriceModel ?? this.currentGoldPriceModel,
      getGoldPriceResponse: getGoldPriceResponse ?? this.getGoldPriceResponse,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      currentGoldPrice: currentGoldPrice ?? this.currentGoldPrice,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      oneGramBuyingPriceInAED:
          oneGramBuyingPriceInAED ?? this.oneGramBuyingPriceInAED,
      oneGramSellingPriceInAED:
          oneGramSellingPriceInAED ?? this.oneGramSellingPriceInAED,
      oneOunceDollarSellingPrice:
          oneOunceDollarSellingPrice ?? this.oneOunceDollarSellingPrice,
      oneOunceDollarBuyingPrice:
          oneOunceDollarBuyingPrice ?? this.oneOunceDollarBuyingPrice,
      lastLowSellingPrice: lastLowSellingPrice ?? lastLowSellingPrice,
      lastHighBuyingPrice: lastHighBuyingPrice ?? lastHighBuyingPrice,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Holds the current SSE subscription
StreamSubscription<SSEModel>? _subscription;

/// Riverpod provider for exposing a stream of SSEGoldPriceState
@riverpod
Stream<SSEGoldPriceState> goldPrice(GoldPriceRef ref) {
  final controller = StreamController<SSEGoldPriceState>();

  // Start listening to the live SSE gold price stream
  _startLiveGoldPriceStream(
    onData: (SSEGoldPriceState sseState) {
      controller.add(sseState); // Add new state to stream
    },
    onError: (error) {
      controller.addError(error); // Emit error if any
    },
  );

  // Dispose handler to clean up when provider is no longer used
  ref.onDispose(() {
    stopSSE(); // Cancel the subscription
    controller.close(); // Close the stream controller
  });

  return controller.stream;
}

/// Initializes and listens to the SSE stream for live gold price updates
Future<void> _startLiveGoldPriceStream({
  required void Function(SSEGoldPriceState) onData,
  required void Function(dynamic error)? onError,
}) async {
  try {
    // Check for actual internet connectivity
    final hasInternet = await InternetConnection().hasInternetAccess;

    if (!hasInternet) {
      // Show the dialog
      Toasts.getErrorToast(text: "No Internet Connection Available");
      return;
    }

    final token = await LocalDatabase.instance.getLoginToken();

    final headers = {
      "Authorization": "Bearer $token",
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
    };

    const aed = 3.674; // Conversion rate from USD to AED
    const ounce = 31.10347; // Grams in a troy ounce

    /// cache value for last valid selling/buying price
    double lastValidSellingPx = 0.0;
    double lastValidBuyingPx = 0.0;

    double lastValidLowSelling = 0.0;
    double lastValidHighBuying = 0.0;

    // Subscribe to the server-sent events
    _subscription =
        SSEClient.subscribeToSSE(
          method: SSERequestType.GET,
          url: ApiEndpoints.getGoldPriceApiUrl,
          header: headers,
        ).listen(
          (event) {
            try {
              final List<dynamic> jsonList = jsonDecode(event.data ?? "[]");

              final getGoldPriceResponse = SSEGetGoldPriceResponse.fromJson(
                jsonList,
              );

              // Process only if data exists
              if (getGoldPriceResponse.prices!.isNotEmpty) {
                // if mDEntryType is == "Bid" pick selling price
                // if mDEntryType is == "Offer" pick buying price

                double sellingPx = 0.0;
                double buyingPx = 0.0;
                double lastHigh = 0.0;
                double lastLow = 0.0;
                // Loop through the entries in reverse to find the latest 'Bid' and 'Offer'
                for (final priceEntry
                    in getGoldPriceResponse.prices!.reversed) {
                  if (sellingPx == 0.0 && priceEntry.mDEntryType == "Bid") {
                    sellingPx = (priceEntry.mDSellingPx ?? 0).toDouble();
                    lastLow = (priceEntry.lastLowSellingPrice ?? 0.0)
                        .toDouble();
                  } else if (buyingPx == 0.0 &&
                      priceEntry.mDEntryType == "Offer") {
                    buyingPx = (priceEntry.mDBuyingPx ?? 0).toDouble();
                    lastHigh = (priceEntry.lastHighBuyingPrice ?? 0.0)
                        .toDouble();
                  }
                  if (priceEntry.mDEntryType == "Bid") {
                    sellingPx = (priceEntry.mDSellingPx ?? 0).toDouble();
                    lastLow = (priceEntry.lastLowSellingPrice ?? 0.0)
                        .toDouble();
                  } else if (priceEntry.mDEntryType == "Offer") {
                    buyingPx = (priceEntry.mDBuyingPx ?? 0).toDouble();
                    lastHigh = (priceEntry.lastHighBuyingPrice ?? 0.0)
                        .toDouble();
                  }
                  if (sellingPx != 0.0 && buyingPx != 0.0) break; // found both
                }

                //Fallback to cached values if current ones are 0.0
                if (sellingPx == 0.0 && lastValidSellingPx != 0.0) {
                  sellingPx = lastValidSellingPx;
                } else if (sellingPx != 0.0) {
                  lastValidSellingPx = sellingPx;
                }

                if (buyingPx == 0.0 && lastValidBuyingPx != 0.0) {
                  buyingPx = lastValidBuyingPx;
                } else if (buyingPx != 0.0) {
                  lastValidBuyingPx = buyingPx;
                }

                //Fall back to cache values if current ones are 0.0
                // Apply fallback for high/low prices
                if (lastHigh == 0.0 && lastValidHighBuying != 0.0) {
                  lastHigh = lastValidHighBuying;
                } else if (lastHigh != 0.0) {
                  lastValidHighBuying = lastHigh;
                }

                if (lastLow == 0.0 && lastValidLowSelling != 0.0) {
                  lastLow = lastValidLowSelling;
                } else if (lastLow != 0.0) {
                  lastValidLowSelling = lastLow;
                }

                // Logging for observability
                if (sellingPx == 0.0 || buyingPx == 0.0) {
                  getLocator<Logger>().w(
                    "⚠️ Missing price fallback: sellingPx=$sellingPx, buyingPx=$buyingPx",
                  );
                }
                if (lastLow == 0.0 || lastHigh == 0.0) {
                  getLocator<Logger>().w(
                    "⚠️ Missing price fallback: sellingPx=$sellingPx, buyingPx=$buyingPx",
                  );
                }

                // getLocator<Logger>().i(
                //   "Live Prices Updated: Selling: [$sellingPx\$], Buying: [$buyingPx\$]",
                // );

                // Convert ounce USD price to AED per gram
                final oneGramSellingAEDPrice =
                    CommonService.getOneGramPriceInAED(
                      ounceDollarPrice: sellingPx,
                      dirham: aed,
                      ounce: ounce,
                    );

                final oneGramBuyingAEDPrice =
                    CommonService.getOneGramPriceInAED(
                      ounceDollarPrice: buyingPx,
                      dirham: aed,
                      ounce: ounce,
                    );
                final lastLowSellingPrice = CommonService.getOneGramPriceInAED(
                  ounceDollarPrice: lastLow,
                  dirham: aed,
                  ounce: ounce,
                );

                final lastHighBuyingPrice = CommonService.getOneGramPriceInAED(
                  ounceDollarPrice: lastHigh,
                  dirham: aed,
                  ounce: ounce,
                );

                // Build new state
                final xState = SSEGoldPriceState(
                  oneGramBuyingPriceInAED: oneGramBuyingAEDPrice,
                  oneGramSellingPriceInAED: oneGramSellingAEDPrice,
                  oneOunceDollarSellingPrice: sellingPx,
                  oneOunceDollarBuyingPrice: buyingPx,
                  lastLowSellingPrice: lastLowSellingPrice,
                  lastHighBuyingPrice: lastHighBuyingPrice,
                  getGoldPriceResponse: getGoldPriceResponse,
                );
                onData(xState); // Send updated state
              } else {
                getLocator<Logger>().w("Empty payload received from SSE.");
              }
            } catch (e) {
              getLocator<Logger>().e(" Failed to parse SSE data: $e");
            }
          },
          onError: (error) async {
            getLocator<Logger>().e(" SSE Stream Error: $error");
          },
          cancelOnError: true, // Automatically cancel on error
        );
  } catch (e) {
    getLocator<Logger>().e(" SSE Setup Failed: $e");
    if (onError != null) onError(e);
  }
}

/// Stops the SSE subscription and logs the cancellation
void stopSSE() {
  _subscription?.cancel();
  _subscription = null;
  getLocator<Logger>().i('SSE connection stopped');
}
