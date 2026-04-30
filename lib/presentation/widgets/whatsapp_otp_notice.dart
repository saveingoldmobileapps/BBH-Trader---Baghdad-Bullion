import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';

class WhatsappOtpNotice extends StatelessWidget {
  final String phoneNumber;

  /// If true, uses a more compact layout (useful when vertical space is tight).
  final bool compact;

  const WhatsappOtpNotice({
    super.key,
    required this.phoneNumber,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final masked = CommonService.maskPhoneNumber(phoneNumber: phoneNumber);

    final title = isArabic
        ? "تم إرسال رمز التحقق عبر واتساب"
        : "Verification code sent via WhatsApp";
    final subtitle = isArabic ? "إلى $masked" : "to $masked";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF262929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: SvgPicture.asset(
              "assets/svg/whatsapp_icon.svg",
              colorFilter: const ColorFilter.mode(
                Color(0xFFBBA473),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: AppColors.neutral80,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
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

