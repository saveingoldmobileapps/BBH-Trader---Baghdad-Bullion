import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/global_time.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// Helper to build Status specific Icon and Colors
  // Widget _buildStatusHeader(String status) {
  //   IconData iconData;
  //   Color primaryColor;

  //   switch (status.toLowerCase()) {
  //     case "completed":
  //     case "delivered":
  //     case "picked up":
  //       iconData = Icons.check_circle_outline;
  //       primaryColor = const Color(0xFF34C759); // Green
  //       break;
  //     case "cancelled":
  //       iconData = Icons.cancel_outlined;
  //       primaryColor = const Color(0xFFFF3B30); // Red
  //       break;
  //     case "pending":
  //     case "confirmed":
  //     case "preparing":
  //     default:
  //       iconData = Icons.access_time_rounded;
  //       primaryColor = const Color(0xFFE8B931); // Yellow/Gold
  //       break;
  //   }

  //   return Column(
  //     children: [
  //       Center(
  //         child: Container(
  //           height: 120,
  //           width: 120,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: primaryColor.withValues(alpha: 0.15),
  //           ),
  //           child: Center(
  //             child: Container(
  //               height: 80,
  //               width: 80,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: primaryColor,
  //               ),
  //               child: Icon(
  //                 iconData,
  //                 color: Colors.black,
  //                 size: 50,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF262929),
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: GetGenericText(
  //           text: status,
  //           color: primaryColor,
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildStatusHeader(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    String localizedStatus;
    switch (status.toLowerCase()) {
      case "completed":
      case "delivered":
        localizedStatus = l10n.approved;
        break;
      case "cancelled":
      case "canceled":
        localizedStatus = l10n.canceled;
        break;
      case "pending":
      case "confirmed":
      case "preparing":
        localizedStatus = l10n.pending;
        break;
      default:
        localizedStatus = status;
    }

  IconData iconData;
  Color primaryColor;

  switch (status.toLowerCase()) {
    case "completed":
    case "delivered":
    case "picked up":
      iconData = Icons.check_circle_outline;
      primaryColor = const Color(0xFF34C759);
      break;
    case "cancelled":
      case "canceled":
        iconData = Icons.cancel_outlined;
        primaryColor = const Color(0xFFFF3B30);
        break;
      case "pending":
      case "confirmed":
      case "preparing":
      default:
        iconData = Icons.access_time_rounded;
        primaryColor = const Color(0xFFE8B931);
        break;
    }

  return Column(
    children: [
      Center(
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.15),
          ),
          child: Center(
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: Icon(
                iconData,
                color: Colors.black,
                size: 50,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF262929),
          borderRadius: BorderRadius.circular(20),
        ),
        child: GetGenericText(
          text: localizedStatus,
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
 }

  /// ✅ Get localized product name
  String getLocalizedProductName() {
    try {
      final product = widget.kAllOrders.productId;
      if (product == null) return "Gold Product";
      
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final rawName = product.rawProductName;
      
      if (rawName != null && rawName is Map) {
        if (isArabic) {
          return rawName['ar']?.toString() ?? rawName['en']?.toString() ?? "منتج ذهب";
        } else {
          return rawName['en']?.toString() ?? rawName['ar']?.toString() ?? "Gold Product";
        }
      }
      
      return product.productName ?? product.productCode ?? "${product.weight ?? "0"}g";
    } catch (e) {
      return "Gold Product";
    }
  }

  @override
  Widget build(BuildContext context) {
    final esouqStateWatchProvider = ref.watch(esouqProvider);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    sizes!.refreshSize(context);

    final statusText = widget.kAllOrders.status ?? "Pending";
    final productName = getLocalizedProductName();
    final weightPerUnit = widget.kAllOrders.productId?.weight ?? "0";
    final weightUnit = widget.kAllOrders.productId?.weightCategory ?? "Gram";
    final totalWeight = (widget.kAllOrders.quantity ?? 0) * (double.tryParse(weightPerUnit) ?? 0);

    final formattedDate = DateTimeHelper.formatLocalDateTime(
      widget.kAllOrders.createdAt,
      context,
    );

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.order_details,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: SafeArea(
        child: esouqStateWatchProvider.isLoading
            ? Center(child: ShimmerLoader(loop: 6))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    /// --- Dynamic Status Header ---
                    _buildStatusHeader(context,statusText),

                    const SizedBox(height: 40),

                    /// --- Order Summary Card ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262929),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GetGenericText(
                            text: AppLocalizations.of(context)!.esouq_order_summary,//"Order Summary",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          _buildSummaryRow(
                            AppLocalizations.of(context)!.esouq_order_id,//"Order ID",
                            "#${widget.kAllOrders.orderId}",
                          ),
                          
                          _buildSummaryRow(
                            AppLocalizations.of(context)!.dateTime,
                            formattedDate,
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFF2C2C2E)),
                          ),
                          
                          /// ✅ Product Name Row
                          _buildSummaryRow(
                            isArabic ? "المنتج" : "Product",
                            productName,
                            isItem: true,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          /// ✅ Quantity Row
                          _buildSummaryRow(
                            isArabic ? "الكمية" : "Quantity",
                            "${widget.kAllOrders.quantity ?? 0}",
                            isItem: true,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          /// ✅ Weight per Unit Row
                          _buildSummaryRow(
                            isArabic ? "الوزن/الوحدة" : "Weight/Unit",
                            "$weightPerUnit ${weightUnit == "Gram" ? (isArabic ? "جرام" : "g") : weightUnit}",
                            isItem: true,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          /// ✅ Total Weight Row
                          _buildSummaryRow(
                            isArabic ? "الوزن الإجمالي" : "Total Weight",
                            "${CommonService.formatGramForDisplay(totalWeight)} ${weightUnit == "Gram" ? (isArabic ? "جرام" : "g") : weightUnit}",
                            isItem: true,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          /// Payment Method Row
                          _buildSummaryRow(
                            isArabic ? "طريقة الدفع" : "Payment Method",
                            widget.kAllOrders.paymentMethod == "Money"
                                ? (isArabic ? "نقدي" : "Cash")
                                : (isArabic ? "محفظة" : "Wallet"),
                            isItem: true,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          /// Delivery Method Row
                          if (widget.kAllOrders.deliveryMethod != null && widget.kAllOrders.deliveryMethod!.isNotEmpty)
                            _buildSummaryRow(
                              isArabic ? "طريقة التوصيل" : "Delivery Method",
                              widget.kAllOrders.deliveryMethod == "Pickup"
                                  ? (isArabic ? "استلام شخصي" : "Pickup")
                                  : (isArabic ? "توصيل" : "Delivery"),
                              isItem: true,
                            ),
                          
                          const SizedBox(height: 20),
                          
                          const Divider(color: Color(0xFF2C2C2E)),
                          
                          const SizedBox(height: 12),
                          
                          /// TOTAL PAID
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetGenericText(
                                text: AppLocalizations.of(context)!.esouq_total_paid,//"Total paid",
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                              GetGenericText(
                                text:
                                    esouqStateWatchProvider
                                            .selectedOrder
                                            .payload!
                                            .paymentMethod ==
                                        'Money'
                                    ? "${l10n.iqd_currency} ${CommonService.formatIQDForDisplay(widget.kAllOrders.grandTotal ?? 0)}"
                                          // "IQD ${widget.kAllOrders.grandTotal ?? '0.00'}":"",
                                         : "${l10n.iqd_gram} ${CommonService.formatGramForDisplay(widget.kAllOrders.grandTotal ?? 0)}",
                                    //: "",
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFBBA473),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// --- Notification Message (Only shows for Pending/Preparing/Confirmed) ---
                    if (statusText.toLowerCase() == "pending" ||
                        statusText.toLowerCase() == "preparing" ||
                        statusText.toLowerCase() == "confirmed")
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262929),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: GetGenericText(
                            text: AppLocalizations.of(context)!.will_notify_you,
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: AppColors.grey5Color,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// Go Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9E772A), Color(0xFF5E4619)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.gift_go_back,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isItem = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GetGenericText(
            text: title,
            fontSize: 14,
            color: isItem ? AppColors.grey6Color : AppColors.grey5Color,
            fontWeight: FontWeight.normal,
          ),
          GetGenericText(
            text: value,
            fontSize: 14,
            fontWeight: isItem ? FontWeight.w400 : FontWeight.w500,
            color: Colors.white,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}