import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baghdad_bullion_house/core/theme/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bbh_onboarding_field_scroll.dart';
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
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 1,
          color: BbhOnboardingColors.gold,
        ),
        if (lede != null) ...[
          const SizedBox(height: 22),
          Text(lede!, style: BbhOnboardingText.stepLede()),
          const SizedBox(height: 26),
        ] else
          const SizedBox(height: 22),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          boxShadow: const [
            BoxShadow(color: Color(0x331C2638), blurRadius: 14, offset: Offset(0, 4)),
            BoxShadow(color: Color(0x14FFFFFF), blurRadius: 0, offset: Offset(0, 1)),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: BbhOnboardingColors.ink,
            foregroundColor: BbhOnboardingColors.cream,
            disabledBackgroundColor: BbhOnboardingColors.muted2,
            disabledForegroundColor: BbhOnboardingColors.paper,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                    size: 14,
                    weight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: BbhOnboardingColors.cream,
                  ),
                ),
        ),
      ),
    );
  }
}

// class BbhGoldButton extends StatelessWidget {
//   const BbhGoldButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//     this.forCover = false,
//   });

//   final String label;
//   final VoidCallback? onPressed;
//   final bool forCover;

//   @override
//   Widget build(BuildContext context) {
//     final gradient = forCover
//         ? const LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [Color(0xFFBB912F), Color(0xFFB19E5C), Color(0xFFCFC78C), Color(0xFFAA8A2A)],
//   )
//         // LinearGradient(
//         //     begin: Alignment.topCenter,
//         //     end: Alignment.bottomCenter,
//         //     colors: [Color(0xFFD4AF64), Color(0xFFB8924A)],
//         //   )
//         : const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [BbhOnboardingColors.gold, BbhOnboardingColors.goldDeep],
//           );
//     final textColor = forCover ? const Color(0xFF0B1426) : BbhOnboardingColors.cream;
//     final shadows = forCover
//         ? const [
//             BoxShadow(color: Color(0x59D4AF64), blurRadius: 24, offset: Offset(0, 8)),
//             BoxShadow(color: Color(0x4D000000), blurRadius: 4, offset: Offset(0, 2)),
//           ]
//         : const [BoxShadow(color: Color(0x4D8D6C2F), blurRadius: 14, offset: Offset(0, 4))];

