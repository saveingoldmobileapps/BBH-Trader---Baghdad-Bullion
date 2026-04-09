import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  // Localized status
  final l10n = AppLocalizations.of(context)!;
  String localizedStatus;
  switch (status.toLowerCase()) {
    case "completed":
    case "delivered":
      localizedStatus = l10n.approved;   // Arabic: "مكتمل"
      break;
    case "cancelled":
    case "canceled":
      localizedStatus = l10n.canceled;   // Arabic: "ملغاة"
      break;
    case "pending":
    case "confirmed":
    case "preparing":
      localizedStatus = l10n.pending;    // Arabic: "قيد الانتظار"
      break;
    default:
      localizedStatus = status;          // fallback
  }

  IconData iconData;
  Color primaryColor;

  switch (status.toLowerCase()) {
    case "completed":
    case "delivered":
    case "picked up":
      iconData = Icons.check_circle_outline;
      primaryColor = const Color(0xFF34C759); // Green
      break;
    case "cancelled":
    case "canceled":
      iconData = Icons.cancel_outlined;
      primaryColor = const Color(0xFFFF3B30); // Red
      break;
    case "pending":
    case "confirmed":
    case "preparing":
    default:
      iconData = Icons.access_time_rounded;
      primaryColor = const Color(0xFFE8B931); // Yellow/Gold
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

  @override
  Widget build(BuildContext context) {
    final esouqStateWatchProvider = ref.watch(esouqProvider);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    sizes!.refreshSize(context);

    final statusText = widget.kAllOrders.status ?? "Pending";

    // String formattedDate = widget.kAllOrders.createdAt != null
    //     ? DateFormat(
    //         'MMM dd, yyyy  •  h:mm a',
    //       ).format(DateTime.parse(widget.kAllOrders.createdAt!))
    //     : "Dec 18, 2024  •  2:45 PM";
    String formattedDate = widget.kAllOrders.createdAt != null
        ? DateFormat(
            'dd/MM/yyyy, HH:mm',
            isArabic ? 'ar_IQ' : 'en_IQ',
          ).format(
            DateTime.parse(widget.kAllOrders.createdAt!)
                .toUtc()
                .add(const Duration(hours: 3)),
          )
        : "Dec 18, 2024  •  2:45 PM";

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
                          _buildSummaryRow("${AppLocalizations.of(context)!.dateTime}", formattedDate),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFF2C2C2E)),
                          ),
                          _buildSummaryRow(
                            "${widget.kAllOrders.quantity ?? 1} ${l10n.gram_unit_plural}",
                            widget.kAllOrders.productId?.productName ??
                                "Gold bar",
                            isItem: true,
                          ),
                          const SizedBox(height: 20),
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
                                         : "${l10n.iqd_gram} ${CommonService.formatIQDForDisplay(widget.kAllOrders.grandTotal ?? 0)}",
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
                                //"We'll notify you when your order is executed",

                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: AppColors.grey5Color,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// --- Go Back Button ---
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
                        child:  Center(
                          child: Text(
                            AppLocalizations.of(context)!.gift_go_back,//"Go back",
                            style: TextStyle(
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
          ),
        ],
      ),
    );
  }
}
