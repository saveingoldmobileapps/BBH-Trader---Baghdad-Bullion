import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field_with_icon.dart';

import '../../../../core/validators.dart';
import '../../../../data/models/shuftipro_model/SubmitKycError.dart';
import '../../../widgets/search_drop_down.dart';
import '../../../widgets/text_form_field.dart';
import 'kyc_first_step_screen.dart';

class KycReentryScreen extends ConsumerStatefulWidget {
  final SubmitKycError? responseData;

  const KycReentryScreen({super.key, required this.responseData});

  @override
  ConsumerState createState() => _KycReentryScreenState();
}

class _KycReentryScreenState extends ConsumerState<KycReentryScreen> {
  final _formKey = GlobalKey<FormState>();
  final dateOfBirthController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  // Initial selected values
  String? _selectResidency;
  String? _selectNationality;

  bool isPDFSelected = false;
  bool isPDFError = false;
  String? selectedPDFFileName;

  // Helper methods to determine which fields to show based on responseData
  bool get showFirstName =>
      widget.responseData?.payload?.nameFromKYC != null &&
      widget.responseData?.payload?.nameFromDB != null;

  bool get showLastName =>
      widget.responseData?.payload?.nameFromKYC != null &&
      widget.responseData?.payload?.nameFromDB != null;

  bool get showDOB =>
      widget.responseData?.payload?.dobFromKYC != null &&
      widget.responseData?.payload?.dobFromDB != null;

  // bool get showCountryOfResidence =>
  //     widget.responseData?.payload?.countryFromKYC != null &&
  //     widget.responseData?.payload?.residencyFromDB != null;

  // bool get showNationality =>
  //     widget.responseData?.payload?.countryFromKYC != null &&
  //     widget.responseData?.payload?.countryFromDB != null;

  // 🔹 Show Country of Residence field if KYC and DB differ
  bool get showCountryOfResidence {
    final payload = widget.responseData?.payload;
    if (payload == null) return false;
    final residencyKYC = payload.residencyFromKYC;
    final residencyDB = payload.residencyFromDB;
    return residencyKYC != null && residencyDB != null
        ? residencyKYC != residencyDB
        : residencyKYC != null || residencyDB != null;
  }

  // 🔹 Show Nationality field if KYC and DB differ
  bool get showNationality {
    final payload = widget.responseData?.payload;
    if (payload == null) return false;
    final nationalityKYC = payload.nationalityFromKYC;
    final nationalityDB = payload.nationalityFromDB;
    return nationalityKYC != null && nationalityDB != null
        ? nationalityKYC != nationalityDB
        : nationalityKYC != null || nationalityDB != null;
  }

  bool get noFieldsVisible =>
      !showFirstName &&
      !showLastName &&
      !showDOB &&
      !showCountryOfResidence &&
      !showNationality;