//     return SizedBox(
//       width: double.infinity,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
//           border: forCover ? Border.all(color: const Color(0x99D4AF64)) : null,
//           boxShadow: shadows,
//         ),
//         child: ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             foregroundColor: textColor,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
//             ),
//           ),
//           child: Text(
//             label.toUpperCase(),
//             style: BbhOnboardingText.manrope(
//               size: forCover ? 14 : 12,
//               weight: FontWeight.w600,
//               letterSpacing: forCover ? 1.1 : 1.4,
//               color: textColor,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class BbhGoldButton extends StatelessWidget {
  const BbhGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.forCover = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool forCover;

  @override
  Widget build(BuildContext context) {
    // ✅ Use VERTICAL gradient for buttons (top to bottom)
    // This matches the gold gradient in your first image
    final gradient = AppColors.brandGoldGradient; // Vertical gradient
    
    // For cover, you might want diagonal
    // final gradient = forCover 
    //     ? AppColors.brandGoldGradient 
    //     : AppColors.brandGoldGradientDiagonal;

    final textColor = forCover 
        ? const Color(0xFF0B1426) 
        : AppColors.whiteColor;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: forCover ? Border.all(color: const Color(0x99D4AF64)) : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: forCover ? 14 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: forCover ? 1.1 : 1.4,
              color: textColor,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    );
  }
}class BbhGhostButton extends StatelessWidget {
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

    return SizedBox(
      
      width: double.infinity,
      child: OutlinedButton(
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
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: BbhOnboardingColors.cream,
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -1.0),
                  radius: 1.1,
                  colors: [
                    BbhOnboardingColors.gold.withValues(alpha: 0.08),
                    BbhOnboardingColors.cream.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, 1.2),
                  radius: 1.0,
                  colors: [
                    BbhOnboardingColors.gold.withValues(alpha: 0.06),
                    BbhOnboardingColors.cream.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    _TopBar(progress: progress),
                    Expanded(child: body),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: BbhOnboardingColors.cream.withValues(alpha: 0.92),
            border: const Border(bottom: BorderSide(color: BbhOnboardingColors.ruleSoft)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/png/app_ic.png', width: 32, height: 32),
                  const SizedBox(width: 10),
                  Text(
                    'BBH',
                    style: BbhOnboardingText.display(
                      size: 14,
                      weight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: BbhOnboardingColors.ruleSoft),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0, 1),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                BbhOnboardingColors.goldDeep,
                                BbhOnboardingColors.gold,
                                BbhOnboardingColors.goldLight,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BbhTextField extends StatelessWidget {
  const BbhTextField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldKey,
    this.hint,
    this.readOnly = false,
    this.locked = false,
    this.verified = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.textDirection,
    this.onTap,
    this.onChanged,
    this.capitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? fieldKey;
  final String? hint;
  final bool readOnly;
  final bool locked;
  final bool verified;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextDirection? textDirection;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    final disableInput = locked;
    final isDatePicker = onTap != null && !locked;
    final effectiveHint = hint ?? (isDatePicker ? 'Tap to select date' : null);

    final fillColor = verified
        ? const Color(0x0F4A6741)
        : (disableInput ? BbhOnboardingColors.paperWarm : BbhOnboardingColors.paper);
    final showError = BbhOnboardingFieldScroll.isError(fieldKey);
    final borderColor = showError
        ? BbhOnboardingColors.error
        : verified
            ? BbhOnboardingColors.success.withValues(alpha: 0.55)
            : BbhOnboardingColors.rule;

    Widget field = TextField(
      controller: controller,
      readOnly: disableInput || readOnly || isDatePicker,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textDirection: textDirection,
      textCapitalization: capitalization,
      onChanged: (value) {
        if (showError) BbhOnboardingFieldScroll.clearError();
        onChanged?.call(value);
      },
      style: textDirection == TextDirection.rtl
          ? BbhOnboardingText.arabic(
              size: 17,
              color: disableInput ? BbhOnboardingColors.muted : BbhOnboardingColors.ink,
            )
          : BbhOnboardingText.manrope(
              size: 15,
              color: disableInput ? BbhOnboardingColors.muted : BbhOnboardingColors.ink,
            ),
      decoration: InputDecoration(
        hintText: effectiveHint,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: locked
            ? const Icon(Icons.lock_outline, size: 16, color: BbhOnboardingColors.muted)
            : (isDatePicker
                ? Icon(Icons.calendar_today_outlined, size: 18, color: BbhOnboardingColors.muted)
                : null),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          borderSide: BorderSide(
            color: verified ? BbhOnboardingColors.success : BbhOnboardingColors.gold,
            width: 1.2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
          borderSide: BorderSide(color: BbhOnboardingColors.ruleSoft),
        ),
      ),
    );

    if (isDatePicker) {
      field = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        child: IgnorePointer(child: field),
      );
    }

    final content = Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
    if (fieldKey == null) return content;
    return BbhOnboardingFieldScroll.anchor(fieldKey!, content);
  }
}

class BbhToggleGroup extends StatelessWidget {
  const BbhToggleGroup({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.fieldKey,
    this.locked = false,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? fieldKey;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final showError = BbhOnboardingFieldScroll.isError(fieldKey);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BbhOnboardingColors.creamDeep,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            border: Border.all(
              color: showError ? BbhOnboardingColors.error : BbhOnboardingColors.rule,
              width: showError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: options.map((opt) {
              final active = value == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: locked
                      ? null
                      : () {
                          if (showError) BbhOnboardingFieldScroll.clearError();
                          onChanged(opt);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? BbhOnboardingColors.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: active
                          ? const [BoxShadow(color: Color(0x331C2638), blurRadius: 8, offset: Offset(0, 2))]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: BbhOnboardingText.manrope(
                        size: 14,
                        weight: FontWeight.w600,
                        letterSpacing: 0.7,
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
    if (fieldKey == null) return content;
    return BbhOnboardingFieldScroll.anchor(fieldKey!, content);
  }
}

class BbhConfirmRow extends StatelessWidget {
  const BbhConfirmRow({
    super.key,
    required this.text,
    required this.checked,
    required this.onChanged,
    this.fieldKey,
  });

  final String text;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String? fieldKey;

  @override
  Widget build(BuildContext context) {
    final showError = BbhOnboardingFieldScroll.isError(fieldKey);
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (showError) BbhOnboardingFieldScroll.clearError();
          onChanged(!checked);
        },
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: checked ? BbhOnboardingColors.paperWarm : BbhOnboardingColors.paper,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            border: Border.all(
              color: showError
                  ? BbhOnboardingColors.error
                  : checked
                      ? BbhOnboardingColors.gold
                      : BbhOnboardingColors.rule,
              width: showError || checked ? 1.5 : 1,
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
                  color: checked ? BbhOnboardingColors.ink : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: checked ? BbhOnboardingColors.ink : BbhOnboardingColors.rule, width: 1.5),
                ),
                alignment: Alignment.center,
                child: checked
                    ? const Text('✓', style: TextStyle(color: BbhOnboardingColors.cream, fontSize: 14, fontWeight: FontWeight.w700))
                    : null,
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
    if (fieldKey == null) return content;
    return BbhOnboardingFieldScroll.anchor(fieldKey!, content);
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
              ],
            ),
          ),
          _DocCaptureButton(
            captured: captured,
            loading: loading,
            onPressed: captured ? onReplace : onCapture,
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
    final borderColor = BbhOnboardingColors.gold;
    final textColor = BbhOnboardingColors.goldDeep;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: captured ? BbhOnboardingColors.gold : Colors.transparent,
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
                  captured ? 'RETAKE' : 'CAPTURE',
                  style: BbhOnboardingText.manrope(
                    size: 11,
                    weight: FontWeight.w600,
                    color: captured ? Colors.white : textColor,
                    letterSpacing: 0.88,
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
  const BbhCallout({super.key, required this.text, this.title});

  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 1),
      //margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paperWarm,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: BbhOnboardingColors.gold, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: BbhOnboardingText.manrope(size: 13.5, color: BbhOnboardingColors.inkSoft, height: 1.6)),
                //style: BbhOnboardingText.display(size: 16, weight: FontWeight.w600)
                const SizedBox(height: 6),
              ],
              Text(text, style: BbhOnboardingText.display(size: 16, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BbhOnboardingColors.gold.withValues(alpha: 0.12),
            BbhOnboardingColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: BbhOnboardingColors.gold,
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: 1.5708,
              child: Text('⤿', style: BbhOnboardingText.display(size: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: BbhOnboardingText.manrope(size: 13, weight: FontWeight.w600, color: BbhOnboardingColors.goldDeep),
            ),
          ),
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
          Text(number, style: BbhOnboardingText.display(size: 13, weight: FontWeight.w600, color: BbhOnboardingColors.goldDeep).copyWith(fontStyle: FontStyle.italic)),
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

class BbhSignaturePad extends StatefulWidget {
  const BbhSignaturePad({
    super.key,
    required this.onSignatureChanged,
    this.hasSignature = false,
    this.padHeight = 120,
    this.inModal = false,
  });

  final ValueChanged<String?> onSignatureChanged;
  final bool hasSignature;
  final double padHeight;

  /// When true, skip parent scroll-hold (used inside a fixed dialog popup).
  final bool inModal;

  @override
  State<BbhSignaturePad> createState() => _BbhSignaturePadState();
}

class _BbhSignaturePadState extends State<BbhSignaturePad> {
  static const _strokeColor = Color(0xFF1C2638);

  double get _padHeight => widget.padHeight;

  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
  bool _drawn = false;
  ScrollHoldController? _scrollHold;

  void _holdParentScroll() {
    if (widget.inModal) return;
    _scrollHold?.cancel();
    final scrollable = Scrollable.maybeOf(context);
    _scrollHold = scrollable?.position.hold(() {
      _scrollHold = null;
    });
  }

  void _releaseParentScroll() {
    if (widget.inModal) return;
    _scrollHold?.cancel();
    _scrollHold = null;
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _drawn = false;
    });
    widget.onSignatureChanged(null);
  }

  Future<void> _exportSignature(double width) async {
    if (!_drawn || _strokes.isEmpty) {
      widget.onSignatureChanged(null);
      return;
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(dpr, dpr);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, _padHeight),
      Paint()..color = BbhOnboardingColors.paper,
    );

    final paint = Paint()
      ..color = _strokeColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * dpr).round(),
      (_padHeight * dpr).round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null || !mounted) return;

    final encoded = base64Encode(bytes.buffer.asUint8List());
    widget.onSignatureChanged('data:image/png;base64,$encoded');
  }

  @override
  void dispose() {
    _releaseParentScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captured = widget.hasSignature;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Container(
              height: _padHeight,
              decoration: BoxDecoration(
                color: BbhOnboardingColors.paper,
                borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
                border: Border.all(color: BbhOnboardingColors.rule, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BbhOnboardingRadii.md - 1),
                child: Stack(
                  children: [
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        _holdParentScroll();
                        setState(() {
                          _currentStroke = [event.localPosition];
                          _drawn = true;
                        });
                      },
                      onPointerMove: (event) {
                        if (_currentStroke == null) return;
                        setState(() => _currentStroke!.add(event.localPosition));
                      },
                      onPointerUp: (_) async {
                        _releaseParentScroll();
                        if (_currentStroke != null) {
                          setState(() {
                            _strokes.add(List<Offset>.from(_currentStroke!));
                            _currentStroke = null;
                          });
                        }
                        await _exportSignature(width);
                      },
                      onPointerCancel: (_) {
                        _releaseParentScroll();
                        _currentStroke = null;
                      },
                      child: CustomPaint(
                        size: Size(width, _padHeight),
                        painter: _BbhSignaturePainter(
                          strokes: [
                            ..._strokes,
                            if (_currentStroke != null) _currentStroke!,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 22,
                      child: Text(
                        '×',
                        style: BbhOnboardingText.display(
                          size: 18,
                          color: BbhOnboardingColors.muted2,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 34,
                      right: 16,
                      bottom: 28,
                      child: Container(height: 1, color: BbhOnboardingColors.rule),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: _clear,
              style: TextButton.styleFrom(
                foregroundColor: BbhOnboardingColors.inkSoft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'Clear',
                style: BbhOnboardingText.manrope(
                  size: 13,
                  weight: FontWeight.w600,
                  color: BbhOnboardingColors.inkSoft,
                ),
              ),
            ),
            const Spacer(),
            Text(
              captured ? 'Signature captured ✓' : 'Awaiting signature',
              style: BbhOnboardingText.manrope(
                size: 12.5,
                weight: FontWeight.w600,
                color: captured
                    ? BbhOnboardingColors.success
                    : BbhOnboardingColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BbhSignaturePainter extends CustomPainter {
  _BbhSignaturePainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _BbhSignaturePadState._strokeColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BbhSignaturePainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}

/// Tap-to-open signature capture — avoids scroll conflicts on the consent step.
class BbhSignatureTrigger extends StatelessWidget {
  const BbhSignatureTrigger({
    super.key,
    required this.hasSignature,
    required this.onTap,
    this.fieldKey,
  });

  final bool hasSignature;
  final VoidCallback onTap;
  final String? fieldKey;

  @override
  Widget build(BuildContext context) {
    final showError = BbhOnboardingFieldScroll.isError(fieldKey);
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (showError) BbhOnboardingFieldScroll.clearError();
          onTap();
        },
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            color: BbhOnboardingColors.paper,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            border: Border.all(
              color: showError
                  ? BbhOnboardingColors.error
                  : hasSignature
                      ? BbhOnboardingColors.success.withValues(alpha: 0.55)
                      : BbhOnboardingColors.rule,
              width: showError || hasSignature ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasSignature ? Icons.draw_outlined : Icons.gesture_outlined,
                size: 22,
                color: hasSignature
                    ? BbhOnboardingColors.success
                    : BbhOnboardingColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSignature ? 'Signature captured' : 'Tap to sign',
                      style: BbhOnboardingText.manrope(
                        size: 14,
                        weight: FontWeight.w600,
                        color: BbhOnboardingColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasSignature
                          ? 'Tap to view or change your signature'
                          : 'Opens a signing popup',
                      style: BbhOnboardingText.manrope(
                        size: 12,
                        color: BbhOnboardingColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: BbhOnboardingColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
    if (fieldKey == null) return content;
    return BbhOnboardingFieldScroll.anchor(fieldKey!, content);
  }
}

/// Centered modal popup for signature capture — fixed position, no sheet drag/scroll.
class BbhSignatureDialog {
  BbhSignatureDialog._();

  static Future<void> show(
    BuildContext context, {
    required bool hasSignature,
    required ValueChanged<String?> onSignatureChanged,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: BbhOnboardingColors.cream,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your signature',
                          style: BbhOnboardingText.display(
                            size: 22,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close, size: 22),
                        color: BbhOnboardingColors.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign inside the box below using your finger.',
                    style: BbhOnboardingText.manrope(
                      size: 13,
                      color: BbhOnboardingColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BbhSignaturePad(
                    inModal: true,
                    padHeight: 180,
                    hasSignature: hasSignature,
                    onSignatureChanged: onSignatureChanged,
                  ),
                  const SizedBox(height: 16),
                  BbhGoldButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
