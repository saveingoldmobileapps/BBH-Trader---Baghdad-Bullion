import 'package:baghdad_bullion_house/presentation/screens/fund_screens/funding_portal/funding_portal_flow.dart';
import 'package:baghdad_bullion_house/presentation/screens/fund_screens/funding_portal/funding_portal_layout.dart';
import 'package:baghdad_bullion_house/presentation/screens/fund_screens/funding_portal/funding_portal_theme.dart';
import 'package:baghdad_bullion_house/presentation/screens/fund_screens/funding_portal/funding_portal_typography.dart';
import 'package:baghdad_bullion_house/presentation/screens/fund_screens/funding_portal/funding_portal_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// BBH Funding Portal — mobile `.app` UI only (matches HTML prototype).
class FundingPortalMobileFlow extends StatefulWidget {
  const FundingPortalMobileFlow({
    super.key,
    this.entry = FundingPortalEntry.fullPrototype,
    this.exitOnDone = false,
  });

  /// [depositDemo] = `BBH_Deposit_UI_2.html` link + instant sequence only.
  final FundingPortalEntry entry;

  /// When true, fund-success "Done" pops this route (used from Add Funds).
  final bool exitOnDone;

  @override
  State<FundingPortalMobileFlow> createState() => _FundingPortalMobileFlowState();
}

class _FundingPortalMobileFlowState extends State<FundingPortalMobileFlow> {
  late FundingPortalScreenId _screen;

  bool get _depositDemo => widget.entry == FundingPortalEntry.depositDemo;

  bool _linked = false;
  String _linkedMasked = '—';
  num _balanceIqd = 0;
  num _fundingAmount = 250000;
  final String _customerId = 'BBH-A1B2C3D4';

  late final TextEditingController _tibAccountController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _amountController;
  String? _amountError;

  static const _minAmount = 10000;
  static const _maxAmount = 5000000;

  @override
  void initState() {
    super.initState();
    _screen = FundingPortalScreenId.linkHome;
    _tibAccountController =
        TextEditingController(text: '0042-1108-8675309');
    _accountHolderController = TextEditingController(
      text: _depositDemo ? 'Hussein Hammoodi' : 'Ahmed Al-Sayed',
    );
    _amountController = TextEditingController(text: '250000');
  }

