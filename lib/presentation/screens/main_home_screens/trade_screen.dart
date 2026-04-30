import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../notification_screens/notification_screen.dart';
import '../trade_screens/buy_gold_screen.dart';

enum TradeType {
  buy,
  sell,
}

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final l10n = AppLocalizations.of(context)!;
    final goldPriceState = ref.watch(goldPriceProvider);
    final mainStateWatchProvider = ref.watch(homeProvider);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff171919),
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.transparent,
        surfaceTintColor: AppColors.greyScale1000,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            /// Profile Avatar
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

                final imageToShow = networkImage.isNotEmpty
                    ? networkImage
                    : cachedImage;

                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldLightColor,
                        width: 1.2,
                      ),
                      image: imageToShow.isNotEmpty
                          ? DecorationImage(
                              image: imageToShow.startsWith('http')
                                  ? NetworkImage(imageToShow)
                                  : FileImage(File(imageToShow))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                "assets/png/account_card_bg.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            /// Search Bar
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.goldLightColor.withOpacity(0.4),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF1E1E1E),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.gift_search_here,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// Notification Icon
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: SvgPicture.asset(
                "assets/svg/notify_icon.svg",
                height: 24,
                width: 24,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 2. Current Market Price Card
              _buildMarketPriceCard(context, goldPriceState),

              const SizedBox(height: 24),

              // 3. Trade Gold Action Button
              Builder(
                builder: (context) {
                  final liveBuyingPriceIqd =
                      goldPriceState.value?.oneGramBuyingPriceInIQD ?? 0.0;
                  final canOpenTradeBuy = liveBuyingPriceIqd > 0;
                  return AbsorbPointer(
                    absorbing: !canOpenTradeBuy,
                    child: Opacity(
                      opacity: canOpenTradeBuy ? 1.0 : 0.5,
                      child: LoaderButton(
                        title: l10n.trade_gold,
                        onTap: () {
                          if (!canOpenTradeBuy) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BuyGoldScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 4. Max grams based on IQD balance
              goldPriceState.when(
                data: (data) {
                  final walletBalance =
                      double.tryParse(
                        mainStateWatchProvider
                                .getHomeFeedResponse
                                .payload
                                ?.walletExists
                                ?.moneyBalance
                                ?.toString() ??
                            '0',
                      ) ??
                      0.0;
                  final pricePerGram = data.oneGramBuyingPriceInIQD;
                  final maxGrams = pricePerGram > 0
                      ? (walletBalance / pricePerGram)
                      : 0.0;
                  return Center(
                    child: GetGenericText(
                      text:
                          "${AppLocalizations.of(context)!.max_grams_note} ${maxGrams.toStringAsFixed(3)}",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey4Color,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      // Use your existing bottom navigation bar here if applicable
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // User Profile Pic
        CircleAvatar(
          radius: 20,
          backgroundImage: const AssetImage(
            "assets/images/user_placeholder.png",
          ), // Update with actual path
        ),
        const SizedBox(width: 12),
        // Search Placeholder Bar
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Text(
                  l10n.gift_search_here,
                  style: const TextStyle(color: Colors.white38),
                ),
                const Spacer(),
                const Icon(Icons.search, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Notification Icon
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          ),
          child: SvgPicture.asset(
            "assets/svg/notify_icon.svg",
            height: 24,
            width: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPriceCard(
    BuildContext context,
    AsyncValue goldPriceState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262929),
        borderRadius: BorderRadius.circular(16),
      ),
      child: goldPriceState.when(
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.current_market_price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPriceRow(
              l10n: l10n,
              label: l10n.buying_at,
              price: data.oneGramBuyingPriceInIQD,
              ouncePrice: data.oneOunceBuyingPriceInIQD,
              highLowPrice: data.lastHighBuyingPrice,
              isHigh: true,
            ),

            const SizedBox(height: 16),

            _buildPriceRow(
              l10n: l10n,
              label: l10n.selling_at,
              price: data.oneGramSellingPriceInIQD,
              ouncePrice: data.oneOunceSellingPriceInIQD,
              highLowPrice: data.lastLowSellingPrice,
              isHigh: false,
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold500),
        ),
        error: (_, __) => Center(
          child: Text(
            l10n.error_loading_prices,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required AppLocalizations l10n,
    required String label,
    required double price,
    required double ouncePrice,
    required double highLowPrice,
    required bool isHigh,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.price_iqd_per_gram(
                CommonService.formatIQDForDisplay(price),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.ounce_price_iqd(
                CommonService.formatIQDForDisplay(ouncePrice),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        /// High / Low badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHigh
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                isHigh ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isHigh ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isHigh
                    ? l10n.high_price_badge(
                        CommonService.formatIQDForDisplay(highLowPrice),
                      )
                    : l10n.low_price_badge(
                        CommonService.formatIQDForDisplay(highLowPrice),
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isHigh ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
