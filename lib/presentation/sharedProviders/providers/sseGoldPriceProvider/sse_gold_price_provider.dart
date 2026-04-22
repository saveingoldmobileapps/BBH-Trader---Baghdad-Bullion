import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
import '../../../../main.dart';
import '../../../feature_injection.dart';
import '../../../widgets/pop_up_widget.dart';

part 'sse_gold_price_provider.g.dart';

class SSEGoldPriceState {
  final CurrentGoldPriceModel currentGoldPriceModel;
  final SSEGetGoldPriceResponse getGoldPriceResponse;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final LoadingState loadingState;

  final double oneOunceDollarSellingPrice;
  final double oneOunceDollarBuyingPrice;
  final double lastLowSellingPrice;
  final double lastHighBuyingPrice;

  final double oneGramBuyingPriceInIQD;
  final double oneGramSellingPriceInIQD;

  final double oneOunceBuyingPriceInIQD;
  final double oneOunceSellingPriceInIQD;

  final bool isLoading;

  SSEGoldPriceState({
    CurrentGoldPriceModel? currentGoldPriceModel,
    SSEGetGoldPriceResponse? getGoldPriceResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.oneGramBuyingPriceInIQD = 0.0,
    this.oneGramSellingPriceInIQD = 0.0,
    this.oneOunceBuyingPriceInIQD = 0.0,
    this.oneOunceSellingPriceInIQD = 0.0,
    this.oneOunceDollarSellingPrice = 0.0,
    this.oneOunceDollarBuyingPrice = 0.0,
    this.lastLowSellingPrice = 0.0,
    this.lastHighBuyingPrice = 0.0,
    this.loadingState = LoadingState.loading,
    this.isLoading = false,
  }) : currentGoldPriceModel = currentGoldPriceModel ?? CurrentGoldPriceModel(),
       getGoldPriceResponse = getGoldPriceResponse ?? SSEGetGoldPriceResponse(),
       errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();
}

/// ---------------------------------------------------------------------------
/// GLOBAL SSE CONTROL
/// ---------------------------------------------------------------------------

StreamSubscription<SSEModel>? _subscription;
Timer? _reconnectTimer;
Timer? _heartbeatTimer;

DateTime _lastEventTime = DateTime.now();
bool _isConnecting = false;

/// ---------------------------------------------------------------------------
/// RIVERPOD PROVIDER
/// ---------------------------------------------------------------------------

@riverpod
Stream<SSEGoldPriceState> goldPrice(GoldPriceRef ref) {
  final controller = StreamController<SSEGoldPriceState>();
  _startSSE(
    onData: (state) {
      if (!controller.isClosed) {
        controller.add(state);
      }
    },
    onError: (error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    },
  );

  // _startSSE(
  //   onData: controller.add,
  //   onError: (error) => controller.addError(error),
  // );

  ref.onDispose(() {
    stopSSE();
    controller.close();
  });

  return controller.stream;
}

