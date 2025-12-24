import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/news_models/NewsAllResponseModel.dart';

import '../../l10n/app_localizations.dart';

class AllHomeNewsCard extends StatelessWidget {
  final Allnews newsUpdates;

  const AllHomeNewsCard({
    super.key,
    required this.newsUpdates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          GetGenericText(
            text: newsUpdates.title ?? AppLocalizations.of(context)!.title_not_available,
            fontSize: sizes!.isPhone ? 16 : 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFFF2F2F2),
          ),

          /// Description
          GetGenericText(
            text: newsUpdates.description ?? AppLocalizations.of(context)!.description_not_available,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w400,
            color: Color(0xFFBDBDBD),
            lines: 4,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Read More
          GestureDetector(
            onTap: () async {
              String serviceUrl = newsUpdates.url ?? "";
              if (serviceUrl.isNotEmpty) {
                await CommonService.openServiceUrl(serviceUrl: serviceUrl);
              } else {
                Toasts.getWarningToast(
                  text: AppLocalizations.of(context)!.link_not_available,
                );
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.read_more,
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFBBA473),
                  ),
                  ConstPadding.sizeBoxWithWidth(width: 4),
                  SvgPicture.asset(
                    "assets/svg/news_icon.svg",
                    height: sizes!.responsiveHeight(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    width: sizes!.responsiveWidth(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
