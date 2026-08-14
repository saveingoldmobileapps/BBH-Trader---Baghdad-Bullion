import 'dart:async';
import 'dart:io';

import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_queue.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_service.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_url_store.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_scan_store.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_builder.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_logger.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_service.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_phone_number_util.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/bbh_onboarding_state_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_document_image_util.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_formdata_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_residence_formdata_mapper.dart';
import 'package:baghdad_bullion_house/core/kyc/ipass_document_rejection_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bbh_onboarding_field_scroll.dart';
import 'bbh_onboarding_form.dart';

enum BbhOnboardingStep {
  cover,
  preflight,
  purpose,
  documents,
  ocrReview,
  residenceAddress,
  personalDetails,
  income,
  fatca,
  pep,
  contact,
  custodian,
  consent,
  review,
  success,
}

extension BbhOnboardingStepX on BbhOnboardingStep {
  bool get hidesChrome =>
      this == BbhOnboardingStep.cover || this == BbhOnboardingStep.success;

  bool get isFinalFlowStep => this == BbhOnboardingStep.review;
}

class BbhOnboardingController extends ChangeNotifier {
  /// Temporary — allow continuing without WhatsApp/mobile OTP until numbers are available.
  static const bypassMobileVerification = true;

  /// Per-document iPass rejection bypass — see [IpassDocumentRejectionPolicy].

  /// Stable key for signature upload in [ipassImageUrls].
  static const signatureImageKey = 'signature|consent|signatureImage';

  BbhOnboardingController({BbhOnboardingForm? form})
    : form = form ?? BbhOnboardingForm() {
    BbhOnboardingImageUploadQueue.instance.onUploaded = (key, url) {
      ipassImageUrls[key] = url;
    };
  }

  BbhOnboardingForm form;
  BbhOnboardingStep step = BbhOnboardingStep.cover;
  BbhOnboardingStep? editReturnStep;
  IpassScanTarget? activeIpassScan;
  bool get ipassInProgress => activeIpassScan != null;
  final Map<IpassScanTarget, IpassKycResult> ipassScanResults = {};
  final Map<String, String> ipassImageUrls = {};
  IpassFormDataResultResponse? residenceFormDataFront;
  IpassFormDataResultResponse? residenceFormDataBack;
  String? kycReference;
  Map<String, dynamic>? submissionPayload;
  Map<String, dynamic>? lastSubmissionResponse;
  bool submitInProgress = false;

  static const flowSteps = [
    BbhOnboardingStep.preflight,
    BbhOnboardingStep.purpose,
    BbhOnboardingStep.documents,
    BbhOnboardingStep.ocrReview,
    BbhOnboardingStep.residenceAddress,
    BbhOnboardingStep.personalDetails,
    BbhOnboardingStep.income,
    BbhOnboardingStep.fatca,
    BbhOnboardingStep.pep,
    BbhOnboardingStep.contact,
    BbhOnboardingStep.custodian,
    BbhOnboardingStep.consent,
    BbhOnboardingStep.review,
  ];

  int get progressIndex {
    if (step.hidesChrome) return 0;
    final idx = flowSteps.indexOf(step);
    return idx < 0 ? 0 : idx + 1;
  }

  double get progressFraction => progressIndex / flowSteps.length;

  Future<void> loadPersistedState() async {
    final raw = BbhOnboardingStateStore.instance.load();

    if (raw != null) {
      final formJson = raw['form'];
      if (formJson is Map) {
        final restored = BbhOnboardingForm.fromJson(
          Map<String, dynamic>.from(formJson),
        );
        _copyForm(restored);
      }

      final stepName = raw['step']?.toString();
      if (stepName != null && stepName.isNotEmpty) {
        final restoredStep = BbhOnboardingStep.values.firstWhere(
          (s) => s.name == stepName,
          orElse: () => BbhOnboardingStep.cover,
        );
        if (restoredStep != BbhOnboardingStep.cover &&
            restoredStep != BbhOnboardingStep.success) {
          step = restoredStep;
        }
      }

      kycReference = raw['kycReference']?.toString();
    }

    final scans = await BbhOnboardingScanStore.instance.loadIpassScans();
    ipassScanResults
      ..clear()
      ..addAll(scans);

    final residence = await BbhOnboardingScanStore.instance
        .loadResidenceScans();
    residenceFormDataFront = residence.front;
    residenceFormDataBack = residence.back;

    ipassImageUrls
      ..clear()
      ..addAll(await BbhOnboardingImageUrlStore.instance.load());

    _resumeBackgroundImageUploads();
    _resumeSignatureUploadIfNeeded();

    notifyListeners();
  }

