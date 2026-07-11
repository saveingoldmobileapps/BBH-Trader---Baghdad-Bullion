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
    this.notVerified = false,
    this.showAction = true,
    this.verificationStatus,
    super.key,
  });

  final KycDocumentType documentType;
  final KycDocumentReviewStatus reviewStatus;
  final VoidCallback onTap;
  final bool notVerified;
  final bool showAction;
  final ProfileVerificationStatus? verificationStatus;

  String _documentLabel(AppLocalizations l10n) => switch (documentType) {
        KycDocumentType.nationalId => l10n.kyc_doc_national_id,
        KycDocumentType.passport => l10n.kyc_doc_passport,
        KycDocumentType.residency => l10n.kyc_doc_residency,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final docLabel = _documentLabel(l10n);
    final status = verificationStatus;
    final isRejected = status == ProfileVerificationStatus.rejected ||
        (status == null && reviewStatus.isRejected);
    final isVerified = status?.isApprovedOrVerified ??
        (status == null && reviewStatus == KycDocumentReviewStatus.approved);
    final isReviewing = status == ProfileVerificationStatus.reviewing;
    final isPending = status == ProfileVerificationStatus.pending ||
        (status == null && reviewStatus == KycDocumentReviewStatus.pending);

    final borderColor = isRejected
        ? const Color(0xffE04c4E)
        : isVerified
        ? const Color(0xff4CAF50)
        : AppColors.primaryGold500;

    final message = notVerified
        ? l10n.kyc_document_not_verified(docLabel)
        : isRejected
        ? l10n.kyc_document_rejected(docLabel)
        : isVerified
        ? l10n.kyc_document_verified(docLabel)
        : isReviewing
        ? l10n.kyc_document_reviewing(docLabel)
        : isPending
        ? (showAction
            ? l10n.kyc_document_pending(docLabel)
            : l10n.kyc_document_pending_review(docLabel))
        : showAction
        ? l10n.kyc_document_pending(docLabel)
        : l10n.kyc_document_pending_review(docLabel);

    final action = isRejected
        ? l10n.kyc_retake_document
        : isVerified
        ? null
        : l10n.verify_account;

    final content = Container(
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
                if (showAction && action != null) ...[
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
              ],
            ),
          ),
        ],
      ).get6VerticalPadding(),
    );

    if (!showAction || action == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}
