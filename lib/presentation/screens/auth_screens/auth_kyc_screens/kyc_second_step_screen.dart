import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/feature_injection.dart';
import 'package:baghdad_bullion_house/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/home_provider.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/shuftipro_provider/shufti_pro_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/dot_bullet.dart';
import 'package:baghdad_bullion_house/presentation/widgets/loader_button.dart';
import 'package:baghdad_bullion_house/presentation/widgets/search_drop_down.dart';
import 'package:baghdad_bullion_house/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../services/ipass_kyc/ipass_kyc_service.dart';
import '../../../sharedProviders/providers/language_provider.dart';

class KycSecondStepScreen extends ConsumerStatefulWidget {
  const KycSecondStepScreen({super.key});

  @override
  ConsumerState createState() => _KycSecondStepScreenState();
}

class _KycSecondStepScreenState extends ConsumerState<KycSecondStepScreen> {
  String? _selectNationality;
  final _formKey = GlobalKey<FormState>();
  Locale? locale;
  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).fetchAllCountries();
      ref.read(homeProvider.notifier).getUserProfile();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  // String? validateCountrySelection(
  //   String? selectedCountryCode,
  //   String? yourNationality,
  //   String? yourResidency,
  // ) {
  //   if (selectedCountryCode == null || selectedCountryCode.trim().isEmpty) {
  //     return AppLocalizations.of(
  //       context,
  //     )!.ky_selec_cont; //'Please select a country';
  //   }

  //   final selected = selectedCountryCode.trim();
  //   final nationality = yourNationality?.trim();
  //   final residency = yourResidency?.trim();

  //   if (nationality != null && residency != null) {
  //     if (selected != nationality && selected != residency) {
  //       return '${AppLocalizations.of(context)!.kyc_select_either} $nationality\n${AppLocalizations.of(context)!.kyc_or} $residency.'; // <-- 2-line message
  //     }
  //   } else if (nationality != null && selected != nationality) {
  //     return "${AppLocalizations.of(context)!.kyc_select_nat}\n($nationality)."; // 2 lines
  //   } else if (residency != null && selected != residency) {
  //     return "${AppLocalizations.of(context)!.kyc_selct_res}\n($residency)."; // 2 lines
  //   }

  //   return null;
  // }
  String? validateCountrySelection(
    String? selectedCountry,
    String? yourNationalityName,
    String? yourResidencyName,
  ) {
    if (selectedCountry == null || selectedCountry.trim().isEmpty) {
      return AppLocalizations.of(context)!.ky_selec_cont;
    }

    final selected = selectedCountry.trim();
    final nationalityName = yourNationalityName?.trim();
    final residencyName = yourResidencyName?.trim();

    // Extract country code from selected value (if format is "AE - United Arab Emirates")
    String? extractCountryCode(String countryString) {
      if (countryString.contains(' - ')) {
        return countryString.split(' - ').first.trim();
      }
      return null;
    }

    // Extract country name from selected value
    String? extractCountryName(String countryString) {
      if (countryString.contains(' - ')) {
        return countryString.split(' - ').last.trim();
      }
      return countryString;
    }

    final selectedCode = extractCountryCode(selected);
    final selectedName = extractCountryName(selected);

    // Helper function to check if selected matches either name or expected value
    bool matchesCountry(
      String selectedCode,
      String selectedName,
      String expectedValue,
    ) {
      final expectedCode = extractCountryCode(expectedValue);
      final expectedName = extractCountryName(expectedValue);

      return selectedCode == expectedCode ||
          selectedName == expectedName ||
          selectedName == expectedValue ||
          selectedCode == expectedValue;
    }

    if (nationalityName != null && residencyName != null) {
      final matchesNationality = matchesCountry(
        selectedCode ?? '',
        selectedName ?? '',
        nationalityName,
      );
      final matchesResidency = matchesCountry(
        selectedCode ?? '',
        selectedName ?? '',
        residencyName,
      );

      if (!matchesNationality && !matchesResidency) {
        return '${AppLocalizations.of(context)!.kyc_select_either} $nationalityName \n${AppLocalizations.of(context)!.kyc_or} $residencyName';
      }
    } else if (nationalityName != null &&
        !matchesCountry(
          selectedCode ?? '',
          selectedName ?? '',
          nationalityName,
        )) {
      final displayName =
          extractCountryName(nationalityName) ?? nationalityName;
      return "${AppLocalizations.of(context)!.kyc_select_nat}\n($displayName).";
    } else if (residencyName != null &&
        !matchesCountry(
          selectedCode ?? '',
          selectedName ?? '',
          residencyName,
        )) {
      final displayName = extractCountryName(residencyName) ?? residencyName;
      return "${AppLocalizations.of(context)!.kyc_selct_res}\n($displayName).";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final languageState = ref.watch(languageProvider);
    locale = Locale(languageState.languageCode);
    final mainStateWatchProvider = ref.watch(homeProvider);
    final shuftiProWatchProvider = ref.watch(shuftiProProvider);

    final authState = ref.watch(authProvider);
    //final authNotifier = ref.read(authProvider.notifier);

    final List<String> countries =
        authState.countries
            .map((country) => "${country.name} - ${country.countryCode}")
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,

        // titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(
            context,
          )!.kyc_identity, //"Identity Verification",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ), //20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: shuftiProWatchProvider.isLoading
              ? Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ),
                ).get20HorizontalPadding()
              : authState.loadingState == LoadingState.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        height: sizes!.heightRatio * 30,
                        width: sizes!.widthRatio * 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.primaryGold500,
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: AppColors.whiteColor,
                          size: 16,
                        ),
                      ),
                      GetGenericText(
                        text:
                            "${authState.errorResponse.payload?.message.toString()}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey6Color,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 6),
                      LoaderButton(
                        title: AppLocalizations.of(
                          context,
                        )!.kyc_refresh, //"Refresh",
                        onTap: () async {
                          await ref
                              .read(authProvider.notifier)
                              .fetchAllCountries();
                        },
                      ).get16HorizontalPadding(),
                    ],
                  ),
                )
              : authState.loadingState == LoadingState.data
              ? SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ConstPadding.sizeBoxWithHeight(height: 24),
                        // GetGenericText(
                        //   text: "Identity Verification",
                        //   fontSize: sizes!.responsiveFont(
                        //     phoneVal: 24,
                        //     tabletVal: 32,
                        //   ),
                        //   //24,
                        //   fontWeight: FontWeight.w400,
                        //   color: AppColors.neutral92,
                        // ).getAlign(),
                        // ConstPadding.sizeBoxWithHeight(height: 20),
                        // SearchableDropdown(
                        //   iconString: "assets/svg/arrow_down.svg",
                        //   title: "title",
                        //   items: countries,
                        //   label: "Country",
                        //   hint: "Select",
                        //   selectedItem: _selectNationality,
                        //   validator: (value) =>
                        //       value == null ? 'Please select country' : null,
                        //   onChanged: (String value) {
                        //     setState(() {
                        //       // _selectNationality = value;
                        //       _selectNationality = value.split(' - ').last;
                        //       debugPrint(
                        //         "_selectNationality: $_selectNationality",
                        //       );
                        //     });
                        //   },
                        // ),
                        SearchableDropdown(
                          iconString: "assets/svg/arrow_down.svg",
                          title: "title",
                          items: countries,
                          label: AppLocalizations.of(
                            context,
                          )!.kyc_country, //"Country",
                          hint: AppLocalizations.of(
                            context,
                          )!.kyc_select, //"Select",
                          selectedItem: _selectNationality,
                          validator: (value) {
                            final nationality = mainStateWatchProvider
                                .getUserProfileResponse
                                .payload
                                ?.userProfile
                                ?.nationality;
                            final residency = mainStateWatchProvider
                                .getUserProfileResponse
                                .payload
                                ?.userProfile
                                ?.countryOfResidence;

                            return validateCountrySelection(
                              value,
                              nationality!.en ?? "", // English name
                              residency!.en ?? "", // English name
                            );
                          },
                          // validator: (value) {
                          //   final nationality = mainStateWatchProvider
                          //       .getUserProfileResponse
                          //       .payload
                          //       ?.userProfile
                          //       ?.nationality;
                          //   final residency = mainStateWatchProvider
                          //       .getUserProfileResponse
                          //       .payload
                          //       ?.userProfile
                          //       ?.countryOfResidence;
                          //   debugPrint(
                          //     'Validating: $value against nationality: $nationality, residency: $residency',
                          //   );
                          //   return validateCountrySelection(
                          //     value,
                          //     nationality!.en ?? "",
                          //     residency!.en ?? "",
                          //   );
                          // },
                          onChanged: (String value) {
                            setState(() {
                              _selectNationality = value.split(' - ').last;
                            });
                          },
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 8),
                        GetGenericText(
                          text:
                              "${AppLocalizations.of(context)!.kyc_upload} ${_selectNationality != null ? _selectNationality!.split('-')[0] : {AppLocalizations.of(context)!.kyc_govt}} ${AppLocalizations.of(context)!.kyc_issue}",

                          // "Upload a ${_selectNationality != null ? _selectNationality!.split('-')[0] : 'government'}'s issued ID to verify your identity securely. Following documents are accepted:",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          //16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral80,
                          lines: 4,
                        ).getAlign(),
                        ConstPadding.sizeBoxWithHeight(height: 24),
                        Row(
                          children: [
                            DotBullet(),
                            ConstPadding.sizeBoxWithWidth(width: 4),
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.kyc_na_id, //"National ID",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.neutral90,
                            ),
                          ],
                        ),
                        //ConstPadding.sizeBoxWithHeight(height: 4),
                        // Row(
                        //   children: [
                        //     DotBullet(),
                        //     ConstPadding.sizeBoxWithWidth(width: 4),
                        //     GetGenericText(
                        //       text: AppLocalizations.of(
                        //         context,
                        //       )!.kyc_em_id, //"Emirates ID",
                        //       fontSize: sizes!.responsiveFont(
                        //         phoneVal: 16,
                        //         tabletVal: 18,
                        //       ),
                        //       fontWeight: FontWeight.w400,
                        //       color: AppColors.neutral90,
                        //     ),
                        //   ],
                        // ),
                        ConstPadding.sizeBoxWithHeight(height: 4),
                        Row(
                          children: [
                            DotBullet(),
                            ConstPadding.sizeBoxWithWidth(width: 4),
                            GetGenericText(
                              text: "Housing Card",
                              // text: 
                              // AppLocalizations.of(
                              //   context,
                              // )!.kyc_driving, //"Driving License",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.neutral90,
                            ),
                          ],
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 4),
                        Row(
                          children: [
                            DotBullet(),
                            ConstPadding.sizeBoxWithWidth(width: 4),
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.kyc_passport, //"Passport",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w400,
                              color: AppColors.neutral90,
                            ),
                          ],
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 40),
                        SvgPicture.asset(
                          "assets/svg/user124_icon.svg",
                          height: sizes!.responsiveHeight(
                            phoneVal: 124,
                            tabletVal: 224,
                          ),
                          width: sizes!.responsiveWidth(
                            phoneVal: 124,
                            tabletVal: 224,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 40),
                        getStartButton(
                          title: AppLocalizations.of(
                            context,
                          )!.kyc_get_st, //"Get Started",
                          isLoadingState: ref
                              .watch(shuftiProProvider)
                              .isLoading,
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              Toasts.getSuccessToast(
                                text: AppLocalizations.of(context)!.wait_please,
                              );
                              // Toasts.getSuccessToast(text: "Please Wait...");
                              await ipassKyc(countryCode: _selectNationality!);
                            }
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                        GestureDetector(
                          onTap: () async {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainHomeScreen(),
                              ),
                              ((route) => false),
                            );
                          },
                          child: GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.kyc_skip, //"Skip for Now",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            //14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGold500,
                          ).getChildCenter(),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 20),
                      ],
                    ).get16HorizontalPadding(),
                  ),
                )
              : Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ),
                ).get20HorizontalPadding(),
        ),
      ),
    );
  }

  // get start button
  Widget getStartButton({
    required String title,
    required bool isLoadingState,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
        height: sizes!.responsiveLandscapeHeight(
          phoneVal: 56,
          tabletVal: 56,
          tabletLandscapeVal: 84,
          isLandscape: sizes!.isLandscape(),
        ),
        decoration: BoxDecoration(
          color: Color(0x33BBA473),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.50,
            color: Color(0xFFBBA473),
          ),
        ),
        child: Center(
          child: isLoadingState
              ? Container(
                  width: sizes!.widthRatio * 26,
                  height: sizes!.widthRatio * 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : GetGenericText(
                  text: title,
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 16,
                    tabletVal: 18,
                  ),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  /// generate random hex reference
  String generateRandomHexReference() {
    try {
      // Use secure random number generator
      final random = Random.secure();
      // Generate 16 bytes (32 hex characters)
      final bytes = Uint8List(16);
      for (var i = 0; i < 16; i++) {
        bytes[i] = random.nextInt(256);
      }
      // Convert to hex string
      return hex.encode(bytes);
    } catch (e, stackTrace) {
      // Capture error in Sentry for debugging
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        // hint: 'Failed to generate random hex reference',
      );
      // Log error locally
      getLocator<Logger>().e(
        'Failed to generate random hex reference',
        error: e,
        stackTrace: stackTrace,
      );
      // Return fallback reference with timestamp to ensure uniqueness
      return 'fallback-ref-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
    }
  }

  /// Camera + mic for KYC. iOS uses native AVFoundation prompts (see IpassKycPlugin).
  Future<bool> _ensureKycMediaPermissions() async {
    if (Platform.isIOS) {
      // Native plugin shows system dialogs; do not call openAppSettings here.
      return true;
    }

    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (camera.isGranted && mic.isGranted) {
      return true;
    }

    Toasts.getErrorToast(
      text: camera.isPermanentlyDenied || mic.isPermanentlyDenied
          ? 'Enable camera and microphone in app settings for KYC.'
          : 'Camera and microphone permissions are required for KYC.',
    );
    return false;
  }

  /// iPass KYC via native method channel (Android/iOS SDK).
  Future<void> ipassKyc({required String countryCode}) async {
    try {
      final config = IpassKycService.instance.loadConfigFromEnv();
      final email = config.email;
      final phone = config.phoneNumber;
      final socialEmail =
          config.socialMediaEmail.isNotEmpty ? config.socialMediaEmail : email;

      if (!config.isValid && email.isEmpty) {
        Toasts.getErrorToast(
          text: 'Configuration error, please try again later.',
        );
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[iPass] start — workflowId=${config.workflowId} dbType=${config.dbType}',
        );
      }

      if (!await _ensureKycMediaPermissions()) {
        return;
      }

      final ipassResult = await IpassKycService.instance.startKycVerification(
        email: email,
        password: config.password,
        appToken: config.appToken,
        workflowId: config.workflowId,
        socialMediaEmail: socialEmail,
        phoneNumber: phone,
        serverUrl: config.serverUrl,
        dbType: config.dbType,
        useDynamicDb: config.useDynamicDb,
        enableHologram: config.enableHologram,
      );

      if (!ipassResult.success || !ipassResult.apiStatus) {
        Toasts.getErrorToast(
          text: AppLocalizations.of(context)!.shufti_pro_verification_failed,
        );
        return;
        
      }


      final userId = await LocalDatabase.instance.getUserId();
      if (userId == null) {
        Toasts.getErrorToast(
          text: AppLocalizations.of(context)!.shufti_user_auth_issue,
        );
        return;
      }

      final kycPayload = IpassKycService.instance.buildBackendKycPayload(
        userId: userId,
        countryCode: countryCode,
        ipassResult: ipassResult,
      );

      await LocalDatabase.instance.saveKycData(
        kycPayload['kycData'] as Map<String, dynamic>,
      );

      if (!mounted) return;

      await ref.read(shuftiProProvider.notifier).submitKycPayload(
            data: kycPayload,
            context: context,
          );
    } on PlatformException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(
        text: e.message ??
            AppLocalizations.of(context)!.kyc_verification_failed,
      );
    } on IpassKycException catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(
        text: e.message,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      Toasts.getErrorToast(
        text: AppLocalizations.of(context)!.kyc_verification_failed,
      );
    }
  }
}
