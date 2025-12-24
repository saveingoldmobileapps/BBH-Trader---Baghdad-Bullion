// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:saveingold_fzco/core/core_export.dart';
// import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
// import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';

// import '../../../data/models/esouq_model/GetAllProductResponse.dart';

// class OrderDetailScreen extends ConsumerStatefulWidget {
//   final AllProducts product;

//   final String address;
//   final double totalAmount;
//   final String paymentMethod;
//   final String price;
//   final String quantity;

//   const OrderDetailScreen({
//     required this.product,
//     required this.address,
//     required this.totalAmount,
//     required this.paymentMethod,
//     required this.price,
//     required this.quantity,
//     super.key,
//   });

//   @override
//   ConsumerState createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     sizes!.initializeSize(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     /// Refresh sizes on orientation change
//     sizes!.refreshSize(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.greyScale1000,
//         elevation: 0,
//         surfaceTintColor: AppColors.greyScale1000,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         title: GetGenericText(
//           text: "Order Details",
//           fontSize: sizes!.isPhone ? 20 : 24,
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
//               GetGenericText(
//                 text: "Order No. 143142",
//                 fontSize: sizes!.isPhone ? 18 : 22,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.grey6Color,
//               ).getAlign(),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//               GetGenericText(
//                 text: "Your Delivery Address:",
//                 fontSize: sizes!.isPhone ? 16 : 20,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.grey5Color,
//               ).getAlign(),
//               ConstPadding.sizeBoxWithHeight(height: 4),
//               GetGenericText(
//                 text: widget.address,
//                 fontSize: sizes!.isPhone ? 14 : 16,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.grey4Color,
//               ).getAlign(),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//               Container(
//                 width: sizes!.isPhone ? sizes!.widthRatio * 361 : sizes!.width,
//                 height: sizes!.isPhone
//                     ? sizes!.heightRatio * 180
//                     : sizes!.heightRatio * 280,
//                 decoration: BoxDecoration(
//                   color: AppColors.greyScale900,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: AppColors.primaryGold500,
//                     width: 1.5,
//                   ),
//                 ),
//                 child: Center(
//                   child: GetGenericText(
//                     text: "Google Map View",
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.whiteColor,
//                   ),
//                 ),
//               ),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GetGenericText(
//                     text: "Payment Method",
//                     fontSize: sizes!.isPhone ? 15 : 17,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.grey5Color,
//                   ),
//                   GetGenericText(
//                     text: widget.paymentMethod,
//                     fontSize: sizes!.isPhone ? 14 : 16,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.grey4Color,
//                   ),
//                 ],
//               ),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: sizes!.heightRatio * 52,
//                     width: sizes!.widthRatio * 52,
//                     decoration: BoxDecoration(
//                       color: AppColors.whiteColor,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(2),
//                       child: CachedNetworkImage(
//                         imageUrl:
//                             "https://plus.unsplash.com/premium_photo-1678025061438-786888bfcaf1?q=80&w=3424&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//                         fit: BoxFit.cover,
//                         progressIndicatorBuilder:
//                             (context, url, downloadProgress) => SizedBox(
//                           height: sizes!.heightRatio * 10,
//                           width: sizes!.widthRatio * 10,
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: downloadProgress.progress,
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Icon(Icons.error),
//                       ),
//                     ),
//                   ),
//                   ConstPadding.sizeBoxWithWidth(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       GetGenericText(
//                         text:
//                             "${widget.quantity} ${widget.product.productName}",
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.grey6Color,
//                       ),
//                       ConstPadding.sizeBoxWithHeight(height: 2),
//                       GetGenericText(
//                         text: widget.totalAmount.toString(),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                         color: AppColors.grey4Color,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               LoaderButton(
//                 title: "Return to Home",
//                 onTap: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const MainHomeScreen(),
//                     ),
//                     ((route) => false),
//                   );
//                 },
//               ),
//               ConstPadding.sizeBoxWithHeight(height: 16),
//             ],
//           ).get16HorizontalPadding(),
//         ),
//       ),
//     );
//   }
// }
