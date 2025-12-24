import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../sharedProviders/providers/direct_transfer/direct_transfer_provider.dart';
import '../../sharedProviders/providers/states/direct_transfer/direct_transfer_states.dart';
import '../../widgets/shimmers/shimmer_loader.dart';
import '../../widgets/text_form_field.dart';

class BankDetailsScreen extends ConsumerStatefulWidget {
  final String bankId;

  const BankDetailsScreen({
    super.key,
    required this.bankId,
  });

  @override
  ConsumerState createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final fabIbanController = TextEditingController();
  final fabSwiftController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Trigger API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(directTransferProvider.notifier)
          .getBankDetailById(widget.bankId);
    });
  }

  @override
  void dispose() {
    accountNameController.dispose();
    accountNumberController.dispose();
    fabIbanController.dispose();
    fabSwiftController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// copy to clipboard
  // void _copyToClipboard({required String text}) {
  //   Clipboard.setData(ClipboardData(text: text));
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   const SnackBar(
  //   //     content: Text("Copied to clipboard"),
  //   //     duration: Duration(seconds: 1),
  //   //   ),
  //   // );
  // }
  void _copyToClipboard({required String text, String? label}) {
    Clipboard.setData(ClipboardData(text: text));

    final message = label != null
        ? '$label ${AppLocalizations.of(context)!.saved_to_clipboard}'
        : AppLocalizations.of(context)!.copied_to_clipboard;

    if (Platform.isIOS) {
      Toasts.getSuccessToast(
        text: message,
        gravity: ToastGravity.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    final state = ref.watch(directTransferProvider);

    // Move the ref.listen to the build method
    ref.listen<DirectTransferState>(directTransferProvider, (prev, next) {
      final bank = next.bankDetailResponse?.payload;
      if (bank != null) {
        accountNameController.text = bank.bank!.accountName ?? '';
        accountNumberController.text = bank.bank!.accountNumber ?? '';
        fabIbanController.text = bank.bank!.iban ?? '';
        fabSwiftController.text = bank.bank!.swiftCode ?? '';
      }
    });

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
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
          )!.account_details, //"Account Details",
          fontSize: sizes!.isPhone ? 18 : 22,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
        actions: [
          Directionality.of(context) == TextDirection.rtl
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () async {
                      _copyToClipboard(
                        text:
                            "${accountNameController.text}, ${accountNumberController.text}, ${fabIbanController.text}, ${fabSwiftController.text}",
                        label: AppLocalizations.of(
                          context,
                        )!.account_details, //"Account Details"
                      );
                    },
                    child: GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.dep_copyDetails, //"Copy Details",
                      fontSize: sizes!.isPhone ? 16 : 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryGold500,
                      isUnderline: true,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () async {
                      _copyToClipboard(
                        text:
                            "${accountNameController.text}, ${accountNumberController.text}, ${fabIbanController.text}, ${fabSwiftController.text}",
                        label: AppLocalizations.of(
                          context,
                        )!.account_details, //"Account Details"
                      );
                    },
                    child: GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.dep_copyDetails, //"Copy Details",
                      fontSize: sizes!.isPhone ? 16 : 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryGold500,
                      isUnderline: true,
                    ),
                  ),
                ),
        ],
      ),
      body: state.isDetailsLoading
          ? Center(
              child: ShimmerLoader(
                loop: 6,
              ).get16HorizontalPadding(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstPadding.sizeBoxWithHeight(height: 15),
                    CommonTextFormField(
                      title: AppLocalizations.of(
                        context,
                      )!.dep_label_accountName, //"Account Name",
                      labelText: AppLocalizations.of(
                        context,
                      )!.dep_label_accountName, //"Account Name",
                      controller: accountNameController,
                      readOnly: true,
                      hintText: "",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(
                            text: accountNameController.text,
                            label: "Name",
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/copy_icon.svg",
                          ),
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 15),
                    CommonTextFormField(
                      title: AppLocalizations.of(
                        context,
                      )!.dep_label_accountNumber, //"Account Number",
                      labelText: AppLocalizations.of(
                        context,
                      )!.dep_label_accountNumber, //"Account Number",
                      controller: accountNumberController,
                      readOnly: true,
                      hintText: "",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(
                            text: accountNumberController.text,
                            label: AppLocalizations.of(
                              context,
                            )!.dep_label_accountNumber, //"Account Number"
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/copy_icon.svg",
                          ),
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 15),
                    CommonTextFormField(
                      title: AppLocalizations.of(
                        context,
                      )!.dep_label_iban, //"IBAN Number",
                      labelText: AppLocalizations.of(
                        context,
                      )!.dep_label_iban, //"IBAN Number",
                      controller: fabIbanController,
                      readOnly: true,
                      hintText: "",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(
                            text: fabIbanController.text,
                            label: AppLocalizations.of(
                              context,
                            )!.dep_label_iban, //"IBAN Number"
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/copy_icon.svg",
                          ),
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 15),
                    CommonTextFormField(
                      title: AppLocalizations.of(
                        context,
                      )!.dep_label_swift, //"Swift",
                      labelText: AppLocalizations.of(
                        context,
                      )!.dep_label_swift, //"Swift",
                      controller: fabSwiftController,
                      readOnly: true,
                      hintText: "",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(
                            text: fabSwiftController.text,
                            label: AppLocalizations.of(context)!.swift_code,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/copy_icon.svg",
                          ),
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 25),

                    Container(
                      height: sizes!.heightRatio * 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(95, 86, 68, 0),
                            Color.fromRGBO(95, 86, 68, 1),
                            Color.fromRGBO(197, 179, 141, 0),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 25),

                    /// share receipt
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.dep_share_title, //"Share Receipt",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.dep_share_desc,
                      //"Choose any of the options below to share the receipt once you’ve transferred the funds in Save In Gold FZCO account.",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                      lines: 4,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 12),

                    /// upload receipt
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             const TransactionSuccessScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     width: sizes!.isPhone
                    //         ? sizes!.widthRatio * 360
                    //         : sizes!.width,
                    //     height: sizes!.responsiveLandscapeHeight(
                    //       phoneVal: 50,
                    //       tabletVal: 60,
                    //       tabletLandscapeVal: 70,
                    //       isLandscape: sizes!.isLandscape(),
                    //     ),
                    //     decoration: ShapeDecoration(
                    //       gradient: LinearGradient(
                    //         begin: Alignment(1.00, 0.01),
                    //         end: Alignment(-1, -0.01),
                    //         colors: [
                    //           Color(0xFF675A3D),
                    //           Color(0xFFBBA473),
                    //         ],
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         SvgPicture.asset(
                    //           "assets/svg/export.svg",
                    //           height: sizes!.heightRatio *
                    //               (sizes!.isPhone
                    //                   ? 22
                    //                   : (sizes!.isLandscape() ? 32 : 20)),
                    //           width: sizes!.widthRatio *
                    //               (sizes!.isPhone
                    //                   ? 22
                    //                   : (sizes!.isLandscape() ? 32 : 20)),
                    //         ),
                    //         ConstPadding.sizeBoxWithWidth(width: 10),
                    //         GetGenericText(
                    //           text: "Upload Receipt",
                    //           fontSize: sizes!.responsiveFont(
                    //             phoneVal: 18,
                    //             tabletVal: 20,
                    //           ),
                    //           fontWeight: FontWeight.w500,
                    //           color: Colors.white,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // ConstPadding.sizeBoxWithHeight(height: 16),

                    /// share on whatsapp
                    GestureDetector(
                      onTap: () async {
                        final message = AppLocalizations.of(
                          context,
                        )!.whatsapp_inbox;
                        //"Hi Save In Gold Sales Team, \n\nTo confirm and process your payment, please attach a copy of the payment receipt to this WhatsApp message. \n\nThis will help us verify the transaction and update your account accordingly.\nYou can simply reply to this email with the receipt attached. If you have any questions or concerns, feel free to reach out to us.\n\nRegards,\nSave In Gold Team.";

                        /// launch whatsapp
                        await CommonService.openWhatsappUrl(
                          phoneNumber: "+971504971269",
                          message: message,
                        );
                      },
                      child: Container(
                        width: sizes!.isPhone
                            ? sizes!.widthRatio * 360
                            : sizes!.width,
                        height: sizes!.responsiveLandscapeHeight(
                          phoneVal: 50,
                          tabletVal: 60,
                          tabletLandscapeVal: 70,
                          isLandscape: sizes!.isLandscape(),
                        ),
                        decoration: BoxDecoration(
                          color: Color(0x33BBA473),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.50,
                            color: Color(0xFFBBA473),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/whatsapp_icon.svg",
                              color: Colors.white,
                              height:
                                  sizes!.heightRatio *
                                  (sizes!.isPhone
                                      ? 22
                                      : (sizes!.isLandscape() ? 32 : 20)),
                              width:
                                  sizes!.widthRatio *
                                  (sizes!.isPhone
                                      ? 22
                                      : (sizes!.isLandscape() ? 32 : 20)),
                            ),
                            ConstPadding.sizeBoxWithWidth(width: 10),
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.dep_share_whatsapp, //"Share on Whatsapp",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 18,
                                tabletVal: 20,
                              ), //16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),

                    /// send via email
                    GestureDetector(
                      onTap: () async {
                        final body = AppLocalizations.of(
                          context,
                        )!.email_message;
                        //"Hi Save In Gold Sales Team, \n\nTo confirm and process your payment, please attach a copy of the payment receipt to this email. \n\nThis will help us verify the transaction and update your account accordingly.\nYou can simply reply to this email with the receipt attached. If you have any questions or concerns, feel free to reach out to us.\n\nRegards,\nSave In Gold Team.";
                        // Send via email
                        await CommonService.openEmailApp(
                          emailAddress: "info@saveingold.ae",
                          subject: AppLocalizations.of(
                            context,
                          )!.email_url_title, //"Direct Bank Transfer Payment Receipt",
                          body: body,
                        );
                      },
                      child: Container(
                        width: sizes!.isPhone
                            ? sizes!.widthRatio * 360
                            : sizes!.width,
                        height: sizes!.responsiveLandscapeHeight(
                          phoneVal: 50,
                          tabletVal: 60,
                          tabletLandscapeVal: 70,
                          isLandscape: sizes!.isLandscape(),
                        ),
                        decoration: BoxDecoration(
                          color: Color(0x33BBA473),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.50,
                            color: Color(0xFFBBA473),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/sms.svg",
                              height:
                                  sizes!.heightRatio *
                                  (sizes!.isPhone
                                      ? 22
                                      : (sizes!.isLandscape() ? 32 : 20)),
                              width:
                                  sizes!.widthRatio *
                                  (sizes!.isPhone
                                      ? 22
                                      : (sizes!.isLandscape() ? 32 : 20)),
                            ),
                            ConstPadding.sizeBoxWithWidth(width: 10),
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.dep_share_email, //"Send via Email",
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 18,
                                tabletVal: 20,
                              ),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).get16HorizontalPadding(),
              ),
            ),
    );
  }
}
