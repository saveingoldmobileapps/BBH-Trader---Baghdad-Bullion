import 'dart:async';

import 'package:baghdad_bullion_house/services/ipass_kyc/bbh_onboarding_state_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  BbhOnboardingController({BbhOnboardingForm? form})
    : form = form ?? BbhOnboardingForm();

  BbhOnboardingForm form;
  BbhOnboardingStep step = BbhOnboardingStep.cover;
  IpassScanTarget? activeIpassScan;
  bool get ipassInProgress => activeIpassScan != null;
  IpassKycResult? ipassResult;
  String? kycReference;

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
    ipassResult = null;
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
    if (!validateCurrent()) return;
    final idx = _stepIndex(step);
    if (idx < 0 || idx >= BbhOnboardingStep.values.length - 1) return;
    goTo(BbhOnboardingStep.values[idx + 1]);
  }

  void back() {
    final idx = _stepIndex(step);
    if (idx <= 0) return;
    goTo(BbhOnboardingStep.values[idx - 1]);
  }

  int _stepIndex(BbhOnboardingStep s) => BbhOnboardingStep.values.indexOf(s);

  bool validateCurrent() {
    switch (step) {
      case BbhOnboardingStep.purpose:
        return _require(form.purposeConfirmed, 'Please confirm Section 1.');
      case BbhOnboardingStep.ocrReview:
        return _validateOcr();
      case BbhOnboardingStep.residenceAddress:
        return _validateResidence();
      case BbhOnboardingStep.personalDetails:
        return _validatePersonal();
      case BbhOnboardingStep.income:
        return _validateIncome();
      case BbhOnboardingStep.fatca:
        return form.fatca != 'Yes' ||
            (_filled(form.fatcaTin) && _filled(form.fatcaAddr));
      case BbhOnboardingStep.pep:
        return form.pep != 'Yes' ||
            (_filled(form.pepPosition) &&
                _filled(form.pepCountry) &&
                _filled(form.pepFrom) &&
                _filled(form.pepTo));
      case BbhOnboardingStep.contact:
        if (!_filled(form.mobile) || !_filled(form.email)) {
          return _fail('Enter mobile and email.');
        }
        if (!form.verifiedMobile.value || !form.verifiedEmail.value) {
          return _fail('Verify mobile and email before continuing.');
        }
        return true;
      case BbhOnboardingStep.consent:
        if (!form.hasSignature) return _fail('Please provide your signature.');
        if (!form.consentConfirmed) {
          return _fail('Please confirm Section 6 has been read.');
        }
        return true;
      default:
        return true;
    }
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
      if (c == null || !_filled(c))
        return _fail('Please fill all required fields.');
    }
    if (!form.noPassport) {
      if (!_filled(form.ppNo) ||
          !_filled(form.ppPlace) ||
          !_filled(form.ppIssue) ||
          !_filled(form.ppExpiry)) {
        return _fail('Complete passport fields or skip passport.');
      }
    }
    final personal = form.idPersonal.text.trim();
    if (!RegExp(r'^\d{12}$').hasMatch(personal)) {
      return _fail('Personal Number must be exactly 12 digits.');
    }
    final serial = form.idSerial.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]\d{8}$').hasMatch(serial)) {
      return _fail('ID Number must be one letter + 8 digits.');
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
      if (c == null || !_filled(c))
        return _fail('Please fill all address fields.');
    }
    if (form.foreignRes == 'Yes' && !_filled(form.foreignResCountry)) {
      return _fail('Enter foreign residency country.');
    }
    if (form.foreignCit == 'Yes' && !_filled(form.foreignCitCountry)) {
      return _fail('Enter foreign citizenship country.');
    }
    return true;
  }

  bool _validatePersonal() {
    if (form.gender == null) return _fail('Select gender.');
    if (!_filled(form.nationality) ||
        !_filled(form.dob) ||
        !_filled(form.countryBirth) ||
        !_filled(form.placeBirth)) {
      return _fail('Complete all personal details.');
    }
    return true;
  }

  bool _validateIncome() {
    if (form.education == null || form.sector == null) {
      return _fail('Select education and sector.');
    }
    if (!_filled(form.income) ||
        !_filled(form.occupation) ||
        !_filled(form.employer) ||
        !_filled(form.employerAddr)) {
      return _fail('Complete income and employment fields.');
    }
    return true;
  }

  bool _filled(TextEditingController c) => c.text.trim().isNotEmpty;

  String? lastError;
  String? lastWarning;
  String? lastSuccess;

  bool _fail(String msg) {
    lastError = msg;
    notifyListeners();
    return false;
  }

  bool _require(bool ok, String msg) => ok ? true : _fail(msg);

  bool _applyIpassDocumentFields(IpassKycResult result, IpassScanTarget target) {
    final mapped = IpassOnboardingMapper.extractFieldValues(result.data, target: target);
    final htmlFields = IpassHtmlFieldMapper.forScanTarget(
      target,
      IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
    );

    if (kDebugMode) {
      if (target == IpassScanTarget.residence || target == IpassScanTarget.passport) {
        IpassOnboardingMapper.logDocumentScanDebug(
          target: target,
          ipassData: result.data,
          mapped: mapped,
          formFields: htmlFields,
        );
      } else {
        IpassOnboardingMapper.logMappedFields(mapped);
      }
    }

    if (htmlFields.isEmpty) return false;

    form.applyScanValues(target, htmlFields);
    return true;
  }

  bool _faceVerificationRejected(Map<String, dynamic>? data) {
    if (data == null) return false;
    final overall = data['OverAllStatus']?.toString().toUpperCase();
    if (overall == 'REJECTED') return true;

    final reasons = data['Reason'];
    if (reasons is! List) return false;
    for (final item in reasons) {
      if (item is! Map) continue;
      final text = item['Text']?.toString().toLowerCase() ?? '';
      if (text.contains('face') || text.contains('liveness')) return true;
    }
    return false;
  }

  Future<bool> _handleIpassResult(IpassKycResult result, IpassScanTarget target) async {
    ipassResult = result;
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

  Future<bool> runIpassKyc(IpassScanTarget target) async {
    if (activeIpassScan != null) return false;
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
    goTo(BbhOnboardingStep.success);
  }

  void resetAll() {
    final old = form;
    form = BbhOnboardingForm();
    old.dispose();
    step = BbhOnboardingStep.cover;
    ipassResult = null;
    kycReference = null;
    BbhOnboardingStateStore.instance.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