  void _resumeSignatureUploadIfNeeded() {
    if (!BbhOnboardingImageUploadService.enabled) return;
    final existing = ipassImageUrls[signatureImageKey]?.trim();
    if (existing != null && existing.isNotEmpty) return;
    final sig = form.signature?.trim();
    if (sig == null || sig.isEmpty) return;
    unawaited(_uploadSignature(sig));
  }

  /// Stores signature locally and uploads to iPass doc endpoint in background.
  void setSignature(String? base64) {
    form.signature = base64;
    ipassImageUrls.remove(signatureImageKey);
    notifyListeners();

    if (base64 == null || base64.trim().isEmpty) {
      unawaited(BbhOnboardingImageUrlStore.instance.save(ipassImageUrls));
      return;
    }
    unawaited(_uploadSignature(base64.trim()));
  }

  Future<String?> _ensureSignatureImageUrl() async {
    final cached = ipassImageUrls[signatureImageKey]?.trim();
    if (cached != null && cached.isNotEmpty) return cached;

    final fromDisk = await BbhOnboardingImageUrlStore.instance.load();
    ipassImageUrls.addAll(fromDisk);
    final stored = ipassImageUrls[signatureImageKey]?.trim();
    if (stored != null && stored.isNotEmpty) return stored;

    final sig = form.signature?.trim();
    if (sig == null || sig.isEmpty) return null;

    return _uploadSignature(sig);
  }

  Future<String?> _uploadSignature(String base64) async {
    if (!BbhOnboardingImageUploadService.enabled) return null;

    final url = await BbhOnboardingImageUploadService.instance.uploadBase64Image(
      base64: base64,
      fileNameStem: 'bbh_signature',
      mimeType: 'image/png',
    );

    if (url != null && url.isNotEmpty) {
      ipassImageUrls[signatureImageKey] = url;
      await BbhOnboardingImageUrlStore.instance.save(ipassImageUrls);
      if (kDebugMode) {
        debugPrint('BbhImageUpload: signature uploaded → $url');
      }
      notifyListeners();
      return url;
    }

    if (kDebugMode) {
      debugPrint('BbhImageUpload: signature upload failed');
    }
    return null;
  }

  /// Re-queue any scan images that still need uploading after app restart.
  void _resumeBackgroundImageUploads() {
    if (!BbhOnboardingImageUploadService.enabled) return;

    final allImages = IpassOnboardingMapper.collectUploadableImages(
      scanResults: ipassScanResults,
      residenceFront: residenceFormDataFront,
      residenceBack: residenceFormDataBack,
    );
    BbhOnboardingImageUploadQueue.instance.enqueueMissing(
      allImages: allImages,
      uploaded: ipassImageUrls,
    );
  }

  void _copyForm(BbhOnboardingForm source) {
    form.copyValuesFrom(source);
  }

