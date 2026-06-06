import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bbh_onboarding_theme.dart';

class BbhStepHeader extends StatelessWidget {
  const BbhStepHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lede,
  });

  final String eyebrow;
  final String title;
  final String? lede;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: BbhOnboardingText.stepEyebrow()),
        const SizedBox(height: 10),
        Text(title, style: BbhOnboardingText.stepTitle()),
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 1,
          color: BbhOnboardingColors.gold,
        ),
        if (lede != null) ...[
          const SizedBox(height: 14),
          Text(lede!, style: BbhOnboardingText.stepLede()),
        ],
      ],
    );
  }
}

class BbhPrimaryButton extends StatelessWidget {
  const BbhPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BbhOnboardingColors.ink,
          foregroundColor: BbhOnboardingColors.cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: BbhOnboardingColors.cream),
              )
            : Text(
                label.toUpperCase(),
                style: BbhOnboardingText.manrope(
                  size: 12,
                  weight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: BbhOnboardingColors.cream,
                ),
              ),
      ),
    );
  }
}

class BbhGoldButton extends StatelessWidget {
  const BbhGoldButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [BbhOnboardingColors.goldLight, BbhOnboardingColors.gold, BbhOnboardingColors.goldDeep],
          ),
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          boxShadow: const [
            BoxShadow(color: Color(0x1A1C2638), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: BbhOnboardingColors.cream,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: BbhOnboardingText.manrope(
              size: 12,
              weight: FontWeight.w700,
              letterSpacing: 1.4,
              color: BbhOnboardingColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}

class BbhGhostButton extends StatelessWidget {
  const BbhGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onDark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark
        ? BbhOnboardingColors.cream.withValues(alpha: 0.78)
        : BbhOnboardingColors.ink;
    final borderColor = onDark
        ? BbhOnboardingColors.cream.withValues(alpha: 0.30)
        : BbhOnboardingColors.rule;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(color: borderColor),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BbhOnboardingRadii.md)),
      ),
      child: Text(
        label,
        style: BbhOnboardingText.manrope(
          size: 13,
          weight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class BbhOnboardingShell extends StatelessWidget {
  const BbhOnboardingShell({
    super.key,
    required this.progress,
    required this.stepLabel,
    required this.body,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
    this.backVisible = true,
    this.nextLoading = false,
    this.nextIsGold = false,
  });

  final double progress;
  final String stepLabel;
  final Widget body;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool backVisible;
  final bool nextLoading;
  final bool nextIsGold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbhOnboardingColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BbhOnboardingColors.cream,
              Color(0xFFF6F0E2),
              Color(0xFFEDE4CF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  _TopBar(progress: progress, stepLabel: stepLabel),
                  Expanded(child: body),
                  Container(
                    decoration: BoxDecoration(
                      color: BbhOnboardingColors.cream.withValues(alpha: 0.95),
                      border: const Border(top: BorderSide(color: BbhOnboardingColors.rule)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        if (backVisible)
                          Expanded(
                            child: BbhGhostButton(label: 'Back', onPressed: onBack),
                          ),
                        if (backVisible) const SizedBox(width: 10),
                        Expanded(
                          flex: backVisible ? 2 : 1,
                          child: nextIsGold
                              ? BbhGoldButton(label: nextLabel, onPressed: nextLoading ? null : onNext)
                              : BbhPrimaryButton(
                                  label: nextLabel,
                                  onPressed: onNext,
                                  loading: nextLoading,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.stepLabel});

  final double progress;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BbhOnboardingColors.cream.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: BbhOnboardingColors.ruleSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/png/app_ic.png'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BBH', style: BbhOnboardingText.display(size: 14, weight: FontWeight.w600)),
                  Text(
                    'DIGITAL ONBOARDING',
                    style: BbhOnboardingText.manrope(size: 9.5, color: BbhOnboardingColors.goldDeep, letterSpacing: 2),
                  ),
                ],
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  text: '$stepLabel ',
                  style: BbhOnboardingText.display(size: 13, weight: FontWeight.w600),
                  children: [
                    TextSpan(
                      text: 'of 13',
                      style: BbhOnboardingText.display(size: 13, color: BbhOnboardingColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 2,
              backgroundColor: BbhOnboardingColors.ruleSoft,
              valueColor: const AlwaysStoppedAnimation(BbhOnboardingColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class BbhTextField extends StatelessWidget {
  const BbhTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.readOnly = false,
    this.locked = false,
    this.verified = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.textDirection,
    this.onTap,
    this.capitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool readOnly;
  final bool locked;
  final bool verified;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextDirection? textDirection;
  final VoidCallback? onTap;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    final disabled = locked || readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
            if (verified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BbhOnboardingColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 12, color: BbhOnboardingColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: BbhOnboardingText.manrope(size: 10, weight: FontWeight.w700, color: BbhOnboardingColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: disabled,
          onTap: disabled ? null : onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textDirection: textDirection,
          textCapitalization: capitalization,
          style: BbhOnboardingText.manrope(size: 15, color: disabled ? BbhOnboardingColors.muted : BbhOnboardingColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: disabled ? BbhOnboardingColors.paperWarm : BbhOnboardingColors.paper,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: locked ? const Icon(Icons.lock_outline, size: 16, color: BbhOnboardingColors.muted) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
              borderSide: BorderSide(
                color: verified ? BbhOnboardingColors.success.withValues(alpha: 0.5) : BbhOnboardingColors.rule,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
              borderSide: BorderSide(
                color: verified ? BbhOnboardingColors.success : BbhOnboardingColors.gold,
                width: 1.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
              borderSide: BorderSide(color: BbhOnboardingColors.ruleSoft),
            ),
          ),
        ),
      ],
    );
  }
}

class BbhToggleGroup extends StatelessWidget {
  const BbhToggleGroup({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.locked = false,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BbhOnboardingColors.creamDeep,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
          ),
          child: Row(
            children: options.map((opt) {
              final active = value == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: locked ? null : () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? BbhOnboardingColors.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm - 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: BbhOnboardingText.manrope(
                        size: 13,
                        weight: FontWeight.w600,
                        color: active ? BbhOnboardingColors.cream : BbhOnboardingColors.muted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class BbhConfirmRow extends StatelessWidget {
  const BbhConfirmRow({
    super.key,
    required this.text,
    required this.checked,
    required this.onChanged,
  });

  final String text;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: checked ? BbhOnboardingColors.paperWarm : BbhOnboardingColors.paper,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            border: Border.all(
              color: checked ? BbhOnboardingColors.gold : BbhOnboardingColors.rule,
              width: checked ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: checked ? BbhOnboardingColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: BbhOnboardingColors.goldDeep),
                ),
                child: checked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text, style: BbhOnboardingText.manrope(size: 13.5, color: BbhOnboardingColors.inkSoft, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BbhDocCaptureRow extends StatelessWidget {
  const BbhDocCaptureRow({
    super.key,
    required this.badge,
    required this.title,
    required this.captured,
    required this.onCapture,
    this.onReplace,
    this.loading = false,
  });

  final String badge;
  final String title;
  final bool captured;
  final VoidCallback? onCapture;
  final VoidCallback? onReplace;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paper,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: captured ? BbhOnboardingColors.success : BbhOnboardingColors.creamDeep,
              shape: BoxShape.circle,
            ),
            child: Text(
              captured ? '✓' : badge,
              style: BbhOnboardingText.manrope(
                size: 12,
                weight: FontWeight.w700,
                color: captured ? Colors.white : BbhOnboardingColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BbhOnboardingText.manrope(
                    size: 13.5,
                    weight: FontWeight.w600,
                    color: BbhOnboardingColors.ink,
                  ),
                ),
                if (captured && onReplace != null)
                  GestureDetector(
                    onTap: onReplace,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Replace document',
                        style: BbhOnboardingText.manrope(
                          size: 11,
                          weight: FontWeight.w600,
                          color: BbhOnboardingColors.muted,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _DocCaptureButton(
            captured: captured,
            loading: loading,
            onPressed: captured ? null : onCapture,
          ),
        ],
      ),
    );
  }
}

class _DocCaptureButton extends StatelessWidget {
  const _DocCaptureButton({
    required this.captured,
    required this.loading,
    required this.onPressed,
  });

  final bool captured;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = captured ? BbhOnboardingColors.success : BbhOnboardingColors.gold;
    final textColor = captured ? BbhOnboardingColors.success : BbhOnboardingColors.goldDeep;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: captured ? BbhOnboardingColors.success.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
            border: Border.all(color: borderColor),
          ),
          child: loading && !captured
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BbhOnboardingColors.goldDeep,
                  ),
                )
              : Text(
                  captured ? 'Captured' : 'Capture',
                  style: BbhOnboardingText.manrope(
                    size: 11,
                    weight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}

class BbhDocSkipLink extends StatelessWidget {
  const BbhDocSkipLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: BbhOnboardingText.manrope(
              size: 12.5,
              color: BbhOnboardingColors.muted,
            ).copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }
}

class BbhDocSkippedRow extends StatelessWidget {
  const BbhDocSkippedRow({
    super.key,
    required this.title,
    required this.note,
    required this.onUndo,
  });

  final String title;
  final String note;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.creamDeep,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: BbhOnboardingColors.muted2, style: BorderStyle.solid),
            ),
            child: Text('—', style: BbhOnboardingText.manrope(size: 12, color: BbhOnboardingColors.muted2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BbhOnboardingText.manrope(size: 13.5, weight: FontWeight.w600, color: BbhOnboardingColors.ink)),
                Text(note, style: BbhOnboardingText.manrope(size: 11.5, color: BbhOnboardingColors.muted, height: 1.4)),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onUndo,
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
                  border: Border.all(color: BbhOnboardingColors.rule),
                ),
                child: Text(
                  'Undo',
                  style: BbhOnboardingText.manrope(size: 11, weight: FontWeight.w600, color: BbhOnboardingColors.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BbhCallout extends StatelessWidget {
  const BbhCallout({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paperWarm,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Text(text, style: BbhOnboardingText.manrope(size: 13.5, color: BbhOnboardingColors.inkSoft, height: 1.55)),
    );
  }
}

class BbhPreflightNote extends StatelessWidget {
  const BbhPreflightNote({super.key, required this.lead, required this.body});

  final String lead;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paperWarm,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
        border: const Border(
          left: BorderSide(color: BbhOnboardingColors.gold, width: 3),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: BbhOnboardingText.manrope(size: 13, color: BbhOnboardingColors.inkSoft, height: 1.6),
          children: [
            TextSpan(
              text: '$lead ',
              style: BbhOnboardingText.display(size: 13, weight: FontWeight.w600, color: BbhOnboardingColors.ink),
            ),
            TextSpan(text: body),
          ],
        ),
      ),
    );
  }
}

class BbhInfoBanner extends StatelessWidget {
  const BbhInfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paperWarm,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text('⤿', style: BbhOnboardingText.display(size: 20, color: BbhOnboardingColors.gold)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: BbhOnboardingText.manrope(size: 13, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class BbhClauseItem extends StatelessWidget {
  const BbhClauseItem({super.key, required this.number, required this.bold, required this.body});

  final String number;
  final String bold;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: BbhOnboardingText.manrope(size: 13, weight: FontWeight.w700, color: BbhOnboardingColors.goldDeep)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: BbhOnboardingText.manrope(size: 14.5, color: BbhOnboardingColors.inkSoft, height: 1.6),
                children: [
                  TextSpan(text: bold, style: const TextStyle(fontWeight: FontWeight.w700, color: BbhOnboardingColors.ink)),
                  TextSpan(text: ' $body'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
