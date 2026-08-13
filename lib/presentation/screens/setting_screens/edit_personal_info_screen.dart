import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/widgets/profile_image.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';

import '../../sharedProviders/providers/auth_provider.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart' show ShimmerLoader;

class EditPersonalInfoScreen extends ConsumerStatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  ConsumerState createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState
    extends ConsumerState<EditPersonalInfoScreen> {
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String currentIsoCode = "IQ";
  String _originalFirstName = '';
  String dialCode = "+964";
  String orignalDialCode = "+964";
  String orignalIsoCode = "IQ";
  String _originalSurname = '';
  String _originalEmail = '';
  String _originalPhoneNumber = '';
  final _formKey = GlobalKey<FormState>();
  bool isEditable = false;

  // final List<Map<String, String>> countryOptions = [
  //   {'name': 'UAE', 'code': '971', 'flag': '🇦🇪', 'hint': '009 XX || +9X XX'},
  //   {'name': 'Iraq', 'code': '964', 'flag': '🇮🇶', 'hint': '009 XX || +9X XX'},
  //   {
  //     'name': 'Jordan',
  //     'code': '962',
  //     'flag': '🇯🇴',
  //     'hint': '009 XX || +9X XX',
  //   },
  //   {
  //     'name': 'Saudia',
  //     'code': '966',
  //     'flag': '🇸🇦',
  //     'hint': '009 XX || +9X XX',
  //   },
  // ];

  // String currentFlag = '🇦🇪'; // Default to UAE flag
  // String currentHint = '009 XX || +9X XX'; // Default to UAE hint

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void initData() async {
    await ref.read(homeProvider.notifier).getUserProfile();
    final userProfile = ref
        .read(homeProvider)
        .getUserProfileResponse
        .payload
        ?.userProfile;

    if (userProfile != null) {
      firstNameController.text = userProfile.firstName!.en ?? "";
      surnameController.text = userProfile.surname!.en ?? "";
      phoneNumberController.text = userProfile.phoneNumber ?? "";
      emailController.text = userProfile.email ?? "";
      currentIsoCode = userProfile.isoCode ?? "IQ";
      dialCode = userProfile.dialCode ?? "+964";
      orignalIsoCode = userProfile.isoCode ?? "IQ";
      orignalDialCode = userProfile.dialCode ?? "+964";
      // Store original values for comparison
      _originalFirstName = firstNameController.text;
      _originalSurname = surnameController.text;
      _originalEmail = emailController.text;
      _originalPhoneNumber = userProfile.phoneNumber ?? "";
      final String fullNumber = userProfile.phoneNumber ?? "";
      final String altDialCode = dialCode.replaceFirst("+", "00");
      String localNumber = fullNumber;
      if (localNumber.startsWith(dialCode)) {
        localNumber = localNumber.replaceFirst(dialCode, "");
      } else if (localNumber.startsWith(altDialCode)) {
        localNumber = localNumber.replaceFirst(altDialCode, "");
      }
      localNumber = localNumber.trim();
      phoneNumberController.text = localNumber;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  // void _updateFlagBasedOnCountryCode(String phoneNumber) {
  //   if (phoneNumber.startsWith('00971')) {
  //     setState(() {
  //       currentFlag = countryOptions[0]['flag']!;
  //       currentHint = countryOptions[0]['hint']!;
  //     });
  //     return;
  //   }
  //   if (phoneNumber.startsWith('00962')) {
  //     setState(() {
  //       currentFlag = countryOptions[2]['flag']!;
  //       currentHint = countryOptions[2]['hint']!;
  //     });
  //     return;
  //   }
  //   if (phoneNumber.startsWith('00964')) {
  //     setState(() {
  //       currentFlag = countryOptions[1]['flag']!;
  //       currentHint = countryOptions[1]['hint']!;
  //     });
  //     return;
  //   }

  //   // Fallback to UAE if no match
  //   setState(() {
  //     currentFlag = countryOptions[0]['flag']!;
  //     currentHint = countryOptions[0]['hint']!;
  //   });
  // }

  //   // Already in international format
  //   if (phone.startsWith('00971') ||
  //       phone.startsWith('00964') ||
  //       phone.startsWith('00962') ||
  //       phone.startsWith('00966')) {
  //     return phone;
  //   }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final authStateWatchProvider = ref.watch(authProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);
    final mainStateWatchProvider = ref.watch(homeProvider);
    bool isKycVerfied = mainStateWatchProvider.isProfileVerified;

    // force to bool
    final bool isDemo = LocalDatabase.instance.getIsDemo() == true;

    // prepare subtitle dynamically instead of duplicating widget
    final subtitle = (isDemo || !isKycVerfied)
        // ? "Warning: Updating your profile will log you out of your account. Are you sure you want to continue?"
        // : "Once your profile is verified, you will be logged out automatically. Are you sure you want to continue?";
        ? AppLocalizations.of(context)!.profile_update_warning
        : AppLocalizations.of(context)!.profile_verified_warning;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        // title: GetGenericText(
        //   text: AppLocalizations.of(context)!.settings_personal_info,
        //   fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
        //   fontWeight: FontWeight.w400,
        //   color: AppColors.grey6Color,
        // ),
        actions: [
          mainStateWatchProvider
                      .getUserProfileResponse
                      .payload
                      ?.userProfile!
                      .personalInfoUpdateStatus !=
                  "Pending"
              ? Directionality.of(context) == TextDirection.rtl
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEditable = !isEditable;
                            });
                            initData();
                          },
                          child: Container(
                            width: sizes!.responsiveWidth(
                              phoneVal: 60,
                              tabletVal: 80,
                            ),
                            height: sizes!.responsiveLandscapeHeight(
                              phoneVal: 24,
                              tabletVal: 34,
                              tabletLandscapeVal: 44,
                              isLandscape: sizes!.isLandscape(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: Color(0xFF333333),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: AppColors.goldColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Center(
                              child: GetGenericText(
                                text: isEditable
                                    ? AppLocalizations.of(context)!.pi_cancel
                                    : AppLocalizations.of(context)!.edit,
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 12,
                                  tabletVal: 14,
                                ),
                                fontWeight: FontWeight.w400,
                                color: AppColors.goldColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isEditable = !isEditable;
                            });
                            initData();
                          },
                          child: Container(
                            width: sizes!.responsiveWidth(
                              phoneVal: 60,
                              tabletVal: 80,
                            ),
                            height: sizes!.responsiveLandscapeHeight(
                              phoneVal: 24,
                              tabletVal: 34,
                              tabletLandscapeVal: 44,
                              isLandscape: sizes!.isLandscape(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: ShapeDecoration(
                              color: Color(0xFF333333),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: AppColors.goldColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: GetGenericText(
                                text: isEditable
                                    ? AppLocalizations.of(context)!.pi_cancel
                                    : AppLocalizations.of(context)!.edit,
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 12,
                                  tabletVal: 14,
                                ),
                                fontWeight: FontWeight.w400,
                                color: AppColors.goldColor,
                              ),
                            ),
                          ),
                        ),
                      )
              : Container(),
        ],
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(color: AppColors.greyScale1000),
        child: SafeArea(
          child: mainStateWatchProvider.loadingState == LoadingState.loading
              ? Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ),
                ).get20HorizontalPadding()
              : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.settings_personal_info,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 26,
                              tabletVal: 32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ),
                        ),

                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.settings_personal_info_desc,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 20,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                            lines: 4,
                          ),
                        ),

                        DisplayImage(
                          imagePath:
                              mainStateWatchProvider
                                  .getUserProfileResponse
                                  .payload
                                  ?.userProfile
                                  ?.imageUrl ??
                              '',
                          onImageSelected: (file) async {
                            if (file != null) {
                              debugPrint("Picked: ${file.path}");
                              await authStateReadProvider.uploadProfileImage(
                                filePath: file.path,
                                context: context,
                              );
                              if (context.mounted) {
                                await ref
                                    .read(homeProvider.notifier)
                                    .getUserProfile();
                                setState(() {}); // Refresh to show new image
                              }
                            }
                          },
                          isEditable: true, // Always allow profile image change
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),

                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(context)!.warning,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.redColor,
                          ),
                        ),
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.pi_update_warning,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 12,
                              tabletVal: 14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            lines: 4,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(context)!.kyc_first_name,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        CommonTextFormField(
                          title: AppLocalizations.of(context)!.pi_first_name,
                          hintText: AppLocalizations.of(
                            context,
                          )!.user_firstName, //"Amro",
                          labelText: AppLocalizations.of(
                            context,
                          )!.pi_first_name,
                          controller: firstNameController,
                          readOnly: isEditable ? false : true,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.enter_first_name; //"Please enter your first name."; //AppLocalizations.of(context)!.enter_first_name;
                            }
                            return null;
                          },
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 16),
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(context)!.kyc_last_name,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        CommonTextFormField(
                          title: AppLocalizations.of(context)!.surname,
                          hintText: AppLocalizations.of(
                            context,
                          )!.user_lastName, //"Jaber",
                          labelText: AppLocalizations.of(context)!.pi_surname,
                          controller: surnameController,
                          readOnly: isEditable ? false : true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.enter_surname; //"Please enter your surname."; //AppLocalizations.of(context)!.enter_first_name;
                            }
                            return null;
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.login_email_Labe,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        CommonTextFormField(
                          title: AppLocalizations.of(context)!.email,
                          hintText: AppLocalizations.of(
                            context,
                          )!.enter_email_hint,
                          labelText: AppLocalizations.of(context)!.pi_email,
                          controller: emailController,
                          readOnly: isEditable ? false : true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.please_enter_email;
                              // 'Please enter email';
                            } else if (!value.validateEmail()) {
                              return AppLocalizations.of(
                                context,
                              )!.invalid_email;
                              // 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        mainStateWatchProvider
                                    .getUserProfileResponse
                                    .payload
                                    ?.userProfile!
                                    .personalInfoUpdateStatus ==
                                "Pending"
                            ? Container(
                                width: sizes!.responsiveWidth(
                                  phoneVal: 100,
                                  tabletVal: 140,
                                ),
                                height: sizes!.responsiveLandscapeHeight(
                                  phoneVal: 22,
                                  tabletVal: 32,
                                  tabletLandscapeVal: 42,
                                  isLandscape: sizes!.isLandscape(),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: ShapeDecoration(
                                  color: Color(0xFF333333),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.pending_approval,
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 10,
                                      tabletVal: 12,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFC7C7CC),
                                  ),
                                ),
                              ).getAlignRight()
                            : SizedBox(),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // CommonPhoneFieldWithDropdown(
                        //   title: AppLocalizations.of(context)!.phone_number,
                        //   hintText: "52 00 00 000", // fallback
                        //   controller: phoneNumberController,
                        //   isoCode:
                        //       currentIsoCode, // this will trigger didUpdateWidget
                        //   onPhoneNumberChanged: (number, isoCode, dCode) {
                        //     currentIsoCode = isoCode;
                        //     dialCode = dCode;
                        //   },
                        //   validator: (value) {
                        //     final currentText = phoneNumberController.text.trim();
                        //     if (currentText.isEmpty) {
                        //       return AppLocalizations.of(
                        //         context,
                        //       )!.please_enter_email_or_phone;
                        //     }
                        //     return null;
                        //   },
                        // ),
                        _fieldSectionLabelAlign(
                          GetGenericText(
                            text: AppLocalizations.of(context)!.phone_number,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // Localizations.localeOf(context).languageCode == 'ar'
                        //     ? Row(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Expanded(
                        //             child: Directionality(
                        //               textDirection:
                        //                   Localizations.localeOf(
                        //                         context,
                        //                       ).languageCode ==
                        //                       'ar'
                        //                   ? TextDirection.rtl
                        //                   : TextDirection.ltr,
                        //               child: _buildTextField(
                        //                 phoneNumberController,
                        //                 '',
                        //                 isNumeric: true,
                        //                 readOnly: !isEditable,
                        //               ),
                        //             ),
                        //           ),
                        //           const SizedBox(width: 10),

                        //           Container(
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 12,
                        //               vertical: 15,
                        //             ),
                        //             decoration: BoxDecoration(
                        //               border: Border.all(
                        //                 color: AppColors.secondaryColor,
                        //               ),
                        //               borderRadius: BorderRadius.circular(12),
                        //             ),
                        //             child: Row(
                        //               children: [
                        //                 Image.asset(
                        //                   "packages/country_code_picker/flags/${currentIsoCode.toLowerCase()}.png",
                        //                   width: 24,
                        //                   errorBuilder: (c, e, s) => const Icon(
                        //                     Icons.flag,
                        //                     color: Colors.white,
                        //                   ),
                        //                 ),
                        //                 const SizedBox(width: 8),
                        //                 Text(
                        //                   dialCode,
                        //                   style: const TextStyle(
                        //                     color: AppColors.secondaryColor,
                        //                     fontSize: 16,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        Localizations.localeOf(context).languageCode == 'ar'
    ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FLAG + CODE (ALWAYS LTR - FIXED POSITION)
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: _buildTextField(
                phoneNumberController,
                '',
                isNumeric: true,
                readOnly: !isEditable,
              ),
            ),
          ),

          const SizedBox(width: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.secondaryColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "packages/country_code_picker/flags/${currentIsoCode.toLowerCase()}.png",
                    width: 24,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.flag,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dialCode,
                    style: const TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
           /// PHONE FIELD (ALWAYS LTR INPUT)
          

         
        ],
      )  
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.secondaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "packages/country_code_picker/flags/${currentIsoCode.toLowerCase()}.png",
                                          width: 24,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.flag,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dialCode,
                                          style: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Directionality(
                                      textDirection:
                                          Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: _buildTextField(
                                        phoneNumberController,
                                        '',
                                        isNumeric: true,
                                        readOnly: !isEditable,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                        // CommonPhoneFieldWithDropdown(
                        //   title: AppLocalizations.of(context)!.phone_number,
                        //   hintText: "52 00 00 000",
                        //   controller: phoneNumberController,
                        //   isoCode: currentIsoCode,
                        //   onPhoneNumberChanged: (number, isoCode, dCode) {
                        //     currentIsoCode = isoCode;
                        //     dialCode = dCode;
                        //   },
                        //   validator: (value) {
                        //     final text = value?.trim() ?? '';
                        //     if (text.isEmpty) {
                        //       return AppLocalizations.of(
                        //         context,
                        //       )!.enter_valid_phone; //"Enter a valid phone number";
                        //       // AppLocalizations.of(
                        //       //   context,
                        //       // )!.phone_format_note;
                        //     }
                        //     if (text.replaceAll(RegExp(r'\D'), '').length < 7) {
                        //       return AppLocalizations.of(
                        //         context,
                        //       )!.enter_valid_phone; //"Enter a valid phone number";
                        //       // AppLocalizations.of(
                        //       //   context,
                        //       // )!.phone_format_note;
                        //     }
                        //     return null;
                        //   },
                        // ),
                        ConstPadding.sizeBoxWithHeight(height: 20),
                        Visibility(
                          visible: isEditable,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                print("Current Iso=$currentIsoCode");
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  Map<String, String> updatedFields = {};

                                  if (firstNameController.text !=
                                      _originalFirstName) {
                                    updatedFields['firstName'] =
                                        firstNameController.text;
                                  }

                                  if (surnameController.text !=
                                      _originalSurname) {
                                    updatedFields['surname'] =
                                        surnameController.text;
                                  }
                                  if (emailController.text
                                          .trim()
                                          .toLowerCase() !=
                                      _originalEmail.trim().toLowerCase()) {
                                    updatedFields['email'] = emailController
                                        .text
                                        .trim();
                                  }

                                  String normalizedPhone =
                                      dialCode.replaceAll("+", "00") +
                                      phoneNumberController.text;
                                  bool isPhoneUpdated =
                                      normalizedPhone.replaceAll(" ", "") !=
                                      _originalPhoneNumber;
                                  if (isPhoneUpdated) {
                                    updatedFields['phoneNumber'] =
                                        normalizedPhone.replaceAll(" ", "");
                                    updatedFields['dialCode'] = dialCode;
                                    updatedFields['isoCode'] = currentIsoCode;
                                  }

                                  if (updatedFields.isNotEmpty) {
                                    debugPrint("Updated fields $updatedFields");
                                    if (isPhoneUpdated) {
                                      await authStateReadProvider
                                          .sendOtpForChnagePhoneNumber(
                                            phoneNumber: normalizedPhone
                                                .replaceAll(" ", ""),
                                            data: updatedFields,
                                            context: context,
                                            navigate: true,
                                          );
                                    } else {
                                      genericPopUpWidget(
                                        context: context,
                                        heading: AppLocalizations.of(
                                          context,
                                        )!.update_profile, //"Update Profile"
                                        subtitle: subtitle,
                                        noButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.cancel, //"Cancel",
                                        yesButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.update, //"Update",
                                        isLoadingState: ref
                                            .watch(authProvider)
                                            .isButtonState,
                                        onNoPress: () {
                                          Navigator.pop(context);
                                        },
                                        onYesPress: () async {
                                          Navigator.pop(context); // close popup
                                          await authStateReadProvider
                                              .editProfile(
                                                updatedFields: updatedFields,
                                                context: context,
                                              );
                                        },
                                      );
                                    }
                                  } else {
                                    Toasts.getErrorToast(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.update_profile_first,
                                    );
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              splashColor: Colors.white.withValues(alpha: 0.2),
                              highlightColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              child: Ink(
                                width: sizes!.isPhone
                                    ? sizes!.widthRatio * 353
                                    : sizes!.width,
                                height: sizes!.responsiveLandscapeHeight(
                                  phoneVal: 50,
                                  tabletVal: 56,
                                  tabletLandscapeVal: 76,
                                  isLandscape: sizes!.isLandscape(),
                                ),
                                decoration: BoxDecoration(
                                  color: isEditable
                                      ? null
                                      : const Color(0xFF8E8E93),
                                  gradient: isEditable
                                      ? const LinearGradient(
                                          begin: Alignment(1.00, 0.01),
                                          end: Alignment(-1, -0.01),
                                          colors: [
                                            AppColors.goldColor,
                                            AppColors.goldLightColor,
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: authStateWatchProvider.isButtonState
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : GetGenericText(
                                          text: AppLocalizations.of(
                                            context,
                                          )!.pi_update,
                                          fontSize: sizes!.responsiveFont(
                                            phoneVal: 18,
                                            tabletVal: 20,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          color: isEditable
                                              ? AppColors.grey6Color
                                              : AppColors.grey4Color,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).get16HorizontalPadding(),
                  ),
                ),
        ),
      ),
    );
  }

  /// Section labels above text fields — start edge (right in RTL, left in LTR).
  Widget _fieldSectionLabelAlign(Widget label) {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: label,
      ),
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String hint, {
  bool isPassword = false,
  bool isNumeric = false,
  String? label,
  bool showWarning = false,
  bool readOnly = false, // ✅ ADD THIS
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (label != null)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey6Color),
            ),
          ),
        ),
      TextFormField(
        controller: controller,
        readOnly: readOnly, // ✅ APPLY HERE
        enabled: !readOnly, // ✅ disables keyboard & cursor
        obscureText: isPassword,
        keyboardType: isNumeric
            ? TextInputType.number
            : TextInputType.emailAddress,
        style: const TextStyle(color: AppColors.secondaryColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          suffixIcon: showWarning
              ? const Icon(Icons.error_outline, color: Colors.white54)
              : (isPassword
                    ? const Icon(
                        Icons.visibility_outlined,
                        color: Colors.white54,
                      )
                    : null),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            // ✅ optional UI polish
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
      ),
    ],
  );
}
