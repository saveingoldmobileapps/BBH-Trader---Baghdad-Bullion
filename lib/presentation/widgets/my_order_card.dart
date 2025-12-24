import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0xFF333333) /* GreyScale-900 */,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: sizes!.heightRatio * 52,
              width: sizes!.widthRatio * 52,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: 
                  kAllOrders.productId?.imageUrl != null && kAllOrders.productId!.imageUrl!.isNotEmpty
                  ? kAllOrders.productId!.imageUrl!.first
                  : "https://plus.unsplash.com/premium_photo-1678025061438-786888bfcaf1?q=80&w=3424&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"

                  //kAllOrders.productId?.imageUrl != null?"${kAllOrders.productId?.imageUrl}":     
                 ,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                        height: sizes!.heightRatio * 10,
                        width: sizes!.widthRatio * 10,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  GetGenericText(
                    text: kAllOrders.productId?.productName != null?"${kAllOrders.productId?.productName}": "",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF2F2F7),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetGenericText(
                        text: "#${kAllOrders.orderId}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ), //14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC7C7CC),
                      ),
                      statusCard(status: kAllOrders.status ?? "", context: context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget statusCard({
  required String status,
  required BuildContext context,
}) {
  final statusColors = {
    "Confirmed": const Color(0xFFBBA473),
    "Ready to pick": const Color(0xFFBBA473),
    "Delivered": const Color(0xFF34C759),
    "Cancelled": const Color(0xFFFF3B30),
    "Pending": const Color(0xFFE8B931),
  };

  // Arabic translations
  final statusArabic = {
    "Confirmed": "مؤكد",
    "Ready to pick": "جاهز للاستلام",
    "Delivered": "تم التوصيل",
    "Cancelled": "أُلغيت",
    "Pending": "قيد الانتظار",
    "Picked Up": "تم الاستلام",
    "Preparing": "قيد التحضير",

  };

  Color borderColor = statusColors[status] ?? const Color(0xFFBBA473);

  // Detect if the current locale is Arabic
  bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // Get the translated status if Arabic is active
  String displayStatus = isArabic ? (statusArabic[status] ?? status) : status;

  return _buildStatusCard(
    status: displayStatus,
    borderColor: borderColor,
  );
}

Widget _buildStatusCard({
  required String status,
  required Color borderColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: ShapeDecoration(
      color: borderColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GetGenericText(
          text: status.toUpperCase(),
          fontSize: sizes!.responsiveFont(
            phoneVal: 10,
            tabletVal: 14,
          ),
          fontWeight: FontWeight.w600,
          color: borderColor,
        ),
      ],
    ),
  );
}


  // Widget statusCard({
  //   required String status,
  // }) {
  //   final statusColors = {
  //     "Confirmed": const Color(0xFFBBA473),
  //     "Ready to pick": const Color(0xFFBBA473),
  //     "Delivered": const Color(0xFF34C759),
  //     "Cancelled": const Color(0xFFFF3B30),
  //     "Pending": const Color(0xFFE8B931),
  //   };

  //   Color borderColor = statusColors[status] ?? const Color(0xFFBBA473);
  //   return _buildStatusCard(status: status, borderColor: borderColor);
  // }

  // Widget _buildStatusCard({
  //   required String status,
  //   required Color borderColor,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: ShapeDecoration(
  //       color: borderColor.withValues(alpha: 0.2),
  //       shape: RoundedRectangleBorder(
  //         side: BorderSide(
  //           width: 1,
  //           color: borderColor,
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         GetGenericText(
  //           text: status.toUpperCase(),
  //           fontSize: sizes!.responsiveFont(
  //             phoneVal: 10,
  //             tabletVal: 14,
  //           ),
  //           fontWeight: FontWeight.w600,
  //           color: borderColor,
  //         ),
  //       ],
  //     ),
  //   );
  // }

}
