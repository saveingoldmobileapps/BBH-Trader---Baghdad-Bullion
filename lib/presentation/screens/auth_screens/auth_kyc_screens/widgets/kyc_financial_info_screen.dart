import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/widgets/documets_selection_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/kyc_provider.dart/kyc_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../../../../core/theme/const_padding.dart';
import '../../../../widgets/search_drop_down.dart';

class FinancialInfoScreen extends ConsumerStatefulWidget {
  const FinancialInfoScreen({super.key});

  @override
  ConsumerState<FinancialInfoScreen> createState() =>
      _FinancialInfoScreenState();
}

class _FinancialInfoScreenState extends ConsumerState<FinancialInfoScreen> {
  String? employmentStatus;
  String? annualIncome;
  String? incomeSource;

  final compNameController = TextEditingController();

  final List<String> employmentOptions = [
    "Employed",
    "Self-Employed",
    "Unemployed",
    "Retired",
    "Student"
  ];

  final List<String> annualIncomeOptions = [
    "Below \$20,000",
    "\$20,000 - \$50,000",
    "\$50,000 - \$100,000",
    "Above \$100,000"
  ];

  final List<String> incomeSourceOptions = [
    "Investment Income",
    "Business Earnings",
    "Salary",
    "Property Income",
    "Other"
  ];

  void _saveFinancialInfo() {
    final kycNotifier = ref.read(kYCProvider.notifier);
    final kycWatch = ref.watch(kYCProvider);
    kycNotifier.updateFinancialInfo(
      employmentStatus: employmentStatus ?? "",
      companyName: compNameController.text.toString().trim(),
      salaryRange: annualIncome ?? "",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumetsSelectionScreen(kycData: kycWatch.kycData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyScale1000, // Dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Due Diligence Forms",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold500,
                    ),
                  ),
                  Text(
                    "Step 1 of 3",
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

              ConstPadding.sizeBoxWithHeight(height: 12),

              // Progress bar
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                value: 0.3, // 30% progress
                backgroundColor: Colors.grey[800],
                color: AppColors.primaryGold500,
                minHeight: 6,
              ),

              ConstPadding.sizeBoxWithHeight(height: 20),

              // Main Content (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Financial Information",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold500,
                        ),
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 24),

                      // Employment Status
                      Text(
                        "Employment Status",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold500,
                        ),
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 10),
                      SearchableDropdown(
                        items: employmentOptions,
                        title: "Employment Status",
                        hint: "Select item",
                        label: "Employment Status",
                        iconString: "assets/svg/employment_icon.svg",
                        selectedItem: employmentStatus,
                        onChanged: (value) {
                          setState(() {
                            employmentStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      employmentStatus == "Employed"?Text(
                        "Company Name",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold500,
                        ),
                      ):SizedBox.shrink(),
                      employmentStatus == "Employed"?
                      ConstPadding.sizeBoxWithHeight(height: 10)
                      :SizedBox.shrink(),
                     employmentStatus == "Employed"? 
                     CommonTextFormField(
                      title: "Company Name",
                      hintText: "Jaber",
                      labelText: "Company Name",//"Surname (Legal Name)",
                      controller: compNameController,
                      textInputType: TextInputType.text,

                      isCapitalizationEnabled: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                          // 'Please enter surname';
                        }
                        return null;
                      },
                    ):SizedBox.shrink(),
                    const SizedBox(height: 16),

                      // Annual Income
                      Text(
                        "Estimated Annual Income",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold500,
                        ),
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 10),
                      SearchableDropdown(
                        items: annualIncomeOptions,
                        title: "Estimated Annual Income",
                        hint: "Select item",
                        label: "Estimated Annual Income",
                        iconString: "assets/svg/income_icon.svg",
                        selectedItem: annualIncome,
                        onChanged: (value) {
                          setState(() {
                            annualIncome = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Income Source (Radio Buttons)
                      Text(
                        "Source of Income *",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: incomeSourceOptions.map((option) {
                          return RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: option,
                            groupValue: incomeSource,
                            activeColor: AppColors.primaryGold500,
                            onChanged: (value) {
                              setState(() {
                                incomeSource = value;
                              });
                            },
                            title: GetGenericText(
                              text: option,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold500,
                            ),
                          );
                        }).toList(),
                      ),

                      // Add some extra space at the bottom for scrolling
                      ConstPadding.sizeBoxWithHeight(height: 20),
                    ],
                  ),
                ),
              ),

              // Next Button (Fixed at the bottom)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: employmentStatus != null &&
                          annualIncome != null &&
                          incomeSource != null
                      ? _saveFinancialInfo // Use the new method
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
            ],
          ),
        ),
      ),
    );
  }
}
