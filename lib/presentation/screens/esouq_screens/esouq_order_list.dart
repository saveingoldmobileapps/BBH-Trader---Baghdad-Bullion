import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/extensions/extensions.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/const_padding.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/loan_request_screens/add_loan_request_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/loan_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/no_data_widget.dart';

import '../../../core/enums/loading_state.dart';
import '../../../data/models/bank_models/GetAllLoanResponse.dart';
import '../../widgets/pop_up_widget.dart';
import '../loan_request_screens/edit_loan_request_screen.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(loanProvider.notifier).fetchAllLoans(showLoading: true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLoanRequestScreen(),
            ),
          ).then((_) {
            if (context.mounted) {
              ref.read(loanProvider.notifier).fetchAllLoans(showLoading: true);
            }
          });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AddLoanRequestScreen(),
          //   ),
          // ).then((_) {
          //   ref.read(loanNotifierProvider.notifier).fetchAllLoans(true);
          // });
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
          text: AppLocalizations.of(context)!.order_list,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      //Will update if get all API ready for E-Souq orders
      body: Consumer(
        builder: (context, ref, child) {
          final loanState = ref.watch(loanProvider); // Changed to loanProvider

          if (loanState.loadingState == LoadingLoanState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (loanState.errorResponse != null) {
            return Center(
              child: Text(
                loanState.errorResponse!.message ?? "Some Error Occurred",
              ),
            );
          }

          if (loanState.loans.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: NoDataWidget(
                title: AppLocalizations.of(context)!.empty_no_data,
                description: AppLocalizations.of(context)!.no_order_available,
              ),
            );
          }

          return Container(
            height: sizes!.height,
            width: sizes!.width,
            decoration: BoxDecoration(color: AppColors.greyScale1000),
            child: SafeArea(
              child: Column(
                children: [
                  ConstPadding.sizeBoxWithHeight(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: loanState.loans.length,
                      itemBuilder: (context, index) {
                        UserAllLoanRequests loan = loanState.loans[index];
                        return Dismissible(
                          key: Key(loan.id.toString()),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditLoanRequestScreen(
                                    id: loan.id,
                                    amount: loan.loanAmount.toString(),
                                    comment: AppLocalizations.of(
                                      context,
                                    )!.comment_here,
                                    branchId: loan.branchId,
                                    holdAmount: loan.metalFroze.toString(),
                                  ),
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  ref
                                      .read(loanProvider.notifier)
                                      .fetchAllLoans(
                                        showLoading: true,
                                      ); // Updated
                                }
                              });
                              return false;
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              await genericPopUpWidget(
                                isLoadingState: false,
                                context: context,
                                heading: AppLocalizations.of(context)!.warning,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.gift_friend_del_warning,
                                noButtonTitle: AppLocalizations.of(context)!.no,
                                yesButtonTitle: AppLocalizations.of(
                                  context,
                                )!.yes,
                                onNoPress: () {
                                  Navigator.pop(context);
                                },
                                onYesPress: () async {
                                  Navigator.pop(context);
                                  await ref
                                      .read(loanProvider.notifier)
                                      .deleteLoan(loanId: loan.id!); // Updated
                                },
                              );
                            }
                            return false;
                          },
                          child: orderRequestCard(
                            amount: loan.loanAmount.toString(),
                            date: loan.createdAt!,
                            status: loan.loanStatus!,
                          ).get6VerticalPadding(),
                        );
                      },
                    ).get16HorizontalPadding(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // body: Consumer(
      //   builder: (context, ref, child) {
      //     final loanState = ref.watch(loanNotifierProvider);

      //     if (loanState.isLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     }

      //     if (loanState.errorMessage != null) {
      //       return Center(child: Text(loanState.errorMessage!));
      //     }

      //     if (loanState.loans.isEmpty) {
      //       return Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 15),
      //         child: NoDataWidget(
      //           title: "No Data To Show",
      //           description: "No Order Available",
      //         ),
      //       );
      //     }

      //     return Container(
      //       height: sizes!.height,
      //       width: sizes!.width,
      //       decoration: BoxDecoration(color: AppColors.greyScale1000),
      //       child: SafeArea(
      //         child: Column(
      //           children: [
      //             ConstPadding.sizeBoxWithHeight(height: 24),
      //             Expanded(
      //               child: ListView.builder(
      //                 itemCount: loanState.loans.length,
      //                 itemBuilder: (context, index) {
      //                   AllLoanRequests loan = loanState.loans[index];
      //                   return Dismissible(
      //                     key: Key(loan.id.toString()),
      //                     background: Container(
      //                       color: Colors.green,
      //                       alignment: Alignment.centerLeft,
      //                       padding: EdgeInsets.symmetric(horizontal: 20),
      //                       child: Icon(Icons.edit, color: Colors.white),
      //                     ),
      //                     secondaryBackground: Container(
      //                       color: Colors.red,
      //                       alignment: Alignment.centerRight,
      //                       padding: EdgeInsets.symmetric(horizontal: 20),
      //                       child: Icon(Icons.delete, color: Colors.white),
      //                     ),
      //                     direction: DismissDirection.horizontal,
      //                     confirmDismiss: (direction) async {
      //                       if (direction == DismissDirection.startToEnd) {
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) => EditLoanRequestScreen(
      //                               id: loan.id,
      //                               amount: loan.loanAmount.toString(),
      //                               comment: "comment here ",
      //                             ),
      //                           ),
      //                         ).then((_) {
      //                           ref
      //                               .read(loanNotifierProvider.notifier)
      //                               .fetchAllLoans(true);
      //                         });
      //                         return false;
      //                       } else if (direction ==
      //                           DismissDirection.endToStart) {
      //                         // Delete loan
      //                         genericPopUpWidget(
      //                           isLoadingState: false,
      //                           context: context,
      //                           heading: "Warning",
      //                           subtitle: "Are you sure want to delete",
      //                           noButtonTitle: "No",
      //                           yesButtonTitle: "Yes",
      //                           onNoPress: () {
      //                             Navigator.pop(context);
      //                           },
      //                           onYesPress: () async {
      //                             Navigator.pop(context);
      //                             await ref
      //                                 .read(loanNotifierProvider.notifier)
      //                                 .deleteLoan(loanId: loan.id!);
      //                           },
      //                         );
      //                       }
      //                       return false;
      //                     },
      //                     child: orderRequestCard(
      //                       amount: loan.loanAmount.toString(),
      //                       date: loan.createdAt!,
      //                       status: loan.loanStatus!,
      //                     ).get6VerticalPadding(),
      //                   );
      //                 },
      //               ).get16HorizontalPadding(),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }

  Widget orderRequestCard({
    required String amount,
    required String date,
    required String status,
  }) {
    DateTime parsedDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    String formattedTime = DateFormat('HH:mm').format(parsedDate);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // width: sizes?.responsiveWidth(phoneVal: 361, tabletVal: 600),
      // width: sizes!.widthRatio * 361,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Color(0xFF333333),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.amountVar, //"Amount",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.aed} $amount", // "AED $amount",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              statusCard(status),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),
          Row(
            children: [
              GetGenericText(
                text: formattedDate,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4Color,
              ),
              ConstPadding.sizeBoxWithWidth(width: 4),
              GetGenericText(
                text: formattedTime,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4Color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statusCard(String status) {
    switch (status.toLowerCase()) {
      case "rejected":
        return rejectionCard();
      case "approved":
        return acceptanceCard();
      default:
        return pendingCard();
    }
  }

  Widget rejectionCard() {
    return _statusContainer(
      "Rejected",
      AppColors.red900Color,
      AppColors.red800Color,
    );
  }

  Widget acceptanceCard() {
    return _statusContainer(
      "Approved",
      Color(0xFF34C759),
      AppColors.green900Color,
    );
  }

  Widget pendingCard() {
    return _statusContainer("Pending", Color(0xFFE8B931), Color(0xFF11271C));
  }

  Widget _statusContainer(String text, Color bgColor, Color textColor) {
    return Container(
      width: sizes!.responsiveLandscapeWidth(
        phoneVal: 70,
        tabletVal: 90,
        tabletLandscapeVal: 70,
        isLandscape: sizes!.isLandscape(),
      ),
      height: sizes!.responsiveLandscapeHeight(
        phoneVal: 24,
        tabletVal: 34,
        tabletLandscapeVal: 40,
        isLandscape: sizes!.isLandscape(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Center(
        child: GetGenericText(
          text: text,
          fontSize: sizes!.responsiveFont(
            phoneVal: 12,
            tabletVal: 14,
          ),
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