/// ---------------------------------------------------------------------------
/// SSE START
/// ---------------------------------------------------------------------------
bool maxDurationPopupShown = false;
Future<void> _startSSE({
  required void Function(SSEGoldPriceState) onData,
  required void Function(dynamic error)? onError,
}) async {
  if (_isConnecting) return;
  _isConnecting = true;
  getLocator<Logger>().i("SSE start requested");
  dynamic responseData;
  try {
    final hasInternet = await InternetConnection().hasInternetAccess;
    getLocator<Logger>().i("SSE internet check: $hasInternet");
    if (!hasInternet) {
      Toasts.getErrorToast(text: "No Internet Connection");
      getLocator<Logger>().w("SSE blocked: no internet");
      _scheduleReconnect(onData, onError);
      return;
    }

    final token = await LocalDatabase.instance.getLoginToken();
    getLocator<Logger>().i(
      "SSE token status: ${token == null || token.isEmpty ? 'missing' : 'available'}",
    );

    final headers = {
      "Authorization": "Bearer $token",
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    };
    getLocator<Logger>().i(
      "SSE subscribing to: ${ApiEndpoints.getGoldPriceApiUrl}",
    );

    const ounce = 31.10347; // Grams in a troy ounce

    double lastSelling = 0.0;
    double lastBuying = 0.0;
    double lastLow = 0.0;
    double lastHigh = 0.0;
    double lastExchangeRate = 0.00;
    Future<void> showMaxDurationPopup() async {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      await genericPopUpWidget(
        isLoadingState: false,
        context: context,
        heading: "Warning",
        subtitle: "Your session has expired due to maximum duration.",
        yesButtonTitle: "OK",
        onYesPress: () async {
          Navigator.pop(context);
        },
        onNoPress: () {},
      );
    }

    _subscription =
        SSEClient.subscribeToSSE(
          method: SSERequestType.GET,
          url: ApiEndpoints.getGoldPriceApiUrl,
          header: headers,
        ).listen(
          (event) {
            final raw = event.data;
            if (raw == null || raw.trim().isEmpty) {
              getLocator<Logger>().w("SSE received empty payload");
              return;
            }
            _lastEventTime = DateTime.now();
            getLocator<Logger>().d("SSE event received: ${raw.length} chars");

            try {
              // final decoded = jsonDecode(event.data ?? "{}");
              // responseData = jsonDecode(event.data ?? "{}");

              // /// 🔴 HANDLE MAX DURATION EVENT
              // if (decoded is Map &&
              //     decoded["reason"] == "max_duration_reached") {
              //   if (!maxDurationPopupShown) {
              //     maxDurationPopupShown = true;

              // stopSSE();

              //     showMaxDurationPopup();
              //   }
              //   return;
              // }
              // if (decoded is! List) {
              //   return;
              // }
              final List<dynamic> jsonList = jsonDecode(event.data ?? "[]");
              getLocator<Logger>().d(
                "SSE payload decoded, entries: ${jsonList.length}",
              );

              final response = SSEGetGoldPriceResponse.fromJson(jsonList);

              if (response.prices!.isEmpty) {
                getLocator<Logger>().w("SSE parsed but prices list is empty");
                return;
              }

              double sellingPx = 0.0;
              double buyingPx = 0.0;
              double lowPx = 0.0;
              double highPx = 0.0;
              double exchangeRate = 0.0;

              // for (final p in response.prices!.reversed) {
              //   if (p.mDEntryType == "Bid") {
              //     sellingPx = (p.mDSellingPx ?? 0).toDouble();
              //     lowPx = (p.lastLowSellingPrice ?? 0).toDouble();
              //   }
              //   if (p.mDEntryType == "Offer") {
              //     buyingPx = (p.mDBuyingPx ?? 0).toDouble();
              //     highPx = (p.lastHighBuyingPrice ?? 0).toDouble();
              //   }
              //   final liveRate =
              //       (p.exchangeRate?.buying ?? p.exchangeRate?.selling ?? 0)
              //           .toDouble();
              //   if (liveRate > 0) {
              //     exchangeRate = liveRate;
              //   }
              //   if (sellingPx != 0 && buyingPx != 0) break;
              // }
              double sellingExchangeRate = 0.0;
              double buyingExchangeRate = 0.0;

              for (final p in response.prices!.reversed) {
                if (p.mDEntryType == "Bid") {
                  sellingPx = (p.mDSellingPx ?? 0).toDouble();
                  lowPx = (p.lastLowSellingPrice ?? 0).toDouble();

                  /// ✅ Selling uses SELLING exchange rate
                  final rate = (p.exchangeRate?.selling ?? 0).toDouble();
                  if (rate > 0) {
                    sellingExchangeRate = rate;
                  }
                }

                if (p.mDEntryType == "Offer") {
                  buyingPx = (p.mDBuyingPx ?? 0).toDouble();
                  highPx = (p.lastHighBuyingPrice ?? 0).toDouble();

                  /// ✅ Buying uses BUYING exchange rate
                  final rate = (p.exchangeRate?.buying ?? 0).toDouble();
                  if (rate > 0) {
                    buyingExchangeRate = rate;
                  }
                }

                if (sellingPx != 0 && buyingPx != 0) break;
              }

              sellingPx = sellingPx == 0 ? lastSelling : sellingPx;
              buyingPx = buyingPx == 0 ? lastBuying : buyingPx;
              lowPx = lowPx == 0 ? lastLow : lowPx;
              highPx = highPx == 0 ? lastHigh : highPx;
              exchangeRate = exchangeRate == 0
                  ? lastExchangeRate
                  : exchangeRate;
              getLocator<Logger>().i(
                "SSE computed values: selling=$sellingPx buying=$buyingPx low=$lowPx high=$highPx exchangeRate=$exchangeRate",
              );

              lastSelling = sellingPx;
              lastBuying = buyingPx;
              lastLow = lowPx;
              lastHigh = highPx;
              lastExchangeRate = exchangeRate;
              sellingExchangeRate = sellingExchangeRate == 0
                  ? lastExchangeRate
                  : sellingExchangeRate;

              buyingExchangeRate = buyingExchangeRate == 0
                  ? lastExchangeRate
                  : buyingExchangeRate;

              lastExchangeRate =
                  buyingExchangeRate; // or keep separate if needed
              final state = SSEGoldPriceState(
                oneOunceDollarSellingPrice: sellingPx,
                oneOunceDollarBuyingPrice: buyingPx,

                oneGramSellingPriceInIQD: CommonService.getOneGramPriceInIQD(
                  ounceDollarPrice: sellingPx,
                  dirham: sellingExchangeRate,
                  ounce: ounce,
                ),

                oneGramBuyingPriceInIQD: CommonService.getOneGramPriceInIQD(
                  ounceDollarPrice: buyingPx,
                  dirham: buyingExchangeRate,
                  ounce: ounce,
                ),

                oneOunceSellingPriceInIQD: sellingPx * sellingExchangeRate,
                oneOunceBuyingPriceInIQD: buyingPx * buyingExchangeRate,

                lastLowSellingPrice: CommonService.getOneGramPriceInIQD(
                  ounceDollarPrice: lowPx,
                  dirham: sellingExchangeRate,
                  ounce: ounce,
                ),

                lastHighBuyingPrice: CommonService.getOneGramPriceInIQD(
                  ounceDollarPrice: highPx,
                  dirham: buyingExchangeRate,
                  ounce: ounce,
                ),

                getGoldPriceResponse: response,
              );
              // final state = SSEGoldPriceState(
              //   oneOunceDollarSellingPrice: sellingPx,
              //   oneOunceDollarBuyingPrice: buyingPx,
              //   lastLowSellingPrice: CommonService.getOneGramPriceInIQD(
              //     ounceDollarPrice: lowPx,
              //     dirham: exchangeRate,
              //     ounce: ounce,
              //   ),
              //   lastHighBuyingPrice: CommonService.getOneGramPriceInIQD(
              //     ounceDollarPrice: highPx,
              //     dirham: exchangeRate,
              //     ounce: ounce,
              //   ),
              //   oneGramSellingPriceInIQD: CommonService.getOneGramPriceInIQD(
              //     ounceDollarPrice: sellingPx,
              //     dirham: exchangeRate,
              //     ounce: ounce,
              //   ),
              //   oneGramBuyingPriceInIQD: CommonService.getOneGramPriceInIQD(
              //     ounceDollarPrice: buyingPx,
              //     dirham: exchangeRate,
              //     ounce: ounce,
              //   ),
              //   oneOunceBuyingPriceInIQD: buyingPx * exchangeRate,
              //   oneOunceSellingPriceInIQD: sellingPx * exchangeRate,
              //   getGoldPriceResponse: response,
              // );

              print(
                "SSE state emitted: gramBuy=${state.oneGramBuyingPriceInIQD} gramSell=${state.oneGramSellingPriceInIQD}",
              );
              print(
                "Exchange Rates${buyingExchangeRate} gramSell=${sellingExchangeRate}",
              );
              onData(state);
            } catch (e) {
              getLocator<Logger>().e(
                "SSE parse error: $e | raw=${event.data}",
              );
            }
          },
          onError: (e) {
            getLocator<Logger>().e("SSE error: $e");
            _scheduleReconnect(onData, onError);
          },
          onDone: () {
            getLocator<Logger>().w("SSE closed");
            _scheduleReconnect(onData, onError);
          },
          cancelOnError: false,
        );

    _startHeartbeat(onData, onError);
  } catch (e) {
    getLocator<Logger>().e("SSE init failed: $e");
    _scheduleReconnect(onData, onError);
  } finally {
    _isConnecting = false;
  }
}