  // 1️⃣ Validate against KYC data (English + Arabic)
  String? _validateAgainstKYC() {
    final payload = widget.responseData?.payload;
    if (payload == null) return null;

    // Validate Name (check against both English and Arabic names from KYC)
    if (showFirstName) {
      final enteredFirstName = firstNameController.text.trim();
      final enteredLastName = lastNameController.text.trim();
      final enteredFullName = '$enteredFirstName $enteredLastName'.trim();

      bool englishNameMatch = false;
      bool arabicNameMatch = false;

      // Check English KYC
      if (payload.nameFromKYC != null && payload.nameFromKYC!.isNotEmpty) {
        final normalizedKYC = _normalizeName(payload.nameFromKYC!);

        // Match full name OR first + last anywhere in KYC full name
        englishNameMatch =
            normalizedKYC.contains(_normalizeName(enteredFullName)) ||
            _normalizeName(enteredFullName).contains(normalizedKYC) ||
            (normalizedKYC.contains(_normalizeName(enteredFirstName)) &&
                normalizedKYC.contains(_normalizeName(enteredLastName)));

        // englishNameMatch =
        //     _normalizeName(enteredFullName) == normalizedKYC ||
        //     (normalizedKYC.contains(_normalizeName(enteredFirstName)) &&
        //         normalizedKYC.contains(_normalizeName(enteredLastName)));
      }

      // Check Arabic KYC
      if (payload.nativeNameFromKYC != null &&
          payload.nativeNameFromKYC!.isNotEmpty) {
        final normalizedKYC = _normalizeArabic(payload.nativeNameFromKYC!);

        // Combine first and last names entered by the user
        final enteredFullArabicName = '$enteredFirstName $enteredLastName';
        final normalizedEnteredFullArabic = _normalizeArabic(
          enteredFullArabicName,
        );

        // Check for exact match after normalization
        arabicNameMatch = normalizedEnteredFullArabic == normalizedKYC;
      }

      // if (payload.nativeNameFromKYC != null &&
      //     payload.nativeNameFromKYC!.isNotEmpty) {
      //   final normalizedKYC = _normalizeName(payload.nativeNameFromKYC!);

      //   arabicNameMatch =
      //       normalizedKYC.contains(_normalizeName(enteredFullName)) ||
      //       _normalizeName(enteredFullName).contains(normalizedKYC) ||
      //       (normalizedKYC.contains(_normalizeName(enteredFirstName)) &&
      //           normalizedKYC.contains(_normalizeName(enteredLastName)));

      // }

      // If both KYC names exist, user can match either
      if (payload.nameFromKYC != null && payload.nativeNameFromKYC != null) {
        if (!englishNameMatch && !arabicNameMatch) {
          return "${AppLocalizations.of(context)!.name_does_not_match} ${payload.nameFromKYC}, ${AppLocalizations.of(context)!.arabic_n} ${payload.nativeNameFromKYC})"; //"Name does not match KYC records (English: ${payload.nameFromKYC}, Arabic: ${payload.nativeNameFromKYC})";
        }
      }
      // Only English KYC exists
      else if (payload.nameFromKYC != null && !englishNameMatch) {
        return "${AppLocalizations.of(context)!.name_kyc} ${payload.nameFromKYC}"; //"Name does not match KYC records: ${payload.nameFromKYC}";
      }
      // Only Arabic KYC exists
      else if (payload.nativeNameFromKYC != null && !arabicNameMatch) {
        return "${AppLocalizations.of(context)!.name_native} ${payload.nativeNameFromKYC}"; //"Name does not match KYC records: ${payload.nativeNameFromKYC}";
      }
    }

    // Validate DOB
    if (showDOB) {
      String? kycDOB = payload.dobFromKYC ?? payload.dobFromDB;
      if (kycDOB != null && dateOfBirthController.text.trim() != kycDOB) {
        return "${AppLocalizations.of(context)!.dob_kyc} $kycDOB"; //"Date of Birth does not match KYC records: $kycDOB";
      }
    }
    if (showCountryOfResidence) {
      final selectedResidenceCode = _extractCountryCode(_selectResidency);
      String? kycResidenceCode =
          payload.residencyFromKYC ?? payload.residencyFromDB;

      if (kycResidenceCode != null &&
          selectedResidenceCode != null &&
          selectedResidenceCode != kycResidenceCode) {
        return "${AppLocalizations.of(context)!.residency_kyc} $kycResidenceCode";
      }
    }

    // Validate Nationality
    if (showNationality) {
      final selectedNationalityCode = _extractCountryCode(_selectNationality);
      String? kycNationalityCode =
          payload.nationalityFromKYC ?? payload.nationalityFromDB;

      if (kycNationalityCode != null &&
          selectedNationalityCode != null &&
          selectedNationalityCode != kycNationalityCode) {
        return "${AppLocalizations.of(context)!.nationality_kyc} $kycNationalityCode";
      }
    }

    return null;
  }

  String _normalizeArabic(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[ًٌٍَُِّْـٰ‌‍‏]'), '') // remove Arabic diacritics
        .replaceAll(RegExp(r'\s+'), ' '); // normalize spaces
  }

