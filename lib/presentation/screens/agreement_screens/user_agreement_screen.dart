import 'package:baghdad_bullion_house/core/agreement_service.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/widgets/loader_button.dart';
import 'package:baghdad_bullion_house/presentation/widgets/signature_pad_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  bool _isLoadingDocument = true;
  bool _hasReachedDocumentEnd = false;
  String? _agreementUrl;
  String? _documentLoadError;
  bool _isImageDocument = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(_onPdfViewerUpdate);
    _loadAgreementDocument();
  }

  @override
  void dispose() {
    _pdfViewerController.removeListener(_onPdfViewerUpdate);
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _onPdfViewerUpdate() {
    _markDocumentEndIfNeeded();
  }

  void _markDocumentEndIfNeeded() {
    final pageCount = _pdfViewerController.pageCount;
    if (pageCount == 0) return;

    final onLastPage = _pdfViewerController.pageNumber >= pageCount;
    if (onLastPage && !_hasReachedDocumentEnd && mounted) {
      setState(() => _hasReachedDocumentEnd = true);
    }
  }

  Future<void> _loadAgreementDocument() async {
    setState(() {
      _isLoadingDocument = true;
      _documentLoadError = null;
      _agreementUrl = null;
      _isImageDocument = false;
      _hasReachedDocumentEnd = false;
    });

    final link = await AgreementService.fetchAgreementLink();
    if (!mounted) return;

    final document = AgreementService.resolveDocumentSource(link);

    setState(() {
      _isLoadingDocument = false;
      if (!document.isValid) {
        _documentLoadError = Directionality.of(context) == TextDirection.rtl
            ? 'تعذر تحميل الاتفاقية'
            : 'Could not load agreement';
      } else {
        _agreementUrl = document.networkUrl;
        _isImageDocument = document.isImage;
        if (_isImageDocument) {
          _hasReachedDocumentEnd = true;
        }
      }
    });
  }

  Future<void> _openSignAgreementPopup() async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SignAgreementDialog(isRtl: isRtl),
    );

    if (!mounted || submitted != true) return;

    Toasts.getSuccessToast(
      text: isRtl ? 'تم حفظ التوقيع' : 'Agreement signed successfully',
    );
    Navigator.pop(context, true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final canSign =
        !_isLoadingDocument &&
        _documentLoadError == null &&
        _agreementUrl != null &&
        _hasReachedDocumentEnd;

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.sig_agreement,
          fontSize: sizes!.responsiveFont(phoneVal: 18, tabletVal: 22),
          fontWeight: FontWeight.w500,
          color: AppColors.grey6Color,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isLoadingDocument &&
                _agreementUrl != null &&
                !_hasReachedDocumentEnd)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyScale900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold500.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.primaryGold500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GetGenericText(
                          text: isRtl
                              ? 'يرجى التأكد من مراجعة اتفاقية دار بغداد للسبائك بالكامل قبل المتابعة بالتوقيع.'
                              : 'Kindly ensure the Baghdad Bullion House agreement is fully reviewed before proceeding with your signature.',
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 12,
                            tabletVal: 14,
                          ),
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey3Color,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyScale900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyScale800),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildDocumentContent(isRtl),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: canSign
                  ? Padding(
                      key: const ValueKey('sign_button'),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: LoaderButton(
                        title: AppLocalizations.of(context)!.sign_agreement,
                        onTap: _openSignAgreementPopup,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }

  void _onPdfDocumentLoaded(PdfDocumentLoadedDetails details) {
    if (details.document.pages.count <= 1 && mounted) {
      setState(() => _hasReachedDocumentEnd = true);
    }
  }

  void _onPdfPageChanged(PdfPageChangedDetails details) {
    final totalPages = _pdfViewerController.pageCount;
    if (totalPages == 0) return;

    final isLastPage = details.newPageNumber >= totalPages;

    if (mounted) {
      setState(() {
        _hasReachedDocumentEnd = isLastPage;
      });
    }
  }

  Widget _buildDocumentContent(bool isRtl) {
    if (_isLoadingDocument) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentLoadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GetGenericText(
                text: _documentLoadError!,
                fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                fontWeight: FontWeight.w400,
                color: AppColors.grey4Color,
                textAlign: TextAlign.center,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),
              LoaderButton(
                title: isRtl ? 'إعادة المحاولة' : 'Retry',
                onTap: _loadAgreementDocument,
              ),
            ],
          ),
        ),
      );
    }

    if (_isImageDocument) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Image.network(
          _agreementUrl!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: GetGenericText(
                text: isRtl ? 'تعذر تحميل الاتفاقية' : 'Could not load agreement',
                fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                fontWeight: FontWeight.w400,
                color: AppColors.grey4Color,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      );
    }

    return SfPdfViewer.network(
      _agreementUrl!,
      controller: _pdfViewerController,
      canShowScrollHead: false,
      onDocumentLoaded: _onPdfDocumentLoaded,
      onPageChanged: _onPdfPageChanged,
    );
  }
}

