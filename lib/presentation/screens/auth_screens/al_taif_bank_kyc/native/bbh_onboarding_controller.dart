import 'dart:async';
import 'dart:io';

import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_builder.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_logger.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/bbh_onboarding_state_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_formdata_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_document_image_util.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_residence_formdata_mapper.dart';
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

  BbhOnboardingController({BbhOnboardingForm? form})
    : form = form ?? BbhOnboardingForm();

  BbhOnboardingForm form;
  BbhOnboardingStep step = BbhOnboardingStep.cover;
  BbhOnboardingStep? editReturnStep;
  IpassScanTarget? activeIpassScan;
  bool get ipassInProgress => activeIpassScan != null;
  final Map<IpassScanTarget, IpassKycResult> ipassScanResults = {};
  IpassFormDataResultResponse? residenceFormDataFront;
  IpassFormDataResultResponse? residenceFormDataBack;
  String? kycReference;
  Map<String, dynamic>? submissionPayload;

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
    if (raw == null) {
      notifyListeners();
      return;
    }

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
      // Resume in-progress onboarding — skip cover when a later step was saved.
      if (restoredStep != BbhOnboardingStep.cover &&
          restoredStep != BbhOnboardingStep.success) {
        step = restoredStep;
      }
    }

    kycReference = raw['kycReference']?.toString();
    ipassScanResults.clear();
    notifyListeners();
  }

  void _copyForm(BbhOnboardingForm source) {
    form.copyValuesFrom(source);
  }

  Future<void> persist() async {
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
      'en_first',
      'en_father',
      'en_gf',
      'en_surname',
      'en_mother',
      'id_personal',
      'id_serial',
      'id_issue_place',
      'id_issue_date',
      'id_expiry_date',
    ];
    for (final key in required) {
      final c = form.controllerFor(key);
      if (c == null || !_filled(c)) {
        return _fail('Please fill all required fields.', fieldKey: key);
      }
    }
    if (!form.noPassport) {
      for (final key in ['pp_no', 'pp_place', 'pp_issue', 'pp_expiry']) {
        final c = form.controllerFor(key);
        if (c == null || !_filled(c)) {
          return _fail('Complete passport fields or skip passport.', fieldKey: key);
        }
      }
    }
    final personal = form.idPersonal.text.trim();
    if (!RegExp(r'^\d{12}$').hasMatch(personal)) {
      return _fail('Personal Number must be exactly 12 digits.', fieldKey: 'id_personal');
    }
    final serial = form.idSerial.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]\d{8}$').hasMatch(serial)) {
      return _fail('ID Number must be one letter + 8 digits.', fieldKey: 'id_serial');
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
      return _fail('Enter foreign residency country.', fieldKey: 'foreign_res_country');
    }
    if (form.foreignCit == 'Yes' && !_filled(form.foreignCitCountry)) {
      return _fail('Enter foreign citizenship country.', fieldKey: 'foreign_cit_country');
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
    if (!bypassMobileVerification && !form.verifiedMobile.value) {
      return _fail('Verify your mobile number before continuing.', fieldKey: 'mobile');
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
      return _fail('Enter a valid Iraqi IBAN (IQ + 21 characters).', fieldKey: 'iban');
    }
    return true;
  }

  bool _validateConsent() {
    if (!form.hasSignature) {
      return _fail('Please provide your signature.', fieldKey: 'signature');
    }
    if (!form.consentConfirmed) {
      return _fail('Please confirm Section 6 has been read.', fieldKey: 'consent_confirmed');
    }
    return true;
  }

  bool _filled(TextEditingController c) => c.text.trim().isNotEmpty;

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

  bool _applyIpassDocumentFields(IpassKycResult result, IpassScanTarget target) {
    final mapped = IpassOnboardingMapper.extractFieldValues(result.data, target: target);
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
    return true;
  }

  bool _faceVerificationRejected(Map<String, dynamic>? data) {
    if (data == null) return false;
    final root = _resolveScanDataRoot(data);
    final overall = root['OverAllStatus']?.toString().toUpperCase();
    if (overall == 'REJECTED') return true;

    final reasons = root['Reason'];
    if (reasons is! List) return false;
    for (final item in reasons) {
      if (item is! Map) continue;
      final text = item['Text']?.toString().toLowerCase() ?? '';
      if (text.contains('face') || text.contains('liveness')) return true;
    }
    return false;
  }

  Map<String, dynamic> _resolveScanDataRoot(Map<String, dynamic> data) {
    var current = data;
    for (var depth = 0; depth < 4; depth++) {
      if (current.containsKey('OverAllStatus') || current.containsKey('DocDetails')) {
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

  Future<bool> _handleIpassResult(IpassKycResult result, IpassScanTarget target) async {
    ipassScanResults[target] = result;
    final docApplied = _applyIpassDocumentFields(result, target);

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
          final faceRejected = _faceVerificationRejected(result.data);
          if (faceRejected) {
            lastWarning =
                'Document details captured. Face verification failed — tap Continue to review.';
          } else {
            lastSuccess = 'Document captured. Tap Continue to review your details.';
          }
        case IpassScanTarget.residence:
          lastSuccess =
              'Residence card captured. Details will appear on the next screen.';
        case IpassScanTarget.passport:
          lastSuccess =
              'Passport captured. Missing English name fields were filled where available.';
      }
      notifyListeners();
      return true;
    }

    if (!result.success || !result.apiStatus) {
      lastError = switch (target) {
        IpassScanTarget.nationalId => 'Identity verification failed.',
        IpassScanTarget.residence => 'Residence card scan failed. Please try again.',
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
    notifyListeners();
  }

  /// Step 1: capture front → encode → OCR. Does not mark document as captured.
  Future<bool> processResidenceFrontSide({required File frontImage}) async {
    if (activeIpassScan != null && activeIpassScan != IpassScanTarget.residence) {
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

      final frontBase64 = await IpassDocumentImageUtil.encodeToBase64(frontImage);
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
  Future<bool> processResidenceBackSideAndFinalize({required File backImage}) async {
    if (residenceFormDataFront == null) {
      lastError = 'Capture the front side first.';
      notifyListeners();
      return false;
    }
    if (activeIpassScan != null && activeIpassScan != IpassScanTarget.residence) {
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
        final residenceEnvelope =
            scans is Map ? scans['residence'] : null;
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
        form.applyScanValues(IpassScanTarget.residence, htmlFields);
      }

      form.resFrontCaptured = true;
      form.resBackCaptured = true;
      await persist();

      lastSuccess = htmlFields.isEmpty
          ? 'Residence document captured (front & back). Enter details on the next screen.'
          : 'Residence document captured. Details will appear on the next screen.';
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

  void submitPack() {
    kycReference =
        'BBH-KYC-${DateTime.now().year.toString().substring(2)}'
        '${DateTime.now().month.toString().padLeft(2, '0')}'
        '${DateTime.now().day.toString().padLeft(2, '0')}-'
        '${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final ipassBundle = IpassOnboardingMapper.mergeSubmissionBundles(
      IpassOnboardingMapper.buildSubmissionIpassBundle(ipassScanResults),
      IpassOnboardingMapper.buildResidenceSubmissionPayload(
        front: residenceFormDataFront,
        back: residenceFormDataBack,
      ),
    );
    final submittedAt = DateTime.now();
    submissionPayload = BbhOnboardingSubmissionBuilder.build(
      form: form,
      kycReference: kycReference!,
      submittedAt: submittedAt,
      ipassBundle: ipassBundle,
    );
    try {
      BbhOnboardingSubmissionLogger.logFinalSubmissionOnce(submissionPayload!);
    } catch (_) {
      // Logging must never block the success screen.
    }

    goTo(BbhOnboardingStep.success);
    unawaited(persist());
  }

  void resetAll() {
    final old = form;
    form = BbhOnboardingForm();
    old.dispose();
    step = BbhOnboardingStep.cover;
    editReturnStep = null;
    ipassScanResults.clear();
    residenceFormDataFront = null;
    residenceFormDataBack = null;
    kycReference = null;
    submissionPayload = null;
    BbhOnboardingStateStore.instance.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
