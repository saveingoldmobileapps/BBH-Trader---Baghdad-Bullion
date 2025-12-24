import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../main_home_screens/home_screen.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final String amount;

  const AccountDetailScreen({
    super.key,
    required this.amount,
  });

  @override
  ConsumerState createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  final amountController = TextEditingController();
  final beneficiaryNameController = TextEditingController();
  final accountNumberController = TextEditingController();

  final fabNameController = TextEditingController(
    text: "First Abu Dhabi Bank",
  );
  final mashraqNameController = TextEditingController(
    text: "Mashreq Bank",
  );
  final accountNameController = TextEditingController(
    text: "Save in Gold FZCO",
  );
  final fabAccController = TextEditingController(
    text: "1641325917125001",
  );
  final fabIbanController = TextEditingController(
    text: "AE410351641325917125001",
  );
  final fabSwiftController = TextEditingController(
    text: "NBADAEAA",
  );

  final mashreqNameController = TextEditingController(
    text: "Mashreq Bank",
  );
  final mashreqAccController = TextEditingController(
    text: "019101203592",
  );
  final mashreqIbanController = TextEditingController(
    text: "AE320330000019101203592",
  );
  final mashreqSwiftController = TextEditingController(
    text: "BOMLAEAD",
  );

  @override
  void initState() {
    super.initState();
    amountController.text = widget.amount;
  }

  @override
  void dispose() {
    amountController.dispose();
    beneficiaryNameController.dispose();
    accountNumberController.dispose();
    fabNameController.dispose();
    fabAccController.dispose();
    fabIbanController.dispose();
    fabSwiftController.dispose();
    mashreqNameController.dispose();
    mashreqAccController.dispose();
    mashreqIbanController.dispose();
    mashreqSwiftController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// copy to clipboard
  void _copyToClipboard({required String text}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          text: AppLocalizations.of(context)!
              .account_details, //"Account Details",
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
                ConstPadding.sizeBoxWithHeight(height: 24),
                CommonTextFormField(
                  title: "title",
                  hintText: AppLocalizations.of(context)!
                      .enter_withdraw_amount, //"Enter amount to be withdrawn",
                  labelText: "Amount",
                  controller: amountController,
                ),

                ConstPadding.sizeBoxWithHeight(height: 12),
                GetGenericText(
                  text: "First Abu Dhabi Bank",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey6Color,
                ).getChildCenter(),
                ConstPadding.sizeBoxWithHeight(height: 12),

                /// FAB Details
                CommonTextFormField(
                  title: "Bank",
                  labelText: "Bank",
                  controller: fabNameController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: fabNameController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "Name",
                  labelText: "Name",
                  controller: accountNameController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: fabNameController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "FAB Account",
                  labelText: "Account Number",
                  controller: fabAccController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: fabAccController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "FAB IBAN",
                  labelText: "IBAN",
                  controller: fabIbanController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: fabIbanController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "FAB Swift",
                  labelText: "Swift Code",
                  controller: fabSwiftController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: fabSwiftController.text.toString().trim(),
                    ),
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 12),
                GetGenericText(
                  text: "Mashreq Bank",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey6Color,
                ).getChildCenter(),
                ConstPadding.sizeBoxWithHeight(height: 12),

                /// Mashreq Details
                CommonTextFormField(
                  title: "Bank",
                  labelText: "Bank",
                  controller: mashreqNameController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: mashraqNameController.text.toString().trim(),
                    ),
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "Mashreq Name",
                  labelText: "Name",
                  controller: accountNameController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: accountNameController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "Mashreq Account",
                  labelText: "Account Number",
                  controller: mashreqAccController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: mashreqAccController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "Mashreq IBAN",
                  labelText: "IBAN",
                  controller: mashreqIbanController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: mashreqIbanController.text.toString().trim(),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 12),
                CommonTextFormField(
                  title: "Mashreq Swift",
                  labelText: "Swift Code",
                  controller: mashreqSwiftController,
                  readOnly: true,
                  hintText: "",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.goldLightColor,
                    ),
                    onPressed: () => _copyToClipboard(
                      text: mashreqSwiftController.text.toString().trim(),
                    ),
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 32),
                LoaderButton(
                  isLoadingState: false,
                  title: "Close",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                ConstPadding.sizeBoxWithHeight(height: 24),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
