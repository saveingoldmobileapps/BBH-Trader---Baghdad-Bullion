import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/withdraw_provider/withdraw_provider.dart';

import '../../widgets/shimmers/shimmer_loader.dart';
import '../main_home_screens/main_home_screen.dart';

class WithdrawalSuccessScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> json;

  const WithdrawalSuccessScreen({
    required this.json,
    super.key,
  });

  @override
  ConsumerState createState() => _EsouqCartScreenState();
}

class _EsouqCartScreenState extends ConsumerState<WithdrawalSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// create withdraw request
      ref
          .read(withdrawProvider.notifier)
          .createWithdrawRequest(
            json: widget.json,
            context: context,
          );
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
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    final withdrawState = ref.watch(withdrawProvider);

    sizes!.refreshSize(context);
    return Scaffold(
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: withdrawState.isLoading == true
            ? Center(
                child: ShimmerLoader(
                  loop: 5,
                ),
              ).get16HorizontalPadding()
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes!.heightRatio * 16,
                        horizontal: sizes!.widthRatio * 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/success_tick_icon.svg",
                            height: sizes!.heightRatio * 48,
                            width: sizes!.widthRatio * 48,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 10),
                          GetGenericText(
                            text: AppLocalizations.of(context)!.success,//"Success!",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                            lines: 2,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GetGenericText(
                              text:
                                  AppLocalizations.of(context)!.withdrawSuccessMsg,//"You have successfully submitted your withdrawal request",
                              // "You've successfully submitted AED ${widget.json["amount"]} into the account ${widget.json["iban"]}",
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: AppColors.grey4Color,
                              lines: 6,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 20),
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainHomeScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: sizes!.fontRatio * 48,
                              // width: sizes!.widthRatio * 300,
                              decoration: BoxDecoration(
                                //color: AppColors.primaryGold500,
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFF675A3D),
                                    Color(0xFFBBA473),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GetGenericText(
                                      text: AppLocalizations.of(context)!.returnHome,//"Return to Home",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