  String _normalizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  // 2️⃣ Update _hasDataChanged() to handle Arabic names properly
  bool _hasDataChanged() {
    final payload = widget.responseData?.payload;
    if (payload == null) return false;

    // Check name changes
    if (showFirstName) {
      final enteredFullName =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
              .trim();
      final enteredFirstName = firstNameController.text.trim();

      bool nameChanged = false;

      // Check against DB English name
      if (payload.nameFromDB != null && payload.nameFromDB!.isNotEmpty) {
        nameChanged =
            _normalizeName(enteredFullName) !=
            _normalizeName(payload.nameFromDB!);
      }

      // If DB has Arabic name, check against that too
      if (!nameChanged &&
          payload.nativeNameFromKYC != null &&
          _isArabic(payload.nativeNameFromKYC!)) {
        nameChanged =
            _normalizeName(enteredFirstName) !=
            _normalizeName(payload.nativeNameFromKYC!);
      }

      if (nameChanged) return true;
    }

    // Check DOB
    if (showDOB) {
      String? dbDOB = payload.dobFromDB ?? payload.dobFromKYC;
      if (dbDOB != null && dateOfBirthController.text.trim() != dbDOB) {
        return true;
      }
    }

    // Check residency
    if (showCountryOfResidence) {
      final dbResidency = payload.residencyFromDB ?? payload.countryFromKYC;
      if (dbResidency != null && _selectResidency != dbResidency) {
        return true;
      }
    }

    // Check nationality
    // if (showNationality) {
    //   final dbNationality = payload.countryFromDB ?? payload.countryFromKYC;
    //   if (dbNationality != null && _selectNationality != dbNationality) {
    //     return true;
    //   }
    // }?
    if (showNationality) {
    final dbNationality = payload.nationalityFromDB ?? payload.nationalityFromKYC;
    
    // DEBUG: Print the values being compared
    print('=== NATIONALITY DEBUG ===');
    print('_selectNationality: "$_selectNationality" (type: ${_selectNationality.runtimeType})');
    print('dbNationality: "$dbNationality" (type: ${dbNationality.runtimeType})');
    print('Are they equal: ${_selectNationality == dbNationality}');
    print('showNationality: $showNationality');
    
    if (dbNationality != null && _selectNationality != dbNationality) {
      print('NATIONALITY CHANGED DETECTED!');
      return true;
    } else {
      print('No nationality change detected');
    }
  }

    return false;
  }

  //  Update _prefillData() to handle both English and Arabic names
  // void _prefillData() {
  //   final payload = widget.responseData?.payload;
  //   if (payload == null) return;

  //   // Pre-fill name fields - prioritize DB data, fallback to KYC data
  //   if (showFirstName) {
  //     String? nameToUse = payload.nameFromDB ?? payload.nameFromKYC;

  //     if (nameToUse != null && nameToUse.isNotEmpty) {
  //       final nameParts = nameToUse.split(' ');
  //       if (nameParts.isNotEmpty) {
  //         firstNameController.text = nameParts.first;
  //       }
  //       if (nameParts.length > 1) {
  //         lastNameController.text = nameParts.sublist(1).join(' ');
  //       }
  //     }
  //     // If we have Arabic name in KYC and no English name, use Arabic name
  //     else if (payload.nativeNameFromKYC != null &&
  //         payload.nativeNameFromKYC!.isNotEmpty) {
  //       firstNameController.text = payload.nativeNameFromKYC!;
  //       lastNameController.text =
  //           ''; // Arabic names often don't have last names
  //     }
  //   }

  //   // Pre-fill DOB - prioritize DB data, fallback to KYC data
  //   if (showDOB) {
  //     String? dobToUse = payload.dobFromDB ?? payload.dobFromKYC;
  //     if (dobToUse != null) {
  //       dateOfBirthController.text = dobToUse;
  //     }
  //   }

