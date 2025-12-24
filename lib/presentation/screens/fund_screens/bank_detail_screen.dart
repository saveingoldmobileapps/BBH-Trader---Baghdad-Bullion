import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/bank_text_form_field.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';

class BankDetailScreen extends ConsumerStatefulWidget {
  const BankDetailScreen({super.key});

  @override
  ConsumerState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends ConsumerState<BankDetailScreen> {
  final transactionCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final beneficiaryNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final iBANNumberController = TextEditingController();
  final swiftCodeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    transactionCodeController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    beneficiaryNameController.dispose();
    accountNumberController.dispose();
    iBANNumberController.dispose();
    swiftCodeController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.account_detail,//"Account Details",
          fontSize: 20,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                ConstPadding.sizeBoxWithHeight(height: 12),
                // bank card
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const FundAmountScreen(),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: sizes!.isPhone
                        ? sizes!.widthRatio * 361
                        : sizes!.width,
                    // height: sizes!.heightRatio * 60,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/bank_icon.svg",
                          height: sizes!.heightRatio * 24,
                          width: sizes!.widthRatio * 24,
                        ),
                        ConstPadding.sizeBoxWithWidth(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GetGenericText(
                                    text: "Zand Bank",
                                    fontSize: sizes!.isPhone ? 14 : 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey6Color,
                                  ),
                                  GetGenericText(
                                    text: "Amount",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey6Color,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GetGenericText(
                                    text: "Dubai",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey3Color,
                                  ),
                                  GetGenericText(
                                    text: "AED 3,000.00",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGold500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "DEPOSIT/2025/12/0311",
                  labelText: "Transaction Code",
                  controller: transactionCodeController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "Zand Bank",
                  labelText: "Bank Name",
                  controller: bankNameController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "Dubai",
                  labelText: "Branch Name",
                  controller: branchNameController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "SaveInGold",
                  labelText: "Beneficiary Name",
                  controller: beneficiaryNameController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "310001023134111",
                  labelText: "Account Number",
                  controller: accountNumberController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "AE871981310001023134111",
                  labelText: "IBAN Number",
                  controller: iBANNumberController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                BankTextFormField(
                  title: "title",
                  hintText: "ZANDAEAA",
                  labelText: "Swift Code",
                  controller: swiftCodeController,
                  onCopyTap: () {},
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),

                LoaderButton(
                  title: "Return to Home",
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainHomeScreen(),
                      ),
                      ((route) => false),
                    );
                  },
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
