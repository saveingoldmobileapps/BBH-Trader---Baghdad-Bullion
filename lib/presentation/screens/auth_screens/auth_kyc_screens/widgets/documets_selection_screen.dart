import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';

import '../../../../../core/theme/const_padding.dart';
import '../../../../sharedProviders/providers/auth_provider.dart';
import '../../../../sharedProviders/providers/home_provider.dart';
import '../../../../sharedProviders/providers/kyc_provider.dart/kyc_provider.dart';
import '../../../../widgets/search_drop_down.dart';
import 'kyc_upload_docments_widget.dart';

class DocumetsSelectionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> kycData;
  const DocumetsSelectionScreen({super.key, required this.kycData});

  @override
  ConsumerState createState() => _DocumetsSelectionScreenState();
}

class _DocumetsSelectionScreenState
    extends ConsumerState<DocumetsSelectionScreen> {
  String? employmentStatus;
  String? annualIncome;
  String? incomeSource;
  String? _selectNationality;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    Future.microtask(() {
      ref.read(kYCProvider.notifier).updateKycData(widget.kycData);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mainStateWatchProvider = ref.watch(homeProvider);
    final kycNotifier = ref.read(kYCProvider.notifier);
    final kycState = ref.watch(kYCProvider);
    final authState = ref.watch(authProvider);
    //final authNotifier = ref.read(authProvider.notifier);

    final List<String> countries = authState.countries
        .map((country) => "${country.name} - ${country.countryCode}")
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return Scaffold(
      backgroundColor: AppColors.greyScale1000, // Dark background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              /// Header

              /// Header
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Documents\nVerification",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold500,
                    ),
                  ),
                  Text(
                    "Step 2 of 3",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 168, 156, 140),
                    ),
                  ),
                  Text(
                    "Help",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold500,
                    ),
                  ),
                ],
              ),

              /// Progress bar
              ConstPadding.sizeBoxWithHeight(height: 12),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                value: 0.6, // 30% progress
                backgroundColor: Colors.grey[800],
                color: AppColors.primaryGold500,
                minHeight: 6,
              ),

              ConstPadding.sizeBoxWithHeight(height: 20),

              /// Title
              Text(
                "Choose your documents issuing\ncountry",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold500,
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 24),

              // SearchableDropdown(
              //   iconString: "assets/svg/arrow_down.svg",
              //   title: "title",
              //   items: countries,
              //   label: "Country",
              //   hint: "Select",
              
              //   selectedItem: _selectNationality,
              //   validator: (value) {
              //     final nationality = mainStateWatchProvider
              //         .getUserProfileResponse.payload?.userProfile?.nationality;
              //     final residency = mainStateWatchProvider
              //         .getUserProfileResponse
              //         .payload
              //         ?.userProfile
              //         ?.countryOfResidence;
              //     debugPrint(
              //       'Validating: $value against nationality: $nationality, residency: $residency',
              //     );
              //     return validateCountrySelection(
              //       value,
              //       nationality!.en??"",
              //       residency!.en??"",
              //     );
              //   },
              //   onChanged: (String value) {
              //     setState(() {
              //       _selectNationality = value.split(' - ').last;
              //       kycNotifier.setIssuingCountry(value);
              //     });
              //   },
              // ),
              SearchableDropdown(
  iconString: "assets/svg/arrow_down.svg",
  title: "title",
  items: countries,
  label: "Country",
  hint: "Select",
  selectedItem: _selectNationality,
  validator: (value) {
    // Get nationality & residency from your state
    final nationality = mainStateWatchProvider
        .getUserProfileResponse.payload?.userProfile?.nationality;
    final residency = mainStateWatchProvider
        .getUserProfileResponse.payload?.userProfile?.countryOfResidence;

    debugPrint(
      'Validating: $value against nationality: $nationality, residency: $residency',
    );

    // Use the helper function
    return validateCountrySelection(
      value,
      nationality?.en ?? "",
      residency?.en ?? "",
    );
  },
  onChanged: (String value) {
    setState(() {
      // Keep only the country name after " - "
      _selectNationality = value.split(' - ').last;
      kycNotifier.setIssuingCountry(value);
    });
  },
),

              ConstPadding.sizeBoxWithHeight(height: 24),
              Text(
                "Select documents type for verification",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold500,
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 5),
              Text(
                "valid government issued document",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.goldMoreLightColor,
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 5),
              _buildDocumentCard(
                  title: "Passport",
                  subtitle: "Photo Page",
                  icon: Icons.travel_explore,
                  onTap: () {
                    kycNotifier.setDocumentType(KYCDocumentType.passport);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentUploadScreen(),
                      ),
                    );
                  }),
              SizedBox(height: 15),
              _buildDocumentCard(
                title: "ID Card",
                subtitle: "Front & Back",
                icon: Icons.badge,
                onTap: () {
                  kycNotifier.setDocumentType(KYCDocumentType.idCard);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentUploadScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              _buildDocumentCard(
                title: "Driving License",
                subtitle: "Front & Back",
                icon: Icons.drive_eta,
                onTap: () {
                  kycNotifier.setDocumentType(KYCDocumentType.drivingLicense);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentUploadScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              _buildDocumentCard(
                title: "Credit/Debit Card",
                subtitle: "Front & Back",
                icon: Icons.credit_card,
                onTap: () {
                  kycNotifier.setDocumentType(KYCDocumentType.creditDebitCard);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentUploadScreen(),
                    ),
                  );
                },
              ),

              ConstPadding.sizeBoxWithHeight(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectNationality != null
                      ? () {
                          // Go to Step 2
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primaryGold500,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyScale1000,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}

Widget _buildDocumentCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.whiteColor,
            child: Icon(
              icon,
              color: AppColors.primaryGold500,
              size: 28,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGold500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[500]),
        ],
      ),
    ),
  );
}

String? validateCountrySelection(
  String? selectedCountryCode,
  String? yourNationality,
  String? yourResidency,
) {
  if (selectedCountryCode == null || selectedCountryCode.trim().isEmpty) {
    return 'Please select a country';
  }

  final selected = selectedCountryCode.trim();
  final nationality = yourNationality?.trim();
  final residency = yourResidency?.trim();

  if (nationality != null && residency != null) {
    if (selected != nationality && selected != residency) {
      return 'Select either $nationality\nor $residency.'; // <-- 2-line message
    }
  } else if (nationality != null && selected != nationality) {
    return "Select your nationality\n($nationality)."; // 2 lines
  } else if (residency != null && selected != residency) {
    return "Select your residency\n($residency)."; // 2 lines
  }

  return null;
}