  //   // Pre-set residency and nationality - prioritize DB data, fallback to KYC data
  //   if (showCountryOfResidence) {
  //     _selectResidency = payload.residencyFromDB ?? payload.countryFromKYC;
  //   }
  //   if (showNationality) {
  //     _selectNationality = payload.countryFromDB ?? payload.countryFromKYC;
  //   }
  // }
  void _prefillData() {
    final payload = widget.responseData?.payload;
    if (payload == null) return;

    // Name
    if (showFirstName) {
      String? nameToUse = payload.nameFromDB ?? payload.nameFromKYC;
      if (nameToUse != null && nameToUse.isNotEmpty) {
        final nameParts = nameToUse.split(' ');
        firstNameController.text = nameParts.first;
        lastNameController.text = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';
      } else if (payload.nativeNameFromKYC != null &&
          payload.nativeNameFromKYC!.isNotEmpty) {
        firstNameController.text = payload.nativeNameFromKYC!;
        lastNameController.text = '';
      }
    }

    // DOB
    if (showDOB) {
      dateOfBirthController.text =
          payload.dobFromDB ?? payload.dobFromKYC ?? '';
    }

    // Residency
    if (showCountryOfResidence) {
      _selectResidency =
          payload.residencyFromDB ?? payload.residencyFromKYC ?? null;
    }

    // Nationality
    if (showNationality) {
      _selectNationality = payload.nationalityFromDB ?? payload.nationalityFromKYC ?? null;
    }
  }

