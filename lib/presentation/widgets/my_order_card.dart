import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class MyOrderCard extends ConsumerWidget {
  final KAllOrders kAllOrders;
  final VoidCallback onTap;

  const MyOrderCard({
    super.key,
    required this.kAllOrders,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esouqStateWatchProvider = ref.watch(esouqProvider);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    String formattedDate = kAllOrders.createdAt != null
        ? DateFormat(
            'dd/MM/yyyy, HH:mm',
            isArabic ? 'ar_IQ' : 'en_IQ',
          ).format(
            DateTime.parse(kAllOrders.createdAt!)
                .toUtc()
                .add(const Duration(hours: 3)),
          )
        : "Dec 18, 2024  •  2:45 PM";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262929), // Darker card background per image
          borderRadius: BorderRadius.circular(16), // Softer rounding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header: Icon, ID, and Status ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold Bar Icon Container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/metal_active_icon.svg",
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GetGenericText(
                        text: "#${kAllOrders.orderId ?? 'GLD5QUF3K'}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 18,
                          tabletVal: 20,
                        ),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      GetGenericText(
                        text: formattedDate,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 12,
                          tabletVal: 14,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey6Color,
                      ),
                    ],
                  ),
                ),

                statusCard(
                  status: kAllOrders.status ?? "Completed",
                  context: context,
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFF2C2C2E), thickness: 1),
            ),

            /// --- Items List ---
            // Assuming your model has a way to list items, if not, we use the product info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetGenericText(
                  text: "${kAllOrders.quantity ?? 0} ${l10n.gram_unit_plural}",
                  fontSize: 14,
                  color: AppColors.grey6Color,
                  fontWeight: FontWeight.normal,
                ),
                GetGenericText(
                  text: kAllOrders.productId?.productName ?? "10g Gold bar",
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFF2C2C2E), thickness: 1),
            ),

            /// TOTAL PAID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 GetGenericText(
                  text: AppLocalizations.of(context)!.esouq_total_paid,//"Total paid",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),

                GetGenericText(
                  text:
                      esouqStateWatchProvider
                              .selectedOrder
                              .payload
                              ?.paymentMethod ==
                          'Money'
                      ? "${l10n.iqd_currency} ${CommonService.formatIQDForDisplay(kAllOrders.grandTotal ?? 0)}"
                      // "IQD ${widget.kAllOrders.grandTotal ?? '0.00'}":"",
                      : "${l10n.iqd_gram} ${CommonService.formatIQDForDisplay(kAllOrders.grandTotal ?? 0)}",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusCard({required String status, required BuildContext context}) {
    // Colors updated to match the pill style in the image
    final statusColors = {
      "Completed": const Color(0xFF1E3A1E), // Dark green background
      "Delivered": const Color(0xFF1E3A1E),
      "Pending": const Color(0xFF3A2E1E), // Dark orange/gold background
      "Cancelled": const Color(0xFF3A1E1E), // Dark red background
    };

    final textColors = {
      "Completed": const Color(0xFF34C759),
      "Delivered": const Color(0xFF34C759),
      "Pending": const Color(0xFFE8B931),
      "Cancelled": const Color(0xFFFF453A),
    };

    Color bgColor = statusColors[status] ?? const Color(0xFF2C2C2E);
    Color textColor = textColors[status] ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GetGenericText(
        text: _localizedStatus(context, status),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  String _localizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = status.trim().toLowerCase();
    switch (normalized) {
      case "pending":
        return l10n.pending;
      case "cancelled":
      case "canceled":
        return l10n.canceled;
      case "completed":
      case "delivered":
        return l10n.approved;
      default:
        return status;
    }
  }
}
