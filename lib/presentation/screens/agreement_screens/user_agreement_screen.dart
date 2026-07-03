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
  int _currentPage = 1;
  int _totalPages = 0;

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
      _currentPage = 1;
      _totalPages = 0;
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

  Future<void> _openSignAgreementSheet() async {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SignAgreementSheet(isRtl: isRtl),
    );

    if (!mounted || submitted != true) return;

    Toasts.getSuccessToast(
      text: isRtl ? 'تم حفظ التوقيع' : 'Agreement signed successfully',
    );
    Navigator.pop(context, true);
  }

  double get _readProgress {
    if (_hasReachedDocumentEnd) return 1;
    if (_isImageDocument) return 1;
    if (_totalPages <= 1) return 0;
    return ((_currentPage - 1) / (_totalPages - 1)).clamp(0.0, 1.0);
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
    final canSign =
        !_isLoadingDocument &&
        _documentLoadError == null &&
        _agreementUrl != null &&
        _hasReachedDocumentEnd;

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AgreementHeader(
              title: l10n.sig_agreement,
              onBack: () => Navigator.pop(context),
              isRtl: isRtl,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: _DocumentViewerFrame(
                      isRtl: isRtl,
                      showPageBadge:
                          !_isImageDocument &&
                          _totalPages > 0 &&
                          !_isLoadingDocument,
                      pageLabel: '$_currentPage / $_totalPages',
                      progress: (!_isImageDocument && _totalPages > 0)
                          ? _readProgress
                          : null,
                      lockedHint: !canSign && !_isLoadingDocument
                          ? (isRtl
                                ? 'مرّر إلى النهاية للتوقيع'
                                : 'Scroll to the end to sign')
                          : null,
                      child: _buildDocumentContent(isRtl),
                    ),
                  ),
                  if (canSign)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 8,
                      child: _AgreementBottomBar(
                        signLabel: l10n.sign_agreement,
                        onSign: _openSignAgreementSheet,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPdfDocumentLoaded(PdfDocumentLoadedDetails details) {
    final pageCount = details.document.pages.count;
    if (!mounted) return;
    setState(() {
      _totalPages = pageCount;
      if (pageCount <= 1) {
        _hasReachedDocumentEnd = true;
      }
    });
  }

  void _onPdfPageChanged(PdfPageChangedDetails details) {
    final totalPages = _pdfViewerController.pageCount;
    if (totalPages == 0) return;

    final isLastPage = details.newPageNumber >= totalPages;

    if (mounted) {
      setState(() {
        _currentPage = details.newPageNumber;
        _totalPages = totalPages;
        _hasReachedDocumentEnd = isLastPage;
      });
    }
  }

  Widget _buildDocumentContent(bool isRtl) {
    if (_isLoadingDocument) {
      return _DocumentLoadingState(isRtl: isRtl);
    }

    if (_documentLoadError != null) {
      return _DocumentErrorState(
        message: _documentLoadError!,
        retryLabel: isRtl ? 'إعادة المحاولة' : 'Try again',
        onRetry: _loadAgreementDocument,
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
            return _DocumentLoadingState(isRtl: isRtl);
          },
          errorBuilder: (context, error, stackTrace) {
            return _DocumentErrorState(
              message: isRtl
                  ? 'تعذر تحميل الاتفاقية'
                  : 'Could not load agreement',
              retryLabel: isRtl ? 'إعادة المحاولة' : 'Try again',
              onRetry: _loadAgreementDocument,
            );
          },
        ),
      );
    }

    return SfPdfViewer.network(
      _agreementUrl!,
      controller: _pdfViewerController,
      canShowScrollHead: false,
      canShowPaginationDialog: false,
      onDocumentLoaded: _onPdfDocumentLoaded,
      onPageChanged: _onPdfPageChanged,
    );
  }
}

class _AgreementHeader extends StatelessWidget {
  const _AgreementHeader({
    required this.title,
    required this.onBack,
    required this.isRtl,
  });

