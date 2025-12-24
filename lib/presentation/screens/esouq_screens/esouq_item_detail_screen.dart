import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_first_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/kyc_second_step_screen.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/support_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';

import '../../../data/models/esouq_model/GetAllProductResponse.dart';
import 'esouq_cart_screen.dart';

class EsouqItemDetailScreen extends ConsumerStatefulWidget {
  final AllProducts product;
  final String productPrice;
  final String oneGramPriceInAED;

  const EsouqItemDetailScreen({
    super.key,
    required this.product,
    required this.productPrice,
    required this.oneGramPriceInAED,
  });

  @override
  ConsumerState createState() => _EsouqItemDetailScreenState();
}

class _EsouqItemDetailScreenState extends ConsumerState<EsouqItemDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).getUserProfile();
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(context: context, showLoading: true);
    });
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

  Widget _buildImageGallery() {
    final images = widget.product.imageUrl ?? [];

    if (images.isEmpty) {
      return Container(
        color: AppColors.primaryGold500,
        child: Center(
          child: Icon(Icons.image, size: 50, color: Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: Colors.white,
              ),
            );
          },
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainStateWatchProvider = ref.watch(homeProvider);
    final isDemo = LocalDatabase.instance.getIsDemo() ?? false;

    final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);

    final oneGramBuyingPriceInAED =
        goldPriceStateWatchProvider.value?.oneGramBuyingPriceInAED ?? 0.0;

    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: GestureDetector(
          onTap: () async {
            // If email is not verified
            if (!mainStateWatchProvider.isEmailVerified) {
              await genericPopUpWidget(
                isLoadingState: false,
                context: context,
                heading: AppLocalizations.of(
                  context,
                )!.email_verification_required, //"Email Verification Required",
                subtitle: AppLocalizations.of(
                  context,
                )!.email_verification_message,
                //"To continue, please verify your email address. Do you want to verify now?",
                noButtonTitle: AppLocalizations.of(context)!.cancel, //"Cancel",
                yesButtonTitle: AppLocalizations.of(
                  context,
                )!.verify, //"Verify",
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

            // First check if context is mounted
            if (!context.mounted) return;

            // Get demo status properly with await
            final isDemo = await LocalDatabase.instance.getIsDemo() ?? false;

            // If residency document is not verified
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
                )!.temperory_credit_detect_esouq,
                buttonTitle: AppLocalizations.of(
                  context,
                )!.temporary_credit_contact_support,
                icon: Icons
                    .account_balance_wallet_outlined, //Icons.card_giftcard,
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
                oncloseButtonPress: () {
                   Navigator.pop(context);
                },
              );
              return;
            }
            if (!isDemo &&
                mainStateWatchProvider.isEmailVerified &&
                !mainStateWatchProvider.isBasicUserVerified) {
              await genericPopUpWidget(
                isLoadingState: false,
                context: context,
                heading: AppLocalizations.of(
                  context,
                )!.residency_document_required, //"Residency Document Required",
                subtitle: AppLocalizations.of(
                  context,
                )!.residency_verification_message,
                //"To continue, please complete your residency document verification. Would you like to proceed now?",
                noButtonTitle: AppLocalizations.of(context)!.later, //"Later",
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

            // If KYC is not verified
            if (!isDemo &&
                mainStateWatchProvider.isEmailVerified &&
                mainStateWatchProvider.isBasicUserVerified &&
                !mainStateWatchProvider.isUserKYCVerified) {
              await genericPopUpWidget(
                isLoadingState: false,
                context: context,
                heading: AppLocalizations.of(
                  context,
                )!.kyc_verification_required, //"KYC Verification Required",
                subtitle: AppLocalizations.of(
                  context,
                )!.kyc_verification_message,
                //"To continue, please complete your KYC verification. Would you like to proceed now?",
                noButtonTitle: AppLocalizations.of(context)!.later, //"Later",
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

            // All verifications passed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EsouqCartScreen(
                  product: widget.product,
                  productPrice: widget.productPrice,
                  oneGramPriceInAED: widget.oneGramPriceInAED,
                ),
              ),
            );
          },
          child: Container(
            width: sizes!.isPhone ? sizes!.widthRatio * 325 : sizes!.width - 40,
            height: sizes!.responsiveLandscapeHeight(
              phoneVal: 50,
              tabletVal: 56,
              tabletLandscapeVal: 72,
              isLandscape: sizes!.isLandscape(),
            ),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(1.00, 0.01),
                end: Alignment(-1, -0.01),
                colors: [
                  Color(0xFFBBA473),
                  Color(0xFF675A3D),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Center(
              child: GetGenericText(
                text: AppLocalizations.of(context)!.buy_now, //"Buy Now",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 18,
                  tabletVal: 20,
                ),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: GetGenericText(
          text: "",
          fontSize: 24,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: sizes!.width,
                  // height: sizes!.heightRatio * 258,
                  height: sizes!.responsiveLandscapeHeight(
                    phoneVal: 258,
                    tabletVal: 320,
                    tabletLandscapeVal: 350,
                    isLandscape: sizes!.isLandscape(),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImageGallery(),

                    // borderRadius: BorderRadius.circular(20),
                    // child: CachedNetworkImage(
                    //   imageUrl: widget.product.imageUrl!,
                    //   fit: BoxFit.cover,
                    //   placeholder: (context, url) => SizedBox(
                    //     height: sizes!.heightRatio * 20,
                    //     width: sizes!.widthRatio * 20,
                    //     child: Center(
                    //       child: CircularProgressIndicator(
                    //         color: Colors.white,
                    //         strokeWidth: 2,
                    //       ),
                    //     ),
                    //   ),
                    //   errorWidget: (context, url, error) => Icon(Icons.error),
                    // ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: widget.product.productName?.toUpperCase() ?? "",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),

                    // add to cart
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Container(
                    //     color: Colors.transparent,
                    //     child: SvgPicture.asset(
                    //       "assets/svg/add_cart_icon.svg",
                    //       height: sizes!.heightRatio *
                    //           (sizes!.isPhone
                    //               ? 24
                    //               : (sizes!.isLandscape() ? 32 : 24)),
                    //       width: sizes!.widthRatio *
                    //           (sizes!.isPhone
                    //               ? 24
                    //               : (sizes!.isLandscape() ? 32 : 24)),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 2),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text:
                            "${oneGramBuyingPriceInAED.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 20,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ).getAlignRight()
                    : GetGenericText(
                        text:
                            "${oneGramBuyingPriceInAED.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 20,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 16),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.features, //"Features",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.features, //"Features",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.productCode, //"Product Code",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.productCode ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.purity, //"Purity",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.purity ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.brand, //"Brand",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.brand ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.weight, //"Weight",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text:
                          "${widget.product.weight ?? ""} ${widget.product.weightCategory ?? ""}",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.weightCategory, //"Weight Category",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.weightCategory ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.condition, //"Condition",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.condition ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.origin, //"Origin",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.origin ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.dimensions, //"Dimensions",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.dimensions ?? "",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.inStoreCollection, //"In Store Collection",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.inStoreCollection == true
                          ? AppLocalizations.of(context)!
                                .yes //"Yes"
                          : AppLocalizations.of(context)!.no, //"No",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.deliveryAvailable, //"Delivery Available",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey2Color,
                    ),
                    GetGenericText(
                      text: widget.product.isAvailable == true
                          ? AppLocalizations.of(context)!.yes
                          : AppLocalizations.of(context)!.no,
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ), //14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey6Color,
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),

                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.description, //"Description",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        //16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.description, //"Description",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        //16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: widget.product.description ?? "",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                        lines: 20,
                      ).getAlignRight()
                    : GetGenericText(
                        text: widget.product.description ?? "",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                        lines: 20,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 16),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.shippingDelivery, //"Shipping and Delivery",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        //16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.shippingDelivery, //"Shipping and Delivery",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 16,
                          tabletVal: 18,
                        ),
                        //16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 12),
                Directionality.of(context) == TextDirection.rtl
                    ? SvgPicture.asset(
                        "assets/svg/shop_icon.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ).getAlignRight()
                    : SvgPicture.asset(
                        "assets/svg/shop_icon.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),

                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.inStoreCollection, //"In-Store Collection",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.inStoreCollection, //"In-Store Collection",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.in_store_collection_detail,
                        //"In-store pickup is available for all products. Pickups are available 'Monday to Friday, 11:00 AM to 6:00 PM' (Timezone, Gulf Standard Time). An email confirmation will be sent to you when your order is ready for pickup",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                        lines: 10,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.in_store_collection_detail,
                        //"In-store pickup is available for all products. Pickups are available 'Monday to Friday, 11:00 AM to 6:00 PM' (Timezone, Gulf Standard Time). An email confirmation will be sent to you when your order is ready for pickup",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                        lines: 10,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 12),
                Directionality.of(context) == TextDirection.rtl
                    ? SvgPicture.asset(
                        "assets/svg/shop_icon.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ).getAlignRight()
                    : SvgPicture.asset(
                        "assets/svg/shop_icon.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Directionality.of(context) == TextDirection.rtl
                    ? GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.shippingFees, //"Shipping Fees",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlignRight()
                    : GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.shippingFees, //"Shipping Fees",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        //14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey6Color,
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 4),
                Directionality.of(context) == TextDirection.rtl
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.shipping_fees_detail,
                              //'We offer shipping at the following rates:\nNext day delivery from ',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "${AppLocalizations.of(context)!.monday_to_friday} ${widget.product.deliveryCharges} ${AppLocalizations.of(context)!.aed_currency},", //'Monday to Friday, 11:00 AM to 6:00 PM (Timezone, Gulf Standard Time) will be cost ${widget.product.deliveryCharges} AED. ',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.once_order_ready,
                              //'Once your order is ready, we will send an email with your tracking information.',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), // 14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ).getAlignRight()
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.shipping_fees_detail,
                              // 'We offer shipping at the following rates:\nNext day delivery from ',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${AppLocalizations.of(context)!.monday_to_friday} ${widget.product.deliveryCharges} ${AppLocalizations.of(context)!.aed_currency}. ',
                              // 'Monday to Friday, 11:00 AM to 6:00 PM (Timezone, Gulf Standard Time) will be cost ${widget.product.deliveryCharges} AED. ',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), //14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.once_order_ready, //'Once your order is ready, we will send an email with your tracking information.',
                              style: TextStyle(
                                color: Color(0xFFD1D1D6),
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 14,
                                  tabletVal: 16,
                                ), // 14,
                                fontFamily: GoogleFonts.roboto().fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.delivery_identified_person, //'Delivery to Identified Person: ',
                        style: TextStyle(
                          color: Color(0xFFD1D1D6),
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 14,
                            tabletVal: 16,
                          ), //14,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.customer_have_enter,
                        //'Customer have to enter the correct details of Consignee / Recipient Name (as it is stated in their photo identification that is approved by the Government) with complete Address, nearby landmark, postal code and contact number for hassle free delivery.',
                        style: TextStyle(
                          color: Color(0xFFD1D1D6),
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 14,
                            tabletVal: 16,
                          ), //14,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.delivery_location, //'Delivery Location: ',
                        style: TextStyle(
                          color: Color(0xFFD1D1D6),
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 14,
                            tabletVal: 16,
                          ),
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.order_can_be_delivered, //'Orders can be delivered to only Residential & Commercial Location only.',
                        style: TextStyle(
                          color: Color(0xFFD1D1D6),
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 14,
                            tabletVal: 16,
                          ),
                          fontFamily: GoogleFonts.roboto().fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 100),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
