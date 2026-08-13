import 'package:baghdad_bullion_house/core/agreement_service.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/widgets/loader_button.dart';
import 'package:baghdad_bullion_house/presentation/widgets/signature_pad_widget.dart';
import 'package:flutter/material.dart';

/// Signature-only capture — no agreement document; used when home feed
/// reports [Payload.isSignatureVerified] as false.
class UserSignatureScreen extends StatefulWidget {
  const UserSignatureScreen({super.key});

  @override
  State<UserSignatureScreen> createState() => _UserSignatureScreenState();
}

class _UserSignatureScreenState extends State<UserSignatureScreen> {
  bool _hasSignature = false;
  bool _isSubmitting = false;

  final GlobalKey<SignaturePadWidgetState> _signaturePadKey = GlobalKey();
  final GlobalKey _signatureRepaintKey = GlobalKey();

  Future<void> _submitSignature() async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (!_hasSignature) {
      Toasts.getWarningToast(
        text: isRtl ? 'يرجى إضافة توقيعك' : 'Please add your signature',
      );
      return;
    }

    final signatureBytes =
        await _signaturePadKey.currentState?.exportPngBytes();
    if (signatureBytes == null) {
      Toasts.getErrorToast(
        text: isRtl ? 'تعذر حفظ التوقيع' : 'Could not save signature',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AgreementService.submitSignatureOnly(
      signaturePngBytes: signatureBytes,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      Toasts.getSuccessToast(
        text: isRtl ? 'تم حفظ التوقيع' : 'Signature saved successfully',
      );
      Navigator.pop(context, true);
    } else {
      Toasts.getErrorToast(
        text: result.message ??
            (isRtl ? 'فشل إرسال التوقيع' : 'Failed to submit signature'),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = _hasSignature && !_isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
            color: AppColors.whiteColor,
            size: 20,
          ),
        ),
        title: GetGenericText(
          text: l10n.kyc_signature,
          fontSize: sizes!.responsiveFont(phoneVal: 17, tabletVal: 20),
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GetGenericText(
                text: l10n.signature_capture_message,
                fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                fontWeight: FontWeight.w400,
                color: AppColors.grey5Color,
                lines: 3,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyScale900,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _hasSignature
                              ? AppColors.primaryGold500
                              : AppColors.greyScale800,
                          width: _hasSignature ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SignaturePadWidget(
                          key: _signaturePadKey,
                          repaintKey: _signatureRepaintKey,
                          onSignatureChanged: (hasSignature) {
                            setState(() => _hasSignature = hasSignature);
                          },
                        ),
                      ),
                    ),
                    if (!_hasSignature)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 20,
                        child: IgnorePointer(
                          child: Center(
                            child: GetGenericText(
                              text: isRtl ? 'وقّع هنا' : 'Sign here',
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 14,
                                tabletVal: 16,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.greyScale800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment:
                    isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () => _signaturePadKey.currentState?.clear(),
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppColors.primaryGold500,
                  ),
                  label: GetGenericText(
                    text: isRtl ? 'مسح التوقيع' : 'Clear signature',
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 13,
                      tabletVal: 15,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGold500,
                  ),
                ),
              ),
              LoaderButton(
                title: l10n.sign_agreement,
                isLoadingState: _isSubmitting,
                onTap: canSubmit ? _submitSignature : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
