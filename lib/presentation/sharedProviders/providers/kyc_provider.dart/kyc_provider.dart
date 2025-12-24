import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/theme/const_toasts.dart';
import '../../../../data/data_sources/local_database/local_database.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_experimental_network_manager.dart';
import '../../../../data/models/KycDocuemntsResponse.dart';
import '../../../feature_injection.dart';
import '../../../screens/main_home_screens/main_home_screen.dart';

part 'kyc_provider.g.dart';

// KYC Document Types
enum KYCDocumentType {
  passport,
  idCard,
  drivingLicense,
  creditDebitCard,
}

extension KYCDocumentTypeExtension on KYCDocumentType {
  String get displayName {
    switch (this) {
      case KYCDocumentType.passport:
        return 'Passport';
      case KYCDocumentType.idCard:
        return 'ID Card';
      case KYCDocumentType.drivingLicense:
        return 'Driving License';
      case KYCDocumentType.creditDebitCard:
        return 'Credit/Debit Card';
    }
  }

  String get apiValue {
    switch (this) {
      case KYCDocumentType.passport:
        return 'passport';
      case KYCDocumentType.idCard:
        return 'national_id';
      case KYCDocumentType.drivingLicense:
        return 'driving_license';
      case KYCDocumentType.creditDebitCard:
        return 'credit_card';
    }
  }
}

// KYC Provider State
class KYCState {
  final bool isFrontUploading;
  final bool isBackUploading;
  final bool isSelfieUploading; // NEW
  final File? frontImage;
  final File? backImage;
  final File? selfieImage; // NEW
  final String? frontImagePath;
  final String? backImagePath;
  final String? selfieImagePath; // NEW
  final KYCDocumentType? selectedDocumentType;
  final String? issuingCountry;
  Map<String, dynamic> kycData;
  final String? errorMessage;

  KYCState({
    this.isFrontUploading = false,
    this.isBackUploading = false,
    this.isSelfieUploading = false, // NEW
    this.frontImage,
    this.backImage,
    this.selfieImage, // NEW
    this.frontImagePath,
    this.backImagePath,
    this.selfieImagePath, // NEW
    this.selectedDocumentType,
    this.issuingCountry,
    this.kycData = const {},
    this.errorMessage,
  });

