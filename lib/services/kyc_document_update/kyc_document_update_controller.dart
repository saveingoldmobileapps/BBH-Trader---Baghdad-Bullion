import 'dart:async';
import 'dart:io';

import 'package:baghdad_bullion_house/core/kyc/ipass_document_rejection_policy.dart';
import 'package:baghdad_bullion_house/core/kyc/kyc_document_review_status.dart';
import 'package:baghdad_bullion_house/data/models/ipass_model/ipass_formdata_result_response.dart';
import 'package:baghdad_bullion_house/data/models/user_models/GetUserProfileResponse.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_onboarding_form.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_queue.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_upload_service.dart';
import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_image_url_store.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_document_image_util.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_formdata_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_html_field_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_kyc_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_residence_formdata_mapper.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_payload_builder.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_store.dart';
import 'package:baghdad_bullion_house/services/kyc_document_update/kyc_document_update_submission_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum KycDocumentUpdateStep {
  blocked,
  rejection,
  scan,
  review,
  success,
}

/// Orchestrates single-document iPass re-submission after admin review.
class KycDocumentUpdateController extends ChangeNotifier {
  KycDocumentUpdateController({
    required this.documentType,
    ProfileVerificationStatus? verificationStatus,
    bool canRetake = true,
    BbhOnboardingForm? form,
  }) : form = form ?? BbhOnboardingForm() {
    BbhOnboardingImageUploadQueue.instance.onUploaded = (key, url) {
      ipassImageUrls[key] = url;
    };
    step = _initialStep(
      verificationStatus: verificationStatus,
      canRetake: canRetake,
    );
  }

  final KycDocumentType documentType;

  static KycDocumentUpdateStep _initialStep({
    required ProfileVerificationStatus? verificationStatus,
    required bool canRetake,
  }) {
    if (!canRetake) return KycDocumentUpdateStep.blocked;
    if (verificationStatus == ProfileVerificationStatus.rejected) {
      return KycDocumentUpdateStep.rejection;
    }
    return KycDocumentUpdateStep.scan;
  }

  void syncDocumentStatus({
    required ProfileVerificationStatus? verificationStatus,
    required bool canRetake,
  }) {
    if (step == KycDocumentUpdateStep.success) return;

    if (!canRetake) {
      if (step != KycDocumentUpdateStep.blocked) {
        step = KycDocumentUpdateStep.blocked;
        notifyListeners();
      }
      return;
    }

    if (verificationStatus == ProfileVerificationStatus.rejected) {
      if (step != KycDocumentUpdateStep.rejection) {
        step = KycDocumentUpdateStep.rejection;
        notifyListeners();
      }
      return;
    }

    if (step == KycDocumentUpdateStep.blocked) {
      step = KycDocumentUpdateStep.scan;
      notifyListeners();
    }
  }

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

      final residenceAccepted = IpassDocumentRejectionPolicy.isResidenceOcrAccepted(
        front: residenceFormDataFront,
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
      lastSuccess = !residenceAccepted && bypassResidency
          ? 'Residence captured (demo mode). Review your details.'
          : 'Residence document captured. Review your details.';
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
    bool filled(TextEditingController c) => c.text.trim().isNotEmpty;

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
        return true;
      case KycDocumentType.passport:
        form.noPassport = false;
        for (final c in [form.ppNo, form.ppIssue, form.ppExpiry, form.ppPlace]) {
          if (!filled(c)) {
            lastError = 'Please complete all passport fields.';
            notifyListeners();
            return false;
          }
        }
        return true;
      case KycDocumentType.residency:
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
          if (c == null || !filled(c)) {
            lastError = 'Please fill all address fields.';
            notifyListeners();
            return false;
          }
        }
        if (form.foreignRes == 'Yes' && !filled(form.foreignResCountry)) {
          lastError = 'Enter foreign residency country.';
          notifyListeners();
          return false;
        }
        if (form.foreignCit == 'Yes' && !filled(form.foreignCitCountry)) {
          lastError = 'Enter foreign citizenship country.';
          notifyListeners();
          return false;
        }
        return true;
    }
  }

  Future<bool> submitDocument() async {
    if (submitInProgress) return false;
    if (!validateReviewFields()) return false;

    submitInProgress = true;
    lastError = null;
    notifyListeners();

    try {
      await _ensureImagesUploaded();
      final imageUrls = await _latestImageUrls();

      final payload = KycDocumentUpdatePayloadBuilder.build(
        documentType: documentType,
        form: form,
        imageUrlsByKey: imageUrls,
        nationalIdOrPassportScan: documentType == KycDocumentType.residency
            ? null
            : ipassScanResult,
        residenceFront: residenceFormDataFront,
        residenceBack: residenceFormDataBack,
      );

      final documents = _extractDocuments(payload);
      if (!KycDocumentUpdatePayloadBuilder.hasUploadedDocuments(documents)) {
        lastError =
            'Document images are still uploading. Please wait a moment and try again.';
        notifyListeners();
        return false;
      }

      if (documentType == KycDocumentType.passport &&
          !KycDocumentUpdatePayloadBuilder.isPassportReadyToSubmit(
            form: form,
            scanResult: ipassScanResult,
          )) {
        lastError =
            'Passport could not be verified. Please retake the scan and try again.';
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        await KycDocumentUpdateStore.instance.saveImageUrls(imageUrls);
      }

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

  List<Map<String, dynamic>> _extractDocuments(Map<String, dynamic> payload) {
    final details = switch (documentType) {
      KycDocumentType.nationalId => payload['nationalIdDetails'],
      KycDocumentType.passport => payload['passportDetails'],
      KycDocumentType.residency => payload['residencyDetails'],
    };
    if (details is! Map) return const [];
    final docs = details['documents'];
    if (docs is! List) return const [];
    return docs
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _ensureImagesUploaded() async {
    if (documentType == KycDocumentType.residency) {
      _enqueueResidenceImages();
    } else if (ipassScanResult != null) {
      _enqueueImagesForTarget(documentType.scanTarget);
    }

    final queue = BbhOnboardingImageUploadQueue.instance;
    await queue.waitUntilIdle();
    await persist();
  }

  Future<bool> _handleIpassResult(
    IpassKycResult result,
    IpassScanTarget target,
  ) async {
    final rejected = IpassDocumentRejectionPolicy.isScanRejected(result.data);
    final bypass = IpassDocumentRejectionPolicy.bypassRejectionFor(target);

    if (rejected && !bypass) {
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
        form.noPassport = false;
      case IpassScanTarget.residence:
        form.resFrontCaptured = true;
        form.resBackCaptured = true;
    }

    await KycDocumentUpdateStore.instance.saveIpassScan(documentType, result);
    await persist();

    lastSuccess = rejected && bypass
        ? 'Document captured (demo mode). Review your details before submitting.'
        : 'Document captured. Review your details before submitting.';
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
    final fromDocUpdate = await KycDocumentUpdateStore.instance.loadImageUrls();
    final fromOnboarding = await BbhOnboardingImageUrlStore.instance.load();
    ipassImageUrls
      ..clear()
      ..addAll(fromOnboarding)
      ..addAll(fromDocUpdate);
    return Map<String, String>.from(ipassImageUrls);
  }

  void _clearImageUrlsForScanKey(String scanKey) {
    final prefix = '$scanKey|';
    ipassImageUrls.removeWhere((key, _) => key.startsWith(prefix));
    BbhOnboardingImageUploadQueue.instance.clearForScanKey(scanKey);
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
