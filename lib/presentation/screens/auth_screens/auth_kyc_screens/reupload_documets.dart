import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/const_padding.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/kyc_provider.dart/kyc_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/search_drop_down.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field_with_icon.dart';

class ReUploadScreen extends ConsumerStatefulWidget {
  const ReUploadScreen({super.key});

  @override
  ConsumerState<ReUploadScreen> createState() => _ReUploadScreenState();
}

class _ReUploadScreenState extends ConsumerState<ReUploadScreen> {
  // ---- Financial Info ----
  String? employmentStatus;
  String? annualIncome;
  String? incomeSource;
  final compNameController = TextEditingController();

  final List<String> employmentOptions = [
    "Employed",
    "Self-Employed",
    "Unemployed",
    "Retired",
    "Student",
  ];

  final List<String> annualIncomeOptions = [
    "Below \AED 20,000",
    "\AED20,000 - \AED 50,000",
    "\AED 50,000 - \AED 100,000",
    "Above \AED 100,000",
  ];

  final List<String> incomeSourceOptions = [
    "Investment Income",
    "Business Earnings",
    "Salary",
    "Property Income",
    "Other",
  ];

  // ---- Documents ----
  String? _selectNationality;

  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final dateOfBirthController = TextEditingController();

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

  Future<void> _handleFilePicked(
    File file, {
    bool isFront = false,
    bool isSelfie = false,
  }) async {
    final notifier = ref.read(kYCProvider.notifier);

    if (isSelfie) {
      notifier.setSelfieImage(file);
    } else if (isFront) {
      notifier.setFrontImage(file);
    } else {
      notifier.setBackImage(file);
    }

    await notifier.uploadResidencyDocument(
      image: file,
      fileName: file.path.split("/").last,
      isFront: isFront,
      isSelfie: isSelfie,
      context: context,
    );
  }

  Future<void> _pickImage(
    bool isFront, {
    bool fromCamera = false,
    bool isSelfie = false,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: isSelfie ? CameraDevice.front : CameraDevice.rear,
    );
    if (pickedFile != null) {
      await _handleFilePicked(
        File(pickedFile.path),
        isFront: isFront,
        isSelfie: isSelfie,
      );
    }
  }

