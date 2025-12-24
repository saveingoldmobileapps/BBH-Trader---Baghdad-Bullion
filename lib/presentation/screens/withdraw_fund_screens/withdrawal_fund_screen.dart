import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/no_data_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';

import '../../../core/core_export.dart';
import '../../../data/models/withdrawal_models/GetAllWithdrawalFundsResponse.dart';
import '../../../data/models/withdrawal_models/bankModel.dart';
import '../../sharedProviders/providers/withdraw_provider/withdraw_provider.dart';
import '../../widgets/widget_export.dart';
import 'create_withdrawal_fund_screen.dart';

class WithdrawalFundScreen extends ConsumerStatefulWidget {
  const WithdrawalFundScreen({super.key});

  @override
  ConsumerState createState() => _WithdrawalFundScreenState();
}

class _WithdrawalFundScreenState extends ConsumerState<WithdrawalFundScreen> {
  List<BankDetails> _bankDetailsList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("fetchWithdrawalFundsRequests initState");

      ref
          .read(withdrawProvider.notifier)
          .fetchWithdrawalFundsRequests(context: context);
    });
  }

  void _extractUniqueBankDetails(GetAllWithdrawalFundsResponse response) {
    final allWithdraws = response.payload?.kAllWithdraws ?? [];

    // Use a Set to automatically handle duplicates based on hashCode and ==
    final bankDetailsSet = <BankDetails>{};

    for (final withdraw in allWithdraws) {
      if (withdraw.beneficiaryName != null &&
          withdraw.bankName != null &&
          withdraw.iban != null) {
        final bankDetail = BankDetails(
          beneficiaryName: withdraw.beneficiaryName!,
          bankName: withdraw.bankName!,
          iban: withdraw.iban!,
        );

        bankDetailsSet.add(bankDetail);
      }
    }

    // Convert back to list and update state
    setState(() {
      _bankDetailsList = bankDetailsSet.toList();
    });

    debugPrint("Extracted ${_bankDetailsList.length} unique bank details");
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

    final withdrawState = ref.watch(withdrawProvider);
    if (withdrawState.loadingState == LoadingWithdrawalState.data &&
        _bankDetailsList.isEmpty) {
      _extractUniqueBankDetails(withdrawState.getAllWithdrawalFundsResponse);
    }
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
              builder: (context) => CreateWithdrawalFundScreen(
                // bankDetailsList: _bankDetailsList,
              ),
            ),
          ).then((_) {
            if (!context.mounted) return;
            ref
                .read(withdrawProvider.notifier)
                .fetchWithdrawalFundsRequests(context: context);
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
          text: AppLocalizations.of(
            context,
          )!.withdrawTitle, //"Withdrawal Funds",
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
              await ref
                  .read(withdrawProvider.notifier)
                  .fetchWithdrawalFundsRequests(context: context);
            },
            child: Column(
              children: [
                Expanded(
                  child:
                      withdrawState.loadingState == LoadingWithdrawalState.data
                      ? ListView.builder(
                          itemCount:
                              withdrawState
                                  .getAllWithdrawalFundsResponse
                                  .payload
                                  ?.kAllWithdraws
                                  ?.length ??
                              0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var data = withdrawState
                                .getAllWithdrawalFundsResponse
                                .payload!
                                .kAllWithdraws![index];

                            if (data.status?.toLowerCase() != "pending") {
                              return WithdrawalFundCard(
                                rtl: Directionality.of(context) == TextDirection.rtl,
                                kAllWithdraw: data,
                              ).get6VerticalPadding();
                            }

                            return Dismissible(
                              key: ValueKey(data.id ?? index),
                              direction: DismissDirection.endToStart,
                              background: Container(),
                              // No background for left-to-right
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  final completer = Completer<bool?>();

                                  await genericPopUpWidget(
                                    isLoadingState: false,
                                    context: context,
                                    heading: AppLocalizations.of(context)!.warning,//"Warning",
                                    subtitle:
                                        AppLocalizations.of(context)!.sure_to_cancel_withdraw,//"Are you sure you want to cancel this withdrawal request?",
                                    noButtonTitle: AppLocalizations.of(context)!.no,//"No",
                                    yesButtonTitle: AppLocalizations.of(context)!.yes,//"Yes",
                                    onNoPress: () {
                                      Navigator.pop(context);
                                      completer.complete(false);
                                    },
                                    onYesPress: () async {
                                      await ref
                                          .read(withdrawProvider.notifier)
                                          .cancelWithdrawRequest(
                                            withdrawalId: data.id ?? '',
                                            context: context,
                                          );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ref
                                            .read(homeProvider.notifier)
                                            .getHomeFeed(
                                              context: context,
                                              showLoading: true,
                                            );
                                        completer.complete(true);
                                      }
                                    },
                                  );

                                  return completer.future;
                                }
                                return false;
                              },
                              child: WithdrawalFundCard(
                                rtl: Directionality.of(context) == TextDirection.rtl,
                                kAllWithdraw: data,
                              ).get6VerticalPadding(),
                            );
                          },
                        )
                      : withdrawState.loadingState ==
                            LoadingWithdrawalState.error
                      ? NoDataWidget(
                          title: AppLocalizations.of(
                            context,
                          )!.empty_no_data, //"No Data To Show",
                          description: "",
                        )
                      : const ShimmerLoader(loop: 4),
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
