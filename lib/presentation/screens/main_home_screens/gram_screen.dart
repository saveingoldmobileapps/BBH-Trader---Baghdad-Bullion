import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/gram_screens/gram_deal_detail_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gram_provider/gram_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/no_data_widget.dart';
import '../notification_screens/notification_screen.dart';

class GramScreen extends ConsumerStatefulWidget {
  const GramScreen({super.key});

  @override
  ConsumerState createState() => _GramScreenState();
}

class _GramScreenState extends ConsumerState<GramScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gramProvider.notifier).getUserGramBalance();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(goldPriceProvider);
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final gramStateWatchProvider = ref.watch(gramProvider);
    final goldPriceState = ref.watch(goldPriceProvider);
    final l10n = AppLocalizations.of(context)!;
    final mainStateWatchProvider = ref.watch(homeProvider);
    // Logic: Calculate total grams for the large display
    double totalGrams = 0;
    if (gramStateWatchProvider.gramApiResponseModel.payload != null) {
      for (var item in gramStateWatchProvider.gramApiResponseModel.payload!) {
        totalGrams += (item.tradeMetal ?? 0);
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF53482A), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    /// Profile Avatar with network/cached image logic
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
                          onTap: () => _scaffoldKey.currentState!.openDrawer(),
                          child: Container(
                            width: 40,
                            height: 40,
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
                                        "assets/images/user_avatar.png",
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
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
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
                                "Search here",
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/notify_icon.svg",
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Gram Balance Typography Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gramsBalance_title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalGrams.toStringAsFixed(2),
                          style: const TextStyle(
                            color: AppColors.primaryGold500,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "gram(s)",
                          style: TextStyle(
                            color: AppColors.primaryGold500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Current trade deals",
                      style: TextStyle(
                        color: AppColors.primaryGold500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Trade Deals List Section
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: AppColors.primaryGold500,
                  color: AppColors.whiteColor,
                  onRefresh: () async => await ref
                      .read(gramProvider.notifier)
                      .getUserGramBalance(),
                  child: _buildTradeList(gramStateWatchProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeList(dynamic provider) {
    if (provider.loadingState == LoadingState.loading) {
      return Center(child: ShimmerLoader(loop: sizes!.isPhone ? 4 : 6));
    }
    if (provider.loadingState == LoadingState.error ||
        provider.gramApiResponseModel.payload!.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: sizes!.height * 0.15),
          NoDataWidget(
            title: AppLocalizations.of(context)!.empty_no_data,
            description: AppLocalizations.of(context)!.empty_no_gram_balance,
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: provider.gramApiResponseModel.payload!.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        return GramBalanceCard(
          gramList: provider.gramApiResponseModel.payload![index],
          rtl: Directionality.of(context) == TextDirection.rtl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GramDealDetailScreen(
                  gramData: provider.gramApiResponseModel.payload![index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
