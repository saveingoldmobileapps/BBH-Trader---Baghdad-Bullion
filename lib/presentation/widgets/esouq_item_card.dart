import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class EsouqItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String itemPrice;
  final VoidCallback onTap;
  final VoidCallback onTapAddToCart;

  const EsouqItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.itemPrice,
    required this.onTap,
    required this.onTapAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 150 : sizes!.width,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          // crossAxisAlignment:
          crossAxisAlignment: sizes!.isPhone
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: sizes!.responsiveHeight(phoneVal: 240, tabletVal: 290),
              width: sizes!.responsiveWidth(phoneVal: 180, tabletVal: 320),
              // width: sizes!.isPhone ? sizes!.widthRatio * 180 : sizes!.width,
              // height: sizes!.isPhone
              //     ? sizes!.heightRatio * 250
              //     : sizes!.heightRatio * (sizes!.isLandscape() ? 320 : 290),
              decoration: BoxDecoration(
                color: AppColors.primaryGold500,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SizedBox(
                    height: sizes!.heightRatio * 20,
                    width: sizes!.widthRatio * 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold500,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            ConstPadding.sizeBoxWithHeight(height: 10),
            GetGenericText(
              text: title,
              fontSize: sizes!.isPhone ? 16 : 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              lines: 3,
            ),
            ConstPadding.sizeBoxWithHeight(height: 2),
            Directionality.of(context) == TextDirection.rtl
                ? Row(
                    mainAxisAlignment: sizes!.isPhone
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,

                    children: [
                      GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.aed_currency, //"AED",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),

                      ConstPadding.sizeBoxWithWidth(width: 4),
                      GetGenericText(
                        text: itemPrice,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 18,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: sizes!.isPhone
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,

                    children: [
                      GetGenericText(
                        text: itemPrice,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 18,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 4),
                      GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.aed_currency, //"AED",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class EsouqItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String itemPrice;
  final VoidCallback onTap;
  final VoidCallback onTapAddToCart;

  const EsouqItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.itemPrice,
    required this.onTap,
    required this.onTapAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isLTR = Directionality.of(context) == TextDirection.ltr;

    // ✅ Convert price to Arabic digits if RTL
    final displayPrice = isLTR
        ? itemPrice
        : CommonService.toArabicDigits(itemPrice);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 150 : sizes!.width,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              sizes!.isPhone ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: sizes!.responsiveHeight(phoneVal: 240, tabletVal: 290),
              width: sizes!.responsiveWidth(phoneVal: 180, tabletVal: 320),
              decoration: BoxDecoration(
                color: AppColors.primaryGold500,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SizedBox(
                    height: sizes!.heightRatio * 20,
                    width: sizes!.widthRatio * 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold500,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            ConstPadding.sizeBoxWithHeight(height: 10),
            GetGenericText(
              text: title,
              fontSize: sizes!.isPhone ? 16 : 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              lines: 3,
            ),
            ConstPadding.sizeBoxWithHeight(height: 2),

            // ✅ Dynamic row layout based on text direction
            Row(
              mainAxisAlignment: sizes!.isPhone
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: isLTR
                  ? [
                      GetGenericText(
                        text: displayPrice,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 18,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 4),
                      GetGenericText(
                        text: AppLocalizations.of(context)!.aed_currency,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                    ]
                  : [
                      GetGenericText(
                        text: AppLocalizations.of(context)!.aed_currency,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 4),
                      GetGenericText(
                        text: displayPrice,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 18,
                          tabletVal: 22,
                        ),
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGold500,
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
