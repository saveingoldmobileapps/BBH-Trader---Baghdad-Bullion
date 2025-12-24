import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/core_export.dart';

class LoanRequestCard extends StatelessWidget {
  final String amount;
  final String date;
  final String status;
  final VoidCallback onPayNowClick;

  const LoanRequestCard({
    super.key,
    required this.amount,
    required this.date,
    required this.status,
    required this.onPayNowClick,
  });

  @override
  Widget build(BuildContext context) {
    // Convert from UTC to local time
    DateTime parsedDate = DateTime.parse(date).toLocal();
    // Format date and time
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    String formattedTime = DateFormat('HH:mm').format(parsedDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Color(0xFF333333),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: "Amount",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: "AED $amount",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              // Status column that can show multiple statuses
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  statusCard(status),
                ],
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GetGenericText(
                    text: formattedDate,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ),
                  ConstPadding.sizeBoxWithWidth(width: 4),
                  GetGenericText(
                    text: formattedTime,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey4Color,
                  ),
                ],
              ),
              if (status.toLowerCase() == "approved") _payNowButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// Pay Now button
  Widget _payNowButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPayNowClick,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: sizes!.responsiveLandscapeWidth(
            phoneVal: 70,
            tabletVal: 90,
            tabletLandscapeVal: 100,
            isLandscape: sizes!.isLandscape(),
          ),
          height: sizes!.responsiveLandscapeHeight(
            phoneVal: 24,
            tabletVal: 34,
            tabletLandscapeVal: 40,
            isLandscape: sizes!.isLandscape(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryGold500,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: GetGenericText(
              text: "Pay Now",
              fontSize: sizes!.responsiveFont(
                phoneVal: 12,
                tabletVal: 14,
              ),
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  /// status card
  Widget statusCard(String status) {
    switch (status.toLowerCase()) {
      case "rejected":
        return rejectionCard();
      case "approved":
        return acceptanceCard();
      case "paid":
      case "partially paid":
        return paidCard();
      default:
        return pendingCard();
    }
  }

  /// rejection card
  Widget rejectionCard() {
    return _statusContainer(
      text: "Rejected",
      bgColor: AppColors.red900Color,
      textColor: AppColors.red800Color,
    );
  }

  /// acceptance card
  Widget acceptanceCard() {
    return _statusContainer(
      text: "Approved",
      bgColor: Color(0xFF34C759),
      textColor: AppColors.green900Color,
    );
  }

  /// paid card
  Widget paidCard() {
    return _statusContainer(
      text: "Paid",
      bgColor: Color(0xFF34C759),
      textColor: AppColors.green900Color,
    );
  }

  /// pending card
  Widget pendingCard() {
    return _statusContainer(
      text: "Pending",
      bgColor: Color(0xFFE8B931),
      textColor: Color(0xFF11271C),
    );
  }

  /// status container
  Widget _statusContainer({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: sizes!.responsiveLandscapeWidth(
        phoneVal: 70,
        tabletVal: 90,
        tabletLandscapeVal: 100,
        isLandscape: sizes!.isLandscape(),
      ),
      height: sizes!.responsiveLandscapeHeight(
        phoneVal: 24,
        tabletVal: 34,
        tabletLandscapeVal: 40,
        isLandscape: sizes!.isLandscape(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Center(
        child: GetGenericText(
          text: text,
          fontSize: sizes!.responsiveFont(
            phoneVal: 12,
            tabletVal: 14,
          ),
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