  @override
  void dispose() {
    _tibAccountController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  num? _parseAmount(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return num.tryParse(digits);
  }

  bool _validateAndSaveAmount() {
    final amount = _parseAmount(_amountController.text);
    if (amount == null) {
      setState(() => _amountError = 'Enter an amount in IQD.');
      return false;
    }
    if (amount < _minAmount || amount > _maxAmount) {
      setState(
        () => _amountError =
            'Amount must be between ${_minAmount.toStringAsFixed(0)} and ${_maxAmount.toStringAsFixed(0)} IQD.',
      );
      return false;
    }
    setState(() {
      _amountError = null;
      _fundingAmount = amount;
    });
    return true;
  }

  void _go(FundingPortalScreenId screen) => setState(() => _screen = screen);

  void _switchFlow(FundingPortalFlow flow) {
    setState(() {
      _screen = switch (flow) {
        FundingPortalFlow.link => FundingPortalScreenId.linkHome,
        FundingPortalFlow.instant => FundingPortalScreenId.fundHome,
        FundingPortalFlow.wire => FundingPortalScreenId.wireHome,
      };
    });
  }

  void _back() {
    if (_depositDemo) {
      switch (_screen) {
        case FundingPortalScreenId.linkEnter:
          _go(FundingPortalScreenId.linkHome);
        case FundingPortalScreenId.fundAmount:
          _go(FundingPortalScreenId.fundHome);
        case FundingPortalScreenId.fundReview:
          _go(FundingPortalScreenId.fundAmount);
        default:
          break;
      }
      return;
    }
    switch (_screen) {
      case FundingPortalScreenId.linkEnter:
        _go(FundingPortalScreenId.linkHome);
      case FundingPortalScreenId.fundChoose:
        _go(FundingPortalScreenId.fundHome);
      case FundingPortalScreenId.fundAmount:
        _go(FundingPortalScreenId.fundChoose);
      case FundingPortalScreenId.fundReview:
        _go(FundingPortalScreenId.fundAmount);
      case FundingPortalScreenId.wireChoose:
        _go(FundingPortalScreenId.wireHome);
      case FundingPortalScreenId.wireInstructions:
        _go(FundingPortalScreenId.wireChoose);
      default:
        break;
    }
  }

  @override
  // Widget build(BuildContext context) {
  //   return switch (_screen) {
  //     FundingPortalScreenId.linkVerify ||
  //     FundingPortalScreenId.fundProcessing ||
  //     FundingPortalScreenId.wireWebhook =>
  //       _buildAutoAdvanceScreen(),
  //     _ => _buildStandardScreen(),
  //   };
  // }
  @override
Widget build(BuildContext context) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: FundingPortalColors.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: Scaffold(
      backgroundColor: FundingPortalColors.cream,
      body: switch (_screen) {
        FundingPortalScreenId.linkVerify ||
        FundingPortalScreenId.linkOtp ||
        FundingPortalScreenId.fundProcessing ||
        FundingPortalScreenId.wireWebhook =>
          _buildAutoAdvanceScreen(),
        _ =>
          _buildStandardScreen(),
      },
    ),
  );
}

  Widget _buildAutoAdvanceScreen() {
    return switch (_screen) {
      FundingPortalScreenId.linkOtp => _linkOtp(),
      FundingPortalScreenId.linkVerify => _linkVerify(),
      FundingPortalScreenId.fundProcessing => _fundProcessing(),
      FundingPortalScreenId.wireWebhook => _wireWebhook(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildStandardScreen() {
    final body = switch (_screen) {
      FundingPortalScreenId.linkHome => _linkHomeBody(),
      FundingPortalScreenId.linkEnter => _linkEnterBody(),
      FundingPortalScreenId.linkSuccess => _linkSuccessBody(),
      FundingPortalScreenId.fundHome => _fundHomeBody(),
      FundingPortalScreenId.fundChoose => _fundChooseBody(),
      FundingPortalScreenId.fundAmount => _fundAmountBody(),
      FundingPortalScreenId.fundReview => _fundReviewBody(),
      FundingPortalScreenId.fundOtp => _fundOtpBody(),
      FundingPortalScreenId.fundSuccess => _fundSuccessBody(),
      FundingPortalScreenId.wireHome => _wireHomeBody(),
      FundingPortalScreenId.wireChoose => _wireChooseBody(),
      FundingPortalScreenId.wireInstructions => _wireInstructionsBody(),
      FundingPortalScreenId.wireWaiting => _wireWaitingBody(),
      FundingPortalScreenId.wireSuccess => _wireSuccessBody(),
      _ => const SizedBox.shrink(),
    };

    final bottom = switch (_screen) {
      FundingPortalScreenId.linkHome => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Link TIB Account',
            onPressed: () => _go(FundingPortalScreenId.linkEnter),
          ),
        ],
      ),
      FundingPortalScreenId.linkEnter => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: _depositDemo ? 'Send OTP' : 'Verify with TIB',
            onPressed: () => _go(
              _depositDemo
                  ? FundingPortalScreenId.linkOtp
                  : FundingPortalScreenId.linkVerify,
            ),
          ),
        ],
      ),
      FundingPortalScreenId.linkSuccess => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: _depositDemo ? 'Continue · Add Funds' : 'Continue · Try Funding',
            onPressed: () {
              setState(() {
                _linked = true;
                _linkedMasked = _depositDemo ? '···· 5309' : '···· ···· ···· 5309';
              });
              _go(FundingPortalScreenId.fundHome);
            },
          ),
        ],
      ),
      FundingPortalScreenId.fundHome => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Add Funds',
            enabled: _depositDemo ? _linked : _linked,
            onPressed: _linked
                ? () => _go(
                      _depositDemo
                          ? FundingPortalScreenId.fundAmount
                          : FundingPortalScreenId.fundChoose,
                    )
                : null,
          ),
          if (!_linked && !_depositDemo)
            FundingPortalSecondaryButton(
              label: 'Send a wire instead',
              onPressed: () => _switchFlow(FundingPortalFlow.wire),
            ),
        ],
      ),
      FundingPortalScreenId.fundAmount => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Continue',
            onPressed: () {
              if (!_validateAndSaveAmount()) return;
              _go(FundingPortalScreenId.fundReview);
            },
          ),
        ],
      ),
      FundingPortalScreenId.fundReview => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Confirm with OTP',
            onPressed: () => _go(FundingPortalScreenId.fundOtp),
          ),
          FundingPortalTertiaryButton(
            label: 'Change amount',
            onPressed: _back,
          ),
        ],
      ),
      FundingPortalScreenId.fundSuccess => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Done',
            onPressed: () {
              if (widget.exitOnDone) {
                Navigator.of(context).pop();
                return;
              }
              if (_depositDemo) {
                setState(() {
                  _linked = false;
                  _linkedMasked = '—';
                  _screen = FundingPortalScreenId.linkHome;
                });
                return;
              }
              setState(() => _balanceIqd += _fundingAmount);
              _switchFlow(FundingPortalFlow.wire);
            },
          ),
        ],
      ),
      FundingPortalScreenId.wireHome => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Add Funds',
            onPressed: () => _go(FundingPortalScreenId.wireChoose),
          ),
        ],
      ),
      FundingPortalScreenId.wireInstructions => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: "I've sent the wire",
            onPressed: () => _go(FundingPortalScreenId.wireWaiting),
          ),
          FundingPortalTertiaryButton(label: 'Back', onPressed: _back),
        ],
      ),
      FundingPortalScreenId.wireWaiting => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Simulate TIB Webhook',
            onPressed: () => _go(FundingPortalScreenId.wireWebhook),
          ),
        ],
      ),
      FundingPortalScreenId.wireSuccess => FundingPortalBtnStack(
        children: [
          FundingPortalPrimaryButton(
            label: 'Done · Reset Demo',
            onPressed: () {
              setState(() {
                _linked = false;
                _linkedMasked = '—';
                _balanceIqd += 500000;
              });
              _switchFlow(FundingPortalFlow.link);
            },
          ),
        ],
      ),
      _ => null,
    };

    return FundingPortalScreenShell(body: body, bottom: bottom);
  }

  Widget _walletSection({required String greeting}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(greeting.toUpperCase(), style: FundingPortalTypography.appGreeting),
        const SizedBox(height: 6),
        Text('Your BBH Wallet', style: FundingPortalTypography.appName),
        const SizedBox(height: 24),
        FundingPortalWalletCard(
          balanceIqd: _balanceIqd,
          customerId: _customerId,
        ),
      ],
    );
  }

  // ——— Link flow ———

  Widget _linkHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Wallet'),
        _walletSection(greeting: 'Welcome'),
        const FundingPortalLinkPrompt(
          title: 'Link your Al-Taif Islamic Bank account',
          body:
              'Connect it once, then fund your wallet instantly anytime.',
        ),
      ],
    );
  }

  Widget _linkEnterBody() {
    const introFontSize = 12.5;
    const introLineHeight = 1.6;
    final intro = _depositDemo
        ? "We'll send a verification code to the phone on file for this account."
        : "We'll verify with Al-Taif Islamic Bank that this account belongs to you.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Link Account',
          showBack: true,
          onBack: _back,
        ),
        Text(
          'Account Details',
          style: FundingPortalTypography.appNameSmall.copyWith(height: 1.25),
        ),
        const SizedBox(height: 12),
        Text(
          intro,
          softWrap: true,
          style: FundingPortalTypography.bodyMuted,
          strutStyle: const StrutStyle(
            fontSize: introFontSize,
            height: introLineHeight,
            forceStrutHeight: true,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
        const SizedBox(height: 22),
        if (_depositDemo) ...[
          const FundingPortalReadOnlyField(
            label: 'TIB Account Number',
            value: '0042-1108-8675309',
          ),
          const FundingPortalReadOnlyField(
            label: 'Account Holder Name',
            value: 'Hussein Hammoodi',
            hint: 'Must match the name on the TIB account exactly.',
          ),
        ] else ...[
          FundingPortalTextField(
            label: 'TIB Account Number',
            controller: _tibAccountController,
          ),
          FundingPortalTextField(
            label: 'Account Holder Name',
            controller: _accountHolderController,
            textCapitalization: TextCapitalization.words,
            hint: 'Must match the name on the TIB account exactly.',
          ),
        ],
      ],
    );
  }

  Widget _linkOtp() {
    return FundingPortalScreenShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FundingPortalAppHeader(title: 'Verification'),
          Text(
            'Enter the code from TIB',
            textAlign: TextAlign.center,
            softWrap: true,
            style: FundingPortalTypography.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: FundingPortalColors.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sent to ··· ··· 4421 · valid for 5 minutes',
            textAlign: TextAlign.center,
            softWrap: true,
            style: FundingPortalTypography.bodyMuted,
          ),
          const SizedBox(height: 18),
          FundingPortalOtpGrid(
            onComplete: () {
              if (mounted) _go(FundingPortalScreenId.linkVerify);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Resend in 24s',
            textAlign: TextAlign.center,
            style: FundingPortalTypography.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: FundingPortalColors.goldDeep,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          const FundingPortalFootnote(
            text:
                'Linking an account requires OTP verification.\n'
                'Your code is sent directly by Al-Taif Islamic Bank.',
          ),
        ],
      ),
    );
  }

  Widget _linkVerify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && _screen == FundingPortalScreenId.linkVerify) {
          _go(FundingPortalScreenId.linkSuccess);
        }
      });
    });
    return FundingPortalCenteredShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FundingPortalAppHeader(title: 'Verifying'),
          const FundingPortalLoadingView(
            title: 'Verifying with Al-Taif Islamic Bank',
            subtitle:
                'Confirming account ownership · this takes about a second.',
          ),
        ],
      ),
    );
  }

  Widget _linkSuccessBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Linked'),
        FundingPortalSuccessView(
          title: 'Account Linked',
          subtitle:
              'Your Al-Taif Islamic Bank account ending 5309 is now connected to your BBH wallet.',
          child: FundingPortalLinkedAccountChip(masked: '···· ···· ···· 5309'),
        ),
      ],
    );
  }

  // ——— Instant funding ———

  Widget _fundHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Wallet'),
        _walletSection(greeting: 'Welcome back'),
        if (_linked)
          FundingPortalLinkedAccountChip(masked: _linkedMasked)
        else if (!_depositDemo)
          const FundingPortalLinkPrompt(
            title: 'No linked account yet',
            body:
                'Switch to flow 1 to link a TIB account first, or use external wire (flow 3).',
          ),
      ],
    );
  }

  Widget _fundChooseBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Add Funds',
          showBack: true,
          onBack: _back,
        ),
        Text('Funding method', style: FundingPortalTypography.appNameSmall),
        const SizedBox(height: 8),
        Text(
          "Choose how you'd like to add funds to your BBH wallet.",
          softWrap: true,
          style: FundingPortalTypography.bodyMuted,
        ),
        const SizedBox(height: 14),
        FundingPortalMethodCard(
          icon: '⚡',
          title: 'Instant Transfer',
          description:
              'From your linked TIB account · arrives in seconds · OTP confirmation',
          selected: true,
          badge: 'Fast',
          onTap: () => _go(FundingPortalScreenId.fundAmount),
        ),
        FundingPortalMethodCard(
          icon: '⇆',
          title: 'Wire from Another Bank',
          description:
              'From any bank · uses your BBH Customer ID as reference · ~30 min typical',
          onTap: () => _switchFlow(FundingPortalFlow.wire),
        ),
        const FundingPortalFootnote(
          text:
              "Funds are held in BBH's segregated client account\nat Al-Taif Islamic Bank.",
        ),
      ],
    );
  }

  Widget _fundAmountBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Amount',
          showBack: true,
          onBack: _back,
        ),
        Text('How much?', style: FundingPortalTypography.appNameSmall),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: FundingPortalTypography.bodySmallMuted,
            children: [
              const TextSpan(text: 'From '),
              TextSpan(
                text: _linkedMasked,
                style: FundingPortalTypography.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FundingPortalColors.ink,
                  height: 1.55,
                ),
              ),
            ],
          ),
          softWrap: true,
        ),
        const SizedBox(height: 24),
        FundingPortalAmountField(
          controller: _amountController,
          errorText: _amountError,
          onChanged: (_) {
            if (_amountError != null) setState(() => _amountError = null);
          },
        ),
      ],
    );
  }

  Widget _fundReviewBody() {
    final amt = NumberFormat('#,###', 'en_US').format(_fundingAmount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Review',
          showBack: true,
          onBack: _back,
        ),
        Text('Confirm transfer', style: FundingPortalTypography.appNameSmall),
        const SizedBox(height: 8),
        Text(
          'Review the details · the next step requires an OTP from TIB.',
          softWrap: true,
          style: FundingPortalTypography.bodyMuted,
        ),
        const SizedBox(height: 16),
        FundingPortalReviewCard(
          rows: [
            FundingPortalReviewRow('Amount', '$amt IQD', highlight: true),
            const FundingPortalReviewRow('From', 'TIB ···· 5309'),
            const FundingPortalReviewRow('To', 'Your BBH Wallet'),
            const FundingPortalReviewRow('Fee', '0 IQD'),
            const FundingPortalReviewRow('Arrival', 'Instant'),
          ],
        ),
      ],
    );
  }

  Widget _fundOtpBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Verification'),
        Text(
          'Enter the code from TIB',
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: FundingPortalColors.ink,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sent to ··· ··· 4421 · valid for 5 minutes',
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.bodyMuted,
        ),
        const SizedBox(height: 18),
        FundingPortalOtpGrid(
          onComplete: () {
            if (mounted) _go(FundingPortalScreenId.fundProcessing);
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Resend in 24s',
          textAlign: TextAlign.center,
          style: FundingPortalTypography.manrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: FundingPortalColors.goldDeep,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        const FundingPortalFootnote(
          text:
              "BBH never sees your OTP in clear text.\nIt's verified directly by Al-Taif Islamic Bank via API 3.2.",
        ),
      ],
    );
  }

  Widget _fundProcessing() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        if (mounted && _screen == FundingPortalScreenId.fundProcessing) {
          setState(() => _balanceIqd += _fundingAmount);
          _go(FundingPortalScreenId.fundSuccess);
        }
      });
    });
    final amt = NumberFormat('#,###', 'en_US').format(_fundingAmount);
    return FundingPortalCenteredShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FundingPortalAppHeader(title: 'Processing'),
          FundingPortalLoadingView(
            title: 'Transferring $amt IQD',
            subtitle:
                'TIB is moving funds from your linked account to your BBH wallet.',
          ),
        ],
      ),
    );
  }

  Widget _fundSuccessBody() {
    final amt = NumberFormat('#,###', 'en_US').format(_fundingAmount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Complete'),
        FundingPortalSuccessView(
          amount: '$amt IQD',
          title: 'added to your wallet',
          compactTitle: true,
          child: SizedBox(
            width: double.infinity,
            child: FundingPortalReviewCard(
              rows: const [
                FundingPortalReviewRow('Transfer ID', 'TXN-8F2A-X7B3C9'),
                FundingPortalReviewRow('From', 'TIB ···· 5309'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ——— Wire flow ———

  Widget _wireHomeBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Wallet'),
        _walletSection(greeting: 'Welcome back'),
        if (_linked) FundingPortalLinkedAccountChip(masked: _linkedMasked),
      ],
    );
  }

  Widget _wireChooseBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Add Funds',
          showBack: true,
          onBack: _back,
        ),
        Text('Funding method', style: FundingPortalTypography.appNameSmall),
        const SizedBox(height: 8),
        Text(
          "Choose how you'd like to add funds.",
          softWrap: true,
          style: FundingPortalTypography.bodyMuted,
        ),
        const SizedBox(height: 14),
        if (_linked)
          FundingPortalMethodCard(
            icon: '⚡',
            title: 'Instant Transfer',
            description:
                'From your linked TIB account · arrives in seconds',
            badge: 'Fast',
            onTap: () => _switchFlow(FundingPortalFlow.instant),
          ),
        FundingPortalMethodCard(
          icon: '⇆',
          title: 'Wire from Another Bank',
          description:
              'From any bank · uses your BBH Customer ID as reference · ~30 min typical',
          selected: true,
          onTap: () => _go(FundingPortalScreenId.wireInstructions),
        ),
        const FundingPortalFootnote(
          text:
              "Both methods deposit into BBH's segregated client account\nat Al-Taif Islamic Bank.",
        ),
      ],
    );
  }

  Widget _wireInstructionsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FundingPortalAppHeader(
          title: 'Wire Details',
          showBack: true,
          onBack: _back,
        ),
        Text('Send a wire to BBH', style: FundingPortalTypography.appNameSmall),
        const SizedBox(height: 8),
        Text(
          "Open your bank's app and send a wire using these details.",
          softWrap: true,
          style: FundingPortalTypography.bodySmallMuted,
        ),
        const SizedBox(height: 14),
        FundingPortalReviewCard(
          rows: [
            const FundingPortalReviewRow('Beneficiary', 'Baghdad Bullion House'),
            const FundingPortalReviewRow('Bank', 'Al-Taif Islamic Bank'),
            const FundingPortalReviewRow('Account No.', '12-3456-7890123'),
            const FundingPortalReviewRow('IBAN', 'IQ58 ALTI 1234 5678 9012 3000'),
            FundingPortalReviewRow('Reference', _customerId, crucial: true),
          ],
        ),
        FundingPortalWireWarning(customerId: _customerId),
      ],
    );
  }

  Widget _wireWaitingBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Waiting'),
        const SizedBox(height: 24),
        const Center(child: FundingPortalWaitingPulse()),
        const SizedBox(height: 24),
        Text(
          'Waiting for your deposit',
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.cormorant(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Most domestic wires arrive within 30 minutes.\nYou'll get a notification when funds are credited.",
          textAlign: TextAlign.center,
          softWrap: true,
          style: FundingPortalTypography.bodyMuted.copyWith(fontSize: 11.5),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            style: FundingPortalTypography.bodyMuted.copyWith(fontSize: 11),
            children: [
              const TextSpan(text: 'Reference · '),
              TextSpan(
                text: _customerId,
                style: FundingPortalTypography.mono(fontSize: 11, height: 1.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ],
    );
  }

  Widget _wireWebhook() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && _screen == FundingPortalScreenId.wireWebhook) {
          setState(() => _balanceIqd += 500000);
          _go(FundingPortalScreenId.wireSuccess);
        }
      });
    });
    return FundingPortalCenteredShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FundingPortalAppHeader(title: 'Processing'),
          const FundingPortalLoadingView(
            title: 'Receiving deposit notification',
            subtitle:
                'BBH is verifying the webhook signature, looking up your Customer ID, and crediting your wallet.',
          ),
        ],
      ),
    );
  }

  Widget _wireSuccessBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FundingPortalAppHeader(title: 'Complete'),
        const FundingPortalSuccessView(
          amount: '500,000 IQD',
          title: 'received via wire',
          compactTitle: true,
        ),
      ],
    );
  }
}