  Future<void> persist() async {
    await BbhOnboardingScanStore.instance.saveIpassScans(ipassScanResults);
    await BbhOnboardingScanStore.instance.saveResidenceScans(
      front: residenceFormDataFront,
      back: residenceFormDataBack,
    );
    await BbhOnboardingImageUrlStore.instance.save(ipassImageUrls);
    await BbhOnboardingStateStore.instance.save({
      'step': step.name,
      'form': form.toJson(),
      if (kycReference != null) 'kycReference': kycReference,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  void goTo(BbhOnboardingStep target) {
    step = target;
    unawaited(persist());
    notifyListeners();
  }

  void next() {
    if (editReturnStep != null) {
      if (!validateCurrent()) return;
      final back = editReturnStep!;
      editReturnStep = null;
      goTo(back);
      return;
    }
    if (!validateCurrent()) return;
    final idx = _stepIndex(step);
    if (idx < 0 || idx >= BbhOnboardingStep.values.length - 1) return;
    goTo(BbhOnboardingStep.values[idx + 1]);
  }

  void back() {
    if (editReturnStep != null) {
      editReturnStep = null;
      goTo(BbhOnboardingStep.review);
      return;
    }
    final idx = _stepIndex(step);
    if (idx <= 0) return;
    goTo(BbhOnboardingStep.values[idx - 1]);
  }

  void jumpToEdit(BbhOnboardingStep target) {
    editReturnStep = BbhOnboardingStep.review;
    goTo(target);
  }

  int _stepIndex(BbhOnboardingStep s) => BbhOnboardingStep.values.indexOf(s);

  String? validationFocusField;

  void consumeValidationFocus() => validationFocusField = null;

  bool validateCurrent() {
    final ok = switch (step) {
      BbhOnboardingStep.purpose => _require(
        form.purposeConfirmed,
        'Please confirm Section 1.',
        fieldKey: 'purpose_confirmed',
      ),
      BbhOnboardingStep.ocrReview => _validateOcr(),
      BbhOnboardingStep.residenceAddress => _validateResidence(),
      BbhOnboardingStep.personalDetails => _validatePersonal(),
      BbhOnboardingStep.income => _validateIncome(),
      BbhOnboardingStep.fatca => _validateFatca(),
      BbhOnboardingStep.pep => _validatePep(),
      BbhOnboardingStep.contact => _validateContact(),
      BbhOnboardingStep.custodian => _validateCustodian(),
      BbhOnboardingStep.consent => _validateConsent(),
      _ => true,
    };
    if (ok) {
      BbhOnboardingFieldScroll.clearError();
      validationFocusField = null;
    }
    return ok;
  }

  bool _validateOcr() {
    const required = [
      'ar_first',
      'ar_father',
      'ar_gf',
      'ar_surname',
      'ar_mother',
      // 'id_en_first',
      // 'id_en_surname',
      'id_personal',
      'id_serial',
      'id_issue_place',
      'id_issue_date',
      'id_expiry_date',
    ];
    for (final key in required) {
      if (!_fieldFilled(key)) {
        return _fail('Please fill all required fields.', fieldKey: key);
      }
    }
    // if (form.noPassport) {
    //   for (final key in [
    //     'id_en_father',
    //     'id_en_gf',
    //     'id_en_mother',
    //   ]) {
    //     if (!_fieldFilled(key)) {
    //       return _fail('Please fill all required fields.', fieldKey: key);
    //     }
    //   }
    // }
    if (!form.noPassport) {
      for (final key in [
        'en_first',
        'en_father',
        'en_gf',
        'en_surname',
        'en_mother',
        'pp_no',
        'pp_place',
        'pp_issue',
        'pp_expiry',
      ]) {
        if (!_fieldFilled(key)) {
          return _fail(
            'Complete passport fields or skip passport.',
            fieldKey: key,
          );
        }
      }
    }
    final personal = form.idPersonal.text.trim();
    if (!RegExp(r'^\d{12}$').hasMatch(personal)) {
      return _fail(
        'Personal Number must be exactly 12 digits.',
        fieldKey: 'id_personal',
      );
    }
    final serial = form.idSerial.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]\d{8}$').hasMatch(serial)) {
      return _fail(
        'ID Number must be one letter + 8 digits.',
        fieldKey: 'id_serial',
      );
    }
    return true;
  }

  bool _validateResidence() {
    const required = [
      'res_no',
      'res_place',
      'res_issue',
      'addr_gov',
      'addr_district',
      'addr_city',
      'addr_mahalla',
      'addr_street',
      'addr_house',
      'addr_landmark_ar',
    ];
    for (final key in required) {
      final c = form.controllerFor(key);
      if (c == null || !_filled(c)) {
        return _fail('Please fill all address fields.', fieldKey: key);
      }
    }
    if (form.foreignRes == 'Yes' && !_filled(form.foreignResCountry)) {
      return _fail(
        'Enter foreign residency country.',
        fieldKey: 'foreign_res_country',
      );
    }
    if (form.foreignCit == 'Yes' && !_filled(form.foreignCitCountry)) {
      return _fail(
        'Enter foreign citizenship country.',
        fieldKey: 'foreign_cit_country',
      );
    }
    return true;
  }

  bool _validatePersonal() {
    if (form.gender == null) {
      return _fail('Select gender.', fieldKey: 'gender');
    }
    for (final key in ['nationality', 'dob', 'country_birth', 'place_birth']) {
      final c = form.controllerFor(key);
      if (c == null || !_filled(c)) {
        return _fail('Complete all personal details.', fieldKey: key);
      }
    }
    return true;
  }

  bool _validateIncome() {
    if (form.education == null) {
      return _fail('Select education level.', fieldKey: 'education');
    }
    if (form.sector == null) {
      return _fail('Select economic sector.', fieldKey: 'sector');
    }
    for (final key in ['income', 'occupation', 'employer', 'employer_addr']) {
      final c = form.controllerFor(key);
      if (c == null || !_filled(c)) {
        return _fail('Complete income and employment fields.', fieldKey: key);
      }
    }
    return true;
  }

  bool _validateFatca() {
    if (form.fatca != 'Yes') return true;
    if (!_filled(form.fatcaTin)) {
      return _fail('Enter your U.S. TIN / SSN.', fieldKey: 'fatca_tin');
    }
    if (!_filled(form.fatcaAddr)) {
      return _fail('Enter your U.S. address.', fieldKey: 'fatca_addr');
    }
    return true;
  }

  bool _validatePep() {
    if (form.pep != 'Yes') return true;
    for (final key in ['pep_position', 'pep_country', 'pep_from', 'pep_to']) {
      final c = form.controllerFor(key);
      if (c == null || !_filled(c)) {
        return _fail('Complete all PEP fields.', fieldKey: key);
      }
    }
    return true;
  }

  bool _validateContact() {
    if (!_filled(form.mobile)) {
      return _fail('Enter your mobile number.', fieldKey: 'mobile');
    }
    if (!BbhPhoneNumberUtil.isValidInput(form.mobile.text)) {
      return _fail(
        'Enter a valid mobile number starting with 00 or +.',
        fieldKey: 'mobile',
      );
    }
    if (!bypassMobileVerification && !form.verifiedMobile.value) {
      return _fail(
        'Verify your mobile number before continuing.',
        fieldKey: 'mobile',
      );
    }
    if (!_filled(form.email)) {
      return _fail('Enter your email address.', fieldKey: 'email');
    }
    if (!form.verifiedEmail.value) {
      return _fail('Verify your email before continuing.', fieldKey: 'email');
    }
    return true;
  }

  bool _validateCustodian() {
    if (form.hasAccount != 'Yes') return true;
    final iban = form.iban.text.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!RegExp(r'^IQ[A-Z0-9]{21}$').hasMatch(iban)) {
      return _fail(
        'Enter a valid Iraqi IBAN (IQ + 21 characters).',
        fieldKey: 'iban',
      );
    }
    return true;
  }

