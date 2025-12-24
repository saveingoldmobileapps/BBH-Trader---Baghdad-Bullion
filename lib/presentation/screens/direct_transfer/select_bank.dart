import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/direct_transfer/bank_details_screen.dart';

import '../../sharedProviders/providers/direct_transfer/direct_transfer_provider.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class SelectBankForDirectTransfer extends ConsumerStatefulWidget {
  const SelectBankForDirectTransfer({super.key});

  @override
  ConsumerState createState() => _SelectBankForDirectTransferState();
}

class _SelectBankForDirectTransferState
    extends ConsumerState<SelectBankForDirectTransfer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(directTransferProvider.notifier).fetchAllBanks();
    });
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
    sizes!.refreshSize(context);
    final state = ref.watch(directTransferProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Container(
        width: sizes!.width,
        height: sizes!.height,
        color: AppColors.greyScale1000,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetGenericText(
              text: AppLocalizations.of(context)!.dep_selectBank_title,//"Select a bank",
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.grey6Color,
            ),
            GetGenericText(
              text: AppLocalizations.of(context)!.dep_selectBank_sub,//"Choose which bank to transfer the amount",
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.grey3Color,
            ),
            const SizedBox(height: 15),
            if (state.isLoading)
              const Center(
                child: ShimmerLoader(
                  loop: 1,
                ),
              )
            else if (state.allBanks.isEmpty)
            //Directionality.of(context) == TextDirection.rtl?
              const Center(
                child: Text(
                  "No banks available",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.allBanks.length,
                  itemBuilder: (context, index) {
                    final bank = state.allBanks[index];
                    final initials = _getInitials(title: bank.bankName ?? '');
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.greyScale900,
                            child: GetGenericText(
                              text: initials,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 204),
                            ),
                          ),
                          title: GetGenericText(
                            text: bank.bankName ?? "",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey5Color,
                          ),
                          trailing: SvgPicture.asset(
                            "assets/svg/bank_forward_icon.svg",
                            height: sizes!.heightRatio * 16,
                            width: sizes!.widthRatio * 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BankDetailsScreen(bankId: bank.id!),
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.grey, thickness: 0.3),
                      ],
                    );
                  },
                ),
              ),
          ],
        ).get16HorizontalPadding(),
      ),
    );
  }

  /// get initials from title
  String _getInitials({
    required String title,
  }) {
    final parts = title.split(' ');
    if (parts.length == 1) return title.substring(0, 2).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
