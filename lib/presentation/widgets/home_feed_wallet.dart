import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class HomeFeedWallet extends StatelessWidget {
  final bool isHiddenBalance;
  final WalletExists walletExists;
  final VoidCallback onBalancePress;
  final VoidCallback onDepositPress;

  const HomeFeedWallet({
    super.key,
    required this.isHiddenBalance,
    required this.walletExists,
    required this.onBalancePress,
    required this.onDepositPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amount = walletExists.moneyBalance ?? 0;
    final isMillion = amount.abs() >= 1000000;
    return Container(
      width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xFFBBA473).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xff75540e), width: 2),
                  left: BorderSide(color: Color(0xff75540e), width: 2),
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xff75540e), width: 2),
                  right: BorderSide(color: Color(0xff75540e), width: 2),
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold Section
                Text(
                  l10n.gold,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isHiddenBalance
                            ? "*****"
                            : CommonService.formatGramForDisplay(
                                walletExists.metalBalance,
                              ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMillion ? 22 : 42,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.gramsTab,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(),
                ),

                // Funds Section
                Text(
                  l10n.home_wallet_funds_label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isHiddenBalance
                            ? "*****"
                            : CommonService.formatIQDForDisplay(amount),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMillion
                              ? 22
                              : 42, // 👈 reduce size for millions
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Text(
                      //   isHiddenBalance
                      //       ? "*****"
                      //       : CommonService.formatIQDForDisplay(
                      //           walletExists.moneyBalance,
                      //         ),
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 42,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.idq,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                // Keep existing Balance Visibility Toggle functionality
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: onBalancePress,
                    icon: Icon(
                      isHiddenBalance ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