  final String title;
  final VoidCallback onBack;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.grey6Color,
            ),
          ),
          Expanded(
            child: GetGenericText(
              text: title,
              fontSize: sizes!.responsiveFont(phoneVal: 17, tabletVal: 20),
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor,
              lines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentViewerFrame extends StatelessWidget {
  const _DocumentViewerFrame({
    required this.child,
    required this.isRtl,
    required this.showPageBadge,
    required this.pageLabel,
    this.progress,
    this.lockedHint,
  });

  final Widget child;
  final bool isRtl;
  final bool showPageBadge;
  final String pageLabel;
  final double? progress;
  final String? lockedHint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.greyScale900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyScale800),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showPageBadge || progress != null || lockedHint != null)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: AppColors.greyScale1000.withOpacity(0.6),
                  border: Border(
                    bottom: BorderSide(color: AppColors.greyScale800),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (showPageBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greyScale800,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: GetGenericText(
                              text: pageLabel,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey4Color,
                            ),
                          ),
                        if (showPageBadge && progress != null)
                          const SizedBox(width: 8),
                        if (progress != null)
                          Expanded(
                            child: GetGenericText(
                              text: isRtl
                                  ? '${(progress! * 100).round()}% مقروء'
                                  : '${(progress! * 100).round()}% read',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGold500,
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: AppColors.greyScale800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGold500.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                    if (lockedHint != null) ...[
                      if (progress != null) const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 13,
                            color: AppColors.grey5Color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GetGenericText(
                              text: lockedHint!,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey5Color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DocumentLoadingState extends StatelessWidget {
  const _DocumentLoadingState({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryGold500,
            ),
          ),
          const SizedBox(height: 16),
          GetGenericText(
            text: isRtl ? 'جاري تحميل الاتفاقية…' : 'Loading agreement…',
            fontSize: sizes!.responsiveFont(phoneVal: 13, tabletVal: 15),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ),
        ],
      ),
    );
  }
}

class _DocumentErrorState extends StatelessWidget {
  const _DocumentErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.greyScale800.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: AppColors.grey4Color,
              ),
            ),
            const SizedBox(height: 16),
            GetGenericText(
              text: message,
              fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
              fontWeight: FontWeight.w500,
              color: AppColors.grey4Color,
              textAlign: TextAlign.center,
              lines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: LoaderButton(title: retryLabel, onTap: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementBottomBar extends StatelessWidget {
  const _AgreementBottomBar({
    required this.signLabel,
    required this.onSign,
  });

  final String signLabel;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.greyScale1000.withOpacity(0),
            AppColors.greyScale1000.withOpacity(0.92),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 16, 8, 8 + bottomSafe),
        child: LoaderButton(title: signLabel, onTap: onSign),
      ),
    );
  }
}

class _SignAgreementSheet extends StatefulWidget {
  const _SignAgreementSheet({required this.isRtl});

  final bool isRtl;

  @override
  State<_SignAgreementSheet> createState() => _SignAgreementSheetState();
}

class _SignAgreementSheetState extends State<_SignAgreementSheet> {
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
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = _agreedToTerms && _hasSignature && !_isSubmitting;
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.greyScale800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GetGenericText(
                        text: l10n.sign_agreement,
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
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 160,
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
                                    text: widget.isRtl
                                        ? 'وقّع هنا'
                                        : 'Sign here',
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
                      Align(
                        alignment: widget.isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _signaturePadKey.currentState?.clear(),
                          icon: Icon(
                            Icons.refresh,
                            size: 16,
                            color: AppColors.primaryGold500,
                          ),
                          label: GetGenericText(
                            text: widget.isRtl
                                ? 'مسح التوقيع'
                                : 'Clear signature',
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 13,
                              tabletVal: 15,
                            ),
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGold500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.greyScale900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _agreedToTerms
                                ? AppColors.primaryGold500.withOpacity(0.5)
                                : AppColors.greyScale800,
                          ),
                        ),
                        child: InkWell(
                          onTap: _isSubmitting
                              ? null
                              : () => setState(
                                  () => _agreedToTerms = !_agreedToTerms,
                                ),
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.scale(
                                scale: 1.05,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) {
                                          setState(
                                            () =>
                                                _agreedToTerms = value ?? false,
                                          );
                                        },
                                  activeColor: AppColors.primaryGold500,
                                  checkColor: AppColors.greyScale1000,
                                  side: BorderSide(
                                    color: AppColors.grey5Color.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: GetGenericText(
                                    text: l10n.kyc_agreement_desc,
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 13,
                                      tabletVal: 15,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                    lines: 4,
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
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: LoaderButton(
                    title: l10n.accept_agreement,
                    isLoadingState: _isSubmitting,
                    onTap: canSubmit ? _submitAgreement : () {},
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
