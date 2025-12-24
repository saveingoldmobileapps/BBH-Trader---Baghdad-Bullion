import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.customer_support_title,//"Customer Support",
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
          child: Column(
            children: [
              ConstPadding.sizeBoxWithHeight(height: 24),

              /// Live chat section
              Directionality.of(context) == TextDirection.rtl?
              Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/live_chat_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.email_us_title,//"Email Us",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      //sizes!.isPhone ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                      AppLocalizations.of(context)!.email_us_desc,
                          //"Need instant help? Start an Email Us with our team, available 24/7!",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openEmailApp(
                          emailAddress: "info@saveingold.ae",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.email_now,//"Email Now",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlignRight():
              Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/live_chat_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.email_us_title,//"Email Us",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      //sizes!.isPhone ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                      AppLocalizations.of(context)!.email_us_desc,
                          //"Need instant help? Start an Email Us with our team, available 24/7!",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openEmailApp(
                          emailAddress: "info@saveingold.ae",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.email_now,//"Email Now",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlign(),
              ConstPadding.sizeBoxWithHeight(height: 16),
              Divider(
                color: AppColors.greyScale900,
                thickness: 1.5,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),

              /// Call us section
              
             Directionality.of(context) == TextDirection.rtl?
              Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/call_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.call_us_title,//"Call Us",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                        AppLocalizations.of(context)!.call_us_desc,
                          //"Speak directly with one of our support representatives, available Monday to Friday, 9:00 AM - 6:00 PM (Your Time Zone).",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                      lines: 4,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openCallingUrl(
                          phoneNumber: "+971504971269",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.call_now,//"Call Now",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlignRight()
              : Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/call_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.call_us_title,//"Call Us",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                        AppLocalizations.of(context)!.call_us_desc,
                          //"Speak directly with one of our support representatives, available Monday to Friday, 9:00 AM - 6:00 PM (Your Time Zone).",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                      lines: 4,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openCallingUrl(
                          phoneNumber: "+971504971269",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.call_now,//"Call Now",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlign(),
              
              ConstPadding.sizeBoxWithHeight(height: 16),
              Divider(
                color: AppColors.greyScale900,
                thickness: 1.5,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),

              /// WhatsApp
              Directionality.of(context) == TextDirection.rtl?
              Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/whatsapp_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.whatsapp_title,//"Whatsapp",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                         AppLocalizations.of(context)!.whatsapp_desc,
                          //"Message us on WhatsApp for quick and easy support, available 24/7.",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                      lines: 4,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),

                    /// Whatsapp button
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openWhatsappUrl(
                          phoneNumber: "+971504971269",
                          message:
                              "Hello, I need an assistance from Save in Gold Team",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.message_on_whatsapp,//"Message on Whatsapp",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlignRight():
            
              Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/whatsapp_icon.svg",
                      height: sizes!.responsiveHeight(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                      width: sizes!.responsiveWidth(
                        phoneVal: 24,
                        tabletVal: 32,
                      ),
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text: AppLocalizations.of(context)!.whatsapp_title,//"Whatsapp",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey5Color,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),
                    GetGenericText(
                      text:
                         AppLocalizations.of(context)!.whatsapp_desc,
                          //"Message us on WhatsApp for quick and easy support, available 24/7.",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey3Color,
                      lines: 4,
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 4),

                    /// Whatsapp button
                    GestureDetector(
                      onTap: () async {
                        await CommonService.openWhatsappUrl(
                          phoneNumber: "+971504971269",
                          message:
                              "Hello, I need an assistance from Save in Gold Team",
                        );
                      },
                      child: GetGenericText(
                        text: AppLocalizations.of(context)!.message_on_whatsapp,//"Message on Whatsapp",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGold500,
                        isUnderline: true,
                      ),
                    ),
                  ],
                ),
              ).getAlign(),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
