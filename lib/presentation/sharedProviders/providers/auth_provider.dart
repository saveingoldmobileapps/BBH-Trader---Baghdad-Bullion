import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/push_notification_service/firebase_push_notification_service.dart';
import 'package:saveingold_fzco/core/services/socket_services.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/LoginResponse.dart';
import 'package:saveingold_fzco/data/models/RefreshTokenResponse.dart';
import 'package:saveingold_fzco/data/models/RegisterResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/UploadResidencyResponse.dart';
import 'package:saveingold_fzco/data/models/get_all_country/GetAllCountryResponseModel.dart';
import 'package:saveingold_fzco/data/models/login_fail_response.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_index.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/forgot_screens/forgot_password_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/phone_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/verify_new_email.dart';
import 'package:saveingold_fzco/presentation/screens/get_started_screen.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/animated_overlay_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/sound_services.dart';
import '../../../core/sounds/app_sounds.dart';
import '../../../data/data_sources/local_database/secure_database.dart';
import '../../../data/models/nomineeUploadResponse.dart';
import '../../screens/auth_screens/forgot_screens/reset_password_screen.dart';
import '../../screens/auth_screens/forgot_screens/verify_phone_otp_forgot_password.dart';
import '../../screens/auth_screens/verify_otp_for_signup.dart';
import '../../screens/auth_screens/verify_otp_for_update_profile.dart'
    show UpdateAccountVerifyCodeScreen;
