import 'package:flutter/material.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';

import '../main_home_screens/main_home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final String productInfo;
  final String totalPaid;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.productInfo,
    required this.totalPaid,
  });


//   String _formatIqd(String? value) {
//   final parsed = double.tryParse(value ?? '') ?? 0;
//   return CommonService.formatIQDForDisplay(parsed);
// }
String _formatIqd(String? value) {
  if (value == null || value.isEmpty) return "0";

  final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
  final parsed = double.tryParse(cleaned) ?? 0;

  return CommonService.formatIQDForDisplay(parsed);
}
  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Top Content
            Column(
              children: [
                ConstPadding.sizeBoxWithHeight(height: 40),

                /// Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 24),

                /// Title
                GetGenericText(
                  text: l10n.order_placed_title,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1Color,
                ),

                ConstPadding.sizeBoxWithHeight(height: 6),

                /// Subtitle
                GetGenericText(
                  text: l10n.esouq_order_placed_subtitle,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey4Color,
                ),

                ConstPadding.sizeBoxWithHeight(height: 30),

                /// Order Summary Card
                Container(
                  width: sizes!.width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greyScale900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GetGenericText(
                        text: l10n.esouq_order_summary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey2Color,
                      ),

                      ConstPadding.sizeBoxWithHeight(height: 16),

                      _rowItem(
                        context,
                        l10n.esouq_order_id,
                        orderId,
                      ),
                      _divider(),

                      _rowItem(
                        context,
                        AppLocalizations.of(context)!.dateTime,
                        dateTime,
                      ),
                      _divider(),

                      _rowItem(
                        context,
                        l10n.esouq_items,
                        productInfo,
                      ),

                      ConstPadding.sizeBoxWithHeight(height: 12),
                      _divider(),

                      ConstPadding.sizeBoxWithHeight(height: 12),

                      /// Total Paid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetGenericText(
                            text: l10n.esouq_total_paid,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey2Color,
                          ),
                          GetGenericText(
                            text: _formatIqd(totalPaid),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGold500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 16),

                /// Info Text
                Container(
                  width: sizes!.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyScale900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GetGenericText(
                    text: l10n.will_notify,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey4Color,
                  ),
                ),
              ],
            ),

            /// Bottom Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainHomeScreen(),
                    ),
                    ((route) => false),
                  );
                },
                child: Container(
                  height: 56,
                  width: sizes!.width,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.goldColor, // start (darker gold)
                        AppColors.goldDarkColor, // center (highlight gold)
                        AppColors.goldColor, // end (darker gold)
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: GetGenericText(
                      text: l10n.return_home,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).get16HorizontalPadding(),
      ),
    );
  }

  Widget _rowItem(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GetGenericText(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey4Color,
        ),
        GetGenericText(
          text: value,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey2Color,
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        color: AppColors.greyScale700,
        height: 1,
      ),
    );
  }
}
