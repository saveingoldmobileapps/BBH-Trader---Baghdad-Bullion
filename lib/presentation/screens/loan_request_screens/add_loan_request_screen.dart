import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/search_drop_down.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../sharedProviders/bank_branch_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class AddLoanRequestScreen extends ConsumerStatefulWidget {
  const AddLoanRequestScreen({super.key});

  @override
  ConsumerState createState() => _AddLoadRequestScreenState();
}

class _AddLoadRequestScreenState extends ConsumerState<AddLoanRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final commentController = TextEditingController();
  double _metalHolded = 0.0;

  @override
  @override
  void initState() {
    super.initState();
    amountController.addListener(_calculateMetalHold); // This is correct
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllBranches();
    });
  }

  void _calculateMetalHold() {
    final goldPriceState = ref.read(goldPriceProvider);
    // final oneGramSellingPriceInAED =
    //     goldPriceState.value?.oneGramSellingPriceInAED ?? 0.0;
    final oneGramBuyingPriceInAED =
        goldPriceState.value?.oneGramBuyingPriceInAED ?? 0.0;
    debugPrint(
      'Gold price in calculation: $oneGramBuyingPriceInAED',
    ); // Add this

    final loanAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
    debugPrint('Loan amount: $loanAmount'); // Add this

    if (loanAmount > 0 && oneGramBuyingPriceInAED > 0) {
      final calculated = (loanAmount / oneGramBuyingPriceInAED) * 2;
      debugPrint('Calculated hold amount: $calculated'); // Add this
      setState(() {
        _metalHolded = calculated;
      });
    } else {
      setState(() {
        _metalHolded = 0.0;
      });
    }
  }

  Future<void> getAllBranches() async {
    final notifier = ref.read(bankBranchProvider.notifier);
    await notifier.fetchBankBranches();

    final state = ref.read(bankBranchProvider);
    if (state.loadingState == LoadingState.error) {
      getAllBranches();
      return;
    }
    final branches = state.getAllBranchesResponse.payload;

    if (branches != null && branches.isNotEmpty) {
      final firstBranch = branches.first;
      final branchNameWithLocation =
          '${firstBranch.branchName} - ${firstBranch.branchLocation}';

      notifier.setSelectedBranch(
        branchName: branchNameWithLocation,
        branchId: firstBranch.id ?? '',
      );
    }
  }

  @override
  void dispose() {
    amountController.removeListener(_calculateMetalHold);
    amountController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

    final bankBranchNotifier = ref.watch(bankBranchProvider.notifier);
    final bankBranchState = ref.watch(bankBranchProvider);

    // debugPrint('Current gold price: $oneGramSellingPriceInAED');

    /// StreamProvider
    // final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
    // final oneGramSellingPriceInAED =
    //     goldPriceStateWatchProvider.value?.oneGramSellingPriceInAED ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.whiteColor,
        ),
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        title: GetGenericText(
          text: "Request Advance",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Remove focus to close the keyboard
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: sizes!.height,
          width: sizes!.isLandscape() && !sizes!.isPhone
              ? sizes!.height
              : sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child:
                bankBranchState.loadingState == LoadingState.loading ||
                    bankBranchState.loadingState != LoadingState.data
                ? Center(
                    child: ShimmerLoader(loop: 6),
                  ).get6HorizontalPadding()
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ConstPadding.sizeBoxWithHeight(height: 16),

                          /// Fetch Branches
                          SearchableDropdown(
                            iconString: "assets/svg/arrow_down.svg",
                            title: "Branch",
                            items: bankBranchNotifier
                                .uniqueBranchNamesWithLocation,
                            label: "Branch",
                            hint: "Select Branch",
                            selectedItem:
                                bankBranchState.selectedBranch ??
                                (bankBranchNotifier
                                        .uniqueBranchNamesWithLocation
                                        .isNotEmpty
                                    ? bankBranchNotifier
                                          .uniqueBranchNamesWithLocation
                                          .first
                                    : null),
                            validator: (value) =>
                                value == null ? 'Please select branch' : null,
                            onChanged: (String value) {
                              final branch = bankBranchState
                                  .getAllBranchesResponse
                                  .payload!
                                  .firstWhere(
                                    (b) =>
                                        '${b.branchName} - ${b.branchLocation}' ==
                                        value,
                                  );
                              debugPrint(
                                "branchId: ${branch.id} | newValue: $value",
                              );

                              bankBranchNotifier.setSelectedBranch(
                                branchName: value,
                                branchId: branch.id ?? '',
                              );
                            },
                          ),

                          // DropdownButtonFormField<String>(
                          //   decoration: InputDecoration(
                          //     labelText: "Branch",
                          //     labelStyle: TextStyle(
                          //       color: AppColors.whiteColor,
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w400,
                          //       fontFamily: GoogleFonts.roboto().fontFamily,
                          //     ),
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: AppColors.secondaryColor,
                          //       ),
                          //     ),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: AppColors.secondaryColor,
                          //       ),
                          //     ),
                          //     focusedBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: AppColors.secondaryColor,
                          //         width: 2.0,
                          //       ),
                          //     ),
                          //     errorBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: AppColors.red900Color,
                          //         width: 2.0,
                          //       ),
                          //     ),
                          //     focusedErrorBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: AppColors.red900Color,
                          //         width: 2.0,
                          //       ),
                          //     ),
                          //   ),
                          //   dropdownColor: AppColors.primaryGold500,
                          //   icon: Padding(
                          //     padding: EdgeInsets.only(right: 10),
                          //     child: SvgPicture.asset(
                          //       "assets/svg/arrow_down.svg",
                          //       height: sizes!.heightRatio * 24,
                          //       width: sizes!.widthRatio * 24,
                          //     ),
                          //   ),
                          //   validator: (value) =>
                          //       value == null ? 'Please select branch' : null,
                          //   // Set the default selected value
                          //   value:
                          //       bankBranchState.selectedBranch ??
                          //       (bankBranchNotifier
                          //               .uniqueBranchNamesWithLocation
                          //               .isNotEmpty
                          //           ? bankBranchNotifier
                          //                 .uniqueBranchNamesWithLocation
                          //                 .first
                          //           : null),
                          //   onChanged: (String? newValue) {
                          //     if (newValue != null) {
                          //       final branch = bankBranchState
                          //           .getAllBranchesResponse
                          //           .payload!
                          //           .firstWhere(
                          //             (b) =>
                          //                 '${b.branchName} - ${b.branchLocation}' ==
                          //                 newValue,
                          //           );

                          //       debugPrint(
                          //         "branchId: ${branch.id} | newValue: $newValue",
                          //       );

                          //       bankBranchNotifier.setSelectedBranch(
                          //         branchName: newValue,
                          //         branchId: branch.id ?? '',
                          //       );
                          //     }
                          //   },
                          //   items: bankBranchNotifier
                          //       .uniqueBranchNamesWithLocation
                          //       .map<DropdownMenuItem<String>>((branchName) {
                          //         return DropdownMenuItem<String>(
                          //           value: branchName,
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(left: 16),
                          //             child: Container(
                          //               constraints: BoxConstraints(
                          //                 maxWidth: sizes!.width * 0.7,
                          //               ),
                          //               child: GetGenericText(
                          //                 text: branchName,
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w400,
                          //                 color: AppColors.grey6Color,
                          //                 lines: 2,
                          //                 overflow: TextOverflow.ellipsis,
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       })
                          //       .toList(),
                          // ),

                          ///
                          ConstPadding.sizeBoxWithHeight(height: 16),

                          /// amount
                          CommonTextFormField(
                            title: "title",
                            hintText: "Enter amount",
                            labelText: "Amount",
                            controller: amountController,
                            inputFormatters: [
                              DecimalTextInputFormatter(decimalRange: 2),
                              //LengthLimitingTextInputFormatter(15),
                            ],
                            textInputType: TextInputType.numberWithOptions(signed: true,
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter amount';
                              }
                              final amount = num.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please add a correct amount';
                              }
                              return null;
                            },
                          ),
                          
                          ConstPadding.sizeBoxWithHeight(height: 4),

                          /// information messages
                          GetGenericText(
                            text:
                                "You may request an advance equal to 50% of your gold value.",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 12,
                              tabletVal: 14,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey5Color,
                          ).getAlign(),

                          // Display hold amount calculation
                          if (amountController.text.isNotEmpty)
                            Column(
                              children: [
                                ConstPadding.sizeBoxWithHeight(height: 8),
                                GetGenericText(
                                  text:
                                      "Hold Metal = ${_metalHolded.toStringAsFixed(2)} grams",
                                  fontSize: sizes!.responsiveFont(
                                    phoneVal: 12,
                                    tabletVal: 14,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGold500,
                                ).getAlign(),
                                // GetGenericText(
                                //   text:
                                //       "Calculated as: (${amountController.text} AED / ${oneGramSellingPriceInAED.toStringAsFixed(2)} AED) × 2",
                                //   fontSize: sizes!.responsiveFont(
                                //     phoneVal: 10,
                                //     tabletVal: 12,
                                //   ),
                                //   fontWeight: FontWeight.w400,
                                //   color: AppColors.grey5Color,
                                // ).getAlign(),
                              ],
                            ),
                          ConstPadding.sizeBoxWithHeight(height: 16),

                          /// comment
                          CommonTextFormField(
                            title: "title",
                            hintText: "Enter comment",
                            labelText: "Comment",
                            controller: commentController,
                            maxLines: 3,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 24),

                          /// button
                          LoaderButton(
                            title: "Request Now",
                            isLoadingState: bankBranchState.isButtonState,
                            onTap: () async {
                              debugPrint(
                                "amount ${amountController.text.toString()}",
                              );
                              debugPrint(
                                " hold metal${_metalHolded.toStringAsFixed(4)}",
                              );

                              // Remove focus to close the keyboard
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState?.validate() ?? false) {
                                /// submit loan request
                                await ref
                                    .read(bankBranchProvider.notifier)
                                    .submitLoanRequest(
                                      branchId:
                                          bankBranchState.selectedBranchId ??
                                          "",
                                      comment: commentController.text
                                          .toString()
                                          .trim(),
                                      amount: amountController.text
                                          .toString()
                                          .trim(),
                                      metalFroze: _metalHolded.toStringAsFixed(
                                        4,
                                      ), // Pass the calculated value
                                      context: context,
                                    );
                              }
                            },
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
}
