import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_home_navigation.dart';
import 'package:baghdad_bullion_house/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/widgets/account_warning.dart';
import 'package:flutter/material.dart';

const double _kycWarningCardGap = 8;

Widget _withKycWarningCardSpacing(Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: _kycWarningCardGap),
    child: child,
  );
}

class _KycSeeMoreToggle extends StatelessWidget {
  const _KycSeeMoreToggle({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPhone = sizes?.isPhone ?? true;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onToggle,
        child: GetGenericText(
          text: expanded ? l10n.see_less : l10n.see_all,
          fontSize: isPhone ? 14 : 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFBBA473),
          isUnderline: true,
        ),
      ),
    );
  }
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

class KycProfileVerificationStatusPanel extends StatelessWidget {
  const KycProfileVerificationStatusPanel({
    required this.payload,
    this.onAgreementSigned,
    super.key,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: style.borderColor,
                width: 1,
              ),
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBBA473).withValues(alpha: 0.35),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF75540E).withValues(alpha: 0.22),
            const Color(0xFFB19454).withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xff75540e).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  left: BorderSide(
                    color: const Color(0xff75540e).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xff75540e).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  right: BorderSide(
                    color: const Color(0xff75540e).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: isPhone ? 18 : 20,
                      color: AppColors.primaryGold500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GetGenericText(
                        text: l10n.kyc_documents_status_title,
                        fontSize: isPhone ? 13 : 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                        isInter: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final status =
                      KycHomeNavigation.profileStatusItemStatus(
                        payload,
                        item,
                      ) ??
                      ProfileVerificationStatus.pending;
                  final style = _statusStyle(status, l10n);
                  final canTap =
                      KycHomeNavigation.canNavigateToProfileStatusItem(
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Home UI while profile verification is Reviewing, Pending, or Rejected.
///
/// Shows a profile-level message, then **See all** to expand a single status
/// panel for documents and agreement. Rejected documents can be retaken
/// individually; when all three are rejected, any document row tap starts full
/// native onboarding. Unsigned agreement rows open the agreement screen.
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
    final items = KycHomeNavigation.allProfileStatusItemsForPanel(
      widget.payload,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    final showProfileAction = KycHomeNavigation.showProfileWarningAction(
      widget.payload,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _withKycWarningCardSpacing(
          AccountWarning(
            kycStatus: 'profile',
            warningMessage: KycHomeNavigation.profileWarningMessage(
              widget.payload,
              l10n,
            ),
            actionText: showProfileAction
                ? l10n.kyc_complete_verification
                : null,
            showAction: showProfileAction,
            borderColor: KycHomeNavigation.profileWarningBorderColor(
              widget.payload,
            ),
            onTap: () => KycHomeNavigation.openProfileWarningAction(
              context,
              widget.payload,
            ),
          ),
        ),
        if (!_expanded)
          _KycSeeMoreToggle(
            expanded: false,
            onToggle: () => setState(() => _expanded = true),
          ),
        if (_expanded) ...[
          _withKycWarningCardSpacing(
            KycProfileVerificationStatusPanel(
              payload: widget.payload,
              onAgreementSigned: widget.onAgreementSigned,
            ),
          ),
          _KycSeeMoreToggle(
            expanded: true,
            onToggle: () => setState(() => _expanded = false),
          ),
        ],
      ],
    );
  }
}
