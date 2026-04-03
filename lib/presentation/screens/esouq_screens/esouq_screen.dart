import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/esouq_screens/esouq_item_detail_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';
import '../../widgets/no_data_widget.dart';

class EsouqScreen extends ConsumerStatefulWidget {
  const EsouqScreen({super.key});

  @override
  ConsumerState createState() => _EsouqScreenState();
}

class _EsouqScreenState extends ConsumerState<EsouqScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String? selectedWeight;
  String? selectedWeightCategory;

  @override
  void initState() {
    super.initState();
    fetchESouqProductData();
    _scrollController.addListener(_scrollListener);

    // Delay the provider modification
  }

  /// fetch esouq products
  Future<void> fetchESouqProductData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(esouqProvider.notifier)
          .fetchEsouqProducts(
            paramWeight: selectedWeight,
            paramWeightCategory: selectedWeightCategory,
            reset: true,
          );
    });
  }

  /// scroll listener
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref
          .read(esouqProvider.notifier)
          .loadMoreProducts(
            paramWeight: selectedWeight,
            paramWeightCategory: selectedWeightCategory,
          );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
    final esouqState = ref.watch(esouqProvider);
    final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
    final oneGramBuyingPriceInIQD =
        goldPriceStateWatchProvider.value?.oneGramBuyingPriceInIQD ?? 0.0;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.greyScale1000,
      drawer: GetFilterDrawerBar(
        onTap: () => Navigator.pop(context),
        onApplyFilter: (weight, category) async {
          setState(() {
            selectedWeight = weight;
            selectedWeightCategory = category;
          });
          await fetchESouqProductData();
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,

        elevation: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.esouq,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            icon: SvgPicture.asset(
              'assets/svg/filter_icon.svg',
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // --- THE BACKGROUND GRADIENT ---
          gradient: RadialGradient(
            center: Alignment(1, -0.8),
            radius: 1.2,
            colors: [
              Color(0xFF453d23),
              Color(0xFF121212),
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- NEW SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await fetchESouqProductData(),
                  child: esouqState.isLoading
                      ? const Center(child: ShimmerLoader(loop: 6))
                      : esouqState.products.isEmpty
                      ? NoDataWidget(
                          title: AppLocalizations.of(context)!.no_esouq_product,
                          description: '',
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              esouqState.products.length +
                              (esouqState.hasNextPage ? 1 : 0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: sizes!.isLandscape() ? 3 : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    0.62, // Adjusted for image + text
                              ),
                          itemBuilder: (context, index) {
                            if (index == esouqState.products.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final product = esouqState.products[index];
                            final eSouqProductPrice =
                                CommonService.calculateWeightPrice(
                                  weightFactor: product.weightFactor,
                                  oneGramSellingPrice: oneGramBuyingPriceInIQD,
                                );
                            final itemPrice = CommonService.formatCurrency(
                              amount: eSouqProductPrice.toString(),
                            );

                            return EsouqItemCard(
                              title: product.productName ?? "N/A",
                              imageUrl: product.imageUrl?.isNotEmpty == true
                                  ? product.imageUrl!.first
                                  : "",
                              itemPrice: itemPrice,
                              oneGramPrice: oneGramBuyingPriceInIQD
                                  .toStringAsFixed(3),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EsouqItemDetailScreen(
                                      product: product,
                                      productPrice: eSouqProductPrice
                                          .toStringAsFixed(2),
                                      oneGramPriceInIQD: oneGramBuyingPriceInIQD
                                          .toStringAsFixed(2),
                                    ),
                                  ),
                                );
                              },
                              onTapAddToCart: () {},
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