/// ---------------------------------------------------------------------------
/// HEARTBEAT
/// ---------------------------------------------------------------------------

void _startHeartbeat(
  void Function(SSEGoldPriceState) onData,
  void Function(dynamic error)? onError,
) {
  _heartbeatTimer?.cancel();

  _heartbeatTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      final diff = DateTime.now().difference(_lastEventTime).inSeconds;
      if (diff > 5) {
        getLocator<Logger>().w("SSE heartbeat timeout");
        stopSSE();
        _scheduleReconnect(onData, onError);
      }
    },
  );
}

/// ---------------------------------------------------------------------------
/// RECONNECT
/// ---------------------------------------------------------------------------

void _scheduleReconnect(
  void Function(SSEGoldPriceState) onData,
  void Function(dynamic error)? onError,
) {
  if (_reconnectTimer?.isActive ?? false) return;

  _reconnectTimer = Timer(
    const Duration(seconds: 1),
    () {
      getLocator<Logger>().i("Reconnecting SSE...");
      stopSSE();
      _startSSE(onData: onData, onError: onError);
    },
  );
}

/// ---------------------------------------------------------------------------
/// STOP
/// ---------------------------------------------------------------------------
void stopSSE() {
  _subscription?.cancel();
  _subscription = null;

  _heartbeatTimer?.cancel();
  _reconnectTimer?.cancel();

  _isConnecting = false; // 🔥 prevents stuck state

  getLocator<Logger>().i("SSE stopped");
}

// void stopSSE() {
//   _subscription?.cancel();
//   _subscription = null;

//   _heartbeatTimer?.cancel();
//   _reconnectTimer?.cancel();

//   getLocator<Logger>().i("SSE stopped");
// }
