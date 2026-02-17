import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllOrdersResponse.dart';

class MyOrderCard extends StatelessWidget {
  final KAllOrders kAllOrders;
  final VoidCallback onTap;

  const MyOrderCard({
    super.key,
    required this.kAllOrders,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format date if available, otherwise use a placeholder
    String formattedDate = kAllOrders.createdAt != null
        ? DateFormat(
            'MMM dd, yyyy  •  h:mm a',
          ).format(DateTime.parse(kAllOrders.createdAt!))
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
                  text: "1x", // Replace with actual qty if available
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

            /// --- Total Paid Footer ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetGenericText(
                  text: "Total paid",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                GetGenericText(
                  text: "IQD ${kAllOrders.grandTotal ?? '2,105,000.00'}",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldColor, // Gold text color
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
        text: status,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
