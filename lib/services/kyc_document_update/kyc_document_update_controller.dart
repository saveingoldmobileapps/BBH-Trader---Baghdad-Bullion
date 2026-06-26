import 'dart:async';
import 'dart:io';

import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/data/models/user_models/GetUserProfileResponse.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_form.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_queue.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_service.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_submission_builder.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_document_image_util.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_formdata_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_residence_formdata_mapper.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_store.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_submission_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum KycDocumentUpdateStep {
  rejection,
  scan,
  review,
  success,
}

/// Orchestrates single-document iPass re-submission after admin review.
class KycDocumentUpdateController extends ChangeNotifier {
  KycDocumentUpdateController({
    required this.documentType,
    required this.reviewStatus,
    BbhOnboardingForm? form,
  }) : form = form ?? BbhOnboardingForm() {
    BbhOnboardingImageUploadQueue.instance.onUploaded = (key, url) {
      ipassImageUrls[key] = url;
    };
    step = reviewStatus.isRejected
        ? KycDocumentUpdateStep.rejection
        : KycDocumentUpdateStep.scan;
  }

  final KycDocumentType documentType;
  final KycDocumentReviewStatus reviewStatus;

  BbhOnboardingForm form;
  KycDocumentUpdateStep step = KycDocumentUpdateStep.scan;
  IpassScanTarget? activeIpassScan;
  bool get ipassInProgress => activeIpassScan != null;

  IpassKycResult? ipassScanResult;
  IpassFormDataResultResponse? residenceFormDataFront;
  IpassFormDataResultResponse? residenceFormDataBack;
  final Map<String, String> ipassImageUrls = {};

  bool submitInProgress = false;
  String? lastError;
  String? lastSuccess;

  bool get documentCaptured => switch (documentType) {
        KycDocumentType.nationalId => form.idFrontCaptured,
        KycDocumentType.passport => form.passportCaptured,
        KycDocumentType.residency =>
          form.resFrontCaptured && form.resBackCaptured,
      };

  Future<void> loadPersistedState() async {
    final raw = await KycDocumentUpdateStore.instance.loadState(documentType);
    if (raw != null) {
      final formJson = raw['form'];
      if (formJson is Map) {
        form = BbhOnboardingForm.fromJson(Map<String, dynamic>.from(formJson));
      }
      final stepName = raw['step']?.toString();
      if (stepName != null) {
        step = KycDocumentUpdateStep.values.firstWhere(
          (s) => s.name == stepName,
          orElse: () => step,
        );
      }
    }

    if (documentType == KycDocumentType.residency) {
      final residence =
          await KycDocumentUpdateStore.instance.loadResidenceScans();
      residenceFormDataFront = residence.front;
      residenceFormDataBack = residence.back;
    } else {
      ipassScanResult =
          await KycDocumentUpdateStore.instance.loadIpassScan(documentType);
    }

    ipassImageUrls
      ..clear()
      ..addAll(await KycDocumentUpdateStore.instance.loadImageUrls());

    _resumeBackgroundImageUploads();
    notifyListeners();
  }

  void prefillFromProfile(UserProfile? profile) {
    if (profile == null) return;

    final first = profile.firstName?.en?.trim().isNotEmpty == true
        ? profile.firstName!.en!
        : profile.firstName?.ar ?? '';
    final last = profile.surname?.en?.trim().isNotEmpty == true
        ? profile.surname!.en!
        : profile.surname?.ar ?? '';

    switch (documentType) {
      case KycDocumentType.nationalId:
        if (form.arFirst.text.trim().isEmpty) form.arFirst.text = first;
        if (form.arSurname.text.trim().isEmpty) form.arSurname.text = last;
        if (form.dob.text.trim().isEmpty) {
          form.dob.text = profile.dateOfBirthday ?? '';
        }
        if (form.nationality.text.trim().isEmpty) {
          form.nationality.text =
              profile.nationality?.en ?? profile.nationality?.ar ?? 'Iraqi';
        }
      case KycDocumentType.passport:
        if (form.enFirst.text.trim().isEmpty) form.enFirst.text = first;
        if (form.enSurname.text.trim().isEmpty) form.enSurname.text = last;
        if (form.dob.text.trim().isEmpty) {
          form.dob.text = profile.dateOfBirthday ?? '';
        }
      case KycDocumentType.residency:
        if (form.nationality.text.trim().isEmpty) {
          form.nationality.text =
              profile.nationality?.en ?? profile.nationality?.ar ?? 'Iraqi';
        }
    }
    notifyListeners();
  }

  void goToScan() {
    step = KycDocumentUpdateStep.scan;
    notifyListeners();
  }

  void goToReview() {
    if (!documentCaptured) {
      lastError = 'Please scan your document first.';
      notifyListeners();
      return;
    }
    step = KycDocumentUpdateStep.review;
    persist();
    notifyListeners();
  }

