import 'dart:async';

import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import 'bbh_onboarding_theme.dart';
import 'bbh_onboarding_widgets.dart';

enum _OtpStage { send, enter, success }

/// OTP modal for onboarding contact verification (preVerify API).
class BbhOnboardingOtpSheet extends StatefulWidget {
  const BbhOnboardingOtpSheet({
    super.key,
    required this.channel,
    required this.phoneNumber,
    required this.email,
  });

  final BbhOnboardingOtpChannel channel;
  final String phoneNumber;
  final String email;

  static Future<bool?> openForVerification(
    BuildContext context, {
    required BbhOnboardingOtpChannel channel,
    required String phoneNumber,
    required String email,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => Theme(
        data: BbhOnboardingTheme.materialTheme(),
        child: BbhOnboardingOtpSheet(
          channel: channel,
          phoneNumber: phoneNumber,
          email: email,
        ),
      ),
    );
  }

  @override
  State<BbhOnboardingOtpSheet> createState() => _BbhOnboardingOtpSheetState();
}

class _BbhOnboardingOtpSheetState extends State<BbhOnboardingOtpSheet> {
  _OtpStage _stage = _OtpStage.send;
  bool _busy = false;
  String? _statusMessage;
  String? _errorMessage;
  String? _expectedOtp;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();

  String get _destination => widget.channel == BbhOnboardingOtpChannel.mobile
      ? widget.phoneNumber.trim()
      : widget.email.trim().toLowerCase();

  String get _channelLabel =>
      widget.channel == BbhOnboardingOtpChannel.mobile ? 'mobile number' : 'email';

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _startResendTimer([int seconds = 30]) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _sendCode() async {
    setState(() {
      _busy = true;
      _errorMessage = null;
      _statusMessage = 'Sending code…';
    });

    final result = await BbhOnboardingOtpService.instance.sendOtp(
      channel: widget.channel,
      phoneNumber: widget.phoneNumber,
      email: widget.email,
    );

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _busy = false;
        _statusMessage = null;
        _errorMessage = result.message ?? 'Could not send code.';
      });
      return;
    }

    setState(() {
      _busy = false;
      _expectedOtp = result.oneTimePassword;
      _statusMessage = widget.channel == BbhOnboardingOtpChannel.mobile
          ? 'A 6-digit code was sent to your WhatsApp number $_destination.'
          : 'A 6-digit code was sent to $_destination.';
      _stage = _OtpStage.enter;
    });
    _pinController.clear();
    _startResendTimer();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _pinFocus.requestFocus();
    });
  }

  Future<void> _verifyCode() async {
    final code = _pinController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Enter the full 6-digit code.');
      return;
    }

    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    final result = await BbhOnboardingOtpService.instance.verifyPasscode(
      channel: widget.channel,
      phoneNumber: widget.phoneNumber,
      email: widget.email,
      passcode: code,
      expectedOtp: _expectedOtp,
    );

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _busy = false;
        _errorMessage = result.message ?? 'Incorrect code. Please try again.';
      });
      return;
    }

    setState(() {
      _busy = false;
      _stage = _OtpStage.success;
      _statusMessage = 'Your $_channelLabel is verified.';
    });
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0 || _busy) return;
    await _sendCode();
  }

  PinTheme _pinTheme() {
    return PinTheme(
      width: 44,
      height: 52,
      textStyle: BbhOnboardingText.manrope(
        size: 20,
        weight: FontWeight.w700,
        color: BbhOnboardingColors.ink,
      ),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paper,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BbhOnboardingColors.cream,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _stage == _OtpStage.success
                          ? 'Verified'
                          : 'Verify ${_channelLabel == 'mobile number' ? 'Number' : 'Email'}',
                      style: BbhOnboardingText.display(
                        size: 22,
                        weight: FontWeight.w600,
                        color: BbhOnboardingColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(
                              _stage == _OtpStage.success ? true : false,
                            ),
                    icon: const Icon(Icons.close, color: BbhOnboardingColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _stage == _OtpStage.send
                    ? (widget.channel == BbhOnboardingOtpChannel.mobile
                        ? 'We will send a one-time code to your mobile number via WhatsApp.'
                        : 'We will send a one-time code to your email address.')
                    : _statusMessage ?? '',
                style: BbhOnboardingText.manrope(
                  size: 14,
                  color: BbhOnboardingColors.inkSoft,
                  height: 1.5,
                ),
              ),
              if (_stage != _OtpStage.send) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: BbhOnboardingColors.paper,
                    borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
                    border: Border.all(color: BbhOnboardingColors.ruleSoft),
                  ),
                  child: Text(
                    _destination,
                    textDirection: TextDirection.ltr,
                    style: BbhOnboardingText.manrope(
                      size: 14,
                      weight: FontWeight.w600,
                      color: BbhOnboardingColors.ink,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (_stage == _OtpStage.send) ...[
                if (_errorMessage != null) _errorBanner(_errorMessage!),
                if (_statusMessage != null && _busy)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _statusMessage!,
                      style: BbhOnboardingText.manrope(
                        size: 13,
                        color: BbhOnboardingColors.muted,
                      ),
                    ),
                  ),
              ],
              if (_stage == _OtpStage.enter) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _pinFocus,
                    defaultPinTheme: _pinTheme(),
                    separatorBuilder: (_) => const SizedBox(width: 8),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (_) => _verifyCode(),
                    focusedPinTheme: _pinTheme().copyWith(
                      decoration: _pinTheme().decoration!.copyWith(
                            border: Border.all(
                              color: BbhOnboardingColors.goldDeep,
                              width: 1.4,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null) _errorBanner(_errorMessage!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: BbhOnboardingText.manrope(
                        size: 12.5,
                        color: BbhOnboardingColors.muted,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: (_resendSeconds > 0 || _busy) ? null : _resendCode,
                      child: Text(
                        _resendSeconds > 0
                            ? 'Resend in ${_resendSeconds}s'
                            : 'Resend code',
                        style: BbhOnboardingText.manrope(
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: _resendSeconds > 0
                              ? BbhOnboardingColors.muted
                              : BbhOnboardingColors.goldDeep,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_stage == _OtpStage.success)
                Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: BbhOnboardingColors.success,
                  ),
                ),
              const SizedBox(height: 18),
              if (_stage == _OtpStage.send)
                Row(
                  children: [
                    Expanded(
                      child: BbhGhostButton(
                        label: 'Cancel',
                        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BbhPrimaryButton(
                        label: _busy ? 'Sending…' : 'Send Code',
                        loading: _busy,
                        onPressed: _busy ? null : _sendCode,
                      ),
                    ),
                  ],
                )
              else if (_stage == _OtpStage.enter)
                Row(
                  children: [
                    Expanded(
                      child: BbhGhostButton(
                        label: 'Back',
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() {
                                  _stage = _OtpStage.send;
                                  _errorMessage = null;
                                  _statusMessage = null;
                                  _pinController.clear();
                                });
                                _resendTimer?.cancel();
                                _resendSeconds = 0;
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BbhPrimaryButton(
                        label: 'Verify',
                        loading: _busy,
                        onPressed: _busy ? null : _verifyCode,
                      ),
                    ),
                  ],
                )
              else
                BbhPrimaryButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x14B42318),
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
        border: Border.all(color: const Color(0x33B42318)),
      ),
      child: Text(
        message,
        style: BbhOnboardingText.manrope(
          size: 13,
          weight: FontWeight.w600,
          color: const Color(0xFFB42318),
        ),
      ),
    );
  }
}
