import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

/// Trade confirmation dialog (buy market / limit, sell market / limit).
/// Optional [limitBuyPricePerGram]: when set, dialog closes if live buying price
/// drops so the limit is above market (invalid vs. max ≤ market rule).
Future<void> showConfirmTradeDialog({
  required BuildContext context,
  required bool isLimitOrder,
  required String amountGrams,
  required String targetPrice,
  required String totalCost,
  required Future<void> Function() onConfirm,
  String? title,
  String? subtitle,
  String? confirmButtonText,
  bool showCountdownTimer = true,
  double? limitBuyPricePerGram,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _ConfirmTradeDialog(
      isLimitOrder: isLimitOrder,
      amountGrams: amountGrams,
      targetPrice: targetPrice,
      totalCost: totalCost,
      onConfirm: onConfirm,
      title: title,
      subtitle: subtitle,
      confirmButtonText: confirmButtonText,
      showCountdownTimer: showCountdownTimer,
      limitBuyPricePerGram: limitBuyPricePerGram,
    ),
  );
}

class _ConfirmTradeDialog extends ConsumerStatefulWidget {
  const _ConfirmTradeDialog({
    required this.isLimitOrder,
    required this.amountGrams,
    required this.targetPrice,
    required this.totalCost,
    required this.onConfirm,
    this.title,
    this.subtitle,
    this.confirmButtonText,
    required this.showCountdownTimer,
    this.limitBuyPricePerGram,
  });

  final bool isLimitOrder;
  final String amountGrams;
  final String targetPrice;
  final String totalCost;
  final Future<void> Function() onConfirm;
  final String? title;
  final String? subtitle;
  final String? confirmButtonText;
  final bool showCountdownTimer;
  final double? limitBuyPricePerGram;

  @override
  ConsumerState<_ConfirmTradeDialog> createState() =>
      _ConfirmTradeDialogState();
}

class _ConfirmTradeDialogState extends ConsumerState<_ConfirmTradeDialog> {
  static const double _priceTol = 0.01;

  Timer? _timer;
  int _remainingSeconds = 5;
  ProviderSubscription<AsyncValue<SSEGoldPriceState>>? _goldPriceListenSub;

  void _maybeInvalidateLimitBuy(double? liveBuyingPerGram) {
    final lim = widget.limitBuyPricePerGram;
    if (lim == null || liveBuyingPerGram == null) return;
    if (lim > liveBuyingPerGram + _priceTol) {
      _timer?.cancel();
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.showCountdownTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remainingSeconds <= 1) {
          t.cancel();
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    }

    if (widget.limitBuyPricePerGram != null) {
      _goldPriceListenSub = ref.listenManual(goldPriceProvider, (
        previous,
        next,
      ) {
        next.whenData((data) {
          _maybeInvalidateLimitBuy(data.oneGramBuyingPriceInIQD);
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lim = widget.limitBuyPricePerGram;
      if (lim == null) return;
      final data = ref.read(goldPriceProvider).asData?.value;
      if (data != null) {
        _maybeInvalidateLimitBuy(data.oneGramBuyingPriceInIQD);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _goldPriceListenSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dialogTitle = widget.title ?? l10n.trade_confirm_dialog_title;
    final dialogSubtitle =
        widget.subtitle ?? l10n.trade_confirm_dialog_subtitle;
    final dialogConfirm =
        widget.confirmButtonText ?? l10n.trade_confirm_dialog_button;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dialogTitle,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dialogSubtitle,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8E8E93),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (widget.showCountdownTimer) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _remainingSeconds <= 2
                              ? Colors.red.withOpacity(0.2)
                              : const Color(0xFFBBA473).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _remainingSeconds <= 2
                                ? Colors.red
                                : const Color(0xFFBBA473),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "00:0$_remainingSeconds${l10n.sec}",
                          style: GoogleFonts.inter(
                            color: _remainingSeconds <= 2
                                ? Colors.red
                                : const Color(0xFFBBA473),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      onTap: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (widget.isLimitOrder) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBA473).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFBBA473).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  l10n.deal_take_profit,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFBBA473),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // tradeConfirmDetailRow(
            //   l10n.amountVar,
            //   '${widget.amountGrams} ${l10n.grams_unit_lowercase}',
            // ),
            tradeConfirmDetailRow(
              l10n.amountVar,
              (() {
                final amountValue =
                    double.tryParse(widget.amountGrams.toString()) ?? 0;

                return '${widget.amountGrams} ${amountValue > 1 ? l10n.grams_plural_lowercase : l10n.grams_unit_lowercase}';
              })(),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            if (widget.isLimitOrder) ...[
              tradeConfirmDetailRow(
                l10n.trade_row_target_price,
                l10n.price_iqd_per_gram(widget.targetPrice),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
            ],
            tradeConfirmDetailRow(
              l10n.trade_row_est_total,
              '${l10n.iqd_currency} ${widget.totalCost}',
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.isLimitOrder
                    ? l10n.trade_confirm_limit_body(widget.targetPrice)
                    : l10n.trade_confirm_market_body(widget.targetPrice),
                style: GoogleFonts.inter(
                  color: const Color(0xFF8E8E93),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      _timer?.cancel();
                      Navigator.pop(context);
                      await widget.onConfirm();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.goldColor,
                            AppColors.goldDarkColor,
                            AppColors.goldColor,
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dialogConfirm,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget tradeConfirmDetailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF8E8E93),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
