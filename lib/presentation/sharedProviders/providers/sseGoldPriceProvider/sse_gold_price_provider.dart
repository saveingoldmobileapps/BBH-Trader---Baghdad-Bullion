import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:baghdad_bullion_house/core/enums/loading_state.dart';
import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';

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

  /// USD→IQD exchange rates coming from SSE payload
  /// - `exchangeBuyRate`: used for converting costs into IQD at buy rate
  /// - `exchangeSellRate`: used for converting at sell rate
  final double exchangeBuyRate;
  final double exchangeSellRate;

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
    this.exchangeBuyRate = 0.0,
    this.exchangeSellRate = 0.0,
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
Stream<SSEGoldPriceState> goldPrice(Ref ref) {
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

    final ounce = CommonService.gramsPerTroyOunce;

    double lastSelling = 0.0;
    double lastBuying = 0.0;
    double lastLow = 0.0;
    double lastHigh = 0.0;
    double lastBuyingExchangeRate = 0.0;
    double lastSellingExchangeRate = 0.0;
    double lastBuyingMargin = 0.0;
    double lastSellingMargin = 0.0;
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

              final response = SSEGetGoldPriceResponse.fromJson(jsonList);

              if (response.prices!.isEmpty) {
                getLocator<Logger>().w("SSE parsed but prices list is empty");
                return;
              }

              double sellingPx = 0.0;
              double buyingPx = 0.0;
              double lowPx = 0.0;
              double highPx = 0.0;
              double sellingExchangeRate = 0.0;
              double buyingExchangeRate = 0.0;

              for (final p in response.prices!.reversed) {
                if (p.mDEntryType == "Bid") {
                  sellingPx = (p.mDSellingPx ?? 0).toDouble();
                  lowPx = (p.lastLowSellingPrice ?? 0).toDouble();

                  final rate = (p.exchangeRate?.selling ?? 0).toDouble();
                  if (rate > 0) {
                    sellingExchangeRate = rate;
                    lastSellingExchangeRate = rate;
                  }
                }

                if (p.mDEntryType == "Offer") {
                  buyingPx = (p.mDBuyingPx ?? 0).toDouble();
                  highPx = (p.lastHighBuyingPrice ?? 0).toDouble();

                  final rate = (p.exchangeRate?.buying ?? 0).toDouble();
                  if (rate > 0) {
                    buyingExchangeRate = rate;
                    lastBuyingExchangeRate = rate;
                  }
                }

                final m = p.margin;
                if (m != null) {
                  if (m.buying != null) {
                    lastBuyingMargin = m.buying!.toDouble();
                  }
                  if (m.selling != null) {
                    lastSellingMargin = m.selling!.toDouble();
                  }
                }

                if (sellingPx != 0 && buyingPx != 0) break;
              }

              sellingPx = sellingPx == 0 ? lastSelling : sellingPx;
              buyingPx = buyingPx == 0 ? lastBuying : buyingPx;
              lowPx = lowPx == 0 ? lastLow : lowPx;
              highPx = highPx == 0 ? lastHigh : highPx;

              sellingExchangeRate = sellingExchangeRate == 0
                  ? lastSellingExchangeRate
                  : sellingExchangeRate;
              buyingExchangeRate = buyingExchangeRate == 0
                  ? lastBuyingExchangeRate
                  : buyingExchangeRate;

              lastSelling = sellingPx;
              lastBuying = buyingPx;
              lastLow = lowPx;
              lastHigh = highPx;

              final buyingMargin = lastBuyingMargin;
              final sellingMargin = lastSellingMargin;

              // final oneGramBuyIqd = CommonService.oneGramBuyingPriceInIqd(
              //   ounceUsd: buyingPx,
              //   buyingMargin: buyingMargin,
              //   exchangeBuyRate: buyingExchangeRate,
              //   gramsPerOunce: ounce,
              // );
              // final oneGramSellIqd = CommonService.oneGramSellingPriceInIqd(
              //   ounceUsd: sellingPx,
              //   sellingMargin: sellingMargin,
              //   exchangeSellingRate: sellingExchangeRate,
              //   gramsPerOunce: ounce,
              // );
              final oneGramBuyIqd = roundToNearestHundred(
                CommonService.oneGramBuyingPriceInIqd(
                  ounceUsd: buyingPx,
                  buyingMargin: buyingMargin,
                  exchangeBuyRate: buyingExchangeRate,
                  gramsPerOunce: ounce,
                ),
              );

              final oneGramSellIqd = roundToNearestHundred(
                CommonService.oneGramSellingPriceInIqd(
                  ounceUsd: sellingPx,
                  sellingMargin: sellingMargin,
                  exchangeSellingRate: sellingExchangeRate,
                  gramsPerOunce: ounce,
                ),
              );

              final state = SSEGoldPriceState(
                oneOunceDollarSellingPrice: sellingPx,
                oneOunceDollarBuyingPrice: buyingPx,

                exchangeBuyRate: buyingExchangeRate,
                exchangeSellRate: sellingExchangeRate,

                oneGramSellingPriceInIQD: oneGramSellIqd,

                oneGramBuyingPriceInIQD: oneGramBuyIqd,

                oneOunceSellingPriceInIQD:
                    CommonService.oneOunceSellingPriceInIqd(
                      ounceUsd: sellingPx,
                      sellingMargin: sellingMargin,
                      exchangeSellingRate: sellingExchangeRate,
                      gramsPerOunce: ounce,
                    ),
                oneOunceBuyingPriceInIQD:
                    CommonService.oneOunceBuyingPriceInIqd(
                      ounceUsd: buyingPx,
                      buyingMargin: buyingMargin,
                      exchangeBuyRate: buyingExchangeRate,
                      gramsPerOunce: ounce,
                    ),

                lastLowSellingPrice: CommonService.oneGramSellingPriceInIqd(
                  ounceUsd: lowPx,
                  sellingMargin: sellingMargin,
                  exchangeSellingRate: sellingExchangeRate,
                  gramsPerOunce: ounce,
                ),

                lastHighBuyingPrice: CommonService.oneGramBuyingPriceInIqd(
                  ounceUsd: highPx,
                  buyingMargin: buyingMargin,
                  exchangeBuyRate: buyingExchangeRate,
                  gramsPerOunce: ounce,
                ),

                getGoldPriceResponse: response,
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

double roundToNearestHundred(num value) {
  final val = value.round();
  final lastTwo = val % 100;
  final base = val - lastTwo;

  return lastTwo >= 50 ? (base + 100).toDouble() : base.toDouble();
}

// void stopSSE() {
//   _subscription?.cancel();
//   _subscription = null;

//   _heartbeatTimer?.cancel();
//   _reconnectTimer?.cancel();

//   getLocator<Logger>().i("SSE stopped");
// }
