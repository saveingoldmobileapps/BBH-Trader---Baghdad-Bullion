// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:logger/logger.dart';
// import 'package:saveingold_fzco/core/core_export.dart';
// import 'package:saveingold_fzco/data/models/esouq_model/GetAllProductResponse.dart';
// import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
// import 'package:saveingold_fzco/presentation/feature_injection.dart';
// import 'package:saveingold_fzco/presentation/screens/esouq_screens/order_checkout_screen.dart';
// import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
// import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
//
// enum PaymentMethod {
//   metal,
//   money,
// }
//
// class PaymentMethodScreen extends ConsumerStatefulWidget {
//   final WalletExists walletExists;
//   final AllProducts product;
//   final double goldPrice;
//   final double totalGoldPayablePrice;
//   final double goldItemQuantity;
//   final double deliveryCharges;
//
//   const PaymentMethodScreen({
//     required this.walletExists,
//     required this.product,
//     required this.goldPrice,
//     required this.totalGoldPayablePrice,
//     required this.goldItemQuantity,
//     required this.deliveryCharges,
//     super.key,
//   });
//
//   @override
//   ConsumerState createState() => _EsouqCartScreenState();
// }
//
// class _EsouqCartScreenState extends ConsumerState<PaymentMethodScreen> {
//   var paymentMethod = PaymentMethod.money;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
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
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.greyScale1000,
//         elevation: 0,
//         surfaceTintColor: AppColors.greyScale1000,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         title: GetGenericText(
//           text: "Payment Method",
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
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Metal
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         paymentMethod = PaymentMethod.metal;
//                       });
//                     },
//                     child: Container(
//                       width: sizes!.isPhone
//                           ? sizes!.widthRatio * 160
//                           : sizes!.width / 2.1,
//                       height: sizes!.isPhone
//                           ? sizes!.heightRatio * 160
//                           : sizes!.heightRatio * 280,
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF333333),
//                         borderRadius: BorderRadius.circular(12),
//                         border: paymentMethod == PaymentMethod.metal
//                             ? Border.all(
//                                 width: 1.50,
//                                 color: Color(0xFFBBA473),
//                               )
//                             : null,
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(
//                             "assets/svg/gold_icon.svg",
//                           ),
//                           ConstPadding.sizeBoxWithHeight(height: 12),
//                           GetGenericText(
//                             text: "${CommonService.convertWeight(
//                               grams: double.parse(
//                                 "${widget.walletExists.metalBalance}",
//                               ),
//                             )}\nGram Balance",
//                             fontSize: sizes!.isPhone ? 16 : 20,
//                             fontWeight: FontWeight.w400,
//                             color: AppColors.grey4Color,
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Money
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         paymentMethod = PaymentMethod.money;
//                       });
//                     },
//                     child: Container(
//                       width: sizes!.isPhone
//                           ? sizes!.widthRatio * 160
//                           : sizes!.width / 2.1,
//                       height: sizes!.isPhone
//                           ? sizes!.heightRatio * 160
//                           : sizes!.heightRatio * 280,
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF333333),
//                         borderRadius: BorderRadius.circular(12),
//                         border: paymentMethod == PaymentMethod.money
//                             ? Border.all(
//                                 width: 1.50,
//                                 color: Color(0xFFBBA473),
//                               )
//                             : null,
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(
//                             "assets/svg/money_icon.svg",
//                           ),
//                           ConstPadding.sizeBoxWithHeight(height: 12),
//                           GetGenericText(
//                             text: "${CommonService.convertToShortNum(
//                               num: double.parse(
//                                 "${widget.walletExists.moneyBalance}",
//                               ),
//                             )}\nAED",
//                             fontSize: sizes!.isPhone ? 16 : 20,
//                             fontWeight: FontWeight.w400,
//                             color: AppColors.grey4Color,
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               LoaderButton(
//                 title: "Proceed to Checkout",
//                 onTap: checkAndProceed,
//               ),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//             ],
//           ).get16HorizontalPadding(),
//         ),
//       ),
//     );
//   }
//
//   /// check and proceed
//   void checkAndProceed() async {
//     double walletBalance =
//         double.tryParse(widget.walletExists.moneyBalance?.toString() ?? "0") ??
//             0.0;
//     double walletMetal =
//         double.tryParse(widget.walletExists.metalBalance?.toString() ?? "0") ??
//             0.0;
//
//     getLocator<Logger>().d(
//       "walletBalance: ${walletBalance.toStringAsFixed(3)} | walletMetal: ${walletMetal.toStringAsFixed(3)}",
//     );
//
//     const double epsilon =
//         0.0001; // Small threshold to avoid floating-point precision issues
//
//     if ((walletBalance - 0.0).abs() < epsilon &&
//         (walletMetal - 0.0).abs() < epsilon) {
//       await showInsufficientBalancePopup();
//       return;
//     }
//
//     // Check if selected payment method has sufficient balance
//     bool isMoneyPayment =
//         paymentMethod.toString() == PaymentMethod.money.toString();
//
//     if ((isMoneyPayment && walletBalance < widget.totalGoldPayablePrice) ||
//         (!isMoneyPayment && walletMetal < widget.totalGoldPayablePrice)) {
//       if (!context.mounted) return;
//       await showInsufficientBalancePopup();
//       return;
//     }
//
//     // Proceed to checkout
//     String paymentMethodString = isMoneyPayment ? "Money" : "Metal";
//
//     if (!context.mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OrderCheckoutScreen(
//           product: widget.product,
//           productId: widget.product.id.toString(),
//           deliveryCharges: widget.deliveryCharges,
//           goldPrice: widget.goldPrice,
//           goldQuantity: widget.goldItemQuantity,
//           totalGoldPayableAmount: widget.totalGoldPayablePrice,
//           paymentMethod: paymentMethodString,
//         ),
//       ),
//     );
//   }
//
//   // Helper function to show the insufficient balance popup
//   Future<void> showInsufficientBalancePopup() async {
//     if (!context.mounted) return;
//     await genericPopUpWidget(
//       context: context,
//       heading: "Insufficient Balance",
//       subtitle: "Please add funds into your account to buy gold.",
//       noButtonTitle: "Close",
//       yesButtonTitle: "Add Funds",
//       isLoadingState: false,
//       onNoPress: () => Navigator.pop(context),
//       onYesPress: () async {}, // Handle add funds action
//     );
//   }
// }
