import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../data/data_sources/local_database/secure_database.dart';
import '../../../data/data_sources/network_sources/api_url.dart';
import '../../../data/data_sources/network_sources/dio_experimental_network_manager.dart';
import '../../../data/models/ErrorResponse.dart';
import '../../../data/models/SuccessResponse.dart';

part 'language_provider.g.dart';

enum LanguageList {
  english,
  arabic,
  // russian,
  // hindi,
}

// Extension to override the toString method for LanguageList enum
extension LanguageListExtension on LanguageList {
  /// display name
  String get displayName {
    switch (this) {
      case LanguageList.english:
        return 'English';
      case LanguageList.arabic:
        return 'العربية';
      // case LanguageList.russian:
      //   return 'Русский';
      // case LanguageList.hindi:
      //   return 'हिंदी';
    }
  }

  /// flag icon path
  String get flagIconPath {
    switch (this) {
      case LanguageList.english:
        return "assets/svg/uk_icon.svg";
      case LanguageList.arabic:
        return "assets/svg/ae_icon.svg";
      // case LanguageList.russian:
      //   return "assets/svg/ru_icon.svg";
      // case LanguageList.hindi:
      //   return "assets/svg/india_icon.svg";
    }
  }

  /// locale code
  String get localeCode {
    switch (this) {
      case LanguageList.english:
        return "en";
      case LanguageList.arabic:
        return "ar";
      // case LanguageList.russian:
      //   return "ru";
      // case LanguageList.hindi:
      //   return "hi";
    }
  }
}

class LanguageState {
  final LanguageList selectedLanguage;
  final String languageCode;
  final bool isLoading;

  LanguageState({
    this.languageCode = 'en',
    this.selectedLanguage = LanguageList.english,
    this.isLoading = false,
  });

  LanguageState copyWith({
    String? languageCode,
    bool? isLoading,
  }) {
    return LanguageState(
      languageCode: languageCode ?? this.languageCode,
      selectedLanguage: selectedLanguage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class Language extends _$Language {
  @override
  LanguageState build() {
    init();
    return LanguageState(selectedLanguage: LanguageList.english);
  }

  /// init
  Future<void> init() async {
    getLocator<Logger>().i("LanguageProvider Initialized");
    await getLanguage();
  }

  // get language from storage
  Future<void> getLanguage() async {
    try {
      final result = await LocalDatabase.instance.read(
        key: Strings.kLanguageCode,
      );

      // Default to English if no saved language
      final savedCode = result ?? 'en';

      final selectedLang = savedCode == 'ar'
          ? LanguageList.arabic
          : LanguageList.english;

      state = LanguageState(
        languageCode: savedCode,
        selectedLanguage: selectedLang,
      );

      CommonService.lang = savedCode;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // Future<void> getLanguage() async {
  //   try {
  //     final result = await LocalDatabase.instance.read(
  //       key: Strings.kLanguageCode,
  //     );
  //     state = state.copyWith(languageCode: result);
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //   }
  // }

  Future<void> toggleLanguage(BuildContext context) async {
    final newLang =
        state.languageCode == 'en' ? LanguageList.arabic : LanguageList.english;

    // Save locally
    state = state.copyWith(
      languageCode: newLang.localeCode,
      // selectedLanguage: newLang,
    );
    // CommonService.lang = newLang.localeCode;
    // LocalDatabase.instance.write(
    //   key: Strings.kLanguageCode,
    //   value: newLang.localeCode,
    // );
    // CommonService.lang = newLang.localeCode;
    // await LocalDatabase.instance
    //     .write(key: Strings.kLanguageCode, value: newLang.localeCode);
    // await LocalDatabase.instance.read(key: Strings.kLanguageCode);
    // Call API to update server
    updateLanguage(language: newLang.localeCode, context: context, isDashboard: true);
  }

  // set user language
  void setLanguage({required String code}) async {
    state = state.copyWith(languageCode: code);
    CommonService.lang = code;
    await LocalDatabase.instance.write(key: Strings.kLanguageCode, value: code);
    String savedcode =    await LocalDatabase.instance.read(key: Strings.kLanguageCode);
  }

  Future<void> updateLanguage({
    required String language,
    required BuildContext context,
      required bool isDashboard}) async {
    try {
      if (isDashboard) {
        setLanguage(code: language);
        return;
      }
      state = state.copyWith(isLoading: true);

      /// Get refresh token
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isLoading: false);
        return;
      }

      final requestData = {
        "language": language,
      };

      /// Call API
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.updateLanguageUrl,
        httpMethod: HttpMethod.patch,
        headers: {
          "Authorization": "Bearer $refreshToken",
          "Content-Type": "application/json",
        },
        body: requestData,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Language updated successfully.");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );
          setLanguage(code: language);
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
            ((route) => false),
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
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
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Update Language Error: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // check if Arabic
  bool isRtl() {
    return state.languageCode == 'ar';
  }
}