class _SignAgreementDialog extends StatefulWidget {
  final bool isRtl;

  const _SignAgreementDialog({required this.isRtl});

  @override
  State<_SignAgreementDialog> createState() => _SignAgreementDialogState();
}

class _SignAgreementDialogState extends State<_SignAgreementDialog> {
  bool _hasSignature = false;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  final GlobalKey<SignaturePadWidgetState> _signaturePadKey = GlobalKey();
  final GlobalKey _signatureRepaintKey = GlobalKey();

  Future<void> _submitAgreement() async {
    if (!_agreedToTerms) {
      Toasts.getWarningToast(
        text: widget.isRtl
            ? 'يرجى الموافقة على الاتفاقية'
            : 'Please agree to the agreement',
      );
      return;
    }

    if (!_hasSignature) {
      Toasts.getWarningToast(
        text: widget.isRtl ? 'يرجى إضافة توقيعك' : 'Please add your signature',
      );
      return;
    }

    final signatureBytes = await _signaturePadKey.currentState
        ?.exportPngBytes();
    if (signatureBytes == null) {
      Toasts.getErrorToast(
        text: widget.isRtl ? 'تعذر حفظ التوقيع' : 'Could not save signature',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AgreementService.submitSignature(
      signaturePngBytes: signatureBytes,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      Navigator.pop(context, true);
    } else {
      Toasts.getErrorToast(
        text:
            result.message ??
            (widget.isRtl ? 'فشل إرسال التوقيع' : 'Failed to submit signature'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _agreedToTerms && _hasSignature && !_isSubmitting;

    return Dialog(
      backgroundColor: AppColors.greyScale1000,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: sizes!.isPhone ? double.infinity : 480,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GetGenericText(
                      text: AppLocalizations.of(context)!.sign_agreement,
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 17,
                        tabletVal: 20,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              GetGenericText(
                text: widget.isRtl
                    ? 'يرجى التوقيع لإكمال الاتفاقية'
                    : 'Please sign to complete the agreement',
                fontSize: sizes!.responsiveFont(phoneVal: 12, tabletVal: 14),
                fontWeight: FontWeight.w400,
                color: AppColors.grey4Color,
              ),
              ConstPadding.sizeBoxWithHeight(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.greyScale900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasSignature
                        ? AppColors.primaryGold500
                        : AppColors.greyScale800,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SignaturePadWidget(
                    key: _signaturePadKey,
                    repaintKey: _signatureRepaintKey,
                    onSignatureChanged: (hasSignature) {
                      setState(() => _hasSignature = hasSignature);
                    },
                  ),
                ),
              ),
              Align(
                alignment: widget.isRtl
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _signaturePadKey.currentState?.clear(),
                  child: GetGenericText(
                    text: widget.isRtl ? 'مسح التوقيع' : 'Clear signature',
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 13,
                      tabletVal: 15,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGold500,
                    isUnderline: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greyScale900,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.grey5Color.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(
                                  () => _agreedToTerms = value ?? false,
                                );
                              },
                        activeColor: AppColors.primaryGold500,
                        checkColor: AppColors.greyScale1000,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.kyc_agreement_desc,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 13,
                            tabletVal: 15,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.whiteColor,
                          lines: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),
              LoaderButton(
                title: AppLocalizations.of(context)!.accept_agreement,
                isLoadingState: _isSubmitting,
                onTap: canSubmit ? _submitAgreement : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
