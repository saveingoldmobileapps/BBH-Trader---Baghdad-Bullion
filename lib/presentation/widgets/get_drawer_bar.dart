import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/esouq_screens/esouq_screen.dart';
import 'package:saveingold_fzco/presentation/screens/gift_fund_screens/gift_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/my_order_screens/my_order_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/support_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/demo_account_popup.dart'
    show UpgradeAccountPopup;
import 'package:saveingold_fzco/presentation/widgets/profile_image.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../data/data_sources/local_database/local_database.dart';
import '../screens/alerts/view_alerts.dart';
import '../screens/fund_screens/add_fund_screen.dart';
import '../screens/withdraw_fund_screens/withdrawal_fund_screen.dart';
import '../sharedProviders/providers/auth_provider.dart';

class GetDrawerBar extends ConsumerWidget {
  final VoidCallback onTap;

  const GetDrawerBar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mainStateWatchProvider = ref.watch(homeProvider);
    final authStateReadProvider = ref.read(authProvider.notifier);
    return SizedBox(
      width: sizes!.isPhone ? null : sizes!.width / 2,
      child: Drawer(
        child: Container(
          decoration: Directionality.of(context) == TextDirection.rtl
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1, -0.01),
                    end: Alignment(1.00, 0.01),
                    colors: [
                      Color(0xFFBBA473),
                      Color(0xFF675A3D),
                    ],
                  ),
                )
              : BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1.00, 0.01),
                    end: Alignment(-1, -0.01),
                    colors: [
                      Color(0xFF675A3D),
                      Color(0xFFBBA473),
                    ],
                  ),
                ),
          child: SafeArea(
            child: Padding(
              padding: Directionality.of(context) == TextDirection.rtl
                  ? EdgeInsets.only(
                      top: sizes!.heightRatio * 16.0,
                      right: sizes!.widthRatio * 16.0,
                    )
                  : EdgeInsets.only(
                      top: sizes!.heightRatio * 16.0,
                      left: sizes!.widthRatio * 16.0,
                    ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder<String?>(
                          future: LocalDatabase.instance.getUserProfileImage(),
                          builder: (context, snapshot) {
                            final cachedImage = snapshot.data ?? '';

                            final networkImage =
                                mainStateWatchProvider
                                    .getUserProfileResponse
                                    .payload
                                    ?.userProfile
                                    ?.imageUrl ??
                                '';

                            final imageToShow = (networkImage.isNotEmpty)
                                ? networkImage
                                : cachedImage;

                            final displayWidget = DisplayImage(
                              imagePath: imageToShow,
                              onImageSelected: (file) async {
                                if (file != null) {
                                  debugPrint("Picked: ${file.path}");
                                  await authStateReadProvider
                                      .uploadProfileImage(
                                        filePath: file.path,
                                        context: context,
                                      );
                                  ref
                                      .read(homeProvider.notifier)
                                      .getUserProfile();
                                }
                              },
                            );

                            return Directionality.of(context) ==
                                    TextDirection.rtl
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: displayWidget.getAlignRight(),
                                  )
                                : displayWidget.getAlign();
                          },
                        ),

                        // Directionality.of(context) == TextDirection.rtl
                        //     ? Padding(
                        //         padding: const EdgeInsets.only(right: 12.0),
                        //         child: DisplayImage(
                        //           imagePath:
                        //               mainStateWatchProvider
                        //                   .getUserProfileResponse
                        //                   .payload
                        //                   ?.userProfile
                        //                   ?.imageUrl ??
                        //               '',
                        //           onImageSelected: (file) {
                        //             if (file != null) {
                        //               debugPrint("Picked: ${file.path}");
                        //               authStateReadProvider.uploadProfileImage(
                        //                 filePath: file.path,
                        //                 context: context,
                        //               );
                        //             }
                        //           },
                        //         ).getAlignRight(),
                        //       )
                        //     : DisplayImage(
                        //         imagePath:
                        //             mainStateWatchProvider
                        //                 .getUserProfileResponse
                        //                 .payload
                        //                 ?.userProfile
                        //                 ?.imageUrl ??
                        //             '',
                        //         onImageSelected: (file) {
                        //           if (file != null) {
                        //             debugPrint("Picked: ${file.path}");
                        //             authStateReadProvider.uploadProfileImage(
                        //               filePath: file.path,
                        //               context: context,
                        //             );
                        //           }
                        //         },
                        //       ).getAlign(),
                        ConstPadding.sizeBoxWithWidth(width: 4.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<List<String?>>(
                              future: Future.wait([
                                LocalDatabase.instance.getUserName(),
                                LocalDatabase.instance.getUserAccountId(),
                              ]),
                              builder: (context, snapshot) {
                                final cachedName = snapshot.data?[0] ?? '';
                                final cachedId = snapshot.data?[1] ?? '';

                                final networkName =
                                    mainStateWatchProvider
                                        .getUserProfileResponse
                                        .payload
                                        ?.userProfile
                                        ?.firstName
                                        ?.en ??
                                    '';

                                final networkId =
                                    mainStateWatchProvider
                                        .getUserProfileResponse
                                        .payload
                                        ?.userProfile
                                        ?.accountId ??
                                    '';

                                final finalName = networkName.isNotEmpty
                                    ? networkName
                                    : cachedName;

                                final finalAccountId = networkId.isNotEmpty
                                    ? networkId
                                    : cachedId;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GetGenericText(
                                      text: finalName,
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.greyScale1000,
                                    ),
                                    GetGenericText(
                                      text: finalAccountId,
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.greyScale1000,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              "assets/svg/menu_close.svg",
                              height:
                                  sizes!.heightRatio *
                                  (sizes!.isPhone ? 24 : 32),
                              width:
                                  sizes!.widthRatio *
                                  (sizes!.isPhone ? 24 : 32),
                            ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithWidth(width: 12),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 10),

                    /// Account Details
                    GestureDetector(
                      onTap: () {
                        var userDetails =
                            "Account: ${mainStateWatchProvider.getUserProfileResponse.payload!.userProfile!.accountId}\nFull Name: ${mainStateWatchProvider.getUserProfileResponse.payload!.userProfile!.firstName!.en} ${mainStateWatchProvider.getUserProfileResponse.payload!.userProfile!.surname!.en}\nEmail: ${mainStateWatchProvider.userEmail}";

                        _copyToClipboard(
                          context: context,
                          text: userDetails,
                          label: AppLocalizations.of(context)!.account_detail,//"Account Detail",
                          rtl: Directionality.of(context) == TextDirection.rtl,
                        );
                      },
                      child: Row(
                        children: [
                          Directionality.of(context) == TextDirection.rtl
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: SvgPicture.asset(
                                    "assets/svg/click_copy_icon.svg",
                                    height: sizes!.heightRatio * 16,
                                    width: sizes!.widthRatio * 16,
                                  ).getAlignRight(),
                                )
                              : SvgPicture.asset(
                                  "assets/svg/click_copy_icon.svg",
                                  height: sizes!.heightRatio * 16,
                                  width: sizes!.widthRatio * 16,
                                ).getAlign(),
                          ConstPadding.sizeBoxWithWidth(width: 4),
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.account_details, //"Account Details",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyScale1000,
                            isUnderline: true,
                          ),
                        ],
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    //Deposit Funds
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.deposit_funds, //"Deposit Funds",
                      icon: "assets/svg/fund_icon.svg",
                      onTap: () async {
                        //If email not verified.
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;

                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;

                        if (isDemo) {
                          if (!context.mounted) return;
                          await UpgradeAccountPopup.show(
                            context: context,
                            ref: ref,
                          );
                          return;
                        }

                        if (!isEmailVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.email_verification_required, //"Email Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.email_verification_msg,
                            //"To continue, please verify your email address. Do you want to verify now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_cancel_btn, //"Cancel",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_verify_btn, //"Verify",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerifyCodeScreen(
                                    email: mainStateWatchProvider.userEmail,
                                  ),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        //if email verified and Residency documents not verified.
                        if (isEmailVerified && !isUserBasicKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.residency_document_required, //"Residency Document Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"To continue, please complete your residency document verification. Would you like to proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycFirstStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        //if email and residency document verified and kyc not verified
                        if (isEmailVerified &&
                            isUserBasicKycVerified &&
                            !isUserKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.kyc_verification_required, //"KYC Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"To continue, please complete your KYC verification. Would you like to proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycSecondStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // If all verifications are complete
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddFundScreen(),
                          ),
                        );
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.withdraw_requests, //"Withdraw Requests",
                      icon: "assets/svg/withdraw_icon.svg",
                      onTap: () async {
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;
                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;

                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;
                        if (isDemo) {
                          if (!context.mounted) return;
                          await UpgradeAccountPopup.show(
                            context: context,
                            ref: ref,
                          );
                          return;
                        }
                        final temporaryCreditStatus = await LocalDatabase.instance.getIsUsertemporaryCreditStatus() ?? false;

                        //temporary credit
                        if (temporaryCreditStatus) {
                          if (!context.mounted) return;

                          await temporaryCreditPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.temporary_credit_title,
                            subtitle: AppLocalizations.of(
                              context,
                            )!.temperory_credit_detect,
                            buttonTitle: AppLocalizations.of(
                              context,
                            )!.temporary_credit_contact_support,
                            icon: Icons.account_balance_wallet_outlined,//Icons.card_giftcard, 
                            onButtonPress: () {
                              Navigator.pop(context);

                              ///  Navigate to Support Screen (customizable)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SupportScreen(),
                                ),
                              );
                            },
                            oncloseButtonPress:() {
                               Navigator.pop(context);
                            }
                          );
                          return;
                        }
                        // Email not verified
                        if (!isEmailVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.email_verification_required, //"Email Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.email_verification_msg,
                            //"To continue, please verify your email address. Do you want to verify now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_cancel_btn, //"Cancel",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_verify_btn, //"Verify",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerifyCodeScreen(
                                    email: mainStateWatchProvider.userEmail,
                                  ),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        // Email verified but Residency Document not verified
                        if (isEmailVerified && !isUserBasicKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.residency_document_required, //"Residency Document Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"You must complete Residency Document verification first. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycFirstStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // Email and Residency verified but KYC not verified
                        if (isEmailVerified &&
                            isUserBasicKycVerified &&
                            !isUserKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.kyc_verification_required, //"KYC Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.kyc_verification_message, //"You must complete KYC verification to continue. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycSecondStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        if (!context.mounted) return;
                        // All verifications passed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WithdrawalFundScreen(),
                          ),
                        );
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.alert_title, //"Alert",
                      icon: "assets/svg/notify_icon.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActiveAlertsScreen(),
                          ),
                        );
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: //"E-Souq Order",
                      AppLocalizations.of(
                        context,
                      )!.my_orders, //"My Orders",
                      icon: "assets/svg/order_icon.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.esouq, //"Esouq",
                      icon: "assets/svg/bag_icon.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EsouqScreen(),
                          ),
                        );
                      },
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.gift, //"Gift",
                      icon: "assets/svg/gift_icon.svg",
                      onTap: () async {
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;
                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;

                        final temporaryCreditStatus =
                            await LocalDatabase.instance
                                .getIsUsertemporaryCreditStatus() ??
                            false;

                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;
                        if (isDemo) {
                          if (!context.mounted) return;
                          await UpgradeAccountPopup.show(
                            context: context,
                            ref: ref,
                          );
                          return;
                        }

                        //temporaryCreditStatus
                        if (temporaryCreditStatus) {
                          if (!context.mounted) return;

                          await temporaryCreditPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.temporary_credit_title,
                            subtitle: AppLocalizations.of(
                              context,
                            )!.temporary_credit_message,
                            buttonTitle: AppLocalizations.of(
                              context,
                            )!.temporary_credit_contact_support,
                            icon: Icons.card_giftcard,//Icons.card_giftcard, 
                            onButtonPress: () {
                              Navigator.pop(context);

                              /// 👉 Navigate to Support Screen (customizable)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SupportScreen(),
                                ),
                              );
                            },
                            oncloseButtonPress:() {
                               Navigator.pop(context);
                            }
                          );
                          return;
                        }

                        // Email not verified
                        if (!isEmailVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.email_verification_required, //"Email Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.email_verification_msg,
                            //"To continue, please verify your email address. Do you want to verify now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_cancel_btn, //"Cancel",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_verify_btn, //"Verify",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerifyCodeScreen(
                                    email: mainStateWatchProvider.userEmail,
                                  ),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        // Email verified but Residency Document not verified
                        if (isEmailVerified && !isUserBasicKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.residency_document_required, //"Residency Document Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"You must complete Residency Document verification first. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycFirstStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // Email and Residency verified but KYC not verified
                        if (isEmailVerified &&
                            isUserBasicKycVerified &&
                            !isUserKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.kyc_verification_required, //"KYC Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.kyc_verification_message,
                            //"You must complete KYC verification to continue. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycSecondStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        // All verifications passed
                        if (mainStateWatchProvider
                                .getHomeFeedResponse
                                .payload !=
                            null) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftFundScreen(
                                walletExists: mainStateWatchProvider
                                    .getHomeFeedResponse
                                    .payload!
                                    .walletExists!,
                              ),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          await ref
                              .read(homeProvider.notifier)
                              .getHomeFeed(context: context, showLoading: true);

                          final updatedPayload = ref
                              .read(homeProvider)
                              .getHomeFeedResponse
                              .payload;

                          if (updatedPayload != null) {
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftFundScreen(
                                  walletExists: updatedPayload.walletExists!,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),

                    // ConstPadding.sizeBoxWithHeight(height: 8),
                    // MenuItemCard(
                    //   title: "Request Advance",
                    //   icon: "assets/svg/loan_icon.svg",
                    //   onTap: () async {
                    //     final isEmailVerified =
                    //         await LocalDatabase.instance.getIsEmailVerified() ??
                    //         false;
                    //     final isUserBasicKycVerified =
                    //         await LocalDatabase.instance
                    //             .getIsUserBasicKycVerified() ??
                    //         false;
                    //     final isUserKycVerified =
                    //         await LocalDatabase.instance
                    //             .getIsUserBasicKycVerified() ??
                    //         false;
                    //     // Email not verified
                    //     if (!isEmailVerified) {
                    //       if (!context.mounted) return;
                    //       await genericPopUpWidget(
                    //         isLoadingState: false,
                    //         context: context,
                    //         heading: "Email Verification Required",
                    //         subtitle:
                    //             "You must verify your email first. Do you want to verify now?",
                    //         noButtonTitle: "Cancel",
                    //         yesButtonTitle: "Verify",
                    //         onNoPress: () async {
                    //           Navigator.pop(context);
                    //         },
                    //         onYesPress: () async {
                    //           Navigator.pop(context);
                    //           await Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => EmailVerifyCodeScreen(
                    //                 email: mainStateWatchProvider.userEmail,
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //       return;
                    //     }
                    //     // Email verified but Residency Document not verified
                    //     if (isEmailVerified && !isUserBasicKycVerified) {
                    //       if (!context.mounted) return;
                    //       await genericPopUpWidget(
                    //         isLoadingState: false,
                    //         context: context,
                    //         heading: "Residency Document Required",
                    //         subtitle:
                    //             "You must complete Residency Document verification first. Proceed now?",
                    //         noButtonTitle: "Later",
                    //         yesButtonTitle: "Proceed",
                    //         onNoPress: () async {
                    //           Navigator.pop(context);
                    //         },
                    //         onYesPress: () async {
                    //           Navigator.pop(context);
                    //           await Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => KycFirstStepScreen(),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //       return;
                    //     }
                    //
                    //     // Email and Residency verified but KYC not verified
                    //     if (isEmailVerified &&
                    //         isUserBasicKycVerified &&
                    //         !isUserKycVerified) {
                    //       await genericPopUpWidget(
                    //         isLoadingState: false,
                    //         context: context,
                    //         heading: "KYC Verification Required",
                    //         subtitle:
                    //             "You must complete KYC verification to continue. Proceed now?",
                    //         noButtonTitle: "Later",
                    //         yesButtonTitle: "Proceed",
                    //         onNoPress: () async {
                    //           Navigator.pop(context);
                    //         },
                    //         onYesPress: () async {
                    //           Navigator.pop(context);
                    //           await Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => KycSecondStepScreen(),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //       return;
                    //     }
                    //
                    //     // All verifications passed
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const LoanRequestScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(context)!.support, //"Support",
                      icon: "assets/svg/support_icon.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                    //ConstPadding.sizeBoxWithHeight(height: 8),
                    // MenuItemCard(
                    //   title: AppLocalizations.of(context)!.chart, ////"Chart",
                    //   icon: "assets/svg/chart_icon.svg",
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => GoldPriceChartPage(),
                    //       ),
                    //     );
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) => const NewChartScreen(),
                    //     //   ),
                    //     // );
                    //   },
                    // ),
                    ConstPadding.sizeBoxWithHeight(height: 8),
                    MenuItemCard(
                      title: AppLocalizations.of(
                        context,
                      )!.settings, ////"Settings",
                      icon: "assets/svg/setting_icon.svg",
                      onTap: () async {
                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;
                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        // Email not verified
                        // if (!isEmailVerified) {
                        //   if (!context.mounted) return;
                        //   await genericPopUpWidget(
                        //     isLoadingState: false,
                        //     context: context,
                        //     heading: "Email Verification Required",
                        //     subtitle:
                        //         "You must verify your email first. Do you want to verify now?",
                        //     noButtonTitle: "Cancel",
                        //     yesButtonTitle: "Verify",
                        //     onNoPress: () async {
                        //       Navigator.pop(context);
                        //     },
                        //     onYesPress: () async {
                        //       Navigator.pop(context);
                        //       await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => EmailVerifyCodeScreen(
                        //             email: mainStateWatchProvider.userEmail,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   );
                        //   return;
                        // }
                        // Email verified but Residency Document not verified
                        // if (!isDemo &&
                        //     isEmailVerified &&
                        //     !isUserBasicKycVerified) {
                        //   if (!context.mounted) return;
                        //   await genericPopUpWidget(
                        //     isLoadingState: false,
                        //     context: context,
                        //     heading: "Residency Document Required",
                        //     subtitle:
                        //         "You must complete Residency Document verification first. Proceed now?",
                        //     noButtonTitle: "Later",
                        //     yesButtonTitle: "Proceed",
                        //     onNoPress: () async {
                        //       Navigator.pop(context);
                        //     },
                        //     onYesPress: () async {
                        //       Navigator.pop(context);
                        //       await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => KycFirstStepScreen(),
                        //         ),
                        //       );
                        //     },
                        //   );
                        //   return;
                        // }

                        // Email and Residency verified but KYC not verified
                        // if (!isDemo &&
                        //     isEmailVerified &&
                        //     isUserBasicKycVerified &&
                        //     !isUserKycVerified) {
                        //   if (!context.mounted) return;
                        //   await genericPopUpWidget(
                        //     isLoadingState: false,
                        //     context: context,
                        //     heading: "KYC Verification Required",
                        //     subtitle:
                        //         "You must complete KYC verification to continue. Proceed now?",
                        //     noButtonTitle: "Later",
                        //     yesButtonTitle: "Proceed",bu
                        //     onNoPress: () async {
                        //       Navigator.pop(context);
                        //     },
                        //     onYesPress: () async {
                        //       Navigator.pop(context);
                        //       await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => KycSecondStepScreen(),
                        //         ),
                        //       );
                        //     },
                        //   );
                        //   return;
                        // }
                        if (!context.mounted) return;
                        // All verifications passed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                    // onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const SettingScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                    MenuItemCard(
                      title: AppLocalizations.of(context)!.logout, //"Logout",
                      icon: "assets/svg/logout_icon.svg",
                      onTap: () async {
                        final userId = await LocalDatabase.instance
                            .getUserId(); // pre-fetch here

                        if (!context.mounted) return;
                        await genericPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(
                            context,
                          )!.logout_popup_title, //"Are you sure you want to logout?",
                          subtitle: AppLocalizations.of(
                            context,
                          )!.logout_popup_desc, //"You will be logged out of your account.",
                          noButtonTitle: AppLocalizations.of(
                            context,
                          )!.logout_no, //"NO",
                          yesButtonTitle: AppLocalizations.of(
                            context,
                          )!.logout_yes, //"YES",
                          isLoadingState: false,
                          onNoPress: () {
                            Navigator.pop(context);
                          },
                          onYesPress: () async {
                            await authStateReadProvider.logoutUser(
                              context: context,
                              userId: userId!,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// copy to clipboard
  void _copyToClipboard({
    required BuildContext context,
    required String text,
    String? label,
    bool? rtl,
  }) {
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

  // void _copyToClipboard({required String text, String? label}) {
  //   Clipboard.setData(ClipboardData(text: text));
  //   final message = label != null
  //       ? '$label Saved to clipboard'
  //       : 'Copied to clipboard';

  //   if (Platform.isIOS) {
  //     Toasts.getSuccessToast(
  //       text: message,
  //       gravity: ToastGravity.TOP,
  //     );
  //   }
  // }
}
