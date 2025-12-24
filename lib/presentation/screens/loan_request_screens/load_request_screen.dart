import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';

import '../../../core/core_export.dart';
import '../../sharedProviders/loan_provider.dart';
import '../../widgets/no_data_widget.dart';
import '../../widgets/widget_export.dart';
import 'add_loan_request_screen.dart';
import 'edit_loan_request_screen.dart';

class LoanRequestScreen extends ConsumerStatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  ConsumerState createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends ConsumerState<LoanRequestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("fetchAllLoans initState");
      ref.read(loanProvider.notifier).fetchAllLoans();
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(context: context, showLoading: true);
    });
  }

  @override
  void dispose() {
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

    final mainStateWatchProvider = ref.watch(homeProvider);

    final loanState = ref.watch(loanProvider);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold500,
        child: Icon(
          Icons.add_rounded,
          color: AppColors.greyScale900,
          size: 32,
        ),
        onPressed: () {
          final frozenAmount = mainStateWatchProvider
              .getHomeFeedResponse
              .payload!
              .walletExists!
              .frozenMetalBalance;
          debugPrint("frozenAmount: $frozenAmount");

          // final loanAmountBalance = mainStateWatchProvider
          //     .getHomeFeedResponse
          //     .payload!
          //     .walletExists!
          //     .loanAmountBalance;

          // Check if frozen amount exists and is greater than 0
          // if (frozenAmount != null && frozenAmount > 0) {
          //   if (!context.mounted) return;
          //   Toasts.getErrorToast(
          //     gravity: ToastGravity.TOP,
          //     text: 'You already have Hold Amounts',
          //     duration: const Duration(seconds: 2),
          //   );
          //   return;
          // }

          // Check if any loan has Pending status
          bool hasPendingLoan = loanState.loans.any(
            (loan) => loan.loanStatus == "Pending",
          );
          bool hasApprovedLoan = loanState.loans.any(
            (loan) => loan.loanStatus == "Approved",
          );

          if (hasPendingLoan) {
            if (!context.mounted) return;
            Toasts.getErrorToast(
              gravity: ToastGravity.TOP,
              text: 'You have a pending advance request',
              duration: const Duration(seconds: 2),
            );
            return;
          }

          // Check for approved loans with balance > 0
          if (hasApprovedLoan) {
            if (!context.mounted) return;
            Toasts.getErrorToast(
              gravity: ToastGravity.TOP,
              text: 'You have an active advance',
              duration: const Duration(seconds: 2),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLoanRequestScreen(),
            ),
          ).then((_) {
            if (!context.mounted) return;
            ref.read(loanProvider.notifier).fetchAllLoans();
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Advance",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: SafeArea(
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: RefreshIndicator(
            backgroundColor: AppColors.primaryGold500,
            color: AppColors.whiteColor,
            onRefresh: () async {
              await ref.read(loanProvider.notifier).fetchAllLoans();
            },
            child: Column(
              children: [
                loanState.loadingState == LoadingLoanState.data &&
                        loanState.payingLoanState != LoadingState.loading
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: loanState.loans.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var data = loanState.loans[index];

                            return Dismissible(
                              key: Key(data.id.toString()),
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                  horizontal: sizes!.widthRatio * 20,
                                ),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(
                                  horizontal: sizes!.widthRatio * 20,
                                ),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                final status = data.loanStatus!.toLowerCase();
                                // final status = (data.loanStatus ?? "").trim().toLowerCase();

                                final isPending = status == "pending";
                                final isApproved = status == "approved";
                                final isPaid = status == "paid";

                                if (direction == DismissDirection.startToEnd) {
                                  // EDIT logic
                                  if (isPending) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditLoanRequestScreen(
                                              id: data.id,
                                              amount: data.loanAmount
                                                  .toString(),
                                              comment: data.loanComment ?? "",
                                              branchId: data.branchId,
                                              holdAmount: data.metalFroze
                                                  .toString(),
                                            ),
                                      ),
                                    ).then((_) {
                                      if (!context.mounted) return;
                                      ref
                                          .read(loanProvider.notifier)
                                          .fetchAllLoans();
                                    });
                                  } else if (isApproved || isPaid) {
                                    await Toasts.getErrorToast(
                                      gravity: ToastGravity.TOP,
                                      text:
                                          'Approved or paid advance cannot be edited.',
                                    );
                                  }

                                  return false; // prevent swipe auto-dismiss
                                }

                                if (direction == DismissDirection.endToStart) {
                                  // DELETE logic
                                  if (isPending) {
                                    await genericPopUpWidget(
                                      isLoadingState: false,
                                      context: context,
                                      heading: "Warning",
                                      subtitle:
                                          "Are you sure you want to delete this advance request?",
                                      noButtonTitle: "No",
                                      yesButtonTitle: "Yes",
                                      onNoPress: () => Navigator.pop(context),
                                      onYesPress: () async {
                                        await ref
                                            .read(loanProvider.notifier)
                                            .deleteLoan(loanId: data.id!)
                                            .then((_) {
                                              if (!context.mounted) return;
                                              Navigator.pop(context);
                                            });
                                      },
                                    );
                                  } else if (isApproved || isPaid) {
                                    await Toasts.getErrorToast(
                                      gravity: ToastGravity.TOP,
                                      text:
                                          'Approved or paid advance cannot be deleted.',
                                    );
                                  }

                                  return false; // prevent swipe auto-dismiss
                                }

                                return false;
                              },
                              child: LoanRequestCard(
                                amount: data.loanAmount.toString(),
                                date: data.createdAt!,
                                status: data.loanStatus!,
                                onPayNowClick: () async {
                                  await genericPopUpWidget(
                                    context: context,
                                    heading: "Confirmation",
                                    subtitle:
                                        "Would you like to pay the advance amount of ${data.loanAmount} now?",
                                    noButtonTitle: "Cancel",
                                    yesButtonTitle: "Pay Now",
                                    isLoadingState: false,
                                    // Optional: Hook this to a loading state if needed
                                    onNoPress: () {
                                      Navigator.pop(context);
                                    },
                                    onYesPress: () async {
                                      Navigator.pop(context);

                                      if (!context.mounted) return;

                                      debugPrint(
                                        "frozen metal.... ${data.metalFroze}",
                                      );
                                      debugPrint(
                                        "amount.... ${data.loanAmount}",
                                      );

                                      await ref
                                          .read(loanProvider.notifier)
                                          .payLoan(
                                            loanId: data.id!,
                                            userId: data.userId!.id!,
                                            returningAmount: data.loanAmount!,
                                            metalReleased: data.metalFroze!,
                                          );
                                    },
                                  );
                                },
                              ).get6VerticalPadding(),
                            );
                          },
                        ),
                      )
                    : loanState.loadingState == LoadingLoanState.error
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: NoDataWidget(
                            title: "No Data To Show",
                            description:
                                "No advance request available. Click the add button to add a advance request.",
                          ),
                        ),
                      )
                    :  ShimmerLoader(
                        loop: sizes!.isPhone ?4:6,
                      ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
