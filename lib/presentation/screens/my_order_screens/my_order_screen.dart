import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/my_order_card.dart';
import 'package:saveingold_fzco/presentation/widgets/no_data_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';

import 'my_order_detail_screen.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(_scrollListener);

    fetchESouqOrders();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchESouqOrders() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(esouqProvider.notifier).getAllEsouqOrders();
    });
  }

  /// scroll listener
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(esouqProvider.notifier).loadMoreOrders();
    }
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

    final esouqStateWatchProvider = ref.watch(esouqProvider);
    //final esouqStateReadProvider = ref.read(esouqProvider.notifier);

    return Scaffold(
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
          text: AppLocalizations.of(context)!.my_orders,//"My Orders",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
          isInter: true,
        ),
      ),
      body: Container(
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
              await fetchESouqOrders();
            },
            child: Column(
              children: [
                Expanded(
                  child: esouqStateWatchProvider.isLoading
                      ? Center(
                          child: ShimmerLoader(
                            loop: 6,
                          ),
                        )
                      : esouqStateWatchProvider.kAllOrders.isEmpty
                      ? NoDataWidget(
                          title: AppLocalizations.of(context)!.empty_no_data,//"No Data To Show",
                          description: "",
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount:
                              esouqStateWatchProvider.kAllOrders.length +
                              (esouqStateWatchProvider.hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index ==
                                    esouqStateWatchProvider.kAllOrders.length &&
                                esouqStateWatchProvider.hasNextPage) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGold500,
                                  strokeWidth: 2,
                                ),
                              );
                            }

                            final myOrder =
                                esouqStateWatchProvider.kAllOrders[index];

                            return MyOrderCard(
                              kAllOrders: myOrder,
                              onTap: () {
                                debugPrint("status: ${myOrder.status}");
                                debugPrint(
                                  "deliveryFee: ${myOrder.deliveryCharges}",
                                );
                                debugPrint(
                                  "paymentMethod: ${myOrder.paymentMethod}",
                                );
                                // debugPrint("grandTotal: ${esouqStateWatchProvider.kAllOrders}");
                                debugPrint(
                                  "totalCharges: ${myOrder.grandTotal}",
                                ); //grandTotal

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyOrderDetailScreen(
                                      kAllOrders: myOrder,
                                    ),
                                  ),
                                );
                              },
                            ).get6VerticalPadding();
                          },
                        ),
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
