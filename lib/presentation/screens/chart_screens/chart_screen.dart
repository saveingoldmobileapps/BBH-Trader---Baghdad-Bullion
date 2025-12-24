// import 'dart:math';
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:saveingold_fzco/core/core_export.dart';
//
// import '../../../data/models/gold_price_model/CurrentGoldPriceModel.dart';
// import '../../sharedProviders/providers/gold_price_provider/gold_price_provider.dart';
//
// final selectedFilterProvider = StateProvider<String>((ref) => "1H");
//
// class ChartScreen extends ConsumerStatefulWidget {
//   const ChartScreen({super.key});
//
//   @override
//   ConsumerState createState() => _ChartScreenState();
// }
//
// class _ChartScreenState extends ConsumerState<ChartScreen> {
//   String selectedFilter = "1H"; // Default filter
//   List<FlSpot> chartData = [];
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     sizes!.initializeSize(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     sizes!.refreshSize(context);
//     final goldPriceStateWatchProvider = ref.watch(goldPriceProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.greyScale1000,
//         elevation: 0,
//         surfaceTintColor: AppColors.greyScale1000,
//         foregroundColor: Colors.white,
//         centerTitle: false,
//         titleSpacing: 0,
//         title: GetGenericText(
//           text: "Chart",
//           fontSize: 20,
//           fontWeight: FontWeight.w400,
//           color: AppColors.grey6Color,
//         ),
//       ),
//       body: Container(
//         height: sizes!.height,
//         width: sizes!.width,
//         decoration: const BoxDecoration(
//           color: AppColors.greyScale1000,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               ConstPadding.sizeBoxWithHeight(height: 10),
//               goldPriceStateWatchProvider
//                   .when(
//                     data: (data) {
//                       final aed = 3.674; // 1 USD to AED
//                       final ounce = 31.10347; // 1 ounce in grams
//
//                       // Access the last price entry
//                       final lastPrice =
//                           data.currentGoldPriceModel.payload?.prices?.last;
//                       final goldPricePerOunce =
//                           lastPrice?.price ?? 0.0; // Using 'price' field
//
//                       final oneGramAEDPrice = (goldPricePerOunce * aed) / ounce;
//
//                       chartData = _generateChartDataFromResponse(
//                         data.currentGoldPriceModel,
//                         ref.read(selectedFilterProvider),
//                       );
//
//                       return GetGenericText(
//                         text:
//                             "1g Gold ${oneGramAEDPrice.toStringAsFixed(2)} AED",
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.primaryGold500,
//                       );
//                     },
//                     error: (error, stackTrace) {
//                       return GetGenericText(
//                         text: error.toString(),
//                         fontSize: sizes!.isPhone ? 16 : 45,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.redColor,
//                       );
//                     },
//                     loading: () => Center(
//                       child: CircularProgressIndicator(
//                         color: AppColors.redColor,
//                         strokeWidth: 0.5,
//                       ),
//                     ),
//                   )
//                   .getAlign(),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//
//               /// **Time Filter Buttons**
//               SingleChildScrollView(
//                 // scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     _timeFilterButton("1H"),
//                     _timeFilterButton("1D"),
//                     _timeFilterButton("1W"),
//                     _timeFilterButton("1M"),
//                     _timeFilterButton("3M"),
//                     _timeFilterButton("6M"),
//                   ],
//                 ),
//               ),
//
//               ConstPadding.sizeBoxWithHeight(height: 40),
//
//               Expanded(
//                 child: chartData.isNotEmpty
//                     ? LayoutBuilder(
//                         builder: (context, constraints) {
//                           return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             controller: ScrollController(
//                               initialScrollOffset: chartData.length * 32,
//                             ),
//                             child: SizedBox(
//                               width: max(
//                                 chartData.length * 32,
//                                 constraints.maxWidth,
//                               ),
//                               child: LineChart(
//                                 _generateChartUI(
//                                   chartData.reversed.toList(),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       )
//                     : Center(
//                         child: GetGenericText(
//                           text: "No data available",
//                           fontSize: 16,
//                           fontWeight: FontWeight.w400,
//                           color: AppColors.grey6Color,
//                         ),
//                       ),
//               ),
//
//               ConstPadding.sizeBoxWithHeight(height: 20),
//             ],
//           ).get16HorizontalPadding(),
//         ),
//       ),
//     );
//   }
//
//   /// **Filter Button**
//   Widget _timeFilterButton(String text) {
//     bool isSelected = text == ref.watch(selectedFilterProvider);
//     return GestureDetector(
//       onTap: () {
//         ref.read(selectedFilterProvider.notifier).state =
//             text; // Update the selected filter
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primaryGold500 : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: GetGenericText(
//           text: text,
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//           color: isSelected ? Colors.white : AppColors.grey6Color,
//         ),
//       ),
//     );
//   }
//
//   List<FlSpot> _generateChartDataFromResponse(
//     CurrentGoldPriceModel model,
//     String filter,
//   ) {
//     final prices = model.payload?.prices ?? [];
//     List<FlSpot> spots = [];
//
//     int maxPoints = _getMaxPointsForFilter(filter);
//     int startIndex = max(0, prices.length - maxPoints);
//
//     for (int i = startIndex; i < prices.length; i++) {
//       final price = prices[i].price ?? 0.0;
//       spots.add(FlSpot((i - startIndex).toDouble(), price.toDouble()));
//     }
//
//     return spots;
//   }
//
//   int _getMaxPointsForFilter(String filter) {
//     switch (filter) {
//       case "1H":
//         return 60;
//       case "1D":
//         return 24;
//       case "1W":
//         return 7;
//       case "1M":
//         return 30;
//       case "3M":
//         return 90;
//       case "6M":
//         return 180;
//       default:
//         return 24;
//     }
//   }
//
//   LineChartData _generateChartUI(List<FlSpot> chartData) {
//     if (chartData.isEmpty) {
//       return LineChartData();
//     }
//
//     // Conversion factors
//     final double aed = 3.674; // 1 USD to AED
//     final double ounce = 31.10347; // 1 ounce in grams
//
//     List<double> prices = chartData.map((spot) => spot.y).toList();
//
//     // Calculate min and max prices
//     double minPrice = prices.reduce(min);
//     double maxPrice = prices.reduce(max);
//
//     double interval = 0.2;
//
//     double minY = (minPrice / interval).floor() * interval;
//     double maxY = (maxPrice / interval).ceil() * interval;
//
//     if (maxY < maxPrice) {
//       maxY += interval;
//     }
//
//     return LineChartData(
//       backgroundColor: AppColors.greyScale1000,
//       gridData: FlGridData(
//         show: true,
//         drawVerticalLine: false,
//         horizontalInterval: interval,
//         getDrawingHorizontalLine: (value) {
//           return FlLine(
//             color: Colors.grey.withOpacity(0.2),
//             strokeWidth: 1,
//             dashArray: [5, 5],
//           );
//         },
//       ),
//       minY: minY,
//       maxY: maxY,
//       titlesData: FlTitlesData(
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 60,
//             interval: interval,
//             getTitlesWidget: (value, meta) {
//               // Convert the displayed value to AED
//               final aedValue = value * aed / ounce;
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: Text(
//                   '${aedValue.toStringAsFixed(2)} AED',
//                   // Changed to AED with 2 decimal places
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         rightTitles: AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             interval: _getBottomTitleInterval(chartData.length),
//             getTitlesWidget: (value, meta) {
//               String title;
//               if (selectedFilter == "1H") {
//                 title = "${value.toInt()}m";
//               } else if (selectedFilter == "1D") {
//                 title = "${value.toInt()}h";
//               } else {
//                 title = "${value.toInt()}d";
//               }
//               return Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text(
//                   title,
//                   style: const TextStyle(color: Colors.white, fontSize: 10),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       borderData: FlBorderData(show: false),
//       lineBarsData: [
//         LineChartBarData(
//           spots: chartData,
//           dotData: FlDotData(show: false),
//           isCurved: true,
//           color: AppColors.primaryGold500,
//           barWidth: 2,
//           isStrokeCapRound: true,
//           belowBarData: BarAreaData(
//             show: true,
//             gradient: LinearGradient(
//               colors: [
//                 AppColors.primaryGold500.withOpacity(0.2),
//                 Colors.transparent,
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   double _getBottomTitleInterval(int dataLength) {
//     if (dataLength <= 10) return 1;
//     if (dataLength <= 30) return 5;
//     if (dataLength <= 60) return 10;
//     if (dataLength <= 120) return 20;
//     return 30;
//   }
// }
