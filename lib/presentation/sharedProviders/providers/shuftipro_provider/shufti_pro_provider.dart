import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:baghdad_bullion_house/core/sound_services.dart';
import 'package:baghdad_bullion_house/core/sounds/app_sounds.dart';
import 'package:baghdad_bullion_house/core/theme/const_toasts.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/api_url.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_kyc_screens/reupload_infromation.dart';
import 'package:baghdad_bullion_house/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/shuftipro_model/ShuftiProApiReponseModel.dart';
import '../../../../data/models/shuftipro_model/SubmitKycError.dart';
import '../../../feature_injection.dart';
import '../../../screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import '../../../widgets/pop_up_widget.dart';
import '../states/shufti_pro_state.dart';

part 'shufti_pro_provider.g.dart';

@riverpod
class ShuftiPro extends _$ShuftiPro {
  @override
  ShuftiProState build() {
    init();
    return ShuftiProState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("ShuftiProProvider Initialized");
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  /// Submits KYC payload from any provider (e.g. iPass) to the backend.
  Future<void> submitKycPayload({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    return submitKycData(
      data: data,
      shuftiProResult: ShuftiProApiResponseModel(event: 'verification.accepted'),
      context: context,
    );
  }

  Future<void> submitKycData({
    required Map<String, dynamic> data,
    required ShuftiProApiResponseModel shuftiProResult,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      /// Get refresh token from storage
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };
      final body = data;

      getLocator<Logger>().i("ShuftiProKYCBody: $body");

      //print
      String prettyPrintBody(dynamic body) {
  try {
    if (body is Map || body is List) {
      return const JsonEncoder.withIndent('  ').convert(body);
    }
    return body.toString();
  } catch (e) {
    return "Invalid JSON body: $e";
  }
}
getLocator<Logger>().i("ShuftiProKYCBody:\n${prettyPrintBody(body)}");

      /// API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.shuftiProApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      /// Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("KYC data submitted successfully!");
          state = state.copyWith(
            successResponse: SuccessResponse.fromJson(
              serverResponse.resultData,
            ),
          );

          SoundPlayer().playSound(AppSounds.loginSound);

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainHomeScreen(),
            ),
            ((route) => false),
          );

          state = state.copyWith(isLoading: false);
          break;
        case ServerResponseType.error:
          SubmitKycError errorResponse = SubmitKycError.fromJson(
            serverResponse.resultData,
          );

          final errorMessage = errorResponse.message ?? "Something went wrong.";

          state = state.copyWith(
            isLoading: false,
          );

          getLocator<Logger>().e(
            "Error: $errorMessage &%%%% ${errorResponse.payload?.validStatus.toString()}",
          );

          if (context.mounted) {
            // Check if status is "validationFailed" and navigate to KycReentryScreen
            if (errorResponse.payload?.validStatus ==
                "documentNativeNameValidationFailed") {
              await genericPopUpWidget(
                isLoadingState: false,
                context: context,
                heading: AppLocalizations.of(context)!.nam_mismatch,
                    //"Name Mismatch", //"Email Verification Required",
                subtitle: AppLocalizations.of(context)!.doc_mismatch,//"Document name and profile name language do not match. Please upload a matching ID.",
                //"To continue, please verify your email address. Do you want to verify now?",
                noButtonTitle: AppLocalizations.of(context)!.later,//"Later", //"Cancel",
                yesButtonTitle: AppLocalizations.of(context)!.re_submit_document,//"Resubmit", //"Verify",
                onNoPress: () async {
                  Navigator.pop(context);
                },
                onYesPress: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KycSecondStepScreen(),
                    ),
                  );
                },
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => KycReentryScreen(
              //       responseData: errorResponse,
              //     ),
              //   ),
              // );
            }
            if (errorResponse.payload?.validStatus == "validationFailed") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KycReentryScreen(
                    responseData: errorResponse,
                  ),
                ),
              );
            } else {
              // For other types of errors, show toast and stay on current screen
              Toasts.getErrorToast(text: errorMessage);
            }
          }
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          //Toasts.getErrorToast(text: "${serverResponse.resultData}");
          state = state.copyWith(isLoading: false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Submit KYC Data Error: $e");
      Toasts.getErrorToast(text: "Submit KYC Data Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Submit KYC Data to ShuftiPro
  // Future<void> submitKycData({
  //   required Map<String, dynamic> data,
  //   required ShuftiProApiResponseModel shuftiProResult,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     state = state.copyWith(isLoading: true);

  //     /// Get refresh token from storage
  //     // String? refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken =
  //         await SecureStorageService.instance.getRefreshToken();

  //     final headers = {
  //       "Authorization": "Bearer $refreshToken",
  //       "Content-Type": "application/json",
  //     };
  //     final body = data;

  //     getLocator<Logger>().i("ShuftiProKYCBody: $body");

  //     /// API call
  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.shuftiProApiUrl,
  //       httpMethod: HttpMethod.post,
  //       headers: headers,
  //       body: body,
  //     );

  //     /// Handle API Response
  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         getLocator<Logger>().i("KYC data submitted successfully!");
  //         state = state.copyWith(
  //           successResponse: SuccessResponse.fromJson(
  //             serverResponse.resultData,
  //           ),
  //         );

  //         SoundPlayer().playSound(AppSounds.loginSound);

  //         if (!context.mounted) return;
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MainHomeScreen(),
  //           ),
  //           ((route) => false),
  //         );

  //         state = state.copyWith(isLoading: false);
  //         break;
  //       case ServerResponseType.error:
  //         SubmitKycError errorResponse = SubmitKycError.fromJson(
  //           serverResponse.resultData,
  //         );

  //         final errorMessage = errorResponse.message ?? "Something went wrong.";

  //         state = state.copyWith(
  //           // errorResponse: errorResponse,
  //           isLoading: false,
  //         );

  //         getLocator<Logger>().e("Error: $errorMessage");

  //         // Flags (default false)
  //         // bool isNameError = false;
  //         // bool isDobError = false;
  //         // bool isCountryError = false;
  //         // bool isResidencyError = false;

  //         // Normalize message to lowercase
  //         final msg = errorMessage.toLowerCase();

  //         // Check individually if the field exists in the message
  //         // isNameError = msg.contains("name");
  //         // isDobError = msg.contains("dob") || msg.contains("date of birth");
  //         // isCountryError = msg.contains("country");
  //         // isResidencyError = msg.contains("residency");

  //         // Only the ones present in the message are true, rest stay false

  //         if (context.mounted) {
  //           //Toasts.getErrorToast(text: errorMessage);

  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => KycReentryScreen(
  //                 responseData: errorResponse,
  //                 // isFirstTime: false,
  //                 // showFirstName: isNameError,
  //                 // shuftiProResult: shuftiProResult,
  //                 // showLastName:
  //                 //     isNameError, // Can adjust if last name check is needed
  //                 // showEmail: false, // assuming email always shows
  //                 // showPhoneNumber: false,
  //                 // showDOB: isDobError,
  //                 // showCountryOfResidence: isResidencyError,
  //                 // showNationality:
  //                 //     isCountryError, // if your app treats country/nationality together, adjust
  //                 // showResidencyProof: isResidencyError,
  //               ),
  //             ),
  //           );
  //         }
  //         break;

  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "Exception: ${serverResponse.resultData}",
  //         );
  //         Toasts.getErrorToast(text: "${serverResponse.resultData}");
  //         state = state.copyWith(isLoading: false);
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     getLocator<Logger>().e("Submit KYC Data Error: $e");
  //     Toasts.getErrorToast(text: "Submit KYC Data Error: $e");
  //     state = state.copyWith(isLoading: false);
  //   }
  // }
  // // Future<void> submitKycData({
  //   required Map<String, dynamic> data,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     state = state.copyWith(isLoading: true);

  //     /// Get refresh token from storage
  //     // String? refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken = await SecureStorageService.instance
  //         .getRefreshToken();

  //     final headers = {
  //       "Authorization": "Bearer $refreshToken",
  //       "Content-Type": "application/json",
  //     };
  //     final body = data;

  //     getLocator<Logger>().i("ShuftiProKYCBody: $body");

  //     /// API call
  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.shuftiProApiUrl,
  //       httpMethod: HttpMethod.post,
  //       headers: headers,
  //       body: body,
  //     );

  //     /// Handle API Response
  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         getLocator<Logger>().i("KYC data submitted successfully!");
  //         state = state.copyWith(
  //           successResponse: SuccessResponse.fromJson(
  //             serverResponse.resultData,
  //           ),
  //         );

  //     SoundPlayer().playSound(AppSounds.loginSound);

  //         if (!context.mounted) return;
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MainHomeScreen(),
  //           ),
  //           ((route) => false),
  //         );

  //         state = state.copyWith(isLoading: false);
  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         final errorMessage =
  //             errorResponse.payload?.message ?? "Something went wrong.";
  //         state = state.copyWith(
  //           errorResponse: errorResponse,
  //           isLoading: false,
  //         );
  //         getLocator<Logger>().e("Error: $errorMessage");
  //         Toasts.getErrorToast(text: errorMessage);

  //         if (context.mounted) {
  //           Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(builder: (_) => KycSecondStepScreen()),
  //             (route) => false,
  //           );
  //         }
  //         break;

  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "Exception: ${serverResponse.resultData}",
  //         );
  //         Toasts.getErrorToast(text: "${serverResponse.resultData}");
  //         state = state.copyWith(isLoading: false);
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     getLocator<Logger>().e("Submit KYC Data Error: $e");
  //     Toasts.getErrorToast(text: "Submit KYC Data Error: $e");
  //     state = state.copyWith(isLoading: false);
  //   }
  // }
}
