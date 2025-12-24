import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/direct_transfer/direct_transfer_get_started.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';

import '../../widgets/widget_export.dart';
import 'apple_pay_fund_amount_screen.dart';
import 'card_payment_fund_amount_screen.dart';
import 'google_pay_fund_amount_screen.dart';

class AddFundScreen extends ConsumerStatefulWidget {
  const AddFundScreen({super.key});

  @override
  ConsumerState createState() => _AddFundScreenState();
}

class _AddFundScreenState extends ConsumerState<AddFundScreen> {
  bool _showApplePay = false;
  bool _showGooglePay = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      _checkPlatformPaySupport();
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

  /// check platform pay support
  Future<void> _checkPlatformPaySupport() async {
    final isSupported = await Stripe.instance.isPlatformPaySupported();
    if (!mounted) return;
    setState(() {
      _showApplePay = Platform.isIOS && isSupported;
      _showGooglePay = Platform.isAndroid && isSupported;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
   final bool googlePayTrue = 
    ref.read(homeProvider).getHomeFeedResponse.payload?.googlePay ?? false;
    final bool applePayTrue = 
    ref.read(homeProvider).getHomeFeedResponse.payload?.applePay ?? false;


    // var permissions = [
    //   LeanPermissions.identity,
    //   LeanPermissions.transactions,
    //   LeanPermissions.balance,
    //   LeanPermissions.accounts,
    //   LeanPermissions.payments,
    // ];
    // var isSandbox = true;
    // var environment = 'staging';
    //
    // Future<void> connectBank() async {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) => Container(
    //       color: AppColors.greyScale1000,
    //       child: Center(
    //         child: Padding(
    //           padding: EdgeInsets.only(
    //             bottom: MediaQuery.of(context).viewInsets.bottom,
    //           ),
    //           child: Container(
    //             color: AppColors.greyScale1000,
    //             child: Lean.connect(
    //               showLogs: true,
    //               // env: environment,
    //               accessToken:
    //                   "eyJraWQiOiJhNDNhMjFlOS0zNWVhLTRlOTQtOGZhMC1hNDQ5YTg1MjM4MmMiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI3YjgxOTc5Ny0wOGM5LTRmZDktYTU3MC00NjRmMTQ5YzU4OTUiLCJhdWQiOiI3YjgxOTc5Ny0wOGM5LTRmZDktYTU3MC00NjRmMTQ5YzU4OTUiLCJuYmYiOjE3NDQzNzcxNzEsInNjb3BlIjpbImN1c3RvbWVyLnJlYWQiLCJiZW5lZmljaWFyeS53cml0ZSIsInBheW1lbnQud3JpdGUiLCJwYXltZW50LnJlYWQiLCJkZXN0aW5hdGlvbi5yZWFkIiwiY29ubmVjdC53cml0ZSIsImNvbm5lY3QucmVhZCIsImFwcGxpY2F0aW9uLnJlYWQiLCJiYW5rLnJlYWQiLCJrZXkucmVhZCJdLCJpc3MiOiJodHRwczovL2F1dGguc2FuZGJveC5sZWFudGVjaC5tZSIsImN1c3RvbWVycyI6W3siaWQiOiI0MGE2NDE4Yy1kMDEzLTRhOGMtOTA1Mi1hMWIzMmQ1MWY1M2YifV0sImV4cCI6MTc0NDM4MDc3MSwiaWF0IjoxNzQ0Mzc3MTcxLCJqdGkiOiI0NDMwNzRlZi0yZTUxLTQ0NDItODY1Ny1kZDc5M2RiMjQ4MTgiLCJhcHBsaWNhdGlvbnMiOlt7ImlkIjoiN2I4MTk3OTctMDhjOS00ZmQ5LWE1NzAtNDY0ZjE0OWM1ODk1In1dfQ.kHUzQHXUAf9_LfjVPkpG0Ci-bUlML5C2DrHeExmgOyE2Smz2hNeVicqbzGVyie50yMWZb7GsOevvQbQ3cEkuVpOtRNVLLBZX1TX-yp_P66ICb4_KF6Ckzoa-nIIKmYnmvG9J2mUCHef2ox2psmBSEaLZOV9SpN0t80Z9WPfiEjW-vxq7vTgQy6zLdVEjmmBR5v3Idr6h9Zy5N10SBdJdSPKB8MQbKlH5uHwnB2YzPmNvJJET-hq3rZY4LYphDYzLsubOOmjF7bc89sU_hOk_jqmJJ4x0VoTAdDBif6skGpexnc_2ENwa8LytkaQX5t7SJq8SjqaMD9ewHrU3rLnaXw",
    //               appToken: "7b819797-08c9-4fd9-a570-464f149c5895",
    //               isSandbox: isSandbox,
    //               customerId: "40a6418c-d013-4a8c-9052-a1b32d51f53f",
    //               //connectCustomerID,
    //               // bankIdentifier: connectBankIdentifier,
    //               paymentDestinationId: "23b96f1a-e25e-4f45-bd60-5334e159e544",
    //               //connectPaymentDestinationID,
    //               permissions: permissions,
    //               failRedirectUrl:
    //                   "https://cdn.leantech.me/app/flutter/connect/success",
    //               successRedirectUrl:
    //                   "https://cdn.leantech.me/app/flutter/connect/fail",
    //               customization: const {
    //                 "button_text_color": "white",
    //                 "theme_color": "red",
    //                 "button_border_radius": "10",
    //                 "overlay_color": "pink",
    //               },
    //               callback: (LeanResponse resp) {
    //                 if (kDebugMode) {
    //                   ScaffoldMessenger.of(context).showSnackBar(
    //                     SnackBar(content: Text("Callback: ${resp.message}")),
    //                   );
    //                 }
    //                 Navigator.pop(context);
    //               },
    //               actionCancelled: () => Navigator.pop(context),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.add_funds,//"Add Funds",
          fontSize: sizes!.isPhone ? 20 : 24,
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
          child: Column(
            children: [
              ConstPadding.sizeBoxWithHeight(height: 20),
              Directionality.of(context) == TextDirection.rtl
                        ?

              GetGenericText(
                text: AppLocalizations.of(context)!.dep_method_sub,//"Select a Method",
                fontSize: sizes!.isPhone ? 16 : 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ).getAlignRight():
              GetGenericText(
                text: AppLocalizations.of(context)!.dep_method_sub,//"Select a Method",
                fontSize: sizes!.isPhone ? 16 : 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ).getAlign(),
              
              ConstPadding.sizeBoxWithHeight(height: 12),

              ///TODO: Bank Transfer in-progress
              // BuildPaymentMethodCard(
              //   title: "Bank Transfer",
              //   subtitle: "No Fees",
              //   iconString: "assets/svg/bank_icon.svg",
              //   onTap: () async {
              //     // Toasts.getWarningToast(text: "Try it later");
              //     await connectBank();
              //
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //     builder: (context) => const ReturningUserScreen(),
              //     //   ),
              //     // );
              //   },
              // ),
              // ConstPadding.sizeBoxWithHeight(height: 12),
              BuildPaymentMethodCard(
                title: AppLocalizations.of(context)!.dep_method_direct,//"Direct Transfer",
                subtitle: AppLocalizations.of(context)!.dep_method_noFees,//"No Fees",
                iconString: "assets/svg/direct_icon.svg",
                onTap: () async {
                  //Toasts.getWarningToast(text: "Try it later");
                  //await connectBank();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirectTransferGetStarted(),
                    ),
                  );
                },
              ),
              ConstPadding.sizeBoxWithHeight(height: 12),
              BuildPaymentMethodCard(
                title: AppLocalizations.of(context)!.dep_method_card,//"Card Payment",
                subtitle: AppLocalizations.of(context)!.dep_fee_instantNote,//"Instant Deposit, bank fees may apply.",
                iconString: "assets/svg/card_icon.svg",
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CardPaymentFundAmountScreen(),
                    ),
                  );
                },
              ),
              if (_showApplePay && applePayTrue) ...[
                ConstPadding.sizeBoxWithHeight(height: 12),
                BuildPaymentMethodCard(
                  title: "Apple Pay",
                  subtitle: AppLocalizations.of(context)!.dep_fee_instantNote,//"Instant Deposit, bank fees may apply.",
                  iconString: "assets/svg/apple_pay_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplePayFundAmountScreen(),
                      ),
                    );
                  },
                ),
              ],
              ConstPadding.sizeBoxWithHeight(height: 12),
              if (_showGooglePay && googlePayTrue) ...[
                ConstPadding.sizeBoxWithHeight(height: 12),
                BuildPaymentMethodCard(
                  title: "Google Pay",
                  subtitle: AppLocalizations.of(context)!.dep_fee_instantNote,//"Instant Deposit, bank fees may apply.",
                  iconString: "assets/svg/gpay_icon.svg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GooglePayFundAmountScreen(),
                      ),
                    );
                  },
                ),
              ],

              //  Newly code for google pay according brand
              // if (_showGooglePay) ...[
              //   GestureDetector(
              //     onTap: (){

              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const GooglePayFundAmountScreen(),
              //         ),
              //       );

              //     },
              //     child: Container(
              //       width: sizes!.isPhone
              //           ? sizes!.widthRatio * 361
              //           : sizes!.width,
              //       padding: const EdgeInsets.all(12),
              //       decoration: ShapeDecoration(
              //         color: Color(0xFF333333),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //       child: Row(
              //         // mainAxisSize: MainAxisSize.min,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           SvgPicture.asset(
              //             "assets/svg/google-pay-mark_800.svg",
              //             height: sizes!.heightRatio * 34,
              //             width: sizes!.widthRatio * 24,
              //           ),
              //           ConstPadding.sizeBoxWithWidth(width: 10),
              //           Column(
              //             // crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.only(top: 8.0),
              //                 child: GetGenericText(
              //                   text: "Google Pay",
              //                   fontSize: sizes!.isPhone ? 16 : 14,
              //                   fontWeight: FontWeight.w400,
              //                   color: AppColors.whiteColor,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ],
            
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
