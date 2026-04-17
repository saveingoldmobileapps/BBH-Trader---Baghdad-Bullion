import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/email_verify_code_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/support_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';

import '../../../data/models/esouq_model/GetAllProductResponse.dart';
import 'esouq_cart_screen.dart';

class EsouqItemDetailScreen extends ConsumerStatefulWidget {
  final AllProducts product;
  final String productPrice;
  final String oneGramPriceInIQD;

  const EsouqItemDetailScreen({
    super.key,
    required this.product,
    required this.productPrice,
    required this.oneGramPriceInIQD,
  });

  @override
  ConsumerState createState() => _EsouqItemDetailScreenState();
}

class _EsouqItemDetailScreenState extends ConsumerState<EsouqItemDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).getUserProfile();
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(context: context, showLoading: true);
    });
    super.initState();
  }
  // String _formatIqd(num? value) {
  //   return CommonService.formatIQDForDisplay(value ?? 0);
  // }
  String _formatIqd(String? value) {
  final parsed = double.tryParse(value ?? '') ?? 0;
  return CommonService.formatIQDForDisplay(parsed);
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  Widget _buildImageGallery() {
    final images = widget.product.imageUrl ?? [];
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.isEmpty ? 1 : images.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            if (images.isEmpty) {
              return const Center(
                child: Icon(Icons.image, size: 80, color: Colors.grey),
              );
            }
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold500,
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white),
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
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GetGenericText(
            text: label,
            fontSize: 14,
            color: AppColors.grey4Color,
            fontWeight: FontWeight.w400,
          ),
          GetGenericText(
            text: value,
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final mainStateWatchProvider = ref.watch(homeProvider);
    sizes!.refreshSize(context);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          MediaQuery.of(context).padding.bottom + 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.greyScale1000.withOpacity(0.8),
        ),
        child: GestureDetector(
          onTap: () async {
            // Logic for KYC and Navigation (Kept exactly as per your source)
            if (!mainStateWatchProvider.isEmailVerified) {
              await genericPopUpWidget(
                isLoadingState: false,
                context: context,
                heading: AppLocalizations.of(
                  context,
                )!.email_verification_required,
                subtitle: AppLocalizations.of(
                  context,
                )!.email_verification_message,
                noButtonTitle: AppLocalizations.of(context)!.cancel,
                yesButtonTitle: AppLocalizations.of(context)!.verify,
                onNoPress: () => Navigator.pop(context),
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

            final temporaryCreditStatus =
                await LocalDatabase.instance.getIsUsertemporaryCreditStatus() ??
                false;

            if (temporaryCreditStatus) {
              if (!context.mounted) return;
              await temporaryCreditPopUpWidget(
                context: context,
                heading: AppLocalizations.of(context)!.temporary_credit_title,
                subtitle: AppLocalizations.of(
                  context,
                )!.temperory_credit_detect_esouq,
                buttonTitle: AppLocalizations.of(
                  context,
                )!.temporary_credit_contact_support,
                icon: Icons.account_balance_wallet_outlined,
                onButtonPress: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
                oncloseButtonPress: () => Navigator.pop(context),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EsouqCartScreen(
                  product: widget.product,
                  productPrice: widget.productPrice,
                  oneGramPriceInIQD: widget.oneGramPriceInIQD,
                ),
              ),
            );
          },
          child: Container(
            height: 56,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.goldColor, // start (darker gold)
                  AppColors.goldDarkColor, // center (highlight gold)
                  AppColors.goldColor, // end (darker gold)
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: GetGenericText(
                text: AppLocalizations.of(context)!.buy_now,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Card
            Container(
              height: 320,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildImageGallery(),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Title & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: widget.product.localizedProductName(lang)
                        .toUpperCase(),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  GetGenericText(
                    text:
                        "${AppLocalizations.of(context)!.idq_currency}${_formatIqd(widget.productPrice)}",
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold500,
                  ),
                  GetGenericText(
                    text:
                        "${l10n.idq_currency}${_formatIqd(widget.oneGramPriceInIQD)}${l10n.g_}",
                    fontSize: 13,
                    color: AppColors.grey4Color,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Technical Features (INSIDE CONTAINER AS PER UI)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.features,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262929),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.productCode,
                          widget.product.productCode,
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.purity,
                          widget.product.purity,
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.brand,
                          widget.product.localizedBrand(lang),
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.weight,
                          "${widget.product.weight} ${widget.product.weightCategory}",
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.condition,
                          widget.product.localizedCondition(lang),
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.origin,
                          widget.product.localizedOrigin(lang),
                        ),
                        _buildFeatureRow(
                          AppLocalizations.of(context)!.dimensions,
                          widget.product.dimensions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.description,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  GetGenericText(
                    text: widget.product.localizedDescription(lang),
                    fontSize: 14,
                    color: AppColors.grey4Color,
                    lines: 50,
                    fontWeight: FontWeight.normal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. Shipping & Delivery (FULL DETAIL AS PER ORIGINAL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.shippingDelivery,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),

                  // In-Store Section
                  _buildDeliveryInfoRow(
                    iconPath: "assets/svg/shop_icon.svg",
                    title: AppLocalizations.of(context)!.inStoreCollection,
                    detail: AppLocalizations.of(
                      context,
                    )!.in_store,
                  ),
                  const SizedBox(height: 32),

                  // Shipping Section with Full Original Text Details
                  _buildDeliveryInfoRow(
                    icon: Icons.local_shipping_outlined,
                    title: AppLocalizations.of(context)!.shippingFees,
                    richDetail: TextSpan(
                      children: [
                        // Basic shipping info
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.shipping_fees_detail} ",
                          style: TextStyle(
                            color: AppColors.grey4Color,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        // Dynamic delivery charge
                        TextSpan(
                          text:
                              "${widget.product.deliveryCharges} ${AppLocalizations.of(context)!.idq_currency}. ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        // Ready status
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.once_order_ready}\n\n",
                          style: TextStyle(
                            color: AppColors.grey4Color,
                            fontSize: 13,
                          ),
                        ),
                        // Identified Person detail
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.delivery_identified_person} ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.customer_have_enter}\n\n",
                          style: TextStyle(
                            color: AppColors.grey4Color,
                            fontSize: 13,
                          ),
                        ),
                        // Location detail
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.delivery_location} ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.order_can_be_delivered,
                          style: TextStyle(
                            color: AppColors.grey4Color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoRow({
    String? iconPath,
    IconData? icon,
    required String title,
    String? detail,
    InlineSpan? richDetail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconPath != null
            ? SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                color: AppColors.primaryGold500,
              )
            : Icon(icon, color: AppColors.primaryGold500, size: 26),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetGenericText(
                text: title,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              richDetail != null
                  ? Text.rich(richDetail)
                  : GetGenericText(
                      text: detail ?? "",
                      fontSize: 13,
                      color: AppColors.grey4Color,
                      lines: 15,
                      fontWeight: FontWeight.bold,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
