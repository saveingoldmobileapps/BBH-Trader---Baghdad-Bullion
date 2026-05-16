import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'funding_portal_theme.dart';
import 'funding_portal_typography.dart';

class FundingPortalAppHeader extends StatelessWidget {
  const FundingPortalAppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack)
            Material(
              color: const Color(0x1AB8944C),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: SvgPicture.string(
                      '<svg viewBox="0 0 24 24" fill="none" stroke="#1F1A14" stroke-width="2.5"><polyline points="15 18 9 12 15 6"/></svg>',
                      width: 14,
                      height: 14,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                style: FundingPortalTypography.headerTitle,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class FundingPortalWalletCard extends StatelessWidget {
  const FundingPortalWalletCard({
    super.key,
    required this.balanceIqd,
    required this.customerId,
    this.goldGrams = 0,
  });

  final num balanceIqd;
  final String customerId;
  final num goldGrams;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,###', 'en_US').format(balanceIqd);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FundingPortalColors.walletGradientStart,
            FundingPortalColors.walletGradientEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: RadialGradient(
                  center: const Alignment(0.8, -0.2),
                  radius: 1.2,
                  colors: [
                    FundingPortalColors.gold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL BALANCE',
                style: FundingPortalTypography.manrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: FundingPortalColors.gold,
                  letterSpacing: 2.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatted,
                        style: FundingPortalTypography.cormorant(
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          color: FundingPortalColors.cream,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'IQD',
                      style: FundingPortalTypography.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: FundingPortalColors.goldSoft,
                        letterSpacing: 1.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(height: 1, color: FundingPortalColors.line),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _meta('Gold', '${goldGrams.toStringAsFixed(3)} g'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _meta('Customer ID', customerId, alignEnd: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(String key, String val, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          key.toUpperCase(),
          style: FundingPortalTypography.manrope(
            fontSize: 9,
            color: FundingPortalColors.cream.withValues(alpha: 0.5),
            letterSpacing: 1.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          val,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: FundingPortalTypography.mono(
            fontSize: 11,
            color: FundingPortalColors.cream,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class FundingPortalLinkPrompt extends StatelessWidget {
  const FundingPortalLinkPrompt({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static const _titleFontSize = 14.0;
  static const _titleLineHeight = 1.55;
  static const _bodyFontSize = 12.5;
  static const _bodyLineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    final titleStyle = FundingPortalTypography.manrope(
      fontSize: _titleFontSize,
      fontWeight: FontWeight.w600,
      color: FundingPortalColors.ink,
      height: _titleLineHeight,
    );
    final bodyStyle = FundingPortalTypography.manrope(
      fontSize: _bodyFontSize,
      color: FundingPortalColors.muted,
      height: _bodyLineHeight,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0x14B8944C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FundingPortalColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: FundingPortalColors.gold,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '+',
                style: FundingPortalTypography.cormorant(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FundingPortalColors.walletGradientStart,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: titleStyle,
                  strutStyle: StrutStyle(
                    fontSize: _titleFontSize,
                    height: _titleLineHeight,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  softWrap: true,
                  style: bodyStyle,
                  strutStyle: StrutStyle(
                    fontSize: _bodyFontSize,
                    height: _bodyLineHeight,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
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

class FundingPortalLinkedAccountChip extends StatelessWidget {
  const FundingPortalLinkedAccountChip({super.key, required this.masked});

  final String masked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FundingPortalColors.cream2, FundingPortalColors.cream3],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FundingPortalColors.lineStrong, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FundingPortalColors.walletGradientStart,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'TIB',
              style: FundingPortalTypography.cormorant(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FundingPortalColors.gold,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LINKED ACCOUNT',
                  style: FundingPortalTypography.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: FundingPortalColors.muted,
                    letterSpacing: 1.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  masked,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: FundingPortalTypography.mono(fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: FundingPortalColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ACTIVE',
                  style: FundingPortalTypography.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: FundingPortalColors.green,
                    letterSpacing: 1.5,
                    height: 1.5,
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

class FundingPortalPrimaryButton extends StatelessWidget {
  const FundingPortalPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FundingPortalColors.gold,
                      FundingPortalColors.goldDeep,
                    ],
                  )
                : null,
            color: enabled ? null : FundingPortalColors.gold.withValues(alpha: 0.35),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: FundingPortalColors.gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: FundingPortalTypography.btnPrimary,
          ),
        ),
      ),
    );
  }
}

class FundingPortalSecondaryButton extends StatelessWidget {
  const FundingPortalSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FundingPortalColors.goldDeep),
            color: Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: FundingPortalTypography.btnSecondary,
          ),
        ),
      ),
    );
  }
}

class FundingPortalTertiaryButton extends StatelessWidget {
  const FundingPortalTertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: FundingPortalColors.muted,
      ),
      child: Text(label, style: FundingPortalTypography.btnTertiary),
    );
  }
}

class FundingPortalMethodCard extends StatelessWidget {
  const FundingPortalMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.selected = false,
    this.badge,
    this.onTap,
  });

  final String icon;
  final String title;
  final String description;
  final bool selected;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected
            ? const Color(0x14B8944C)
            : const Color(0x66FFFFFF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? FundingPortalColors.gold
                    : FundingPortalColors.lineStrong,
                width: selected ? 1.5 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FundingPortalColors.cream2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          color: FundingPortalColors.goldDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        softWrap: true,
                        style: FundingPortalTypography.cormorant(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: FundingPortalColors.gold,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            badge!.toUpperCase(),
                            style: FundingPortalTypography.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: FundingPortalColors.cream,
                              letterSpacing: 1,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  softWrap: true,
                  style: FundingPortalTypography.manrope(
                    fontSize: 11,
                    color: FundingPortalColors.muted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FundingPortalReviewRow {
  const FundingPortalReviewRow(
    this.keyLabel,
    this.value, {
    this.highlight = false,
    this.crucial = false,
  });

  final String keyLabel;
  final String value;
  final bool highlight;
  final bool crucial;
}

class FundingPortalReviewCard extends StatelessWidget {
  const FundingPortalReviewCard({super.key, required this.rows});

  final List<FundingPortalReviewRow> rows;

  static TextStyle _valueStyle(FundingPortalReviewRow row) {
    if (row.highlight) {
      return FundingPortalTypography.cormorant(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
    }
    final key = row.keyLabel.toLowerCase();
    if (key.contains('iban') ||
        key.contains('account') ||
        key.contains('reference') ||
        key.contains('transfer')) {
      return FundingPortalTypography.mono(fontSize: 12, height: 1.35);
    }
    return FundingPortalTypography.manrope(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x80FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FundingPortalColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    rows[i].keyLabel.toUpperCase(),
                    softWrap: true,
                    style: FundingPortalTypography.manrope(
                      fontSize: rows[i].crucial ? 10 : 11,
                      fontWeight:
                          rows[i].crucial ? FontWeight.w600 : FontWeight.w500,
                      color: FundingPortalColors.muted,
                      letterSpacing: rows[i].crucial ? 1.2 : 1,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: rows[i].crucial
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: FundingPortalColors.gold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              rows[i].value,
                              softWrap: true,
                              style: FundingPortalTypography.mono(
                                fontSize: 12,
                                color: FundingPortalColors.cream,
                                height: 1.4,
                              ),
                            ),
                          )
                        : Text(
                            rows[i].value,
                            softWrap: true,
                            style: _valueStyle(rows[i]),
                          ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: FundingPortalColors.line,
              ),
          ],
        ],
      ),
    );
  }
}

class FundingPortalReadOnlyField extends StatelessWidget {
  const FundingPortalReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return FundingPortalFormField(
      label: label,
      hint: hint,
      child: Text(
        value,
        softWrap: true,
        style: FundingPortalTypography.mono(fontSize: 13, height: 1.35),
      ),
    );
  }
}

/// Editable field matching prototype input styling.
class FundingPortalTextField extends StatelessWidget {
  const FundingPortalTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  static const _inputFontSize = 13.0;
  static const _inputLineHeight = 1.4;

  @override
  Widget build(BuildContext context) {
    final inputStyle = FundingPortalTypography.mono(
      fontSize: _inputFontSize,
      height: _inputLineHeight,
      color: FundingPortalColors.ink,
    );

    return FundingPortalFormField(
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: inputStyle,
        strutStyle: StrutStyle(
          fontSize: _inputFontSize,
          height: _inputLineHeight,
          forceStrutHeight: true,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Shared label + box + optional hint for form fields.
class FundingPortalFormField extends StatelessWidget {
  const FundingPortalFormField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final String? hint;

  static const _labelFontSize = 9.5;
  static const _labelLineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    final labelStyle = FundingPortalTypography.fieldLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: labelStyle,
            strutStyle: const StrutStyle(
              fontSize: _labelFontSize,
              height: _labelLineHeight,
              forceStrutHeight: true,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x80FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FundingPortalColors.lineStrong),
            ),
            child: child,
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint!,
              softWrap: true,
              style: FundingPortalTypography.manrope(
                fontSize: 10.5,
                color: FundingPortalColors.muted,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FundingPortalAmountField extends StatelessWidget {
  const FundingPortalAmountField({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AMOUNT IN IQD', style: FundingPortalTypography.fieldLabel),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x80FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FundingPortalColors.lineStrong),
          ),
          child: Text(
            value,
            style: FundingPortalTypography.cormorant(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Min 10,000 IQD · Max 5,000,000 IQD per transaction',
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.manrope(
            fontSize: 10.5,
            color: FundingPortalColors.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class FundingPortalLoadingView extends StatelessWidget {
  const FundingPortalLoadingView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: FundingPortalColors.gold,
            backgroundColor: Color(0x26B8944C),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.cormorant(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            softWrap: true,
            style: FundingPortalTypography.bodyMuted.copyWith(fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}

class FundingPortalSuccessView extends StatelessWidget {
  const FundingPortalSuccessView({
    super.key,
    this.amount,
    required this.title,
    this.subtitle,
    this.child,
    this.compactTitle = false,
  });

  final String? amount;
  final String title;
  final String? subtitle;
  final Widget? child;
  final bool compactTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: FundingPortalColors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(38, 38),
              painter: _CheckPainter(),
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (amount != null) ...[
          Text(
            amount!,
            textAlign: TextAlign.center,
            style: FundingPortalTypography.cormorant(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: FundingPortalColors.goldDeep,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          softWrap: true,
          style: compactTitle
              ? FundingPortalTypography.cormorant(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FundingPortalColors.muted,
                  height: 1.25,
                )
              : FundingPortalTypography.cormorant(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              softWrap: true,
              style: FundingPortalTypography.manrope(
                fontSize: 13,
                color: FundingPortalColors.muted,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (child != null) ...[
          const SizedBox(height: 18),
          child!,
        ],
      ],
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.85, size.height * 0.25)
      ..lineTo(size.width * 0.38, size.height * 0.72)
      ..lineTo(size.width * 0.15, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FundingPortalOtpGrid extends StatefulWidget {
  const FundingPortalOtpGrid({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  State<FundingPortalOtpGrid> createState() => _FundingPortalOtpGridState();
}

class _FundingPortalOtpGridState extends State<FundingPortalOtpGrid> {
  static const _demoCode = ['1', '2', '3', '4', '5', '6'];
  int _filled = 0;

  @override
  void initState() {
    super.initState();
    _animateFill();
  }

  Future<void> _animateFill() async {
    for (var i = 0; i < _demoCode.length; i++) {
      await Future<void>.delayed(Duration(milliseconds: 200 + i * 180));
      if (!mounted) return;
      setState(() => _filled = i + 1);
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        final filled = i < _filled;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == 5 ? 0 : 4),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: filled
                      ? FundingPortalColors.gold
                      : const Color(0x80FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: filled
                        ? FundingPortalColors.gold
                        : FundingPortalColors.lineStrong,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    filled ? _demoCode[i] : '',
                    style: FundingPortalTypography.cormorant(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: filled
                          ? FundingPortalColors.cream
                          : FundingPortalColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class FundingPortalWireWarning extends StatelessWidget {
  const FundingPortalWireWarning({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: const Color(0x14C75A4F),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: FundingPortalColors.red, width: 3),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: FundingPortalTypography.manrope(
            fontSize: 11.5,
            color: FundingPortalColors.ink2,
            height: 1.5,
          ),
          children: [
            const TextSpan(
              text: 'Important',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: FundingPortalColors.red,
              ),
            ),
            const TextSpan(
              text:
                  ' · Always include your Customer ID ',
            ),
            TextSpan(
              text: customerId,
              style: FundingPortalTypography.mono(
                fontSize: 11.5,
                color: FundingPortalColors.ink2,
                height: 1.5,
              ).copyWith(backgroundColor: const Color(0x26B8944C)),
            ),
            const TextSpan(
              text:
                  ' in the wire reference. Without it, the deposit is unattributed and arrives in a separate exception queue.',
            ),
          ],
        ),
      ),
    );
  }
}

class FundingPortalWaitingPulse extends StatelessWidget {
  const FundingPortalWaitingPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulseRing(delay: Duration.zero),
          _PulseRing(delay: Duration(seconds: 1)),
          DecoratedBox(
            decoration: BoxDecoration(
              color: FundingPortalColors.gold,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 20, height: 20),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.delay});

  final Duration delay;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Transform.scale(
          scale: 1 + t,
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: FundingPortalColors.gold, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FundingPortalFootnote extends StatelessWidget {
  const FundingPortalFootnote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
        style: FundingPortalTypography.manrope(
          fontSize: 11,
          color: FundingPortalColors.muted,
          height: 1.55,
        ),
      ),
    );
  }
}