  bool _validateConsent() {
    if (!form.hasSignature) {
      return _fail('Please provide your signature.', fieldKey: 'signature');
    }
    if (!form.consentConfirmed) {
      return _fail(
        'Please confirm Section 6 has been read.',
        fieldKey: 'consent_confirmed',
      );
    }
    return true;
  }


  bool _filled(TextEditingController c) => c.text.trim().isNotEmpty;

  bool _fieldFilled(String key) {
    if (key == 'gender') {
      return form.gender != null && form.gender!.trim().isNotEmpty;
    }
    final c = form.controllerFor(key);
    return c != null && _filled(c);
  }

  String? lastError;
  String? lastWarning;
  String? lastSuccess;


  bool _fail(String msg, {String? fieldKey}) {
    lastError = msg;
    if (fieldKey != null) {
      validationFocusField = fieldKey;
      BbhOnboardingFieldScroll.markError(fieldKey);
    }
    notifyListeners();
    return false;
  }

  bool _require(bool ok, String msg, {String? fieldKey}) =>
      ok ? true : _fail(msg, fieldKey: fieldKey);

  bool _applyIpassDocumentFields(
    IpassKycResult result,
    IpassScanTarget target,
  ) {
    final mapped = IpassOnboardingMapper.extractFieldValues(
      result.data,
      target: target,
    );
    final htmlFields = IpassHtmlFieldMapper.forScanTarget(
      target,
      IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
    );

    if (kDebugMode) {
      IpassOnboardingMapper.logDocumentScanDebug(
        target: target,
        ipassData: result.data,
        mapped: mapped,
        formFields: htmlFields,
      );
    }

    if (htmlFields.isEmpty) return false;

    form.applyScanValues(target, htmlFields);
    _fillMissingFromOtherDocuments(target);
    return true;
  }

  bool _applyDemoDocumentFields(IpassScanTarget target) {
    final mapped = IpassOnboardingMapper.demoAcceptedMappedFields(target);
    final htmlFields = IpassHtmlFieldMapper.forScanTarget(
      target,
      IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
    );
    if (htmlFields.isEmpty) return false;
    form.applyScanValues(target, htmlFields);
    _fillMissingFromOtherDocuments(target);
    return true;
  }