import '../../screens/auth_screens/verify_phone_number_to_update_email.dart';
import '../../screens/auth_screens/withdraw_verify_phone.dart';
import '../../screens/gift_fund_screens/gift_phone_verify_code_screen.dart';
import '../../screens/gift_fund_screens/gift_success.dart';
import '../../screens/withdraw_fund_screens/withdrawal_fund_success.dart';
import 'states/auth_state.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    init();
    return AuthState();
  }

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("AuthProvider Initialized");
  }

  /// set button state
  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  /// set upload image state
  void setUploadImageState(bool imageState) {
    state = state.copyWith(isImageState: imageState);
  }

  /// set loading state
  void setLoadingState(LoadingState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  /// get device information
  Future getDeviceInformation() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final NetworkInfo networkInfo = NetworkInfo();

    try {
      String deviceName = 'Unknown Device';
      String deviceType = 'Unknown';
      String operatingSystem = 'Unknown';
      String deviceIpAddress = 'Unknown';
      String deviceUniqueId = 'Unknown';

      if (kIsWeb) {
        //  Web platform
        final WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        deviceName = webInfo.userAgent ?? "Web Browser";
        deviceType = "Web";
        operatingSystem = "Web";
      } else if (Platform.isAndroid) {
        //  Android
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // deviceName = androidInfo.model;
        deviceName = "${androidInfo.name} - ${androidInfo.model}";

        operatingSystem = "Android";
        deviceUniqueId = androidInfo.id;
        // Basic guess based on model or hardware
        if ((androidInfo.model.toLowerCase().contains('tablet')) ||
            (androidInfo.hardware.toLowerCase().contains('tablet')) ||
            (androidInfo.manufacturer.toLowerCase().contains('tablet'))) {
          deviceType = "Tablet";
        } else {
          deviceType = "Mobile";
        }
      } else if (Platform.isIOS) {
        //  iOS
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = "${iosInfo.name} - ${iosInfo.modelName}";
        operatingSystem = "iOS";
        deviceUniqueId = iosInfo.identifierForVendor ?? "Unknown";
        deviceType = (iosInfo.model.toLowerCase().contains("ipad") ?? false)
            ? "Tablet"
            : "Mobile";
      } else if (Platform.isMacOS) {
        //  macOS
        final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        deviceName = macInfo.computerName ?? "Mac Device";
        deviceType = "Mac";
        operatingSystem = "macOS";
      } else if (Platform.isWindows) {
        //  Windows
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
        deviceType = "Desktop";
        operatingSystem = "Windows";
      } else if (Platform.isLinux) {
        //  Linux
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        deviceName = linuxInfo.name ?? "Linux Device";
        deviceType = "Desktop";
        operatingSystem = "Linux";
      }

      // 🌐 Get local Wi-Fi IP address
      final wifiIP = await networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        deviceIpAddress = wifiIP;
      }

      // Update your app state (assuming you have `state.copyWith`)
      state = state.copyWith(
        deviceName: deviceName,
        deviceType: deviceType,
        operatingSystem: operatingSystem,
        deviceIpAddress: deviceIpAddress,
        deviceUniqueID: deviceUniqueId,
      );

      //  Log everything
      getLocator<Logger>().i('''
📱 Device Information:
  • Device Name: $deviceName
  • Device Type: $deviceType
  • Operating System: $operatingSystem
  • Device IP: $deviceIpAddress
''');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e('Failed to get device info: $e');
    }
  }

  /// user login
  /// @param {email: String, password: String}
  Future<String> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model; // e.g., "Pixel 4"
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine; // e.g., "iPhone 14"
    }
    return "Unknown Device";
  }

  Future<void> getDeviceDetails() async {
    String deviceName = await getDeviceInformation();
    // String ipAddress = await getDeviceInformation();
    // String country = await getCountry();

    debugPrint("Device Name: $deviceName");
    // print("IP Address: $ipAddress");
    // print("Country: $country");
  }

  /// check biometrics
  Future<bool> _checkBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      debugPrint("Error checking biometrics: $e");
      return false;
    }
  }

  //auth with face
  Future<void> authenticateWithFaceUnlock({
    required BuildContext context,
  }) async {
    try {
      // Check if Face Unlock is available
      List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      if (!availableBiometrics.contains(BiometricType.face)) {
        Toasts.getWarningToast(
          text: "Face Unlock is not available on this device.",
        );
        return;
      }

      // Authenticate using Face Unlock
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan your face to login',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only allow biometrics (no PIN/pattern)
          stickyAuth: true, // Keeps authentication active until resolved
        ),
      );

      if (didAuthenticate) {
        // Face authentication successful
        // String? refreshToken = await LocalDatabase.instance.read(
        //   key: Strings.userRefreshToken,
        // );
        // String? refreshToken = await SecureStorageService.instance
        //     .getRefreshToken();
        String? email = await LocalDatabase.instance.read(
          key: Strings.userPhoneNumber,
        );
        String? password = await LocalDatabase.instance.read(
          key: Strings.userPassword,
        );
        if (password != null && email != null) {
          if (!context.mounted) return;
          await LocalDatabase.instance.storeFaceEnable(isEnable: true);
          if (!context.mounted) return;
          await userLogin(
            email: email,
            password: password,
            context: context,
            showLoader: false,
            isFinger: true,
          );
        }
        // if (refreshToken != null) {
        //   if (!context.mounted) return;
        //   // Proceed with user login
        //   await userLoginWithToken(
        //     context: context,
        //   );
        // }
        // else {
        //   Toasts.getErrorToast(text: "Login failed: credentials not found.");
        // }
      } else {
        // Face authentication failed
        Toasts.getErrorToast(text: "Face Unlock authentication failed.");
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      debugPrint("Error during Face Unlock authentication: $e");
      Toasts.getErrorToast(
        text: "An error occurred during Face Unlock authentication.",
      );
    }
  }

  // To send gift using biometric, facelock, passcode or phone number
  Future<void> authenticateWithBiometricsForGift({
    required BuildContext context,
    required String phoneNumber,
    required String receiverId,
    required String receiverName,
    required String receiverPhoneNumber,
    required String receiverEmail,
    required String giftAmount,
    required String paymentMethod,
    required String comment,
    List<Map<String, dynamic>>? selectedDealsData,
  }) async {
    try {
      // Check if biometric unlock is enabled in app settings
      final bool isBiometricEnabled = Platform.isIOS
          ? await LocalDatabase.instance.getFaceEnable() ?? false
          : await LocalDatabase.instance.getFingerEnable() ?? false;
      // await LocalDatabase.instance.getFingerEnable() ?? false;

      // Proceed only if biometric unlock is enabled by user
      if (!isBiometricEnabled) {
        // Fallback to phone passcode if biometric is disabled in app
        if (!context.mounted) return;
        await resendPhonePasscodeForGift(
          comment: comment,
          phoneNumber: phoneNumber,
          context: context,
          receiverId: receiverId,
          receiverName: receiverName,
          receiverEmail: receiverEmail,
          giftAmount: giftAmount,
          paymentMethod: paymentMethod,
          selectedDealsData: selectedDealsData,
        );
        return;
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = canCheckBiometrics
          ? await _localAuth.getAvailableBiometrics()
          : [];

      if (!isDeviceSupported || availableBiometrics.isEmpty) {
        // If no biometrics available, fallback to passcode
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Authenticate using device passcode',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (didAuthenticate) {
          if (!context.mounted) return;

          SoundPlayer().playSound(AppSounds.depositSounmd);

          SuccessAnimationOverlay.show(
            context: context,
            // message: successResponse.payload?.message ??
            //     AppLocalizations.of(context)!.invest_successfully_submitted,
            displayDuration: const Duration(seconds: 10),
            onComplete: () {
              // Optional: Do something after animation completes
              print("Buy gold animation completed");
            },
            message: '',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftSuccessScreen(
                receiverId: receiverId,
                receiverName: receiverName,
                receiverEmail: receiverEmail,
                giftAmount: giftAmount,
                paymentMethod: paymentMethod,
                comment: comment,
                selectedDealsData: selectedDealsData,
                receiverPhoneNumber: phoneNumber,
              ),
            ),
          );
          return;
        }

        // Fallback to phone passcode if device passcode fails
        if (!context.mounted) return;
        await resendPhonePasscodeForGift(
          comment: comment,
          phoneNumber: phoneNumber,
          context: context,
          receiverId: receiverId,
          receiverName: receiverName,
          receiverEmail: receiverEmail,
          giftAmount: giftAmount,
          paymentMethod: paymentMethod,
        );
        return;
      }

      // Try biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate using biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        if (!context.mounted) return;

        SoundPlayer().playSound(AppSounds.depositSounmd);

        SuccessAnimationOverlay.show(
          context: context,
          // message: successResponse.payload?.message ??
          //     AppLocalizations.of(context)!.invest_successfully_submitted,
          displayDuration: const Duration(seconds: 2),
          onComplete: () {
            // Optional: Do something after animation completes
            print("Buy gold animation completed");
          },
          message: '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GiftSuccessScreen(
              receiverId: receiverId,
              receiverName: receiverName,
              receiverEmail: receiverEmail,
              receiverPhoneNumber: phoneNumber,
              giftAmount: giftAmount,
              paymentMethod: paymentMethod,
              comment: comment,
              selectedDealsData: selectedDealsData,
            ),
          ),
        );
      } else {
        Toasts.getErrorToast(text: "Authentication failed.");
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      debugPrint("Error during authentication: $e");

      if (!context.mounted) return;
      await resendPhonePasscodeForGift(
        comment: comment,
        phoneNumber: phoneNumber,
        context: context,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverEmail: receiverEmail,
        giftAmount: giftAmount,
        paymentMethod: paymentMethod,
        selectedDealsData: selectedDealsData,
      );

      Toasts.getErrorToast(
        text: "An error occurred during authentication.",
      );
    }
  }

  /// authenticate with fingerprint
  Future<void> authenticateWithFingerprint({
    required BuildContext context,
  }) async {
    try {
      // Check if biometrics are available
      final bool canCheckBiometrics = await _checkBiometrics();
      if (!canCheckBiometrics) {
        Toasts.getWarningToast(
          text: "Biometrics not available on this device.",
        );
        return;
      }

      // Authenticate the user
      final bool didAuthenticate = await _localAuth.authenticate(
        // Message shown to the user
        localizedReason: 'Scan your fingerprint to login',
        // Only allow biometric authentication (no PIN/pattern)
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // String? refreshToken = await LocalDatabase.instance.read(
        //   key: Strings.userRefreshToken,
        // );
        String? email = await LocalDatabase.instance.read(
          key: Strings.userPhoneNumber,
        );
        String? password = await LocalDatabase.instance.read(
          key: Strings.userPassword,
        );
        if (password != null && email != null) {
          if (!context.mounted) return;
          await LocalDatabase.instance.storeFingerEnable(isEnable: true);
          if (!context.mounted) return;
          await userLogin(
            email: email,
            password: password,
            context: context,
            isFinger: true,
            showLoader: false,
          );
          // await userLoginWithToken(
          //   context: context,
          // );
        } else {
          Toasts.getErrorToast(
            text: AppLocalizations.of(
              context,
            )!.no_saved_credentials, //"No saved credentials found.",
          );
        }
      } else {
        // Fingerprint authentication failed
        Toasts.getErrorToast(
          text: AppLocalizations.of(
            context,
          )!.finger_print_warning, //"Fingerprint authentication failed.",
        );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      debugPrint(
        "Error during fingerprint authentication: $e",
      );
      Toasts.getErrorToast(
        text: "An error occurred during authentication.",
      );
    }
  }

  /// edit profile
  Future<void> editProfile({
    required Map<String, String> updatedFields,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      final mainStateWatchProvider = ref.watch(homeProvider);
      bool isKycVerfied =
          mainStateWatchProvider.isUserKYCVerified &&
          mainStateWatchProvider.isBasicUserVerified;
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };
      final body = updatedFields;
      debugPrint("before $body");

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateProfileApiUrl,
        body: body,
        headers: headers,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          debugPrint(" after updated $body");
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );

          if (!context.mounted) return;
          final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;
          if (isDemo || !isKycVerfied) {
            bool faceIDEnabled =
                await LocalDatabase.instance.getFaceEnable() ?? false;
            bool isFingerPrintEnabled =
                await LocalDatabase.instance.getFingerEnable() ?? false;
            await LocalDatabase.instance.storeFaceEnable(
              isEnable: true,
            );
            await LocalDatabase.instance.storeAutoLogin(
              autoLogin: true,
            );
            await LocalDatabase.instance.storeFingerEnable(
              isEnable: true,
            );
            if (updatedFields['email'] != null) {
              LocalDatabase.instance.write(
                key: Strings.userEmail,
                value: updatedFields['email'],
              );
              String? password = await LocalDatabase.instance.read(
                key: Strings.userPassword,
              );
              if (!context.mounted) return;
              userLogin(
                email: updatedFields['email']!,
                password: password!,
                context: context,
                isFinger: false,
                showLoader: true,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainHomeScreen()),
                (route) => false,
              );
            }

            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (context) => Mainhom()),
            //   (route) => false,
            // );
            // CommonService.logoutUser(context: context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainHomeScreen(),
              ), //HomeScreen()),
              (route) => false,
            );
          }

          /// re-initialize notification
          if (updatedFields.containsKey("email")) {
            String? email = updatedFields["email"];
            if (email != null) {
              await FirebasePushNotificationService.initializeNotification(
                userTopic: email,
              );
            }
          }

          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// upload profile image
  Future<void> uploadProfileImage({
    required String filePath,
    required BuildContext context,
  }) async {
    try {
      setUploadImageState(true);

      // get refresh token
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      if (refreshToken == null) {
        Toasts.getErrorToast(text: "Token not found.");
        setUploadImageState(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
      };

      final formData = FormData.fromMap({
        "myImage": await MultipartFile.fromFile(
          filePath,
          filename: filePath.split("/").last,
        ),
      });

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.uploadProfileApiUrl,
        body: formData,
        headers: headers,
        httpMethod: HttpMethod.post,
        // isFormData: true, // <- make sure your DioNetworkManager supports this
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          Toasts.getSuccessToast(
            text:
                successResponse.payload?.message ??
                AppLocalizations.of(
                  context,
                )!.image_upload_successfull, //"Image uploaded successfully",
          );

          getLocator<Logger>().i(
            "Profile image uploaded: ${successResponse.payload}",
          );

          setUploadImageState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );

          Toasts.getErrorToast(
            text: errorResponse.payload?.message ?? "Upload failed",
          );

          setUploadImageState(false);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setUploadImageState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      Toasts.getErrorToast(text: "Something went wrong while uploading image.");
      setUploadImageState(false);
    }
  }

  /// user login
  Future<void> userLogin({
    required String email,
    required String password,
    required BuildContext context,
    required bool showLoader,
    required bool isFinger,
  }) async {
    try {
      setButtonState(showLoader);
      // get device details
      await getDeviceInformation();

      final body = {
        "login": email,
        "password": password,
        "deviceType": state.deviceType,

        //"deviceIp": state.deviceUniqueID,
        "deviceIPAddress": state.deviceIpAddress,
        "deviceId":
            state.deviceUniqueID, //"38400000-8cf0-11bd-b23e-10b96e40000d",
        "deviceName": state.deviceName,
        "deviceOperatingSystem": state.operatingSystem,
        // "deviceIPAddress": state.deviceIpAddress,
        "location": "",
        "dateTime": DateTime.now().toString(),
      };
      print(" Json($jsonEncode($body))");

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.loginApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      print("Server Response Data: ${serverResponse.resultData}");

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          bool faceIDEnabled =
              await LocalDatabase.instance.getFaceEnable() ?? false;
          // await LocalDatabase.instance.getFaceEnable() ?? false;
          bool isFingerPrintEnabled =
              await LocalDatabase.instance.getFingerEnable() ?? false;
          // await LocalDatabase.instance.getFingerEnable() ?? false;

          // clear storage
          String lang =
              await LocalDatabase.instance.read(key: Strings.kLanguageCode) ??
              "en";
          await LocalDatabase.instance.getStorageInstance.erase();
          // await LocalDatabase.instance.unsetErase();

          await LocalDatabase.instance.clearAllUserData();
          await LocalDatabase.instance.write(
            key: Strings.kLanguageCode,
            value: lang,
          );
          LoginResponse loginResponse = LoginResponse.fromJson(
            serverResponse.resultData,
          );

          /// update state
          state = state.copyWith(loginResponse: loginResponse);
          getLocator<Logger>().i(
            "loginResponse: ${loginResponse.payload?.userInfo?.toJson()}",
          );

          final accessToken = loginResponse.payload?.userInfo?.accessToken
              .toString();
          final emailnotification = loginResponse.payload?.userInfo!.email;

          if (!context.mounted) return;
          if (accessToken != null) {
            /// get refresh token
            await getRefreshToken(
              accessToken: accessToken,
              isAuthentication: 0,
              email: email,
              phoneNumber: "",
              isDemo: false,
              context: context,
              showLoader: showLoader,
            );
          } else {
            getLocator<Logger>().e("Failed to get tokens [refresh, server]");
          }

          /// saving login data
          await Future.wait([
            LocalDatabase.instance.saveUserLoginData(
              loginResponse: loginResponse,
            ),
            LocalDatabase.instance.storeFaceEnable(
              isEnable: faceIDEnabled,
            ),
            // LocalDatabase.instance.storeFaceEnable(
            //   isEnable: faceIDEnabled,
            // ),
            // LocalDatabase.instance.storeFingerEnable(
            //   isEnable: isFingerPrintEnabled,
            // ),
            LocalDatabase.instance.storeFingerEnable(
              isEnable: isFingerPrintEnabled,
            ),
            LocalDatabase.instance.getLoginUserFromStorage(),

            LocalDatabase.instance.saveUserIDToken(
              userId: loginResponse.payload?.userInfo?.id.toString() ?? "",
            ),
            LocalDatabase.instance.saveUserPassword(
              password: password,
            ),
            LocalDatabase.instance.saveUserAccountID(
              userId:
                  loginResponse.payload?.userInfo?.accountId.toString() ?? "",
            ),
            LocalDatabase.instance.getUserId(),

            LocalDatabase.instance.write(
              key: Strings.userID,
              value: loginResponse.payload?.userInfo?.id.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userFirstName,
              value: loginResponse.payload?.userInfo?.firstName!.en.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userSurname,
              value: loginResponse.payload?.userInfo?.surname!.en.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userEmail,
              value: loginResponse.payload?.userInfo?.email.toString(),
            ),

            LocalDatabase.instance.write(
              key: Strings.userPhoneNumber,
              value: loginResponse.payload?.userInfo?.phoneNumber.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userImageUrl,
              value: loginResponse.payload?.userInfo?.imageUrl.toString(),
            ),

            ///Initializing Push Notification Service
            FirebasePushNotificationService.initializeNotification(
              userTopic: emailnotification.toString(),
            ),
          ]).then((value) {
            getLocator<Logger>().i("loginDataStored");
          });

          setButtonState(false);

          break;
        case ServerResponseType.error:
          LoginfailResponse errorResponse = LoginfailResponse.fromJson(
            serverResponse.resultData,
          );

          getLocator<Logger>().e("error: ${errorResponse.message.toString()}");

          if (isFinger) {
            final updatedPhone = errorResponse.payload?.updatedPhoneNumber;

            if (updatedPhone != null &&
                updatedPhone.toString().trim().isNotEmpty) {
              await LocalDatabase.instance.write(
                key: Strings.userPhoneNumber,
                value: updatedPhone.toString(),
              );
              userLogin(
                email: email,
                password: password,
                context: context,
                showLoader: showLoader,
                isFinger: isFinger,
              );
            } else {
              Toasts.getErrorToast(
                text:
                    errorResponse.payload!.message?.toString() ??
                    "Login failed. Please try again.",
              );
            }
          } else {
            //  Normal login case
            Toasts.getErrorToast(
              text:
                  errorResponse.payload!.message?.toString() ??
                  "Login failed. Please try again.",
            );
          }

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> verifyAndUpdateEmail({
    required String newEmail,
    required BuildContext context,
  }) async {
    try {
      // Check if biometrics are available
      final bool canCheckBiometrics = await _checkBiometrics();
      if (!canCheckBiometrics) {
        Toasts.getWarningToast(
          text: "Biometrics not available on this device.",
        );
        _fallbackToOtp(newEmail, context);
        return;
      }

      // Platform-specific biometric authentication
      if (Platform.isAndroid) {
        await _authenticateWithFingerprintForEmailUpdate(
          context: context,
          newEmail: newEmail,
        );
      } else if (Platform.isIOS) {
        await _authenticateWithFaceUnlockForEmailUpdate(
          context: context,
          newEmail: newEmail,
        );
      } else {
        // Fallback for other platforms
        _fallbackToOtp(newEmail, context);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint("Error during biometric authentication for email update: $e");
      Toasts.getErrorToast(
        text: "An error occurred during authentication.",
      );
      _fallbackToOtp(newEmail, context);
    }
  }

  Future<void> verifyPhonePasscodeToChangeEmail({
    required String phoneNumber,
    required String passcode,
    required String newEmail,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;

          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyNewEmailScreen(
                email: newEmail,
              ),
            ),
          );
        // await updateUserEmail(context: context, newEmail: newEmail);

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> updateUserEmail({
    required String newEmail,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      if (refreshToken == null) {
        Toasts.getErrorToast(text: "Token not found.");
        setUploadImageState(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
      };
      final body = {"email": newEmail};

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateUserEmail,
        body: body,
        headers: headers,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;

          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: successResponse.message ?? "Email updated successfully",
            //successResponse.message.toString(),
          );
          CommonService.logoutUser(context: context);
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  // Fingerprint authentication for Android (email update)
  Future<void> _authenticateWithFingerprintForEmailUpdate({
    required BuildContext context,
    required String newEmail,
  }) async {
    try {
      // Authenticate the user
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to update your email',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Fingerprint authentication successful
        if (!context.mounted) return;
        await LocalDatabase.instance.storeFingerEnable(isEnable: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyNewEmailScreen(
              email: newEmail,
            ),
          ),
        );
        // await genericPopUpWidget(
        //   isLoadingState: false,
        //   context: context,
        //   heading: "Warning",
        //   subtitle: "You Will be logged out after email updates successfully",
        //   noButtonTitle: "Cancel",
        //   yesButtonTitle: "Proceed",
        //   onNoPress: () => Navigator.pop(context),
        //   onYesPress: () async {
        //     Navigator.pop(context);
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => VerifyNewEmailScreen(
        //                   email: newEmail,
        //                 )));
        //     // await updateUserEmail(context: context, newEmail: newEmail);
        //   },
        // );
      } else {
        // Fingerprint authentication failed
        // Toasts.getErrorToast(
        //   text: AppLocalizations.of(context)!.finger_print_warning,
        // );
        _fallbackToOtp(newEmail, context);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint(
        "Error during fingerprint authentication for email update: $e",
      );
      Toasts.getErrorToast(
        text: "An error occurred during fingerprint authentication.",
      );
      _fallbackToOtp(newEmail, context);
    }
  }

  // Face Unlock authentication for iOS (email update)
  Future<void> _authenticateWithFaceUnlockForEmailUpdate({
    required BuildContext context,
    required String newEmail,
  }) async {
    try {
      // Check if Face Unlock is available
      List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      if (!availableBiometrics.contains(BiometricType.face)) {
        Toasts.getWarningToast(
          text: "Face Unlock is not available on this device.",
        );
        _fallbackToOtp(newEmail, context);
        return;
      }

      // Authenticate using Face Unlock
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan your face to update your email',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Face authentication successful
        if (!context.mounted) return;
        await LocalDatabase.instance.storeFaceEnable(isEnable: true);

        // Update email directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyNewEmailScreen(
              email: newEmail,
            ),
          ),
        );
        // await genericPopUpWidget(
        //   isLoadingState: false,
        //   context: context,
        //   heading: "Warning",
        //   subtitle: "You Will be logged out after email updates successfully",
        //   noButtonTitle: "Cancel",
        //   yesButtonTitle: "Proceed",
        //   onNoPress: () => Navigator.pop(context),
        //   onYesPress: () async {
        //     Navigator.pop(context);
        //     await updateUserEmail(context: context, newEmail: newEmail);
        //   },
        // );
      } else {
        // Face authentication failed
        Toasts.getErrorToast(text: "Face Unlock authentication failed.");
        _fallbackToOtp(newEmail, context);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint(
        "Error during Face Unlock authentication for email update: $e",
      );
      Toasts.getErrorToast(
        text: "An error occurred during Face Unlock authentication.",
      );
      _fallbackToOtp(newEmail, context);
    }
  }

  // Helper method for OTP fallback
  Future<void> _fallbackToOtp(String newEmail, BuildContext context) async {
    String? phoneNumber = await LocalDatabase.instance.read(
      key: Strings.userPhoneNumber,
    );

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await sendOtpForChnageEmail(
        phoneNumber: phoneNumber,
        navigate: true,
        newEmail: newEmail,
        context: context,
      );
    } else {
      Toasts.getErrorToast(text: "Phone number not found for OTP verification");
    }
  }

  Future<void> sendOtpForChnageEmail({
    required String phoneNumber,
    required String newEmail,
    required bool navigate,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);
      String? phoneNumber = await LocalDatabase.instance.read(
        key: Strings.userPhoneNumber,
      );
      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendPhonePasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          if (navigate) {
            Toasts.getSuccessToast(
              gravity: ToastGravity.TOP,
              text: AppLocalizations.of(
                context,
              )!.request_sent, //successResponse.message.toString(),
            );
            if (navigate == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailPhoneVerifyCodeScreen(
                    phoneNumber: phoneNumber!,
                    newEmail: newEmail,
                  ),
                ),
              );
            }

            setButtonState(false);
          }

          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          if (!context.mounted) return;

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<bool> userLoginWithToken({
    required BuildContext context,
  }) async {
    try {
      debugPrint("userLoginWithToken");

      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        setButtonState(true);
        return false;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.loginWithTokenApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          bool faceIDEnabled =
              await LocalDatabase.instance.getFaceEnable() ?? false;
          bool isFingerPrintEnabled =
              await LocalDatabase.instance.getFingerEnable() ?? false;

          String? email = await LocalDatabase.instance.read(
            key: Strings.userEmail,
          );
          String? password = await LocalDatabase.instance.read(
            key: Strings.userPassword,
          );
          String lang =
              await LocalDatabase.instance.read(key: Strings.kLanguageCode) ??
              "en";

          await LocalDatabase.instance.getStorageInstance.erase();

          await LocalDatabase.instance.clearAllUserData();
          await LocalDatabase.instance.write(
            key: Strings.kLanguageCode,
            value: lang,
          );

          LoginResponse loginResponse = LoginResponse.fromJson(
            serverResponse.resultData,
          );
          await LocalDatabase.instance.saveUserPassword(
            password: password ?? "",
          );
          await LocalDatabase.instance.write(
            key: Strings.userEmail,
            value: email ?? "",
          );

          state = state.copyWith(loginResponse: loginResponse);
          getLocator<Logger>().i(
            "loginResponse: ${loginResponse.payload?.userInfo?.toJson()}",
          );

          final accessToken = loginResponse.payload?.userInfo?.accessToken
              ?.toString();

          if (!context.mounted) return false;
          if (accessToken != null) {
            await getRefreshToken(
              accessToken: accessToken,
              isAuthentication: 0,
              showLoader: true,
              email: loginResponse.payload?.userInfo?.email ?? "",
              phoneNumber: "",
              isDemo: false,
              context: context,
            );
          } else {
            getLocator<Logger>().e("Failed to get tokens [refresh, server]");
          }

          await Future.wait([
            LocalDatabase.instance.saveUserLoginData(
              loginResponse: loginResponse,
            ),
            LocalDatabase.instance.storeFaceEnable(
              isEnable: faceIDEnabled,
            ),
            LocalDatabase.instance.storeFingerEnable(
              isEnable: isFingerPrintEnabled,
            ),
            LocalDatabase.instance.getLoginUserFromStorage(),
            LocalDatabase.instance.saveUserIDToken(
              userId: loginResponse.payload?.userInfo?.id.toString() ?? "",
            ),
            LocalDatabase.instance.saveUserAccountID(
              userId:
                  loginResponse.payload?.userInfo?.accountId.toString() ?? "",
            ),
            LocalDatabase.instance.getUserId(),
            LocalDatabase.instance.write(
              key: Strings.userID,
              value: loginResponse.payload?.userInfo?.id.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userFirstName,
              value: loginResponse.payload?.userInfo?.firstName!.en.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userSurname,
              value: loginResponse.payload?.userInfo?.surname!.en.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userEmail,
              value: loginResponse.payload?.userInfo?.email.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userPhoneNumber,
              value: loginResponse.payload?.userInfo?.phoneNumber.toString(),
            ),
            LocalDatabase.instance.write(
              key: Strings.userImageUrl,
              value: loginResponse.payload?.userInfo?.imageUrl.toString(),
            ),
            FirebasePushNotificationService.initializeNotification(
              userTopic: loginResponse.payload?.userInfo?.email ?? "",
            ),
          ]).then((_) {
            getLocator<Logger>().i("loginDataStored");
          });

          setButtonState(false);
          return true;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);
          return false;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          return false;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("onError: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      setButtonState(false);
      return false;
    }
  }

  // Future<void> userLoginWithToken({
  //   required BuildContext context,
  // }) async {
  //   try {
  //     debugPrint("userLoginWithToken");

  //     // String? refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken = await SecureStorageService.instance
  //         .getRefreshToken();
  //     if (refreshToken == null) {
  //       getLocator<Logger>().e("No refresh token found!");
  //       setButtonState(true);
  //       return;
  //     }
  //     final headers = {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $refreshToken",
  //     };

  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.loginWithTokenApiUrl,
  //       httpMethod: HttpMethod.post,
  //       headers: headers,
  //     );

  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         bool faceIDEnabled =
  //             await LocalDatabase.instance.getFaceEnable() ?? false;
  //         bool isFingerPrintEnabled =
  //             await LocalDatabase.instance.getFingerEnable() ?? false;

  //         String? email = await LocalDatabase.instance.read(
  //           key: Strings.userEmail,
  //         );
  //         String? password = await LocalDatabase.instance.read(
  //           key: Strings.userPassword,
  //         );

  //         await LocalDatabase.instance.getStorageInstance.erase();

  //         await LocalDatabase.instance.clearAllUserData();

  //         LoginResponse loginResponse = LoginResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         await LocalDatabase.instance.saveUserPassword(
  //           password: password ?? "",
  //         );
  //         await LocalDatabase.instance.write(
  //           key: Strings.userEmail,
  //           value: email ?? "",
  //         );

  //         /// update state
  //         state = state.copyWith(loginResponse: loginResponse);
  //         getLocator<Logger>().i(
  //           "loginResponse: ${loginResponse.payload?.userInfo?.toJson()}",
  //         );

  //         final accessToken = loginResponse.payload?.userInfo?.accessToken
  //             .toString();

  //         if (!context.mounted) return;
  //         if (accessToken != null) {
  //           /// get refresh token
  //           await getRefreshToken(
  //             accessToken: accessToken,
  //             isAuthentication: 0,
  //             showLoader: true,
  //             email: loginResponse.payload?.userInfo?.email ?? "",
  //             phoneNumber: "",
  //             isDemo: false,
  //             context: context,
  //           );
  //         } else {
  //           getLocator<Logger>().e("Failed to get tokens [refresh, server]");
  //         }

  //         /// saving user data
  //         await Future.wait([
  //           LocalDatabase.instance.saveUserLoginData(
  //             loginResponse: loginResponse,
  //           ),
  //           LocalDatabase.instance.storeFaceEnable(
  //             isEnable: faceIDEnabled,
  //           ),
  //           // LocalDatabase.instance.storeFaceEnable(
  //           //   isEnable: faceIDEnabled,
  //           // ),
  //           // LocalDatabase.instance.storeFingerEnable(
  //           //   isEnable: isFingerPrintEnabled,
  //           // ),
  //           LocalDatabase.instance.storeFingerEnable(
  //             isEnable: isFingerPrintEnabled,
  //           ),
  //           LocalDatabase.instance.getLoginUserFromStorage(),

  //           LocalDatabase.instance.saveUserIDToken(
  //             userId: loginResponse.payload?.userInfo?.id.toString() ?? "",
  //           ),
  //           LocalDatabase.instance.saveUserAccountID(
  //             userId:
  //                 loginResponse.payload?.userInfo?.accountId.toString() ?? "",
  //           ),
  //           LocalDatabase.instance.getUserId(),

  //           LocalDatabase.instance.write(
  //             key: Strings.userID,
  //             value: loginResponse.payload?.userInfo?.id.toString(),
  //           ),
  //           LocalDatabase.instance.write(
  //             key: Strings.userFirstName,
  //             value: loginResponse.payload?.userInfo?.firstName.toString(),
  //           ),
  //           LocalDatabase.instance.write(
  //             key: Strings.userSurname,
  //             value: loginResponse.payload?.userInfo?.surname.toString(),
  //           ),
  //           LocalDatabase.instance.write(
  //             key: Strings.userEmail,
  //             value: loginResponse.payload?.userInfo?.email.toString(),
  //           ),
  //           LocalDatabase.instance.write(
  //             key: Strings.userPhoneNumber,
  //             value: loginResponse.payload?.userInfo?.phoneNumber.toString(),
  //           ),
  //           LocalDatabase.instance.write(
  //             key: Strings.userImageUrl,
  //             value: loginResponse.payload?.userInfo?.imageUrl.toString(),
  //           ),

  //           ///Initializing Push Notification Service
  //           FirebasePushNotificationService.initializeNotification(
  //             userTopic: loginResponse.payload?.userInfo?.email ?? "",
  //           ),
  //         ]).then((value) {
  //           getLocator<Logger>().i("loginDataStored");
  //         });

  //         setButtonState(false);

  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(errorResponse: errorResponse);
  //         getLocator<Logger>().e(
  //           "error: ${errorResponse.payload?.message.toString()}",
  //         );
  //         Toasts.getErrorToast(
  //           text: "${errorResponse.payload?.message.toString()}",
  //         );

  //         setButtonState(false);
  //         break;
  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "ExceptionError: ${serverResponse.resultData}",
  //         );
  //         setButtonState(false);
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     getLocator<Logger>().e("onError: $e");
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     setButtonState(false);
  //   }
  // }

  /// update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      String? email = await LocalDatabase.instance.read(
        key: Strings.userEmail,
      );

      final requestData = {
        "email": email,
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      };

      /// get refresh token
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        setButtonState(false);
        return;
      }

      /// update password
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updatePasswordUrl,
        httpMethod: HttpMethod.patch,
        headers: {
          "Authorization": "Bearer $refreshToken",
          "Content-Type": "application/json",
        },
        body: requestData,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Password updated successfully.");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );
          await LocalDatabase.instance.saveUserPassword(
            password: newPassword,
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            ((route) => false),
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Password Update Error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    } finally {
      setButtonState(false);
    }
  }

  /// update password
  Future<void> uploadResidencyDocument({
    required String pdfPath,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      setUploadImageState(true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// get refresh token
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        setButtonState(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        'Content-Type': 'multipart/form-data',
      };

      /// Prepare the file for upload
      FormData formData = FormData.fromMap({
        'myImage': await MultipartFile.fromFile(pdfPath, filename: fileName),
      });

      /// update password
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.uploadResidencyPDFApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: formData,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          UploadResidencyResponse uploadResidencyResponse =
              UploadResidencyResponse.fromJson(
                serverResponse.resultData,
              );
          getLocator<Logger>().i(
            "ResidencyUploaded: ${uploadResidencyResponse.payload?.toJson()}",
          );

          state = state.copyWith(
            residencyPDFUrl: uploadResidencyResponse.payload?.residencyProofURL
                .toString(),
          );
          setUploadImageState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );
          setUploadImageState(false);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          setUploadImageState(false);
          break;
      }
    } catch (e, stackTrace) {
      setUploadImageState(false);
      getLocator<Logger>().e("Uploading Residency Error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    } finally {
      setButtonState(false);
    }
  }

  Future<void> uploadNomineeDocument({
    required String pdfPath,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      setUploadImageState(true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// get refresh token
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        setButtonState(false);
        return;
      }

      final headers = {
        "Authorization": "Bearer $refreshToken",
        'Content-Type': 'multipart/form-data',
      };

      /// Prepare the file for upload
      FormData formData = FormData.fromMap({
        'myImage': await MultipartFile.fromFile(pdfPath, filename: fileName),
      });

      /// update password
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.nomineePDFApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: formData,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          uploadNomineeResponse uploadResidencyResponse = uploadNomineeResponse
              .fromJson(
                serverResponse.resultData,
              );
          getLocator<Logger>().i(
            "NomineeUploaded: ${uploadResidencyResponse.payload?.toJson()}",
          );

          state = state.copyWith(
            residencyPDFUrl: uploadResidencyResponse.payload?.residencyProofURL
                .toString(),
          );
          setUploadImageState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );
          setUploadImageState(false);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          setUploadImageState(false);
          break;
      }
    } catch (e, stackTrace) {
      setUploadImageState(false);
      getLocator<Logger>().e("Uploading Residency Error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    } finally {
      setButtonState(false);
    }
  }

  /// fetch all countries
  Future<void> fetchAllCountries() async {
    try {
      // Set loading state
      setLoadingState(LoadingState.loading);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// Get all countries
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllCountriesApiUrl,
        httpMethod: HttpMethod.get,
        headers: {
          "Authorization": "Bearer $refreshToken",
          "Content-Type": "application/json",
        },
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          GetAllCountryResponseModel countriesData =
              GetAllCountryResponseModel.fromJson(
                serverResponse.resultData,
              );

          state = state.copyWith(
            countries: countriesData.payload?.kAllCountries ?? [],
          );

          setLoadingState(LoadingState.data);

          getLocator<Logger>().i(
            "Fetched ${countriesData.payload} countries successfully.",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          // setLoadingState(LoadingState.error);
          fetchAllCountries();
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          fetchAllCountries();
          // setLoadingState(LoadingState.error);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e(
        "Fetch Countries Error: $e",
      );
      fetchAllCountries();
      // setLoadingState(LoadingState.error);
    }
  }
  // if (isDemo) {
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => MainHomeScreen()),
  //                 (route) => false,
  //               );
  //             } else {
  //               await Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => KycFirstStepScreen(

  //                   ),
  //                 ),
  //               );
  //             }
  /// user login
  /// @param {email: String, fullName: String, password: String}
  Future<void> userRegister({
    required Map<String, dynamic> body,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);
      await getDeviceInformation();
      final Map<String, dynamic> finalBody = {
        ...body,
        "deviceName": state.deviceName,
        "deviceType": state.deviceType, // Android or iOS
        "deviceOperatingSystem": state.operatingSystem,
        //"deviceIp": state.deviceUniqueID,
        "deviceIPAddress": state.deviceIpAddress,
        "deviceId": state.deviceUniqueID,
        // "deviceIPAddress": state.deviceIpAddress,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerApiUrl,
        body: finalBody,
        httpMethod: HttpMethod.post,
      );

      print("  final responmse $finalBody");

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          await LocalDatabase.instance.getStorageInstance.erase();
          await LocalDatabase.instance.clearAllUserData();

          RegisterResponse registerResponse = RegisterResponse.fromJson(
            serverResponse.resultData,
          );
          // SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(registerResponse: registerResponse);
          getLocator<Logger>().i(
            "registerResponse: ${registerResponse.payload?.createdUser?.toJson()}",
          );

          final accessToken = registerResponse.payload?.createdUser?.accessToken
              .toString();

          /// access token
          if (accessToken != null) {
            /// save register data
            await Future.wait([
              /// save register data
              LocalDatabase.instance.saveRegisterData(
                registerResponse: registerResponse,
              ),

              LocalDatabase.instance.saveUserIDToken(
                userId:
                    registerResponse.payload?.createdUser?.id.toString() ?? "",
              ),
              LocalDatabase.instance.getUserId(),

              LocalDatabase.instance.write(
                key: Strings.userEmail,
                value: registerResponse.payload?.createdUser?.email.toString(),
              ),
              LocalDatabase.instance.saveUserPassword(
                password: body['password'],
              ),
              LocalDatabase.instance.write(
                key: Strings.userPhoneNumber,
                value: registerResponse.payload?.createdUser?.phoneNumber
                    .toString(),
              ),
              LocalDatabase.instance.write(
                key: Strings.userSurname,
                value: registerResponse.payload?.createdUser?.surname
                    .toString(),
              ),

              LocalDatabase.instance.saveUserAccountID(
                userId:
                    registerResponse.payload?.createdUser?.accountId
                        .toString() ??
                    "",
              ),
              LocalDatabase.instance.getUserId(),

              LocalDatabase.instance.write(
                key: Strings.userID,
                value: registerResponse.payload?.createdUser?.id.toString(),
              ),
              LocalDatabase.instance.write(
                key: Strings.userFirstName,
                value: registerResponse.payload?.createdUser?.firstName
                    .toString(),
              ),

              ///Initializing Push Notification Service
              FirebasePushNotificationService.initializeNotification(
                userTopic: body['email'],
              ),
            ]);

            if (!context.mounted) return;

            /// get refresh token
            await getRefreshToken(
              accessToken: accessToken,
              isAuthentication: 0,
              email: body['email'],
              phoneNumber: body['phoneNumber'],
              context: context,
              showLoader: true,
              isDemo: body['userType'] == "Demo" ? true : false,
            );

            setButtonState(false);
            if (body['userType'] != "Demo") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const KycFirstStepScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainHomeScreen()),
                (route) => false,
              );
            }
          } else {
            getLocator<Logger>().e("Failed to get tokens [refresh, server]");
          }

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("onError: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      setButtonState(false);
    }
  }

  /// user verify passcode
  /// @param {String: accessToken, num: isAuthentication}
  Future<void> getRefreshToken({
    required String accessToken,
    required num isAuthentication,
    required String email,
    required String phoneNumber,
    required bool isDemo,
    required BuildContext context,
    required bool showLoader,
  }) async {
    try {
      setButtonState(showLoader);

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      };

      final body = {
        "accessToken": accessToken,
      };

      getLocator<Logger>().f("headers: $headers | accessToken: $accessToken");

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.refreshTokenApiUrl,
        headers: headers,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          RefreshTokenResponse refreshTokenResponse =
              RefreshTokenResponse.fromJson(
                serverResponse.resultData,
              );
          // update state
          state = state.copyWith(
            refreshTokenResponse: refreshTokenResponse,
          );
          getLocator<Logger>().i(
            "refreshTokenResponse: ${refreshTokenResponse.payload?.toJson()}",
          );

          /// save register data
          await Future.wait([
            SecureStorageService.instance.saveUserRefreshToken(
              value: refreshTokenResponse.payload?.updatedTokens?.refreshToken
                  ?.toString(),
            ),
            // LocalDatabase.instance.write(
            //   key: Strings.userRefreshToken,
            //   value: refreshTokenResponse.payload?.updatedTokens?.refreshToken
            //       ?.toString(),
            // ),
            LocalDatabase.instance.write(
              key: Strings.userServerToken,
              value: refreshTokenResponse.payload?.updatedTokens?.serverToken
                  ?.toString(),
            ),

            /// save user login token
            LocalDatabase.instance.saveUserLoginToken(
              token: refreshTokenResponse.payload!.updatedTokens!.refreshToken
                  .toString(),
            ),
            LocalDatabase.instance.getLoginToken(),
          ]);

          if (isAuthentication == 0) {
            /// register passcode verify screen
            if (!context.mounted) return;
            SoundPlayer().playSound(AppSounds.loginSound);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainHomeScreen(),
              ),
              ((route) => false),
            );
          } else if (isAuthentication == 1) {
            if (!context.mounted) return;
            SoundPlayer().playSound(AppSounds.loginSound);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneVerifyCodeScreen(
                  isFirstTime: true,
                  phoneNumber: phoneNumber,
                  isDemo: isDemo,
                ),
              ),
            );
          }
          setButtonState(false);
          break;
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("onError: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      setButtonState(false);
    }
  }

  /// resend passcode forgot password
  Future<void> resendPasscodeForgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendEmailPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForgotPasswordVerifyCodeScreen(
                email: email,
              ),
            ),
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// resend passcode forgot password
  Future<void> sendOtpForSignUp({
    required String email,
    required String phoneNumber,
    required Map<String, dynamic> data,
    required bool navigate,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.preVerifyApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            oneTimePassword:
                serverResponse.resultData['payload']['oneTimePassword'],
          );
          if (!context.mounted) return;
          if (navigate) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignupVerifyCodeScreen(
                  data: data,
                  email: email,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          }

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: successResponse.message.toString(),
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> sendOtpForChnagePhoneNumber({
    required String phoneNumber,
    required Map<String, String> data,
    required bool navigate,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.preVerifyApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            oneTimePassword:
                serverResponse.resultData['payload']['oneTimePassword'],
          );
          if (!context.mounted) return;
          if (navigate) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateAccountVerifyCodeScreen(
                  data: data,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          }

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: AppLocalizations.of(
              context,
            )!.request_sent, //successResponse.message.toString(),
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// resend phone passcode forgot password
  Future<void> resendPhonePasscodeForgotPassword({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      setButtonState(true);
      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendPhonePasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForgotPhoneVerifyCodeScreen(
                phoneNumber: phoneNumber,
              ),
            ),
          );
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          if (!context.mounted) return;

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// add new password with email
  Future<void> addNewPasswordWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "userCredential": email,
        "password": password,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.addNewPasswordApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );
          await LocalDatabase.instance.saveUserPassword(
            password: password,
          );
          await LocalDatabase.instance.write(
            key: Strings.userEmail,
            value: email,
          );
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            ((route) => false),
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> reUploadUserKycData({
    String? firstName,
    String? surname,
    String? firstNameInArabic,
    String? surnameInArabic,
    String? email,
    String? phoneNumber,
    String? dateOfBirthday,
    String? countryOfResidence,
    String? countryOfResidenceInArabic,
    String? nationality,
    String? nationalityInArabic,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);
      final token = await LocalDatabase.instance.getLoginToken();
      final Map<String, dynamic> body = {};
      if (firstName != null) body["firstName"] = firstName;
      if (surname != null) body["surname"] = surname;
      if (firstNameInArabic != null) {
        body["firstNameInArabic"] = firstNameInArabic;
      }

      if (surnameInArabic != null) body["surnameInArabic"] = surnameInArabic;
      if (email != null) body["email"] = email;
      if (phoneNumber != null) body["phoneNumber"] = phoneNumber;
      if (dateOfBirthday != null) body["dateOfBirthday"] = dateOfBirthday;
      if (countryOfResidence != null) {
        body["countryOfResidence"] = countryOfResidence;
      }

      if (countryOfResidenceInArabic != null) {
        body["countryOfResidenceInArabic"] = countryOfResidenceInArabic;
      }
      if (nationality != null) body["nationality"] = nationality;
      if (nationalityInArabic != null) {
        body["nationalityInArabic"] = nationalityInArabic;
      }

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.reUploadKycDataUrl,
        body: body,
        httpMethod: HttpMethod.patch,
        headers: {
          "Authorization": "Bearer $token",
          "content-type": "application/json",
        },
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(successResponse: successResponse);

          getLocator<Logger>().i(
            "KYC update success: ${successResponse.payload?.toJson()}",
          );
          getLocator<Logger>().i(
            "token: $token",
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainHomeScreen(),
            ),
            (route) => false,
          );

          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(errorResponse: errorResponse);

          getLocator<Logger>().e(
            "KYC update error: ${errorResponse.payload?.message.toString()}",
          );

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "KYC update exception: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e("KYC update onError: $e");
      setButtonState(false);
    }
  }

  /// user verify passcode
  /// @param {email: String, passcode: String}
  Future<void> userEmailVerifyPasscode({
    required String email,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerEmailVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);

        // **Throw an exception so it can be caught in the calling function**
        //throw Exception(errorResponse.payload?.message.toString());

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
        //throw Exception("An unexpected error occurred. Please try again.");
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
      //throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  /// user verify passcode
  /// @param {email: String, passcode: String}
  Future<void> userEmailVerifyPasscodeFromHome({
    required String email,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerEmailVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.pop(context);

          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);

        // **Throw an exception so it can be caught in the calling function**
        //throw Exception(errorResponse.payload?.message.toString());

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
        // throw Exception("An unexpected error occurred. Please try again.");
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
      //throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  Future<void> verifyUserEmailAndUpdate({
    required String email,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerEmailVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          if (!context.mounted) return;
          // SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          await updateUserEmail(context: context, newEmail: email);
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);

        // **Throw an exception so it can be caught in the calling function**
        //throw Exception(errorResponse.payload?.message.toString());

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
        // throw Exception("An unexpected error occurred. Please try again.");
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
      //throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  /// user email verify passcode password
  Future<void> userEmailVerifyPasscodePassword({
    required String email,
    required String passcode,
    BuildContext? context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerEmailVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context!.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          setButtonState(false);
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: email,
              ),
            ),
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// get email verify passcode
  Future<void> giftEmailVerifyPasscode({
    required String email,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerEmailVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );

          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// user verify passcode
  /// @param {email: String, passcode: String}
  Future<void> userPhoneVerifyPasscode({
    required String phoneNumber,
    required String passcode,
    required bool isFirstTime,
    required bool isDemo,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          // Add debug log
          getLocator<Logger>().i("Attempting navigation to KYC screen");

          if (!context.mounted) {
            getLocator<Logger>().w("Context not mounted, skipping navigation");
            return;
          }

          try {
            if (isDemo) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainHomeScreen()),
                (route) => false,
              );
            } else {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KycFirstStepScreen(
                    isFirstTime: isFirstTime,
                  ),
                ),
              );
            }

            getLocator<Logger>().i("Navigation successful");
          } catch (e, stackTrace) {
            await Sentry.captureException(
              e,
              stackTrace: stackTrace,
            );
            getLocator<Logger>().e("Navigation failed: $e");
          }
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );

          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// user withdraw phone verify passcode
  Future<void> userWithdrawPhoneVerifyPasscode({
    required String phoneNumber,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );

          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
      //return null;
    }
  }

  /// user verify passcode
  /// @param {email: String, passcode: String}
  Future<void> giftPhoneVerifyPasscode({
    required String phoneNumber,
    required String passcode,
    required String receiverId,
    required String receiverName,
    required String receiverEmail,
    required String giftAmount,
    required String paymentMethod,
    required String comment,
    List<Map<String, dynamic>>? selectedDealsData,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;

          SoundPlayer().playSound(AppSounds.depositSounmd);
          SuccessAnimationOverlay.show(
          context: context,
          // message: successResponse.payload?.message ??
          //     AppLocalizations.of(context)!.invest_successfully_submitted,
          displayDuration: const Duration(seconds: 2),
          onComplete: () {
            print("Buy gold animation completed");
          },
          message: '',
        );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftSuccessScreen(
                receiverId: receiverId,
                receiverName: receiverName,
                receiverEmail: receiverEmail,
                receiverPhoneNumber: phoneNumber,
                giftAmount: giftAmount,
                paymentMethod: paymentMethod,
                comment: comment,
                selectedDealsData: selectedDealsData,
              ),
            ),
          );
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );

        // return ServerResponseType.exception;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// delete user account
  /// @param {email: String, passcode: String}
  Future<void> deleteUserAccount({
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final token = await LocalDatabase.instance.getLoginToken();
      final userId = await LocalDatabase.instance.getUserId();
      getLocator<Logger>().i(
        "deleteUserAccountUserId: $userId | token: $token",
      );

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
      final body = {
        "_id": userId,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        headers: headers,
        url: ApiEndpoints.deleteUserAccountApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;

          /// delete account
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => GetStartedScreen(),
            ),
            ((route) => false),
          );

          Toasts.getSuccessToast(text: "${successResponse.payload?.message}");

          setButtonState(false);
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          setButtonState(false);
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> changeUser({required BuildContext context}) async {
    try {
      setButtonState(true);

      final token = await LocalDatabase.instance.getLoginToken();

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = await DioNetworkManager().callAPI(
        headers: headers,
        url: ApiEndpoints.changeUserAccountApiUrl,
        httpMethod: HttpMethod.patch,
      );

      if (!context.mounted) return;

      switch (response.responseType) {
        case ServerResponseType.success:
          final success = SuccessResponse.fromJson(response.resultData);
          getLocator<Logger>().i("Success: ${success.payload?.toJson()}");

          SoundPlayer().playSound(AppSounds.loginSound);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => GetStartedScreen()),
            (route) => false,
          );
          Toasts.getSuccessToast(text: success.payload?.message ?? "Success");
          break;
        case ServerResponseType.error:
          final error = ErrorResponse.fromJson(response.resultData);
          getLocator<Logger>().e("Error: ${error.payload?.message}");
          Toasts.getErrorToast(
            text: error.payload?.message ?? "Error occurred",
          );
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${response.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e("Exception: $e");
    } finally {
      setButtonState(false);
    }
  }

  /// resend phone passcode
  /// @param {phoneNumber: String}
  Future<void> resendPhonePasscode({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendPhonePasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  // resend phone passcode
  Future<void> resendPhonePasscodeForGift({
    required String phoneNumber,
    required BuildContext context,
    required String receiverId,
    required String receiverName,
    required String receiverEmail,
    required String giftAmount,
    required String paymentMethod,
    required String comment,
    List<Map<String, dynamic>>? selectedDealsData,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendPhonePasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            otpSuccessResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          setButtonState(false);
          Navigator.pop(context);
          // Then navigate to verify screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftPhoneVerifyCodeScreen(
                phoneNumber: phoneNumber,
                receiverId: receiverId,
                receiverName: receiverName,
                receiverEmail: receiverEmail,
                giftAmount: giftAmount,
                paymentMethod: paymentMethod,
                selectedDealsData: selectedDealsData,
                comment: comment,
              ),
            ),
          );
          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );

      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// resend phone passcode for withdraw screen
  /// @param {phoneNumber: String}
  /// @param {json: Map<String, dynamic>}
  Future<void> resendPhonePasscodeForWithdraw({
    required BuildContext context,
    required Map<String, dynamic> json,
  }) async {
    try {
      setButtonState(true);
      String? phoneNumber = await LocalDatabase.instance.read(
        key: Strings.userPhoneNumber,
      );
      final body = {
        "phoneNumber": phoneNumber,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendPhonePasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawPhoneVerifyCodeScreen(
                phoneNumber: phoneNumber!,
                json: json,
              ),
            ),
          );

          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawPhoneVerifyCodeScreen(
                phoneNumber: phoneNumber!,
                json: json,
              ),
            ),
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// withdraw phone verify passcode
  /// @param {phoneNumber: String}
  /// @param {json: Map<String, dynamic>}
  Future<void> withdrawPhoneVerifyPasscode({
    required String phoneNumber,
    required String passcode,
    required BuildContext context,
    required Map<String, dynamic> json,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawalSuccessScreen(
                json: json,
              ),
            ),
          );
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawalSuccessScreen(
                json: json,
              ),
            ),
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      setButtonState(false);
    }
  }

  ///verify phone verify passcode forgot password
  Future<void> verifyPhoneVerifyPasscodeForgotPassword({
    required String phoneNumber,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: phoneNumber,
              ),
            ),
          );

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> verifySignupPasscode({
    required String phoneNumber,
    required String passcode,
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          userRegister(body: data, context: context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ResetPasswordScreen(
        //       email: phoneNumber,
        //     ),
        //   ),
        // );

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  ///phone verification after account approval on login
  Future<void> verifyPhoneVerifyPasscodeLogin({
    required String phoneNumber,
    required String passcode,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "phoneNumber": phoneNumber,
        "passcode": passcode,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.registerPhoneVerifyPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      setButtonState(false);

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.loginSound);
          state = state.copyWith(
            successResponse: successResponse,
          );

          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// resend email passcode
  /// @param {email: String}
  Future<void> resendEmailPasscode({
    required String email,
    required BuildContext context,
  }) async {
    try {
      setButtonState(true);

      final body = {
        "email": email,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendEmailPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  /// resend email passcode
  /// @param {email: String}
  Future<void> resendFromHomeEmailPasscode({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final body = {
        "email": email,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.resendEmailPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          Toasts.getSuccessToast(
            gravity: ToastGravity.TOP,
            text: "${successResponse.payload?.message.toString()}",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
    }
  }

  Future<void> resendOtpPreVerifyEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final body = {
        "email": email,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.allEmailPasscodeApiUrl,
        body: body,
        httpMethod: HttpMethod.post,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          // store OTP in AuthState
          state = state.copyWith(
            otpSuccessResponse: successResponse,
            oneTimePassword: successResponse.payload?.otp ?? '',
          );

          // Toasts.getSuccessToast(
          //   gravity: ToastGravity.TOP,
          //   text: "${successResponse.payload?.message}",
          // );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
    }
  }

  /// resend email passcode
  /// @param {email: String}
  Future<void> kycFirstStep({
    required String dateOfBirthday,
    required String countryOfResidence,
    required String nationality,
    required String residencyProofUrl,
    required BuildContext context,
    bool? isFirstTime,
  }) async {
    try {
      setButtonState(true);

      final token = await LocalDatabase.instance.getLoginToken();
      getLocator<Logger>().i("token: $token");

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final body = {
        "dateOfBirthday": dateOfBirthday, //YYYY-MM-DD
        "countryOfResidence": countryOfResidence,
        "nationality": nationality,
        "residencyProof": residencyProofUrl,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.kycFirstStepApiUrl,
        headers: headers,
        body: body,
        httpMethod: HttpMethod.patch,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          // update state
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KycSecondStepScreen(),
            ),
          );
          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            gravity: ToastGravity.TOP,
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }

  Future<void> logoutUser({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      setButtonState(true);

      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      };

      final body = {
        "id": userId,
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.logoutUserApiUrl,
        body: body,
        httpMethod: HttpMethod.patch,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          final responseData = serverResponse.resultData;
          
        SocketService().disconnect();

          SuccessResponse successResponse = SuccessResponse.fromJson(
            responseData,
          );

          if (!context.mounted) return;

          state = state.copyWith(successResponse: successResponse);

          getLocator<Logger>().i(
            "Logout Success: ${successResponse.payload?.toJson()}",
          );

          await CommonService.logoutUser(context: context);
          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );

          Toasts.getErrorToast(text: "${errorResponse.payload?.message}");
          getLocator<Logger>().e(
            "Logout Error: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Logout Exception: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e("Logout Exception: $e");
    } finally {}
    setButtonState(false);
  }

  // Future<void> logoutUser({
  //   required BuildContext context,
  //   required String userId,
  // }) async {
  //   try {
  //     setButtonState(true);

  //     String? refreshToken = await SecureStorageService.instance
  //         .getRefreshToken();

  //     final headers = {
  //       "Authorization": "Bearer $refreshToken",
  //       "Content-Type": "application/json",
  //     };

  //     final body = {
  //       "id": userId,
  //     };

  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.logoutUserApiUrl,
  //       body: body,
  //       httpMethod: HttpMethod.patch,
  //       headers: headers,
  //     );

  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         final responseData = serverResponse.resultData;

  //         SuccessResponse successResponse = SuccessResponse.fromJson(
  //           responseData,
  //         );

  //         if (!context.mounted) return;

  //         state = state.copyWith(successResponse: successResponse);

  //         getLocator<Logger>().i(
  //           "Logout Success: ${successResponse.payload?.toJson()}",
  //         );
  //         CommonService.logoutUser(context: context);
  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );

  //         Toasts.getErrorToast(text: "${errorResponse.payload?.message}");
  //         getLocator<Logger>().e(
  //           "Logout Error: ${errorResponse.payload?.message}",
  //         );
  //         break;

  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "Logout Exception: ${serverResponse.resultData}",
  //         );
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(e, stackTrace: stackTrace);
  //     getLocator<Logger>().e("Logout Exception: $e");
  //   } finally {
  //     setButtonState(false);
  //   }
  // }
}
