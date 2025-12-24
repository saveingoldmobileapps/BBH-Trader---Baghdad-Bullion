import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/withdraw_fund_screens/edit_card_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_arrow_button.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../../data/models/bank_models/BankCardReponse.dart';
import '../../../data/models/withdrawal_models/bankModel.dart';
import '../../sharedProviders/providers/withdraw_provider/withdraw_provider.dart';

class CreateWithdrawalFundScreen extends ConsumerStatefulWidget {
  const CreateWithdrawalFundScreen({
    super.key,
  });

  @override
  ConsumerState createState() => _WithdrawFundScreenState();
}

class _WithdrawFundScreenState
    extends ConsumerState<CreateWithdrawalFundScreen> {
  final _formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();
  final bankController = TextEditingController();
  final beneficiaryNameController = TextEditingController();
  final ibanAccountNumberController = TextEditingController();
  @override
  void initState() {
    super.initState();

    void refresh() => setState(() {});
    amountController.addListener(refresh);
    bankController.addListener(refresh);
    beneficiaryNameController.addListener(refresh);
    ibanAccountNumberController.addListener(refresh);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("fetchWithdrawalFundsRequests initState");
      ref.read(homeProvider.notifier).getHomeFeed(context: context, showLoading: true);
      ref.read(withdrawProvider.notifier).fetchAllCards(context: context);
    });
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     debugPrint("fetchWithdrawalFundsRequests initState");

  //     ref.read(withdrawProvider.notifier).fetchAllCards(context: context);
  //   });
  //   super.initState();
  // }

  @override
  void dispose() {
    amountController.removeListener(() {});
    bankController.removeListener(() {});
    beneficiaryNameController.removeListener(() {});
    ibanAccountNumberController.removeListener(() {});

    amountController.dispose();
    bankController.dispose();
    beneficiaryNameController.dispose();
    ibanAccountNumberController.dispose();
    super.dispose();
  }

  /// Method to fill form data from selected bank details
  void _fillFormData(BankDetails bankDetail) {
    setState(() {
      bankController.text = bankDetail.bankName;
      beneficiaryNameController.text = bankDetail.beneficiaryName;
      ibanAccountNumberController.text = bankDetail.iban;
      // Don't fill amountController - leave it empty for user to enter
    });
  }

  /// Check if current form details already exist in saved cards
  bool _isCurrentDetailsInCardList(List<CardsList>? cardsList) {
    if (cardsList == null || cardsList.isEmpty) return false;

    final currentBankName = bankController.text.trim();
    final currentBeneficiaryName = beneficiaryNameController.text.trim();
    final currentIban = ibanAccountNumberController.text.trim();

    return cardsList.any((card) =>
        card.bankName?.trim() == currentBankName &&
        card.beneficiaryName?.trim() == currentBeneficiaryName &&
        card.ibanNumber?.trim() == currentIban);
  }

  /// Check if all required fields are filled
  bool _areAllFieldsFilled() {
    return amountController.text.trim().isNotEmpty &&
        bankController.text.trim().isNotEmpty &&
        beneficiaryNameController.text.trim().isNotEmpty &&
        ibanAccountNumberController.text.trim().isNotEmpty;
  }

  /// Add current card details to saved cards
  Future<void> _addCurrentCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> cardData = {
        "bankName": bankController.text.trim(),
        "beneficiaryName": beneficiaryNameController.text.trim(),
        "iban": ibanAccountNumberController.text.trim(),
      };

      await ref.read(withdrawProvider.notifier).createCard(
            context: context,
            body: cardData,
          );
    }
  }

  /// submit withdraw request
  Future<void> _submitWithdrawRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Remove focus to close the keyboard
      FocusScope.of(context).unfocus();
      final Map<String, dynamic> withdrawRequestJson = {
        "beneficiaryName": beneficiaryNameController.text.trim(),
        "bankName": bankController.text.trim(),
        "iban": ibanAccountNumberController.text.trim(),
        "amount": amountController.text.trim(),
      };

      /// resend phone passcode
      await ref.read(authProvider.notifier).resendPhonePasscodeForWithdraw(
            json: withdrawRequestJson,
            context: context,
          );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final withdrawalState = ref.watch(withdrawProvider);
    sizes!.refreshSize(context);

    final mainStateWatchProvider = ref.watch(homeProvider);

    /// state
    final authStateWatchProvider = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(
            context,
          )!
              .withdrawTitle, //"Withdrawal Funds",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ConstPadding.sizeBoxWithHeight(height: 24),
                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(
                        context,
                      )!
                          .enter_withdraw_amount, //"Enter amount to be withdrawn",
                      labelText: AppLocalizations.of(
                        context,
                      )!
                          .amount, //"Amount",
                      controller: amountController,
                      textInputType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .amountReq; //"Amount is required";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .withdraw_digit; //"Amount must be digits only";
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .please_enter_valid_amount; //"Enter a valid amount";
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(
                        context,
                      )!
                          .withdraw_enter_bank_name, //"Enter Bank Name",
                      labelText: AppLocalizations.of(
                        context,
                      )!
                          .withdraw_bank_name, //"Bank Name",
                      controller: bankController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .bankReq; //"Bank name is required";
                        }
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .withdraw_only_alphabet; //"Only alphabets are allowed";
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(
                        context,
                      )!
                          .withdraw_benf_name, //"Enter Beneficiary Name",
                      labelText: AppLocalizations.of(
                        context,
                      )!
                          .beneficiary, //"Beneficiary Name",
                      controller: beneficiaryNameController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .beneficiaryReq; //"Beneficiary name is required";
                        }
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .withdraw_only_alphabet; //"Only alphabets are allowed";
                        }
                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    CommonTextFormField(
                      title: "title",
                      hintText: AppLocalizations.of(
                        context,
                      )!
                          .iban, //"IBAN Number",
                      labelText: AppLocalizations.of(
                        context,
                      )!
                          .iban, //"IBAN Number",
                      controller: ibanAccountNumberController,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .ibanReq; //"IBAN Account number is required";
                        }

                        final trimmed = value.trim();

                        // Length between 23 and 30
                        if (trimmed.length < 23 || trimmed.length > 30) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .ibanLength; //"IBAN number must be between 23 and 30 characters";
                        }

                        // Must contain both letters and digits
                        if (!RegExp(
                          r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{23,30}$',
                        ).hasMatch(trimmed)) {
                          return AppLocalizations.of(
                            context,
                          )!
                              .withdraw_alphabet_char; //"Must include both letters and digits";
                        }

                        return null;
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),

                    // Add Card Button - Conditionally shown
                    if (_areAllFieldsFilled() &&
                        !_isCurrentDetailsInCardList(withdrawalState
                            .getAllCardsResponse.payload?.cardsList))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: withdrawalState.cardCreateLoadingState ==
                                      LoadingWithdrawalState.loading
                                  ? Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primaryGold500,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryGold500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: _addCurrentCard,
                                      icon: Icon(
                                        Icons.add,
                                        color: AppColors.primaryGold500,
                                        size: 20,
                                      ),
                                      label: GetGenericText(
                                        text: AppLocalizations.of(context)!.save_card_detail, //"Save Card Details",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGold500,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.primaryGold500,
                                        side: BorderSide(
                                          color: AppColors.primaryGold500,
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                    GetGenericText(
                      text: AppLocalizations.of(context)!.bank_fee_notice,
                      //"Minimum deposit amount is AED 100, charges may apply",
                      fontSize: sizes!.isPhone ? 11 : 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                    ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 24),
                    LoaderArrowButton(
                      title: AppLocalizations.of(
                        context,
                      )!
                          .withdrawBtn, //"Withdrawal",
                      isLoadingState: authStateWatchProvider.isButtonState,
                      onTap: () async {
                        final walletBalance = double.tryParse(
                              mainStateWatchProvider.getHomeFeedResponse.payload
                                      ?.walletExists?.moneyBalance
                                      ?.toString() ??
                                  '0',
                            ) ??
                            0.0;

                        double enteredAmount =
                            double.tryParse(amountController.text.trim()) ??
                                0.0;
                        if (walletBalance < enteredAmount) {
                          await genericPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!
                                .invest_insufficient_balance_title, //"Insufficient Balance",
                            subtitle: AppLocalizations.of(
                              context,
                            )!
                                .withdraw_add_fund,
                            //"Please add funds into your account.",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!
                                .gift_back, //"Back",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!
                                .dep_method_header, //"Add funds",
                            isLoadingState: false,
                            onNoPress: () => Navigator.pop(context),
                            onYesPress: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddFundScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        } else {
                          _submitWithdrawRequest(); // <-- add parentheses
                        }
                      },
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 32),
                    Divider(
                      color: AppColors.greyScale800,
                      thickness: 1,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!
                                .previous_bank_accounts,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey6Color,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.history,
                            color: AppColors.primaryGold500,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!
                            .tap_any_account_to_fill_details,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey3Color,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    if (withdrawalState.cardLoadingState ==
                        LoadingWithdrawalState.loading)
                      const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGold500),
                      )
                    else if (withdrawalState
                            .getAllCardsResponse.payload?.cardsList!.isEmpty ??
                        true)
                      GetGenericText(
                        text: AppLocalizations.of(context)!.no_save_card_found,//"No Saved Card Found",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                      ).getAlign()
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: withdrawalState.getAllCardsResponse.payload?.cardsList?.length ?? 0,
                          itemBuilder: (context, index) {
                            final card = withdrawalState.getAllCardsResponse.payload!.cardsList![index];
                            return GestureDetector(
                                onTap: () => _fillFormData(
                                  BankDetails(
                                    bankName: card.bankName ?? '',
                                    beneficiaryName: card.beneficiaryName ?? '',
                                    iban: card.ibanNumber ?? '',
                                  ),
                                ),
                                child: Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyScale900,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.greyScale700,
                                      width: 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      /// Main card content
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            height: 4
                                          ), // spacing for delete icon area
                                          GetGenericText(
                                            text: card.bankName ?? '',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.grey6Color,
                                          ),
                                          GetGenericText(
                                            text: card.beneficiaryName ?? '',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.grey5Color,
                                          ),
                                          GetGenericText(
                                            text: _formatIBAN( card.ibanNumber ?? ''),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.grey4Color,
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GetGenericText(
                                              text: AppLocalizations.of(context)!.tap_to_use,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.primaryGold500,
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// Delete button (top right)
                                      Positioned(
                                        top: 0,
                                        right: CommonService.lang == "en"
                                            ? 0
                                            : null,
                                        left: CommonService.lang == "ar"
                                            ? 0
                                            : null,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {
                                            genericPopUpWidget(
                                              isLoadingState: false,
                                              context: context,
                                              heading: AppLocalizations.of(
                                                context,
                                              )!
                                                  .warning, //"Warning",
                                              subtitle: AppLocalizations.of(
                                                      context)!
                                                  .sure_want_to_delete_account_detail, //"Are you sure want to delete",
                                              noButtonTitle:
                                                  AppLocalizations.of(
                                                context,
                                              )!
                                                      .logout_no, //"No",
                                              yesButtonTitle:
                                                  AppLocalizations.of(
                                                context,
                                              )!
                                                      .logout_yes, //"Yes",
                                              onNoPress: () async {
                                                Navigator.pop(context);
                                              },
                                              onYesPress: () async {
                                                Navigator.pop(context);
                                                ref
                                                    .read(withdrawProvider
                                                        .notifier)
                                                    .deleteCard(
                                                        context: context,
                                                        cardId: card.id ?? '');
                                              },
                                            );
                                            //  Call your delete card method here
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppColors
                                                  .redColor, // or AppColors.grey5Color for subtle
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: CommonService.lang == "en"
                                            ? 28
                                            : null,
                                        left: CommonService.lang == "ar"
                                            ? 28
                                            : null, // leave space between edit and delete
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditBankCardScreen(
                                                  card: card,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: AppColors.primaryGold500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              );
                          },
                        ),
                      ),
                  ],
                ).get16HorizontalPadding(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to format IBAN for display
  String _formatIBAN(String iban) {
    if (iban.length <= 8) return iban;
    return '${iban.substring(0, 4)} **** **** ${iban.substring(iban.length - 4)}';
  }
}