  Future<void> persist() async {
    await KycDocumentUpdateStore.instance.saveState(
      type: documentType,
      formJson: form.toJson(),
      step: step.name,
    );

    if (ipassScanResult != null && documentType != KycDocumentType.residency) {
      await KycDocumentUpdateStore.instance.saveIpassScan(
        documentType,
        ipassScanResult!,
      );
    }

    if (documentType == KycDocumentType.residency) {
      await KycDocumentUpdateStore.instance.saveResidenceScans(
        front: residenceFormDataFront,
        back: residenceFormDataBack,
      );
    }

    await KycDocumentUpdateStore.instance.saveImageUrls(ipassImageUrls);
  }

  Future<bool> runIpassKyc() async {
    if (activeIpassScan != null) return false;
    final target = documentType.scanTarget;
    if (target == IpassScanTarget.residence) {
      lastError = 'Use the residence camera capture flow.';
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

  void clearResidenceCaptureProgress() {
    residenceFormDataFront = null;
    residenceFormDataBack = null;
    form.resFrontCaptured = false;
    form.resBackCaptured = false;
    _clearImageUrlsForScanKey('residence');
    notifyListeners();
  }

  Future<bool> processResidenceFrontSide({required File frontImage}) async {
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
      residenceFormDataFront =
          await IpassFormDataService.instance.scanImageFile(
        frontImage,
        sideLabel: 'front',
        email: config.email,
        precomputedBase64: frontBase64,
      );
      residenceFormDataBack = null;
      await persist();
      lastSuccess = 'Front side captured. Now scan the back.';
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

  Future<bool> processResidenceBackSideAndFinalize({
    required File backImage,
  }) async {
    if (residenceFormDataFront == null) {
      lastError = 'Capture the front side first.';
      notifyListeners();
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
      residenceFormDataBack = backResult;

      final htmlFields = IpassResidenceFormdataMapper.toHtmlFields(
        front: residenceFormDataFront,
        back: backResult,
      );
      if (htmlFields.isNotEmpty) {
        form.applyScanValues(IpassScanTarget.residence, htmlFields);
      }

      form.resFrontCaptured = true;
      form.resBackCaptured = true;
      _clearImageUrlsForScanKey('residence');
      await persist();
      _enqueueResidenceImages();
      lastSuccess = 'Residence document captured. Review your details.';
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

  bool validateReviewFields() {
    String tc(TextEditingController c) => c.text.trim();
    bool filled(TextEditingController c) => tc(c).isNotEmpty;

    switch (documentType) {
      case KycDocumentType.nationalId:
        for (final c in [
          form.arFirst,
          form.arFather,
          form.arGf,
          form.arSurname,
          form.idPersonal,
          form.idIssueDate,
          form.idExpiryDate,
        ]) {
          if (!filled(c)) {
            lastError = 'Please complete all national ID fields.';
            notifyListeners();
            return false;
          }
        }
      case KycDocumentType.passport:
        if (form.noPassport) {
          lastError = 'Please scan your passport to continue.';
          notifyListeners();
          return false;
        }
        for (final c in [form.ppNo, form.ppIssue, form.ppExpiry, form.ppPlace]) {
          if (!filled(c)) {
            lastError = 'Please complete all passport fields.';
            notifyListeners();
            return false;
          }
        }
      case KycDocumentType.residency:
        for (final c in [form.resNo, form.resIssue, form.resExpiry]) {
          if (!filled(c)) {
            lastError = 'Please complete all residence card fields.';
            notifyListeners();
            return false;
          }
        }
    }
    return true;
  }

  Future<bool> submitDocument() async {
    if (submitInProgress) return false;
    if (!validateReviewFields()) return false;

    submitInProgress = true;
    lastError = null;
    notifyListeners();

    try {
      final kycReference =
          'BBH-DOC-${documentType.apiKey}-${DateTime.now().millisecondsSinceEpoch}';
      final imageUrls = await _latestImageUrls();
      final submittedAt = DateTime.now();

      final ipassBundle = _buildIpassBundle(imageUrls);
      final fullPayload = BbhOnboardingSubmissionBuilder.build(
        form: form,
        kycReference: kycReference,
        submittedAt: submittedAt,
        ipassBundle: ipassBundle,
      );

      final payload = _documentScopedPayload(fullPayload, ipassBundle);

      final result =
          await KycDocumentUpdateSubmissionService.instance.submit(payload);

      if (!result.success) {
        lastError = result.message ?? 'Could not submit document.';
        notifyListeners();
        return false;
      }

      await KycDocumentUpdateStore.instance.clear(documentType);
      step = KycDocumentUpdateStep.success;
      lastSuccess = result.message;
      notifyListeners();
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

  Map<String, dynamic> _documentScopedPayload(
    Map<String, dynamic> full,
    Map<String, dynamic> ipassBundle,
  ) {
    final scoped = <String, dynamic>{
      'documentType': documentType.apiKey,
      'submissionMeta': {
        'kycReference': full['submissionMeta']?['kycReference'],
        'submittedAt': full['submissionMeta']?['submittedAt'],
        'flow': 'bbh_document_update',
        'version': '1.0',
        'reviewStatus': reviewStatus.name,
      },
      'ipassVerificationData': ipassBundle,
    };

    switch (documentType) {
      case KycDocumentType.nationalId:
        scoped['nationalIdDetails'] = full['nationalIdDetails'];
      case KycDocumentType.passport:
        scoped['passportDetails'] = full['passportDetails'];
      case KycDocumentType.residency:
        scoped['residencyDetails'] = full['residencyDetails'];
        scoped['iraqAddressDetails'] = full['iraqAddressDetails'];
    }

    return scoped;
  }

  Map<String, dynamic> _buildIpassBundle(Map<String, String> imageUrls) {
    if (documentType == KycDocumentType.residency) {
      return IpassOnboardingMapper.sanitizeBundleForSubmission(
        IpassOnboardingMapper.buildResidenceSubmissionPayload(
          front: residenceFormDataFront,
          back: residenceFormDataBack,
          imageUrlsByKey: imageUrls,
          preferImageUrls: true,
          omitUnuploaded: false,
        ),
        imageUrlsByKey: imageUrls,
      );
    }

    final target = documentType.scanTarget;
    final results = <IpassScanTarget, dynamic>{};
    if (ipassScanResult != null) {
      results[target] = ipassScanResult;
    }

    return IpassOnboardingMapper.sanitizeBundleForSubmission(
      IpassOnboardingMapper.buildSubmissionIpassBundle(
        results,
        imageUrlsByKey: imageUrls,
        preferImageUrls: true,
        omitUnuploaded: false,
      ),
      imageUrlsByKey: imageUrls,
    );
  }

  Future<bool> _handleIpassResult(
    IpassKycResult result,
    IpassScanTarget target,
  ) async {
    if (_isIpassDocumentRejected(result.data)) {
      lastError = _ipassRejectionMessage(result.data, target);
      notifyListeners();
      return false;
    }

    ipassScanResult = result;
    _clearImageUrlsForScanKey(IpassOnboardingMapper.scanTargetKeys[target]!);
    _enqueueImagesForTarget(target);

    final mapped = IpassOnboardingMapper.extractFieldValues(
      result.data,
      target: target,
    );
    final htmlFields = IpassHtmlFieldMapper.forScanTarget(
      target,
      IpassHtmlFieldMapper.toHtmlFieldValues(mapped),
    );

    if (htmlFields.isNotEmpty) {
      form.applyScanValues(target, htmlFields);
    }

    switch (target) {
      case IpassScanTarget.nationalId:
        form.idFrontCaptured = true;
        form.idBackCaptured = true;
      case IpassScanTarget.passport:
        form.passportCaptured = true;
      case IpassScanTarget.residence:
        form.resFrontCaptured = true;
        form.resBackCaptured = true;
    }

    await KycDocumentUpdateStore.instance.saveIpassScan(documentType, result);
    await persist();

    lastSuccess = 'Document captured. Review your details before submitting.';
    notifyListeners();
    return true;
  }

  void _enqueueImagesForTarget(IpassScanTarget target) {
    if (!BbhOnboardingImageUploadService.enabled || ipassScanResult == null) {
      return;
    }
    final scanKey = IpassOnboardingMapper.scanTargetKeys[target];
    final images = IpassOnboardingMapper.extractAllImagesFromScanResult(
      ipassScanResult!,
      scanTarget: scanKey,
    );
    if (images.isEmpty) return;
    BbhOnboardingImageUploadQueue.instance.enqueue(
      images,
      alreadyUploaded: ipassImageUrls,
    );
  }

  void _enqueueResidenceImages() {
    if (!BbhOnboardingImageUploadService.enabled) return;
    final bundle = IpassOnboardingMapper.buildResidenceSubmissionPayload(
      front: residenceFormDataFront,
      back: residenceFormDataBack,
      preferImageUrls: false,
      omitUnuploaded: false,
    );
    final images = bundle['ipass_residence_images'];
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

  void _resumeBackgroundImageUploads() {
    if (documentType == KycDocumentType.residency) {
      if (form.resFrontCaptured) _enqueueResidenceImages();
    } else if (ipassScanResult != null) {
      _enqueueImagesForTarget(documentType.scanTarget);
    }
  }

  Future<Map<String, String>> _latestImageUrls() async {
    final fromDisk = await KycDocumentUpdateStore.instance.loadImageUrls();
    ipassImageUrls.addAll(fromDisk);
    return Map<String, String>.from(ipassImageUrls);
  }

  void _clearImageUrlsForScanKey(String scanKey) {
    final prefix = '$scanKey|';
    ipassImageUrls.removeWhere((key, _) => key.startsWith(prefix));
    BbhOnboardingImageUploadQueue.instance.clearForScanKey(scanKey);
  }

  bool _isIpassDocumentRejected(Map<String, dynamic>? data) {
    if (data == null) return false;
    final root = _resolveScanDataRoot(data);
    final overall = root['OverAllStatus']?.toString().toUpperCase();
    if (overall == 'REJECTED') return true;
    final reasons = root['Reason'];
    if (reasons is! List) return false;
    for (final item in reasons) {
      if (item is! Map) continue;
      if (item['Status']?.toString().toUpperCase() == 'REJECTED') return true;
    }
    return false;
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
}
