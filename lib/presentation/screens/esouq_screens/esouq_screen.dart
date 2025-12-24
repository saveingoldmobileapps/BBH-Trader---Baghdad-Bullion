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
      ref.read(esouqProvider.notifier).fetchEsouqProducts(
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
      ref.read(esouqProvider.notifier).loadMoreProducts(
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
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    final esouqState = ref.watch(esouqProvider);

    /// StreamProvider
    final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);

    /// AsyncValue builder
    final oneGramBuyingPriceInAED =
        goldPriceStateWatchProvider.value?.oneGramBuyingPriceInAED ?? 0.0;
    return Scaffold(
      key: _scaffoldKey,
      drawer: GetFilterDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.esouq, //"E-Souq",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
          isInter: true,
        ),
        actions: [
          Padding(
            padding: Directionality.of(context) == TextDirection.rtl
                ? EdgeInsets.only(left: 16)
                : EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  'assets/svg/filter_icon.svg',
                  height: sizes!.heightRatio *
                      (sizes!.isPhone ? 24 : (sizes!.isLandscape() ? 32 : 24)),
                  width: sizes!.widthRatio *
                      (sizes!.isPhone ? 24 : (sizes!.isLandscape() ? 32 : 24)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Remove focus to close the keyboard
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: sizes!.height,
          width: sizes!.width,
          decoration: const BoxDecoration(
            color: AppColors.greyScale1000,
          ),
          child: SafeArea(
            child: RefreshIndicator(
              backgroundColor: AppColors.primaryGold500,
              color: AppColors.whiteColor,
              onRefresh: () async {
                await fetchESouqProductData();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: esouqState.isLoading
                        ? const Center(
                            child: ShimmerLoader(
                              loop: 6,
                            ),
                          )
                        : esouqState.products.isEmpty
                            ? NoDataWidget(
                                title: AppLocalizations.of(
                                  context,
                                )!
                                    .empty_no_data, //"No Data To Show",
                                description: "",
                              )
                            : GridView.builder(
                                controller: _scrollController,
                                itemCount: esouqState.products.length +
                                    (esouqState.hasNextPage ? 1 : 0),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: sizes!.isLandscape() ? 3 : 2,
                                  crossAxisSpacing: 6.0,
                                  mainAxisSpacing: 6.0,
                                  childAspectRatio: sizes!.isPhone
                                      ? 0.45
                                      : sizes!.isLandscape() && !sizes!.isPhone
                                          ? 0.9
                                          : (sizes!.isLandscape() ? 1.4 : 0.9),
                                ),
                                itemBuilder: (context, index) {
                                  if (index == esouqState.products.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryGold500,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }

                                  /// product
                                  final product = esouqState.products[index];

                                  /// eSouq product price
                                  final eSouqProductPrice =
                                      CommonService.calculateWeightPrice(
                                    weightFactor: product.weightFactor,
                                    oneGramSellingPrice:
                                        oneGramBuyingPriceInAED,
                                  );

                                  /// item price
                                  final itemPrice =
                                      CommonService.formatCurrency(
                                    amount: eSouqProductPrice.toString(),
                                  );

                                  /// esouq item card
                                  return EsouqItemCard(
                                    title: product.productName ??
                                        AppLocalizations.of(context)!
                                            .na, //"N/A",
                                    imageUrl: product.imageUrl?.isNotEmpty ==
                                            true
                                        ? product.imageUrl!.first
                                        : "", // or use a placeholder image URL
                                    itemPrice: itemPrice,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EsouqItemDetailScreen(
                                            product: product,
                                            productPrice: eSouqProductPrice
                                                .toStringAsFixed(2),
                                            oneGramPriceInAED:
                                                oneGramBuyingPriceInAED
                                                    .toStringAsFixed(2),
                                          ),
                                        ),
                                      );
                                    },
                                    onTapAddToCart: () {
                                      // Add to cart logic
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ).get16HorizontalPadding(),
            ),
          ),
        ),
      ),
    );
  }
}