  // 4️⃣ Helper to detect Arabic text
  bool _isArabic(String input) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    return arabicRegex.hasMatch(input);
  }

  // 5️⃣ Helper to extract country code
  String? _extractCountryCode(String? countryString) {
    if (countryString == null) return null;
    // Extract country code from format "Country Name - CountryCode"
    final parts = countryString.split(' - ');
    return parts.length > 1 ? parts[1] : countryString;
  }

  @override
  void initState() {
    super.initState();

    // Pre-fill controllers with data from responseData
    _prefillData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).fetchAllCountries();
    });
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// select birthday
  Future<void> _selectBirthday() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime eighteenYearsAgo = DateTime(
        now.year - 18,
        now.month,
        now.day,
      );

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: eighteenYearsAgo,
        firstDate: DateTime(1950),
        lastDate: eighteenYearsAgo,
        helpText: "Select Date",
      );

      if (picked != null) {
        setState(() {
          dateOfBirthController.text = DateFormat("yyyy-MM-dd").format(picked);
        });
      }
    } catch (e) {
      getLocator<Logger>().e("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final List<String> countries =
        authState.countries
            .map((country) => "${country.name} - ${country.countryCode}")
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Collect invalid fields based on responseData
    List<String> invalidFields = [];

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Use localized field names
    final firstNameLabel = isArabic
        ? "الاسم الأول واسم العائلة"
        : "First Name & Last Name";
    final dobLabel = isArabic ? "تاريخ الميلاد" : "Date of Birth";
    final residencyLabel = isArabic ? "الإقامة" : "Residency";
    final nationalityLabel = isArabic ? "الجنسية" : "Nationality";

    if (showFirstName) invalidFields.add(firstNameLabel);
    if (showDOB) invalidFields.add(dobLabel);
    if (showCountryOfResidence) invalidFields.add(residencyLabel);
    if (showNationality) invalidFields.add(nationalityLabel);

    // Build warning message
    String warningMessage = "";
    if (invalidFields.isNotEmpty) {
      warningMessage =
          "${AppLocalizations.of(context)!.kyc_some_detail} ${invalidFields.join(", ")} ${AppLocalizations.of(context)!.kyc_match_official}";
    }
    // List<String> invalidFields = [];
    // if (showFirstName) invalidFields.add("irst Name & Last Name");
    // if (showDOB) invalidFields.add("ate of Birth");
    // if (showCountryOfResidence) invalidFields.add("esidency");
    // if (showNationality) invalidFields.add("ationality");

    // // Build warning message
    // String warningMessage = "";
    // if (invalidFields.isNotEmpty) {
    //   warningMessage =
    //       "${AppLocalizations.of(context)!.kyc_some_detail} ${invalidFields.join(", ")} ${AppLocalizations.of(context)!.kyc_match_official}";
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: GetGenericText(
          text: noFieldsVisible
              ? AppLocalizations.of(context)!.kyc_cancellled
              : AppLocalizations.of(context)!.kyc_update_info,
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.isLandscape() && !sizes!.isPhone
            ? sizes!.height
            : sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: noFieldsVisible
              ? _buildCancelledView(context)
              : authState.loadingState == LoadingState.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 10),
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
                        title: "Refresh",
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
                        ConstPadding.sizeBoxWithHeight(height: 8),

                        // Show warning text if needed
                        GetGenericText(
                          text: warningMessage,
                          lines: 4,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          fontWeight: FontWeight.w400,
                          color: warningMessage.isNotEmpty
                              ? Colors.red
                              : AppColors.neutral80,
                        ).getAlign(),

                        ConstPadding.sizeBoxWithHeight(height: 24),

                        if (showFirstName)
                          CommonTextFormField(
                            title: AppLocalizations.of(context)!.kyc_first_name,
                            hintText: AppLocalizations.of(
                              context,
                            )!.kyc_enter_firstname,
                            labelText: AppLocalizations.of(
                              context,
                            )!.kyc_first_name,
                            controller: firstNameController,
                            textInputType: TextInputType.name,
                            validator: ValidatorUtils.validateName,
                          ),
                        ConstPadding.sizeBoxWithHeight(height: 16),

                        if (showFirstName)
                          CommonTextFormField(
                            title: AppLocalizations.of(context)!.kyc_last_name,
                            hintText: AppLocalizations.of(
                              context,
                            )!.kyc_enter_lastname,
                            labelText: AppLocalizations.of(
                              context,
                            )!.kyc_last_name,
                            controller: lastNameController,
                            textInputType: TextInputType.name,
                            validator: ValidatorUtils.validateName,
                          ),
                        ConstPadding.sizeBoxWithHeight(height: 16),

                        // if (showDOB)
                        //   TextFormFieldWithIcon(
                        //     title: AppLocalizations.of(context)!.kyc_dob,
                        //     hintText: "DD/MM/YYYY",
                        //     labelText: AppLocalizations.of(context)!.kyc_dob,
                        //     iconString: "assets/svg/date_icon.svg",
                        //     controller: dateOfBirthController,
                        //     readOnly: true,
                        //     textInputType: TextInputType.number,
                        //     onTap: _selectBirthday,
                        //     validator: (value) {
                        //       if (value == null || value.isEmpty) {
                        //         return AppLocalizations.of(
                        //           context,
                        //         )!.kyc_enter_dob;
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        if (showDOB)
                          TextFormFieldWithIcon(
                            title: AppLocalizations.of(context)!.kyc_dob,
                            hintText:
                                Localizations.localeOf(context).languageCode ==
                                    'ar'
                                ? "اليوم/الشهر/السنة"
                                : "DD/MM/YYYY",
                            labelText: AppLocalizations.of(context)!.kyc_dob,
                            iconString: "assets/svg/date_icon.svg",
                            controller: dateOfBirthController,
                            readOnly: true,
                            textInputType: TextInputType.number,
                            onTap: _selectBirthday,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.kyc_enter_dob;
                              }
                              return null;
                            },
                          ),

                        ConstPadding.sizeBoxWithHeight(height: 16),

                        if (showCountryOfResidence)
                          SearchableDropdown(
                            iconString: "assets/svg/arrow_down.svg",
                            title: AppLocalizations.of(context)!.kyc_res_cont,
                            items: countries,
                            label: AppLocalizations.of(context)!.kyc_res_cont,
                            hint: AppLocalizations.of(context)!.kyc_select,
                            selectedItem: _selectResidency,
                            validator: (value) => value == null
                                ? AppLocalizations.of(
                                    context,
                                  )!.kyc_plz_select_resd
                                : null,
                            onChanged: (String value) {
                              setState(() {
                                _selectResidency = value;
                              });
                            },
                          ),
                        ConstPadding.sizeBoxWithHeight(height: 16),

                        if (showNationality)
                          SearchableDropdown(
                            iconString: "assets/svg/arrow_down.svg",
                            title: AppLocalizations.of(
                              context,
                            )!.kyc_nationality,
                            items: countries,
                            label: AppLocalizations.of(
                              context,
                            )!.kyc_nationality,
                            hint: AppLocalizations.of(context)!.kyc_select,
                            selectedItem: _selectNationality,
                            validator: (value) => value == null
                                ? AppLocalizations.of(
                                    context,
                                  )!.kyc_plz_select_cont
                                : null,
                            onChanged: (String value) {
                              setState(() {
                                _selectNationality = value;
                              });
                            },
                          ),

                        ConstPadding.sizeBoxWithHeight(height: 16),

                        /// Update Information button
                        getUpdateButton(
                          title: AppLocalizations.of(context)!.kyc_update_inf,
                          isLoadingState: authState.isButtonState,
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              // First check if data has changed from DB/KYC
                              if (!_hasDataChanged()) {
                                Toasts.getErrorToast(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.no_change_detected,
                                  //"No changes detected. Please update information if needed.",
                                );
                                return;
                              }

                              // Then validate against KYC data
                              final kycValidationError = _validateAgainstKYC();
                              if (kycValidationError != null) {
                                Toasts.getErrorToast(text: kycValidationError);
                                return;
                              }

                              // Prepare the data for the API call
                              await authNotifier.reUploadUserKycData(
                                firstName: showFirstName
                                    ? firstNameController.text.trim()
                                    : null,
                                surname: showFirstName
                                    ? lastNameController.text.trim()
                                    : null,
                                dateOfBirthday: showDOB
                                    ? dateOfBirthController.text
                                    : null,
                                countryOfResidence: showCountryOfResidence
                                    ? _selectResidency
                                    : null,
                                nationality: showNationality
                                    ? _selectNationality
                                    : null,
                                context: context,
                              );
                            
                            }
                          },

                          // onTap: () async {
                          //   if (_formKey.currentState?.validate() ?? false) {
                          //     // First check if data has changed from DB
                          //     if (!_hasDataChanged()) {
                          //       Toasts.getErrorToast(
                          //         text:
                          //             "Information does not match please update information",
                          //       );
                          //       return;
                          //     }

                          //     // Then validate against KYC data
                          //     final kycValidationError = _validateAgainstKYC();
                          //     if (kycValidationError != null) {
                          //       Toasts.getErrorToast(text: kycValidationError);
                          //       return;
                          //     }

                          //     // Prepare the data for the API call
                          //     await authNotifier.reUploadUserKycData(
                          //       firstName: showFirstName
                          //           ? firstNameController.text.trim()
                          //           : null,
                          //       surname: showFirstName
                          //           ? lastNameController.text.trim()
                          //           : null,
                          //       dateOfBirthday: showDOB
                          //           ? dateOfBirthController.text
                          //           : null,
                          //       countryOfResidence: showCountryOfResidence
                          //           ? _selectResidency
                          //           : null,
                          //       nationality: showNationality
                          //           ? _selectNationality
                          //           : null,
                          //       context: context,
                          //     );
                          //   }
                          // },
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 16),

                        /// Update Information button
                        getUpdateButton(
                          title: AppLocalizations.of(
                            context,
                          )!.re_submit_document, //"Resubmit Documents",
                          isLoadingState: false,
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KycFirstStepScreen(),
                              ),
                            );
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
                              (route) => false,
                            );
                          },
                          child: GetGenericText(
                            text: AppLocalizations.of(context)!.cancel,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGold500,
                          ).getChildCenter(),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
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

  // Update Information button
  Widget getUpdateButton({
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

  Widget _buildCancelledView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GetGenericText(
            text: AppLocalizations.of(context)!.kyc_uhave_cancelled,
            fontSize: sizes!.responsiveFont(phoneVal: 16, tabletVal: 18),
            fontWeight: FontWeight.w400,
            color: Colors.redAccent,
            lines: 3,
          ),
          const SizedBox(height: 30),
          getUpdateButton(
            title: AppLocalizations.of(context)!.kyc_go_home,
            isLoadingState: false,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => MainHomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ).get16HorizontalPadding(),
    );
  }
}
