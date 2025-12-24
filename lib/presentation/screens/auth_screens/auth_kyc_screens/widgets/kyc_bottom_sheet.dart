import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/widgets/kyc_financial_info_screen.dart';


import '../../../../../core/theme/const_padding.dart';

class VerifyIdentitySheet {
  static void show(BuildContext context) {
    bool isChecked = false; // keep state here
    String selectedLang = "En";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.greyScale1000,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Dropdown
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1E1C1A),
                          value: selectedLang,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white70),
                          items: ["En", "Ar"].map((lang) {
                            return DropdownMenuItem(
                              value: lang,
                              child: Row(
                                children: [
                                  const Icon(Icons.g_translate,
                                      size: 18, color: AppColors.whiteColor),
                                  ConstPadding.sizeBoxWithWidth(width: 6),
                                  Text(
                                    lang,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLang = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 20),

                  // Title
                  Text(
                    "Let's verify your identity",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold500,
                    ),
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),

                  // Checkbox with text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            isChecked = val ?? false;
                          });
                        },
                        activeColor: AppColors.primaryGold500,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.primaryGold500,
                                fontWeight: FontWeight.w500),
                            children: [
                              const TextSpan(
                                text:
                                    "I consent to Save In Gold using and processing my personal information, and I confirm that I'm 18 or older. ",
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                    color: AppColors.primaryGold500,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 24),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isChecked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FinancialInfoScreen(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isChecked
                            ? AppColors.primaryGold500
                            : const Color(0xFF73694D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Verify Me",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isChecked ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 12),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryGold500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