  /// After a National ID or Passport scan, fill any still-empty fields from the
  /// other document (shared personal data + English name bridge both ways).
  void _fillMissingFromOtherDocuments(IpassScanTarget justScanned) {
    if (justScanned != IpassScanTarget.nationalId &&
        justScanned != IpassScanTarget.passport) {
      return;
    }

    final other = justScanned == IpassScanTarget.nationalId
        ? IpassScanTarget.passport
        : IpassScanTarget.nationalId;

    final otherResult = ipassScanResults[other];
    if (otherResult != null) {
      final mapped = IpassOnboardingMapper.extractFieldValues(
        otherResult.data,
        target: other,
      );
      final htmlFields = IpassHtmlFieldMapper.complementaryFillValues(
        other,
        IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
      );
      if (htmlFields.isNotEmpty) {
        form.applyMissingScanValues(htmlFields);
      }
    }

    // Maximize English names: empty passport en_* ← id_en_* and vice versa.
    form.bridgeMissingEnglishNames();
  }

  String _ipassRejectionMessage(
    Map<String, dynamic>? data,
    IpassScanTarget target,
  ) {
    final docLabel = switch (target) {
      IpassScanTarget.nationalId => 'National ID',
      IpassScanTarget.passport => 'Passport',
      IpassScanTarget.residence => 'Residence card',
    };
    final root = _resolveScanDataRoot(data ?? {});
    final reasons = root['Reason'];
    final texts = <String>[];
    if (reasons is List) {
      for (final item in reasons) {
        if (item is! Map) continue;
        final text = item['Text']?.toString().trim();
        if (text != null && text.isNotEmpty) texts.add(text);
      }
    }
    final header = '$docLabel could not be verified. Please retake the scan.';
    if (texts.isEmpty) return header;
    return '$header\n\n${texts.join('\n')}';
  }

  void _enqueueImagesForTarget(IpassScanTarget target) {
    if (!BbhOnboardingImageUploadService.enabled) {
      if (kDebugMode) debugPrint('BbhImageUpload: disabled');
      return;
    }

    final result = ipassScanResults[target];
    if (result == null) {
      if (kDebugMode) debugPrint('BbhImageUpload: no scan result for $target');
      return;
    }

    final scanKey = IpassOnboardingMapper.scanTargetKeys[target];
    final images = IpassOnboardingMapper.extractAllImagesFromScanResult(
      result,
      scanTarget: scanKey,
    );

    if (kDebugMode) {
      debugPrint(
        'BbhImageUpload: $target — '
        '${IpassOnboardingMapper.describeScanImageDiagnostics(result, scanTarget: scanKey)}',
      );
    }

    if (images.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'BbhImageUpload: $target — nothing to upload (iPass JSON has no base64 images). '
          'API will NOT be called.',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'BbhImageUpload: $target — queueing ${images.length} image(s)',
      );
    }

