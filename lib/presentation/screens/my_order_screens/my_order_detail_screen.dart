import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';

import '../../widgets/shimmers/shimmer_loader.dart';

class MyOrderDetailScreen extends ConsumerStatefulWidget {
  final KAllOrders kAllOrders;

  const MyOrderDetailScreen({
    required this.kAllOrders,
    super.key,
  });

  @override
  ConsumerState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<MyOrderDetailScreen> {
  String? collectionMethod = "Pickup";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(esouqProvider.notifier)
          .getEsouqOrderById(widget.kAllOrders.sId!.toString());
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

  @override
  Widget build(BuildContext context) {
    final esouqStateWatchProvider = ref.watch(esouqProvider);
    sizes!.refreshSize(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final statusText = widget.kAllOrders.status ?? "";
    final localizedStatus = isRTL
        ? statusArabic[statusText] ?? statusText
        : statusText;

    final deliveryMethod = widget.kAllOrders.deliveryMethod ?? "";
    String localizedDeliveryMethod = deliveryMethod;

    if (isRTL) {
      if (deliveryMethod.toLowerCase() == "delivery") {
        localizedDeliveryMethod = "توصيل";
      } else if (deliveryMethod.toLowerCase() == "pickup" ||
          deliveryMethod.toLowerCase() == "collection") {
        localizedDeliveryMethod = "استلام";
      }
    }
    final paymentMethod = widget.kAllOrders.paymentMethod ?? "";
    String localizedPaymentMethod = paymentMethod;

    if (isRTL) {
      if (paymentMethod.toLowerCase() == "money") {
        localizedPaymentMethod = "نقدي";
      } else if (paymentMethod.toLowerCase() == "metal") {
        localizedPaymentMethod = "ذهب";
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.order_details, //"Order Details",
          fontSize: sizes!.isPhone ? 20 : 24,
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
          child: esouqStateWatchProvider.isLoading
              ? Center(
                  child: ShimmerLoader(
                    loop: 6,
                  ),
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.order_no, //"Order No.",
                          fontSize: sizes!.isPhone ? 18 : 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey6Color,
                        ),
                        GetGenericText(
                          text: "#${widget.kAllOrders.orderId}",
                          fontSize: sizes!.isPhone ? 18 : 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey6Color,
                        ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.order_status, //"Order Status",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 15,
                            tabletVal: 17,
                          ), //sizes!.isPhone ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey5Color,
                        ),
                        GetGenericText(
                          text: localizedStatus,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey4Color,
                        ),
                        // GetGenericText(
                        //   text: widget.kAllOrders.status ?? "",
                        //   fontSize: sizes!.responsiveFont(
                        //     phoneVal: 16,
                        //     tabletVal: 18,
                        //   ), //sizes!.isPhone ? 16 : 18,
                        //   fontWeight: FontWeight.w400,
                        //   color: AppColors.grey4Color,
                        // ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.delivery_method, //"Delivery Method",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 15,
                            tabletVal: 17,
                          ), //sizes!.isPhone ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey5Color,
                        ),
                        isRTL
                            ? GetGenericText(
                                text: localizedDeliveryMethod,
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ),
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey4Color,
                              )
                            : GetGenericText(
                                text: widget.kAllOrders.deliveryMethod ?? "",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //sizes!.isPhone ? 16 : 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey4Color,
                              ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.payment_method, //"Payment Method",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 15,
                            tabletVal: 17,
                          ), //sizes!.isPhone ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey5Color,
                        ),
                        isRTL
                            ? GetGenericText(
                                text: localizedPaymentMethod,
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ),
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey4Color,
                              )
                            : GetGenericText(
                                text: widget.kAllOrders.paymentMethod ?? "",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //sizes!.isPhone ? 16 : 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey4Color,
                              ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    widget.kAllOrders.deliveryMethod != collectionMethod
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.customer_address, //"Customer Address",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 15,
                                  tabletVal: 17,
                                ), //sizes!.isPhone ? 15 : 17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ),
                              // const Spacer(),
                              Expanded(
                                child: GetGenericText(
                                  text: widget.kAllOrders.address!.isNotEmpty
                                      ? widget.kAllOrders.address.toString()
                                      : AppLocalizations.of(
                                          context,
                                        )!.not_available, //"N/A",
                                  fontSize: sizes!.responsiveFont(
                                    phoneVal: 16,
                                    tabletVal: 18,
                                  ),
                                  //sizes!.isPhone ? 16 : 18,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey4Color,
                                  lines: 10,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    widget.kAllOrders.deliveryMethod != collectionMethod
                        ? ConstPadding.sizeBoxWithHeight(height: 16)
                        : Container(),
                    widget.kAllOrders.deliveryMethod == collectionMethod
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.branch_address, //"Branch Address",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 15,
                                  tabletVal: 17,
                                ), //sizes!.isPhone ? 15 : 17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ),
                              // const Spacer(),
                              Expanded(
                                child: GetGenericText(
                                  text: widget.kAllOrders.branchId != null
                                      ? "${widget.kAllOrders.branchId!.branchName}, ${widget.kAllOrders.branchId!.branchLocation}, ${widget.kAllOrders.branchId!.branchManager}, ${widget.kAllOrders.branchId!.branchPhoneNumber}, ${widget.kAllOrders.branchId!.branchEmail}"
                                            .toString()
                                      : AppLocalizations.of(
                                          context,
                                        )!.not_available, //"N/A",
                                  fontSize: sizes!.responsiveFont(
                                    phoneVal: 16,
                                    tabletVal: 18,
                                  ),
                                  //sizes!.isPhone ? 16 : 18,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey4Color,
                                  lines: 10,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: sizes!.heightRatio * 52,
                          width: sizes!.widthRatio * 52,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: CachedNetworkImage(
                              imageUrl:
                                  widget
                                          .kAllOrders
                                          .productId
                                          ?.imageUrl
                                          ?.isNotEmpty ==
                                      true
                                  ? widget.kAllOrders.productId!.imageUrl!.first
                                  : "https://plus.unsplash.com/premium_photo-1678025061438-786888bfcaf1?q=80&w=3424&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              // placeholder: (context, url) => PlaceholderWidget(),
                              // errorWidget: (context, url, error) => PlaceholderWidget(),
                            ),

                            // CachedNetworkImage(
                            //   imageUrl:
                            //       widget.kAllOrders.productId!.imageUrl !=
                            //               null &&
                            //           widget
                            //               .kAllOrders
                            //               .productId!
                            //               .imageUrl!
                            //               .isNotEmpty
                            //       ? widget
                            //             .kAllOrders
                            //             .productId!
                            //             .imageUrl![0] // Access first image URL
                            //       : "https://plus.unsplash.com/premium_photo-1678025061438-786888bfcaf1?q=80&w=3424&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            //   fit: BoxFit.cover,
                            //   progressIndicatorBuilder:
                            //       (context, url, downloadProgress) => SizedBox(
                            //         height: sizes!.heightRatio * 10,
                            //         width: sizes!.widthRatio * 10,
                            //         child: Center(
                            //           child: CircularProgressIndicator(
                            //             value: downloadProgress.progress,
                            //           ),
                            //         ),
                            //       ),
                            //   errorWidget: (context, url, error) =>
                            //       Icon(Icons.error),
                            // ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithWidth(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GetGenericText(
                                text:
                                    widget.kAllOrders.productId?.productName ??
                                    "",
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ), //16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey6Color,
                              ),
                              ConstPadding.sizeBoxWithHeight(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GetGenericText(
                                    text: widget.kAllOrders.quantity != null
                                        ? "${AppLocalizations.of(context)!.quantity}: ${widget.kAllOrders.quantity}"
                                        : AppLocalizations.of(
                                            context,
                                          )!.not_available, //"N/A",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 16,
                                      tabletVal: 18,
                                    ), //16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey4Color,
                                  ),
                                  GetGenericText(
                                    text:
                                        esouqStateWatchProvider
                                                .selectedOrder
                                                .payload!
                                                .paymentMethod ==
                                            'Money'
                                        ? widget.kAllOrders.grandTotal != null
                                              ? "${widget.kAllOrders.grandTotal} ${AppLocalizations.of(context)!.aed_currency}"
                                              : ""
                                        //"${esouqStateWatchProvider.selectedOrder.payload!.grandTotal!.toStringAsFixed(3)} AED"
                                        : widget.kAllOrders.grandTotal != null
                                        ? "${CommonService.convertToWeight(
                                            num: double.parse("${widget.kAllOrders.grandTotal}"),

                                            context: context,
                                          )} "
                                        : AppLocalizations.of(
                                            context,
                                          )!.not_available, //"N/A",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey4Color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // const Spacer(),
                    // LoaderButton(
                    //   title: "Return to Home",
                    //   onTap: () {
                    //     Navigator.pushAndRemoveUntil(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const MainHomeScreen(),
                    //       ),
                    //       ((route) => false),
                    //     );
                    //   },
                    // ),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                  ],
                ).get16HorizontalPadding(),
        ),
      ),
    );
  }

  final statusArabic = {
    "Confirmed": "مؤكد",
    "Ready to pick": "جاهز للاستلام",
    "Delivered": "تم التوصيل",
    "Cancelled": "أُلغيت",
    "Pending": "قيد الانتظار",
    "Picked Up": "تم الاستلام",
    "Preparing": "قيد التحضير",
  };
}