  Widget _buildPlaceholder(
    File? file,
    String title, {
    bool isFront = false,
    bool isSelfie = false,
  }) {
    final kycState = ref.watch(kYCProvider);

    final isLoading = isSelfie
        ? kycState.isSelfieUploading
        : isFront
        ? kycState.isFrontUploading
        : kycState.isBackUploading;

    return GestureDetector(
      onTap: () => _pickImage(
        isFront,
        fromCamera: true,
        isSelfie: isSelfie,
      ), // simplified picker
      child: Container(
        height: 120,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.5,
            color: file != null ? Colors.green : AppColors.primaryGold500,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : file != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      file.path.split("/").last,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Uploaded successfully!",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )
              : Text(title, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kYCProvider);
    final kycNotifier = ref.read(kYCProvider.notifier);
    final authState = ref.watch(authProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);

    final profile = ref
        .watch(homeProvider)
        .getUserProfileResponse
        .payload
        ?.userProfile;

    final kyc = profile!.userCustomKYCData;
    final List<String> countries =
        authState.countries.map((c) => "${c.name} - ${c.countryCode}").toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final isSubmitEnabled =
        kycState.selfieImage != null &&
        kycState.frontImage != null &&
        (kycState.selectedDocumentType == KYCDocumentType.passport ||
            kycState.backImage != null);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        title: const Text("Re-Upload Documents"),
        backgroundColor: AppColors.greyScale1000,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // /// Step 1: Financial Info
            // Text( "Financial Information",
            //   style: GoogleFonts.poppins(
            //     fontSize: 18,
            //     fontWeight: FontWeight.w600,
            //     color: AppColors.primaryGold500,
            //   ),
            // ),
            // ConstPadding.sizeBoxWithHeight(height: 12),
            // SearchableDropdown(
            //   items: employmentOptions,
            //   title: "Employment Status",
            //   hint: "Select item",
            //   label: "Employment Status",
            //   iconString: "assets/svg/employment_icon.svg",
            //   selectedItem: employmentStatus,
            //   onChanged: (value) => setState(() => employmentStatus = value),
            // ),
            // if (employmentStatus == "Employed")
            //   CommonTextFormField(
            //     title: "Company Name",
            //     hintText: "Your company",
            //     controller: compNameController,
            //     labelText: '',
            //   ),
            // ConstPadding.sizeBoxWithHeight(height: 12),
            // SearchableDropdown(
            //   items: annualIncomeOptions,
            //   title: "Annual Income",
            //   hint: "Select item",
            //   label: "Annual Income",
            //   iconString: "assets/svg/income_icon.svg",
            //   selectedItem: annualIncome,
            //   onChanged: (value) => setState(() => annualIncome = value),
            // ),
            // ConstPadding.sizeBoxWithHeight(height: 12),
            //  Text(
            //   "Source of Income",
            //   style: GoogleFonts.poppins(
            //     fontSize: 14,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.primaryGold500,
            //   ),
            // ),
            // ...incomeSourceOptions.map(
            //   (option) => RadioListTile<String>(
            //     value: option,
            //     groupValue: incomeSource,
            //     activeColor: AppColors.primaryGold500,
            //     onChanged: (value) => setState(() => incomeSource = value),
            //     title: GetGenericText(
            //       text: option,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //       color: AppColors.primaryGold500,
            //     ),
            //   ),
            // ),
            kyc!.isFirstNameMatched == false
                ? CommonTextFormField(
                    title: "title",
                    hintText: "Amro",
                    labelText: "First Name (Legal Name)",
                    controller: firstNameController,
                    textInputType: TextInputType.text,

                    isCapitalizationEnabled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  )
                : SizedBox.shrink(),
            kyc.isFirstNameMatched == false
                ? ConstPadding.sizeBoxWithHeight(height: 20)
                : SizedBox.shrink(),
            kyc.isFirstNameMatched == false
                ? CommonTextFormField(
                    title: "title",
                    hintText: "Jaber",
                    labelText: "Surname (Legal Name)",
                    controller: surnameController,
                    textInputType: TextInputType.text,

                    isCapitalizationEnabled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter surname';
                      }
                      return null;
                    },
                  )
                : SizedBox.shrink(),

            kyc.isSurNameMatched == false
                ? ConstPadding.sizeBoxWithHeight(height: 20)
                : SizedBox.shrink(),

            kyc.isDOBMatched == false
                ? TextFormFieldWithIcon(
                    title: "title",
                    hintText: "DD/MM/YYYY",
                    labelText: "Date of Birth",
                    iconString: "assets/svg/date_icon.svg",
                    controller: dateOfBirthController,
                    readOnly: true,
                    textInputType: TextInputType.number,
                    onTap: _selectBirthday,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter date of birth';
                      }
                      return null;
                    },
                  )
                : SizedBox.shrink(),
            kyc.isDOBMatched == false
                ? ConstPadding.sizeBoxWithHeight(height: 20)
                : SizedBox.shrink(),

            kyc.isNationalityMatched == false
                ? SearchableDropdown(
                    iconString: "assets/svg/arrow_down.svg",
                    title: "title",
                    items: countries,
                    label: "Nationality",
                    hint: "Select",
                    selectedItem: _selectNationality,
                    validator: (value) =>
                        value == null ? 'Please select nationality' : null,
                    onChanged: (String value) {
                      setState(() {
                        _selectNationality = value;
                      });
                    },
                  )
                : SizedBox.shrink(),
            kyc.isNationalityMatched == false
                ? ConstPadding.sizeBoxWithHeight(height: 20)
                : SizedBox.shrink(),

            Text(
              "Select Issuing Country",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold500,
              ),
            ),
            ConstPadding.sizeBoxWithHeight(height: 12),
            SearchableDropdown(
              items: countries,
              title: "Country",
              label: "Country",
              hint: "Select",
              selectedItem: _selectNationality,
              onChanged: (String value) {
                setState(() {
                  _selectNationality = value.split(' - ').last;
                  kycNotifier.setIssuingCountry(value);
                });
              },
              iconString: '',
            ),

            ConstPadding.sizeBoxWithHeight(height: 20),
            Text(
              "Upload Documents",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold500,
              ),
            ),
            ConstPadding.sizeBoxWithHeight(height: 12),
            _buildPlaceholder(
              kycState.selfieImage,
              "Upload Selfie",
              isSelfie: true,
            ),
            _buildPlaceholder(
              kycState.frontImage,
              "Upload Front Document",
              isFront: true,
            ),
            if (kycState.selectedDocumentType != KYCDocumentType.passport)
              _buildPlaceholder(kycState.backImage, "Upload Back Document"),

            ConstPadding.sizeBoxWithHeight(height: 20),
            ElevatedButton(
              onPressed: isSubmitEnabled
                  ? () {
                      ref
                          .read(kYCProvider.notifier)
                          .submitKycData(
                            userImage: kycState.selfieImagePath ?? "",
                            context: context,
                          );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primaryGold500,
              ),
              child: const Text("Submit"),
            ),
            ConstPadding.sizeBoxWithHeight(height: 50),
          ],
        ),
      ),
    );
  }
}