    BbhOnboardingImageUploadQueue.instance.enqueue(
      images,
      alreadyUploaded: ipassImageUrls,
    );
  }

  void _enqueueResidenceImages() {
    if (!BbhOnboardingImageUploadService.enabled) return;
    if (residenceFormDataFront == null && residenceFormDataBack == null) return;

    final residenceBundle =
        IpassOnboardingMapper.buildResidenceSubmissionPayload(
          front: residenceFormDataFront,
          back: residenceFormDataBack,
          preferImageUrls: false,
          omitUnuploaded: false,
        );
    final images = residenceBundle['ipass_residence_images'];
    if (images is! List) return;

    final entries = <Map<String, dynamic>>[];
    for (final item in images) {
      if (item is Map) entries.add(Map<String, dynamic>.from(item));
    }

    BbhOnboardingImageUploadQueue.instance.enqueue(
      entries,
      alreadyUploaded: ipassImageUrls,
    );
  }

  Future<Map<String, String>> _latestImageUrls() async {
    final fromDisk = await BbhOnboardingImageUrlStore.instance.load();
    ipassImageUrls.addAll(fromDisk);
    return Map<String, String>.from(ipassImageUrls);
  }

  void _clearImageUrlsForTarget(IpassScanTarget target) {
    final scanKey = IpassOnboardingMapper.scanTargetKeys[target];
    if (scanKey == null) return;
    _clearImageUrlsForScanKey(scanKey);
  }

  void _clearImageUrlsForScanKey(String scanKey) {
    final prefix = '$scanKey|';
    ipassImageUrls.removeWhere((key, _) => key.startsWith(prefix));
    BbhOnboardingImageUploadQueue.instance.clearForScanKey(scanKey);
    unawaited(_persistImageUrlsForScanKey(scanKey));
  }

  Future<void> _persistImageUrlsForScanKey(String scanKey) async {
    final prefix = '$scanKey|';
    final stored = await BbhOnboardingImageUrlStore.instance.load();
    stored.removeWhere((key, _) => key.startsWith(prefix));
    await BbhOnboardingImageUrlStore.instance.save(stored);
    ipassImageUrls
      ..clear()
      ..addAll(stored);
  }

  Map<String, dynamic> _resolveScanDataRoot(Map<String, dynamic> data) {
    var current = data;
    for (var depth = 0; depth < 4; depth++) {
      if (current.containsKey('OverAllStatus') ||
          current.containsKey('DocDetails')) {
        return current;
      }
      final inner = current['data'];
      if (inner is Map<String, dynamic>) {
        current = inner;
      } else if (inner is Map) {
        current = Map<String, dynamic>.from(inner);
      } else {
        break;
      }
    }
    return current;
  }

  Future<bool> _handleIpassResult(
    IpassKycResult result,
    IpassScanTarget target,
  ) async {
    final rejected = IpassDocumentRejectionPolicy.isScanRejected(result.data);
    final bypass = IpassDocumentRejectionPolicy.bypassRejectionFor(target);

    if (rejected && !bypass) {
      lastError = _ipassRejectionMessage(result.data, target);
      lastWarning = null;
      lastSuccess = null;
      notifyListeners();
      return false;
    }

    ipassScanResults[target] = result;
    _clearImageUrlsForTarget(target);
    _enqueueImagesForTarget(target);

    var docApplied = _applyIpassDocumentFields(result, target);
    var usedDemoFallback = false;
    if (!docApplied && rejected && bypass) {
      docApplied = _applyDemoDocumentFields(target);
      usedDemoFallback = docApplied;
    }

    if (docApplied) {
      switch (target) {
        case IpassScanTarget.nationalId:
          form.idFrontCaptured = true;
          form.idBackCaptured = true;
        case IpassScanTarget.residence:
          form.resFrontCaptured = true;
          form.resBackCaptured = true;
        case IpassScanTarget.passport:
          form.passportCaptured = true;
      }
      await persist();

      switch (target) {
        case IpassScanTarget.nationalId:
          if (rejected && bypass) {
            lastWarning = usedDemoFallback
                ? 'Demo mode: iPass rejected this scan. Sample national ID data was filled for testing.'
                : 'Demo mode: iPass rejected this scan but OCR data was filled for testing.';
          } else {
            lastSuccess =
                'Document captured. Tap Continue to review your details.';
          }
        case IpassScanTarget.residence:
          lastSuccess =
              'Residence card captured. Details will appear on the next screen.';
        case IpassScanTarget.passport:
          if (rejected && bypass) {
            lastWarning = usedDemoFallback
                ? 'Demo mode: iPass rejected this scan. Sample passport data was filled for testing.'
                : 'Demo mode: iPass rejected this scan but OCR data was filled for testing.';
          } else {
            lastSuccess =
                'Passport captured. Missing English name fields were filled where available.';
          }
      }
      notifyListeners();
      return true;
    }

    if (!result.success || !result.apiStatus) {
      lastError = switch (target) {
        IpassScanTarget.nationalId => 'Identity verification failed.',
        IpassScanTarget.residence =>
          'Residence card scan failed. Please try again.',
        IpassScanTarget.passport => 'Passport scan failed. Please try again.',
      };
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  /// Clears in-progress residence OCR before a new capture attempt.
  void clearResidenceCaptureProgress() {
    residenceFormDataFront = null;
    residenceFormDataBack = null;
    form.resFrontCaptured = false;
    form.resBackCaptured = false;
    _clearImageUrlsForScanKey('residence');
    notifyListeners();
  }

  /// Step 1: capture front → encode → OCR. Does not mark document as captured.
  Future<bool> processResidenceFrontSide({required File frontImage}) async {
    if (activeIpassScan != null &&
        activeIpassScan != IpassScanTarget.residence) {
      return false;
    }
    activeIpassScan = IpassScanTarget.residence;
    notifyListeners();
    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      if (config.email.isEmpty || config.password.isEmpty) {
        lastError = 'iPass credentials are not configured.';
        notifyListeners();
        return false;
      }

      final frontBase64 = await IpassDocumentImageUtil.encodeToBase64(
        frontImage,
      );
      final frontResult = await IpassFormDataService.instance.scanImageFile(
        frontImage,
        sideLabel: 'front',
        email: config.email,
        precomputedBase64: frontBase64,
      );

      residenceFormDataFront = frontResult;
      residenceFormDataBack = null;

      lastSuccess = 'Front side processed. Now capture the back side.';
      notifyListeners();
      return true;
    } on IpassFormDataException catch (e) {
      lastError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return false;
    } finally {
      activeIpassScan = null;
      notifyListeners();
    }
  }

  /// Step 2: capture back → encode → OCR → merge with front → mark captured.
  Future<bool> processResidenceBackSideAndFinalize({
    required File backImage,
  }) async {
    if (residenceFormDataFront == null) {
      lastError = 'Capture the front side first.';
      notifyListeners();
      return false;
    }
    if (activeIpassScan != null &&
        activeIpassScan != IpassScanTarget.residence) {
      return false;
    }
    activeIpassScan = IpassScanTarget.residence;
    notifyListeners();
    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      if (config.email.isEmpty || config.password.isEmpty) {
        lastError = 'iPass credentials are not configured.';
        notifyListeners();
        return false;
      }

      final backBase64 = await IpassDocumentImageUtil.encodeToBase64(backImage);
      final backResult = await IpassFormDataService.instance.scanImageFile(
        backImage,
        sideLabel: 'back',
        email: config.email,
        precomputedBase64: backBase64,
      );

      final frontResult = residenceFormDataFront!;
      residenceFormDataBack = backResult;

      final residenceAccepted = IpassDocumentRejectionPolicy.isResidenceOcrAccepted(
        front: frontResult,
        back: backResult,
      );
      final bypassResidency =
          IpassDocumentRejectionPolicy.bypassResidencyRejection;
      if (!residenceAccepted && !bypassResidency) {
        lastError =
            'Residence document could not be verified. Please retake the scan.';
        notifyListeners();
        return false;
      }

      final htmlFields = IpassResidenceFormdataMapper.toHtmlFields(
        front: frontResult,
        back: backResult,
      );

      if (kDebugMode) {
        final residencePayload =
            IpassOnboardingMapper.buildResidenceSubmissionPayload(
              front: frontResult,
              back: backResult,
            );
        final scans = residencePayload['ipass_scans'];
        final residenceEnvelope = scans is Map ? scans['residence'] : null;
        IpassOnboardingMapper.logDocumentScanDebug(
          target: IpassScanTarget.residence,
          ipassData: residenceEnvelope is Map
              ? Map<String, dynamic>.from(residenceEnvelope)
              : {
                  'Apistatus': true,
                  'Apimessage': 'Success',
                  'data': {
                    'DocType': 'Residence Form',
                    'front': frontResult.toJson(),
                    'back': backResult.toJson(),
                  },
                },
          mapped: IpassHtmlFieldMapper.toHtmlFieldValues(
            IpassResidenceFormdataMapper.mapResults(
              front: frontResult,
              back: backResult,
            ),
          ),
          formFields: htmlFields,
        );
      }

      if (htmlFields.isNotEmpty) {
        // Residence OCR is stored for submission only — form fields stay manual.
      }

      form.resFrontCaptured = true;
      form.resBackCaptured = true;
      _clearImageUrlsForScanKey('residence');
      await persist();
      _enqueueResidenceImages();

      lastSuccess = !residenceAccepted && bypassResidency
          ? 'Residence captured (demo mode). Enter details on the next screen.'
          : 'Residence document captured (front & back). Enter details on the next screen.';
      notifyListeners();
      return true;
    } on IpassFormDataException catch (e) {
      lastError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return false;
    } finally {
      activeIpassScan = null;
      notifyListeners();
    }
  }

  Future<bool> runIpassKyc(IpassScanTarget target) async {
    if (activeIpassScan != null) return false;
    if (target == IpassScanTarget.residence) {
      lastError =
          'Residence scan requires camera capture — use the residence capture flow.';
      notifyListeners();
      return false;
    }
    activeIpassScan = target;
    notifyListeners();
    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      if (!config.isValid) {
        lastError = 'Identity verification is not configured.';
        notifyListeners();
        return false;
      }

      final result = await IpassKycService.instance.startKycVerification(
        email: config.email,
        password: config.password,
        appToken: config.appToken,
        workflowId: config.workflowIdFor(target),
        socialMediaEmail: config.socialMediaEmail.isNotEmpty
            ? config.socialMediaEmail
            : config.email,
        phoneNumber: config.phoneNumber,
        serverUrl: config.serverUrl,
        dbType: config.dbType,
        useDynamicDb: config.useDynamicDb,
        enableHologram: config.enableHologram,
      );

      return await _handleIpassResult(result, target);
    } on IpassKycException catch (e) {
      lastError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return false;
    } finally {
      activeIpassScan = null;
      notifyListeners();
    }
  }

  Future<bool> submitPack() async {
    if (submitInProgress) return false;

    submitInProgress = true;
    lastError = null;
    notifyListeners();

    try {
      kycReference =
          'BBH-KYC-${DateTime.now().year.toString().substring(2)}'
          '${DateTime.now().month.toString().padLeft(2, '0')}'
          '${DateTime.now().day.toString().padLeft(2, '0')}-'
          '${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final imageUrls = await _latestImageUrls();
      final uploadQueue = BbhOnboardingImageUploadQueue.instance;
      if (kDebugMode &&
          (uploadQueue.pendingCount > 0 || uploadQueue.failedKeys.isNotEmpty)) {
        debugPrint(
          'BbhImageUpload: submit — pending=${uploadQueue.pendingCount}, '
          'failed=${uploadQueue.failedKeys.length} (empty sent for those images)',
        );
      }

      final ipassBundle = IpassOnboardingMapper.sanitizeBundleForSubmission(
        IpassOnboardingMapper.mergeSubmissionBundles(
          IpassOnboardingMapper.buildSubmissionIpassBundle(
            ipassScanResults,
            imageUrlsByKey: imageUrls,
            preferImageUrls: true,
            omitUnuploaded: false,
          ),
          IpassOnboardingMapper.buildResidenceSubmissionPayload(
            front: residenceFormDataFront,
            back: residenceFormDataBack,
            imageUrlsByKey: imageUrls,
            preferImageUrls: true,
            omitUnuploaded: false,
          ),
        ),
        imageUrlsByKey: imageUrls,
      );
      final submittedAt = DateTime.now();
      final signatureUrl = await _ensureSignatureImageUrl();
      submissionPayload = BbhOnboardingSubmissionBuilder.build(
        form: form,
        kycReference: kycReference!,
        submittedAt: submittedAt,
        ipassBundle: ipassBundle,
        signatureImageUrl: signatureUrl,
      );

      if (kDebugMode) {
        final bytes = IpassOnboardingMapper.estimateJsonBytes(
          submissionPayload!,
        );
        debugPrint(
          'BbhSubmit: payload ~${(bytes / 1024).toStringAsFixed(0)} KB '
          '(${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB)',
        );
        await BbhOnboardingSubmissionLogger.logFinalSubmissionOnce(
          submissionPayload!,
        );
      }

      final result = await BbhOnboardingSubmissionService.instance.submit(
        submissionPayload!,
      );

      if (!result.success) {
        lastError = result.message ?? 'Could not submit onboarding pack.';
        notifyListeners();
        return false;
      }

      final apiKycRef = parseSubmissionKycReference(result.responseData);
      if (apiKycRef != null) {
        kycReference = apiKycRef;
      }

      lastSubmissionResponse = result.responseData;
      goTo(BbhOnboardingStep.success);
      unawaited(persist());
      return true;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return false;
    } finally {
      submitInProgress = false;
      notifyListeners();
    }
  }

  void resetAll() {
    final old = form;
    form = BbhOnboardingForm();
    old.dispose();
    step = BbhOnboardingStep.cover;
    editReturnStep = null;
    ipassScanResults.clear();
    ipassImageUrls.clear();
    residenceFormDataFront = null;
    residenceFormDataBack = null;
    kycReference = null;
    submissionPayload = null;
    lastSubmissionResponse = null;
    submitInProgress = false;
    BbhOnboardingStateStore.instance.clear();
    unawaited(BbhOnboardingScanStore.instance.clear());
    unawaited(BbhOnboardingImageUrlStore.instance.clear());
    notifyListeners();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