  KYCState copyWith({
    bool? isFrontUploading,
    bool? isBackUploading,
    bool? isSelfieUploading, // ✅ NEW
    File? frontImage,
    File? backImage,
    File? selfieImage, // ✅ NEW
    String? frontImagePath,
    String? backImagePath,
    String? selfieImagePath, // ✅ NEW
    KYCDocumentType? selectedDocumentType,
    String? issuingCountry,
    Map<String, dynamic>? kycData,
    String? errorMessage,
  }) {
    return KYCState(
      isFrontUploading: isFrontUploading ?? this.isFrontUploading,
      isBackUploading: isBackUploading ?? this.isBackUploading,
      isSelfieUploading: isSelfieUploading ?? this.isSelfieUploading,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      selfieImage: selfieImage ?? this.selfieImage,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
      issuingCountry: issuingCountry ?? this.issuingCountry,
      kycData: kycData ?? this.kycData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class KYC extends _$KYC {
  @override
  KYCState build() {
    return KYCState();
  }

  // Set front image
  void setFrontImage(File image) {
    state = state.copyWith(
      frontImage: image,
      frontImagePath: image.path,
      errorMessage: null,
    );
  }

// Set selfie image
  void setSelfieImage(File image) {
    state = state.copyWith(
      selfieImage: image,
      selfieImagePath: image.path,
      errorMessage: null,
    );
  }

  // Set back image
  void setBackImage(File image) {
    state = state.copyWith(
      backImage: image,
      backImagePath: image.path,
      errorMessage: null,
    );
  }

  void setselfieImage(File image) {
    state = state.copyWith(
      backImage: image,
      backImagePath: image.path,
      errorMessage: null,
    );
  }

  // Update financial information
  void updateFinancialInfo({
    required String employmentStatus,
    required String companyName,
    required String salaryRange,
  }) {
    final updatedKycData = {
      ...state.kycData,
      'employmentStatus': employmentStatus,
      'companyName': companyName,
      'salaryRange': salaryRange,
      'financialInfoCompleted': true,
    };

    state = state.copyWith(kycData: updatedKycData);
    print('Financial Info Updated: ${state.kycData}');
  }

  // Update document information
  void updateDocumentInfo({
    required KYCDocumentType documentType,
    required String issuingCountry,
    required String frontImagePath,
    String? backImagePath,
  }) {
    final updatedKycData = {
      ...state.kycData,
      'documentType': documentType.apiValue,
      'issuingCountry': issuingCountry,
      'frontImagePath': frontImagePath,
      if (backImagePath != null) 'backImagePath': backImagePath,
      'documentInfoCompleted': true,
      'documentInfoTimestamp': DateTime.now().toIso8601String(),
    };

    state = state.copyWith(
      kycData: updatedKycData,
      selectedDocumentType: documentType,
      issuingCountry: issuingCountry,
    );
  }

  // Generic method to update any KYC data
  void updateKycData(Map<String, dynamic> newData) {
    final updatedKycData = {
      ...state.kycData,
      ...newData,
    };

    state = state.copyWith(kycData: updatedKycData);
  }

  // Set document type
  void setDocumentType(KYCDocumentType documentType) {
    state = state.copyWith(
      selectedDocumentType: documentType,
      errorMessage: null,
    );
  }

  // Set issuing country
  void setIssuingCountry(String country) {
    state = state.copyWith(
      issuingCountry: country,
      errorMessage: null,
    );
  }

  // Clear images
  void clearImages() {
    state = state.copyWith(
      frontImage: null,
      backImage: null,
      frontImagePath: null,
      backImagePath: null,
      errorMessage: null,
    );
  }

  Future<void> uploadResidencyDocument({
    required File image,
    required String fileName,
    required bool isFront,
    required bool isSelfie,
    required BuildContext context,
  }) async {
    try {
      // set uploading flag accordingly
      state = state.copyWith(
        isFrontUploading: isFront ? true : state.isFrontUploading,
        isBackUploading: (!isFront && !isSelfie) ? true : state.isBackUploading,
        isSelfieUploading: isSelfie ? true : state.isSelfieUploading,
        errorMessage: null,
      );

      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();

      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(
          isFrontUploading: false,
          isBackUploading: false,
        );
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        'Content-Type': 'multipart/form-data',
      };

      FormData formData = FormData.fromMap({
        'myImage': await MultipartFile.fromFile(image.path,
            filename: '${isFront ? 'front' : 'back'}_$fileName'),
      });

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.uploadKycDocApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: formData,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          KycUrlResponse uploadResponse =
              KycUrlResponse.fromJson(serverResponse.resultData);

          getLocator<Logger>().i(
            "KYC Uploaded: ${uploadResponse.payload?.toJson()}",
          );

          if (isFront) {
            state = state.copyWith(
              frontImagePath: uploadResponse.payload?.kycDocsUrl,
              isFrontUploading: false,
            );
          } else if (isSelfie) {
            state = state.copyWith(
              selfieImagePath: uploadResponse.payload?.kycDocsUrl,
              isSelfieUploading: false,
            );
          } else {
            state = state.copyWith(
              backImagePath: uploadResponse.payload?.kycDocsUrl,
              isBackUploading: false,
            );
          }

          Toasts.getSuccessToast(text: "Document uploaded successfully");
          break;

        case ServerResponseType.error:
          state = state.copyWith(
            isFrontUploading: false,
            isBackUploading: false,
            isSelfieUploading: false,
            errorMessage: "Upload failed",
          );

          Toasts.getErrorToast(
              text: serverResponse.resultData["message"] ?? "Upload failed");
          break;

        case ServerResponseType.exception:
          state = state.copyWith(
            isFrontUploading: false,
            isBackUploading: false,
            errorMessage: "Network error occurred",
          );
          break;
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        isFrontUploading: false,
        isBackUploading: false,
        errorMessage: "An unexpected error occurred",
      );
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> submitKycData({
    required String userImage,
    required BuildContext context,
  }) async {
    try {
      String? userid = await LocalDatabase.instance.getUserId();
      String? refreshToken = await SecureStorageService.instance.getRefreshToken();

      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        Toasts.getErrorToast(text: "Session expired. Please login again.");
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "userId": userid,
        "employmentStatus": state.kycData["employmentStatus"] ?? "",
        "companyName": state.kycData["companyName"] ?? "",
        "salaryRange": state.kycData["salaryRange"] ?? "",
        "documentOfCountry": state.issuingCountry ?? "",
        "documentType": state.selectedDocumentType!.displayName,
        "documentImages": [
          state.frontImagePath ?? "",
          state.backImagePath ?? "",
        ],
        "userImage": state.selfieImagePath ?? "",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.submitKyc,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>()
              .i("KYC Save Success: ${serverResponse.resultData}");
          Toasts.getSuccessToast(text: "KYC submitted successfully");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainHomeScreen(),
            ),
            ((route) => false),
          );
          break;

        case ServerResponseType.error:
          final msg =
              serverResponse.resultData["message"] ?? "KYC submission failed";
          Toasts.getErrorToast(text: msg);
          break;

        case ServerResponseType.exception:
          Toasts.getErrorToast(text: "Network error occurred");
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e(
        "KYC Submit Error",
      );
      Toasts.getErrorToast(text: "Unexpected error occurred");
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // Reset KYC state
  void resetKYC() {
    state = KYCState();
  }
}
