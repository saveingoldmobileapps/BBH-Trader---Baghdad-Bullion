import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/core/theme/const_colors.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KycDocumentWarning extends StatelessWidget {
  const KycDocumentWarning({
    required this.documentType,
    required this.reviewStatus,
    required this.onTap,
    super.key,
  });

  final KycDocumentType documentType;
  final KycDocumentReviewStatus reviewStatus;
  final VoidCallback onTap;

  String _documentLabel(AppLocalizations l10n) => switch (documentType) {
        KycDocumentType.nationalId => l10n.kyc_doc_national_id,
        KycDocumentType.passport => l10n.kyc_doc_passport,
        KycDocumentType.residency => l10n.kyc_doc_residency,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRejected = reviewStatus.isRejected;
    final borderColor = isRejected ? const Color(0xffE04c4E) : AppColors.primaryGold500;
    final message = isRejected
        ? l10n.kyc_document_rejected(_documentLabel(l10n))
        : l10n.kyc_document_pending(_documentLabel(l10n));
    final action = isRejected ? l10n.kyc_retake_document : l10n.verify_account;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset('assets/svg/alert_icon.svg'),
            ConstPadding.sizeBoxWithWidth(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: message,
                    fontSize: sizes!.isPhone ? 12 : 16,
                    fontWeight:
                        sizes!.isPhone ? FontWeight.w400 : FontWeight.w600,
                    color: AppColors.whiteColor,
                    isInter: true,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 4),
                  GetGenericText(
                    text: action,
                    fontSize: sizes!.isPhone ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold500,
                    isInter: true,
                    isUnderline: true,
                  ),
                ],
              ),
            ),
          ],
        ).get6VerticalPadding(),
      ),
    );
  }
}
