import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_arrow_button.dart';

import '../../../data/models/bank_models/BankCardReponse.dart';
import '../../sharedProviders/providers/withdraw_provider/withdraw_provider.dart';
import '../../widgets/text_form_field.dart';

class EditBankCardScreen extends ConsumerStatefulWidget {
  final CardsList card;

  const EditBankCardScreen({super.key, required this.card});

  @override
  ConsumerState<EditBankCardScreen> createState() => _EditBankCardScreenState();
}

class _EditBankCardScreenState extends ConsumerState<EditBankCardScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController bankController;
  late TextEditingController beneficiaryController;
  late TextEditingController ibanController;

  @override
  void initState() {
    super.initState();
    bankController = TextEditingController(text: widget.card.bankName ?? '');
    beneficiaryController =
        TextEditingController(text: widget.card.beneficiaryName ?? '');
    ibanController = TextEditingController(text: widget.card.ibanNumber ?? '');
  }

  @override
  void dispose() {
    bankController.dispose();
    beneficiaryController.dispose();
    ibanController.dispose();
    super.dispose();
  }

  Future<void> _updateCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final updateBody = {
        "bankName": bankController.text.trim(),
        "beneficiaryName": beneficiaryController.text.trim(),
        "iban": ibanController.text.trim(),
      };

      await ref.read(withdrawProvider.notifier).editCard(
            context: context,
            id: widget.card.id ?? '',
            body: updateBody,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.edit_bank_card,//"Edit Bank Card",
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CommonTextFormField(
                    title: "title",
                    hintText:
                        AppLocalizations.of(context)!.withdraw_enter_bank_name,
                    labelText: AppLocalizations.of(context)!.withdraw_bank_name,
                    controller: bankController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.bankReq;
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: AppLocalizations.of(context)!.withdraw_benf_name,
                    labelText: AppLocalizations.of(context)!.beneficiary,
                    controller: beneficiaryController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.beneficiaryReq;
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: AppLocalizations.of(context)!.iban,
                    labelText: AppLocalizations.of(context)!.iban,
                    controller: ibanController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.ibanReq;
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 32),
                  LoaderArrowButton(
                    title: AppLocalizations.of(context)!.save_changes,//"Save Changes",
                    isLoadingState: withdrawalState.cardCreateLoadingState ==
                        LoadingWithdrawalState.loading,
                    onTap: _updateCard,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
