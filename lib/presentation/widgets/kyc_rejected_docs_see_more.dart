import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_home_navigation.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const double _kycWarningCardGap = 8;

Widget _withKycWarningCardSpacing(Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: _kycWarningCardGap),
    child: child,
  );
}

class _KycDocumentStatusStyle {
  const _KycDocumentStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
}

class _KycProfileStatusRows extends StatelessWidget {
  const _KycProfileStatusRows({
    required this.payload,
    this.onAgreementSigned,
  });

  final Payload payload;
  final Future<void> Function()? onAgreementSigned;

  static const _verifiedColor = Color(0xff4CAF50);
  static const _pendingColor = Color(0xFFBBA473);
  static const _rejectedColor = Color(0xffE04c4E);

  String _itemLabel(KycProfileStatusItemType item, AppLocalizations l10n) =>
      KycHomeNavigation.profileStatusItemLabel(item, l10n);

  _KycDocumentStatusStyle _statusStyle(
    ProfileVerificationStatus status,
    AppLocalizations l10n,
  ) {
    return switch (status) {
      ProfileVerificationStatus.verified => _KycDocumentStatusStyle(
        label: l10n.kyc_status_verified,
        backgroundColor: _verifiedColor.withValues(alpha: 0.14),
        textColor: _verifiedColor,
        borderColor: _verifiedColor.withValues(alpha: 0.45),
      ),
      ProfileVerificationStatus.reviewing => _KycDocumentStatusStyle(
        label: l10n.kyc_status_reviewing,
        backgroundColor: _pendingColor.withValues(alpha: 0.14),
        textColor: _pendingColor,
        borderColor: _pendingColor.withValues(alpha: 0.45),
      ),
      ProfileVerificationStatus.rejected => _KycDocumentStatusStyle(
        label: l10n.rejected,
        backgroundColor: _rejectedColor.withValues(alpha: 0.14),
        textColor: _rejectedColor,
        borderColor: _rejectedColor.withValues(alpha: 0.45),
      ),
      _ => _KycDocumentStatusStyle(
        label: l10n.pending,
        backgroundColor: _pendingColor.withValues(alpha: 0.14),
        textColor: _pendingColor,
        borderColor: _pendingColor.withValues(alpha: 0.45),
      ),
    };
  }

  Widget _buildRow({
    required BuildContext context,
    required KycProfileStatusItemType item,
    required _KycDocumentStatusStyle style,
    required bool canTap,
    required bool showDivider,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isPhone = sizes?.isPhone ?? true;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GetGenericText(
              text: _itemLabel(item, l10n),
              fontSize: isPhone ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
              isInter: true,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.borderColor, width: 1),
            ),
            child: GetGenericText(
              text: style.label,
              fontSize: isPhone ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: style.textColor,
              isInter: true,
            ),
          ),
          if (canTap) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: isPhone ? 18 : 20,
              color: AppColors.primaryGold500,
            ),
          ],
        ],
      ),
    );

    final content = showDivider
        ? Column(
            children: [
              row,
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.whiteColor.withValues(alpha: 0.12),
              ),
            ],
          )
        : row;

    if (!canTap) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => KycHomeNavigation.onProfileStatusItemTap(
          context,
          payload,
          item,
          onAgreementSigned: onAgreementSigned,
        ),
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPhone = sizes?.isPhone ?? true;
    final items = KycHomeNavigation.allProfileStatusItemsForPanel(payload);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.whiteColor.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 8),
        GetGenericText(
          text: l10n.kyc_documents_status_title,
          fontSize: isPhone ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
          isInter: true,
        ),
        const SizedBox(height: 4),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final status =
              KycHomeNavigation.profileStatusItemStatus(payload, item) ??
              ProfileVerificationStatus.pending;
          final style = _statusStyle(status, l10n);
          final canTap = KycHomeNavigation.canNavigateToProfileStatusItem(
            payload,
            item,
          );

          return _buildRow(
            context: context,
            item: item,
            style: style,
            canTap: canTap,
            showDivider: index < items.length - 1,
          );
        }),
      ],
    );
  }
}

/// Home UI while profile verification is Reviewing, Pending, or Rejected.
///
/// Single expandable [AccountWarning]-style box: profile message on top, **See all**
/// expands document and agreement statuses inside the same bordered card.
class KycProfileVerificationSeeMore extends StatefulWidget {
  const KycProfileVerificationSeeMore({
    required this.payload,
    this.onAgreementSigned,
    super.key,
  });

  final Payload payload;
  final Future<void> Function()? onAgreementSigned;

  @override
  State<KycProfileVerificationSeeMore> createState() =>
      _KycProfileVerificationSeeMoreState();
}

class _KycProfileVerificationSeeMoreState
    extends State<KycProfileVerificationSeeMore> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPhone = sizes?.isPhone ?? true;
    final items = KycHomeNavigation.allProfileStatusItemsForPanel(
      widget.payload,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    final showProfileAction = KycHomeNavigation.showProfileWarningAction(
      widget.payload,
    );
    final borderColor = KycHomeNavigation.profileWarningBorderColor(
      widget.payload,
    );
    final warningMessage = KycHomeNavigation.profileWarningMessage(
      widget.payload,
      l10n,
    );

    return _withKycWarningCardSpacing(
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/svg/alert_icon.svg'),
                  ConstPadding.sizeBoxWithWidth(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GetGenericText(
                          text: warningMessage,
                          fontSize: isPhone ? 12 : 16,
                          fontWeight:
                              isPhone ? FontWeight.w400 : FontWeight.w600,
                          color: AppColors.whiteColor,
                          isInter: true,
                        ),
                        if (showProfileAction) ...[
                          ConstPadding.sizeBoxWithHeight(height: 4),
                          GestureDetector(
                            onTap: () =>
                                KycHomeNavigation.openProfileWarningAction(
                              context,
                              widget.payload,
                            ),
                            child: GetGenericText(
                              text: l10n.kyc_complete_verification,
                              fontSize: isPhone ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold500,
                              isInter: true,
                              isUnderline: true,
                            ),
                          ),
                        ],
                        if (_expanded)
                          _KycProfileStatusRows(
                            payload: widget.payload,
                            onAgreementSigned: widget.onAgreementSigned,
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _expanded = !_expanded),
                            child: GetGenericText(
                              text: _expanded ? l10n.see_less : l10n.see_all,
                              fontSize: isPhone ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBBA473),
                              isInter: true,
                              isUnderline: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
