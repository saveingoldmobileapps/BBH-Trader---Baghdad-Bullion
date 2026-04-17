import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    String formattedDate = kAllOrders.createdAt != null
        ? DateFormat(
            'dd/MM/yyyy, HH:mm',
            isArabic ? 'ar_IQ' : 'en_IQ',
          ).format(
            DateTime.parse(
              kAllOrders.createdAt!,
            ).toUtc().add(const Duration(hours: 3)),
          )
        : "Dec 18, 2024  •  2:45 PM";

    // ✅ Get product name directly from the rawProductName map
    String getProductName() {
      try {
        final product = kAllOrders.productId;
        if (product == null) return "Gold Product";

        // Try to get rawProductName (which should be the Map)
        final rawName = product.rawProductName;

        if (rawName != null && rawName is Map) {
          if (isArabic) {
            return rawName['ar']?.toString() ??
                rawName['en']?.toString() ??
                "منتج ذهب";
          } else {
            return rawName['en']?.toString() ??
                rawName['ar']?.toString() ??
                "Gold Product";
          }
        }

        // Fallback to productCode or weight
        return product.productCode ?? "${product.weight ?? "0"}g";
      } catch (e) {
        return "Gold Product";
      }
    }

    String getProductWeight() {
      final product = kAllOrders.productId;
      if (product == null) return "0";
      return product.weight ?? "0";
    }

    String getWeightUnit() {
      final product = kAllOrders.productId;
      if (product == null) return "g";
      final category = product.weightCategory ?? "";
      if (category.toLowerCase() == "gram") return isArabic ? "جرام" : "g";
      return category;
    }

    final productName = getProductName();
    final weightPerUnit = getProductWeight();
    final weightUnit = getWeightUnit();
    final totalWeight =
        (kAllOrders.quantity ?? 0) * (double.tryParse(weightPerUnit) ?? 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262929),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Icon, ID, and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/metal_active_icon.svg",
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GetGenericText(
                        text: "#${kAllOrders.orderId ?? 'N/A'}",
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
                  status: kAllOrders.status ?? "Pending",
                  context: context,
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFF2C2C2E), thickness: 1),
            ),

            /// Product Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Quantity Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetGenericText(
                      text: isArabic ? "الكمية" : "Quantity",
                      fontSize: 12,
                      color: AppColors.grey4Color,
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 4),
                    GetGenericText(
                      text: "${kAllOrders.quantity ?? 0}",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),

                /// Product Name Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GetGenericText(
                        text: isArabic ? "المنتج" : "Product",
                        fontSize: 12,
                        color: AppColors.grey4Color,
                        fontWeight: FontWeight.normal,
                      ),
                      const SizedBox(height: 4),
                      GetGenericText(
                        text: productName,
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Weight Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetGenericText(
                      text: isArabic ? "الوزن/الوحدة" : "Weight/Unit",
                      fontSize: 12,
                      color: AppColors.grey4Color,
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 4),
                    GetGenericText(
                      text: "$weightPerUnit $weightUnit",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GetGenericText(
                      text: isArabic ? "الوزن الإجمالي" : "Total Weight",
                      fontSize: 12,
                      color: AppColors.grey4Color,
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 4),
                    GetGenericText(
                      text: "${totalWeight.toStringAsFixed(2)} $weightUnit",
                      fontSize: 14,
                      color: AppColors.goldColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
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
                  text: AppLocalizations.of(context)!.esouq_total_paid,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                GetGenericText(
                  text:
                      "${l10n.iqd_currency} ${CommonService.formatIQDForDisplay(kAllOrders.grandTotal ?? 0)}",
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
    final statusColors = {
      "Completed": const Color(0xFF1E3A1E),
      "Delivered": const Color(0xFF1E3A1E),
      "Pending": const Color(0xFF3A2E1E),
      "Cancelled": const Color(0xFF3A1E1E),
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
