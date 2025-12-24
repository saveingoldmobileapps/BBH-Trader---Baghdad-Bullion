import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/loan_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/search_drop_down.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

import '../../sharedProviders/bank_branch_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class EditLoanRequestScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? amount;
  final String? comment;
  final String? branchId;
  final String? holdAmount;
  const EditLoanRequestScreen({
    required this.id,
    required this.amount,
    required this.comment,
    required this.branchId,
    required this.holdAmount,
    super.key,
  });

  @override
  ConsumerState createState() => _AddLoadRequestScreenState();
}

class _AddLoadRequestScreenState extends ConsumerState<EditLoanRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final commentController = TextEditingController();

  double _metalHold = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize with widget values
    amountController.text = widget.amount ?? "";
    commentController.text = widget.comment ?? "";
    _metalHold = double.tryParse(widget.holdAmount ?? '0') ?? 0.0;

    amountController.addListener(_calculateMetalHold);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(loanProvider.notifier).fetchAllLoans();
      await getAllBranches();
      if (widget.branchId != null) {
        _selectBranchById(widget.branchId!);
      }
      // Trigger initial calculation
      _calculateMetalHold();
    });
  }
  @override
  void dispose() {
    amountController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  void _calculateMetalHold() {
    final goldPriceAsync = ref.read(goldPriceProvider);
    final oneGramBuyingPriceInAED = goldPriceAsync.maybeWhen(
      data: (state) => state.oneGramBuyingPriceInAED,
      orElse: () => 0.0,
    );

    final loanAmount = double.tryParse(amountController.text.trim()) ?? 0.0;

    if (loanAmount > 0 && oneGramBuyingPriceInAED > 0) {
      final calculated = (loanAmount / oneGramBuyingPriceInAED) * 2;
      setState(() {
        _metalHold = calculated;
      });
    } else {
      setState(() {
        _metalHold = 0.0;
      });
    }
  }

  void _selectBranchById(String branchId) {
    final state = ref.read(bankBranchProvider);
    final branches = state.getAllBranchesResponse.payload;

    if (branches != null) {
      final matchingBranch = branches.firstWhere(
        (b) => b.id == branchId,
        orElse: () => branches.first, // fallback to first branch if not found
      );

      final branchNameWithLocation =
          '${matchingBranch.branchName} - ${matchingBranch.branchLocation}';

      ref
          .read(bankBranchProvider.notifier)
          .setSelectedBranch(
            branchName: branchNameWithLocation,
            branchId: matchingBranch.id ?? '',
          );
    }
  }

  Future<void> getAllBranches() async {
  final notifier = ref.read(bankBranchProvider.notifier);
  await notifier.fetchBankBranches();

  if (!mounted) return;

  await ref.read(homeProvider.notifier).getHomeFeed(context: context, showLoading: true);

  final state = ref.read(bankBranchProvider);
  if (state.loadingState == LoadingState.error) {
    await getAllBranches();
    return;
  }
}


  @override
  Widget build(BuildContext context) {
    ref.listen<double?>(goldPriceProvider.select((state) => 
      state.maybeWhen(
        data: (data) => data.oneGramBuyingPriceInAED,
        orElse: () => null,
      ),
    ), (previous, next) {
      if (next != null) {
        _calculateMetalHold();
      }
    });
    sizes!.refreshSize(context);

    /// states
    final bankBranchNotifier = ref.watch(bankBranchProvider.notifier);
    final bankBranchState = ref.watch(bankBranchProvider);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.whiteColor,
        ),
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        title: GetGenericText(
          text: "Update Advance",
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
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child:
              bankBranchState.loadingState == LoadingState.loading ||
                  bankBranchState.loadingState != LoadingState.data
              ? Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ).get6HorizontalPadding(),
                )
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
                          items:
                              bankBranchNotifier.uniqueBranchNamesWithLocation,
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
                          textInputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 4),

                        /// comment
                        GetGenericText(
                          text:
                              "You may request an advance equal to 50% of your gold value.",
                          // "Apply for an advance if your balance exceeds AED 10,000.",
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
                                    "Hold Metal = ${_metalHold.toStringAsFixed(2)} grams",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 12,
                                  tabletVal: 14,
                                ),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGold500,
                              ).getAlign(),
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
                        ConstPadding.sizeBoxWithHeight(height: 24),

                        /// button
                        LoaderButton(
                          title: "Update Now",
                          isLoadingState: bankBranchState.isButtonState,
                          onTap: () async {
                            try {
                              // 1. First fetch latest loan status
                              await ref
                                  .read(loanProvider.notifier)
                                  .fetchAllLoans();
                              if (!context.mounted) return;

                              // 2. Get updated state after fetch
                              final loanState = ref.read(loanProvider);

                              // 4. Check loan status (case-insensitive comparison)
                              final hasApprovedLoan = loanState.loans.any(
                                (loan) =>
                                    loan.loanStatus?.toLowerCase() ==
                                    "approved",
                              );

                              // 5. Block if approved loan exists with frozen metal
                              if (hasApprovedLoan) {
                                Toasts.getErrorToast(
                                  gravity: ToastGravity.TOP,
                                  text:
                                      'Your advance already approved not able update',
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }

                              // 6. Validate form if checks pass
                              if (!_formKey.currentState!.validate()) return;

                              // 7. Proceed with update
                              final loanUpdateData = {
                                "id": widget.id,
                                "loanAmount": amountController.text,
                                "loanComment": commentController.text,
                                "metalFroze": _metalHold,
                              };

                              await ref
                                  .read(loanProvider.notifier)
                                  .updateLoan(loanData: loanUpdateData);

                              if (!context.mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              Toasts.getErrorToast(
                                gravity: ToastGravity.TOP,
                                text: 'Update failed: ${e.toString()}',
                                duration: const Duration(seconds: 2),
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
    );
  }
}
