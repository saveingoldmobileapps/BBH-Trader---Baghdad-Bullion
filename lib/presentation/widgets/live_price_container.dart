import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/core_export.dart';
import '../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

class LivePriceContainer extends ConsumerStatefulWidget {
  final String title;
  final bool isSelling;
  final String todayHighLow;

  const LivePriceContainer({
    super.key,
    required this.title,
    required this.isSelling,
    required this.todayHighLow,
  });

  @override
  ConsumerState<LivePriceContainer> createState() => _LivePriceContainerState();
}

class _LivePriceContainerState extends ConsumerState<LivePriceContainer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(goldPriceProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopSSE();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(goldPriceProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // (Same build code as before)
    return Container(
      width: sizes!.isPhone ? sizes!.widthRatio * 160 : sizes!.width / 2.1,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyScale900,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final goldPriceState = ref.watch(goldPriceProvider);
          return goldPriceState.when(
            data: (data) {
              final oneGramAEDPrice = widget.isSelling
                  ? data.oneGramSellingPriceInAED
                  : data.oneGramBuyingPriceInAED;
              final pricePerOunce = widget.isSelling
                  ? data.oneOunceDollarSellingPrice
                  : data.oneOunceDollarBuyingPrice;
              final lastPrice = widget.isSelling
                  ? data.lastLowSellingPrice
                  : data.lastHighBuyingPrice;

              final isPriceValid = oneGramAEDPrice > 0 && pricePerOunce > 0;
              if (!isPriceValid) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.redColor,
                    strokeWidth: 0.5,
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetGenericText(
                    text: widget.title,
                    fontSize: sizes!.isPhone ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 6),
                  GetGenericText(
                    text: NumberFormat("#,##0.00").format(oneGramAEDPrice),
                    fontSize: sizes!.isPhone ? 16 : 45,
                    fontWeight: FontWeight.w500,
                    color: widget.isSelling
                        ? AppColors.redColor
                        : AppColors.greenColor,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 6),
                  GetGenericText(
                    text:
                        "\$${NumberFormat("#,##0.00").format(pricePerOunce)}/troy ounce",
                    fontSize: sizes!.isPhone ? 11 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey3Color,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 6),
                  GetGenericText(
                    text:
                        "${widget.todayHighLow} ${NumberFormat("#,##0.00").format(lastPrice)}",
                    fontSize: sizes!.isPhone ? 12 : 36,
                    fontWeight: FontWeight.w400,
                    color: widget.isSelling
                        ? AppColors.redColor
                        : AppColors.greenColor,
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GetGenericText(
                    text: widget.title,
                    fontSize: sizes!.isPhone ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 6),
                  GetGenericText(
                    text: "Price Unavailable",
                    fontSize: sizes!.isPhone ? 16 : 45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.redColor,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 6),
                  GetGenericText(
                    text: "-/troy ounce",
                    fontSize: sizes!.isPhone ? 11 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey3Color,
                  ),
                ],
              );
            },
            loading: () => Center(
              child: Container(
                height: sizes!.heightRatio * 10,
                width: sizes!.widthRatio * 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.redColor,
                  strokeWidth: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class LivePriceContainer extends ConsumerWidget {
//   final String title;
//   final bool isSelling;
//   final String todayHighLow;

//   const LivePriceContainer({
//     super.key,
//     required this.title,
//     required this.isSelling,
//     required this.todayHighLow,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       width: sizes!.isPhone ? sizes!.widthRatio * 160 : sizes!.width / 2.1,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.greyScale900,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Consumer(
//         builder: (context, ref, child) {
//           final goldPriceState = ref.watch(goldPriceProvider);
//           return goldPriceState.when(
//             data: (data) {
//               final buyingPrice = data.oneGramBuyingPriceInAED;
//               final sellingPrice = data.oneGramSellingPriceInAED;

//               final oneGramAEDPrice = isSelling ? sellingPrice : buyingPrice;
//               final pricePerOunce = isSelling
//                   ? data.oneOunceDollarSellingPrice
//                   : data.oneOunceDollarBuyingPrice;
//               final lastPrice = isSelling
//                   ? data.lastLowSellingPrice
//                   : data.lastHighBuyingPrice;
//               // debugPrint(
//               //   "Buying: ${buyingPrice.toStringAsFixed(3)} AED | Selling: ${sellingPrice.toStringAsFixed(3)} AED",
//               // );

//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GetGenericText(
//                     text: title,
//                     fontSize: sizes!.isPhone ? 12 : 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                   ConstPadding.sizeBoxWithHeight(height: 6),
//                   GetGenericText(
//                     text: NumberFormat("#,##0.00").format(oneGramAEDPrice),
//                     fontSize: sizes!.isPhone ? 16 : 45,
//                     fontWeight: FontWeight.w500,
//                     color: isSelling
//                         ? AppColors.redColor
//                         : AppColors.greenColor,
//                   ),
//                   ConstPadding.sizeBoxWithHeight(height: 6),
//                   GetGenericText(
//                     text:
//                         "\$${NumberFormat("#,##0.00").format(pricePerOunce)}/troy ounce",
//                     fontSize: sizes!.isPhone ? 11 : 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.grey3Color,
//                   ),
//                   ConstPadding.sizeBoxWithHeight(height: 6),
//                   GetGenericText(
//                     text: "$todayHighLow ${NumberFormat("#,##0.00").format(lastPrice)}",
//                     fontSize: sizes!.isPhone ? 12 : 36,
//                     fontWeight: FontWeight.w400,
//                     color: isSelling
//                         ? AppColors.redColor
//                         : AppColors.greenColor,
//                   ),
//                 ],
//               );
//             },
//             error: (error, stackTrace) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GetGenericText(
//                     text: title,
//                     fontSize: sizes!.isPhone ? 12 : 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                   ConstPadding.sizeBoxWithHeight(height: 6),
//                   GetGenericText(
//                     text: "Price Unavailable",
//                     fontSize: sizes!.isPhone ? 16 : 45,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.redColor,
//                   ),
//                   ConstPadding.sizeBoxWithHeight(height: 6),
//                   GetGenericText(
//                     text: "-/troy ounce",
//                     fontSize: sizes!.isPhone ? 11 : 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.grey3Color,
//                   ),
//                 ],
//               );
//             },
//             loading: () => Center(
//               child: Container(
//                 height: sizes!.heightRatio * 10,
//                 width: sizes!.widthRatio * 10,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                 ),
//                 child: const CircularProgressIndicator(
//                   color: AppColors.redColor,
//                   strokeWidth: 0.5,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
