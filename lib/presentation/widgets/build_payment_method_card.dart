// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../../core/core_export.dart';

// class BuildPaymentMethodCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String iconString;
//   final VoidCallback onTap;

//   const BuildPaymentMethodCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.iconString,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: sizes!.isPhone ? sizes!.widthRatio * 361 : sizes!.width,
//         padding: const EdgeInsets.all(12),
//         decoration: ShapeDecoration(
//           color: Color(0xFF262929),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SvgPicture.asset(
//               iconString,
//               height: sizes!.heightRatio * 24,
//               width: sizes!.widthRatio * 24,
//             ),
//             ConstPadding.sizeBoxWithWidth(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GetGenericText(
//                   text: title,
//                   fontSize: sizes!.isPhone ? 14 : 20,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.grey6Color,
//                 ),
//                 GetGenericText(
//                   text: subtitle,
//                   fontSize: sizes!.isPhone ? 11 : 14,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.grey3Color,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/core_export.dart';

class BuildPaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final VoidCallback onTap;

  const BuildPaymentMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.onTap,
  });

  bool get isSvg => iconString.toLowerCase().endsWith(".svg");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone
            ? sizes!.widthRatio * 361
            : sizes!.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: ShapeDecoration(
          color:  Color(0xFF262929),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ICON CONTAINER
            Container(
              height: sizes!.isPhone ? 54 : 64,
              width: sizes!.isPhone ? 54 : 64,
              //padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold500.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isSvg
                  ? SvgPicture.asset(
                      iconString,
                      fit: BoxFit.fill,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryGold500,
                        BlendMode.srcIn,
                      ),
                    )
                  : Image.asset(
                      iconString,
                      fit: BoxFit.cover,
                      color: AppColors.primaryGold500,
                      height: sizes!.heightRatio * 34,
                    width: sizes!.widthRatio * 34,
                    ),
            ),

            ConstPadding.sizeBoxWithWidth(width: 14),

            /// TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetGenericText(
                    text: title,
                    fontSize: sizes!.isPhone ? 15 : 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey6Color,
                  ),

                  const SizedBox(height: 4),

                  GetGenericText(
                    text: subtitle,
                    fontSize: sizes!.isPhone ? 12 : 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}