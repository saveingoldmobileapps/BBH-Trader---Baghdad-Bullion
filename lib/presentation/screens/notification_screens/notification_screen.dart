import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/notification_provider/notification_provider.dart';

import '../../widgets/no_data_widget.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Refresh sizes on orientation change
    sizes!.initializeSize(context);
  }

  List<String> _extractGoldChips(String message) {
    final List<String> chips = [];

    /// Match grams (e.g. 1g, 10 grams, 5 gram(s))
    final gramRegex = RegExp(
      r'(\d+(\.\d+)?)\s*(g|gram|grams)',
      caseSensitive: false,
    );
    final gramMatch = gramRegex.firstMatch(message);
    if (gramMatch != null) {
      chips.add("${gramMatch.group(1)}g");
    }

    /// Match price (e.g. 544.23 AED, AED 544.23)
    final priceRegex = RegExp(
      r'(AED|IQD)\s*(\d+(\.\d+)?)|(\d+(\.\d+)?)\s*(AED|IQD)',
      caseSensitive: false,
    );
    final priceMatch = priceRegex.firstMatch(message);
    if (priceMatch != null) {
      final currency = priceMatch.group(1) ?? priceMatch.group(6);
      final amount = priceMatch.group(2) ?? priceMatch.group(4);
      if (currency != null && amount != null) {
        chips.add("$currency $amount");
      }
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.notification, //"Notifications",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
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
          child: RefreshIndicator(
            backgroundColor: AppColors.primaryGold500,
            color: AppColors.whiteColor,
            onRefresh: () async {
              await ref
                  .read(notificationProvider.notifier)
                  .fetchNotifications();
            },
            child: Column(
              children: [
                Expanded(
                  child: notificationState.isLoading
                      ? Center(
                          child: ShimmerLoader(
                            loop: 6,
                          ).get6HorizontalPadding(),
                        )
                      : notificationState.notifications.isEmpty
                      ? Center(
                          child: NoDataWidget(
                            title: AppLocalizations.of(
                              context,
                            )!.empty_no_data, //"No Data To Show",
                            description: AppLocalizations.of(
                              context,
                            )!.no_notification, //"No Notification found",
                          ),
                        )
                      : ListView.builder(
                          itemCount: notificationState.notifications.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final notification =
                                notificationState.notifications[index];
                            final chips = _extractGoldChips(
                              Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? notification.messageInArabic ??
                                        notification.message ??
                                        ""
                                  : notification.message ?? "",
                            );
                            // Calculate if text is long
                            final bool isLongTitle =
                                (notification.title ?? '').length > 40;
                            final bool isLongMessage =
                                (notification.message ?? '').length > 100;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical: sizes!.heightRatio * 6,
                              ),
                              padding: EdgeInsets.all(sizes!.widthRatio * 14),
                              decoration: BoxDecoration(
                                color: Color(0xff262929),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// LEFT AVATAR
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryGold500,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: GetGenericText(
                                        text: "AM",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryGold500,
                                      ),
                                    ),
                                  ),

                                  ConstPadding.sizeBoxWithWidth(width: 12),

                                  /// RIGHT CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TITLE + TIME
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GetGenericText(
                                                text:
                                                    Localizations.localeOf(
                                                          context,
                                                        ).languageCode ==
                                                        'ar'
                                                    ? notification
                                                              .titleInArabic ??
                                                          notification.title ??
                                                          ""
                                                    : notification.title ?? "",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.grey6Color,
                                                lines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            ConstPadding.sizeBoxWithWidth(
                                              width: 8,
                                            ),
                                            GetGenericText(
                                              text: CommonService.formatTimeAgo(
                                                notification.createdAt!,
                                                isArabic:
                                                    Localizations.localeOf(
                                                      context,
                                                    ).languageCode ==
                                                    'ar',
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.greyScale10,
                                            ),
                                          ],
                                        ),

                                        ConstPadding.sizeBoxWithHeight(
                                          height: 6,
                                        ),

                                        /// MESSAGE
                                        GetGenericText(
                                          text:
                                              Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'ar'
                                              ? notification.messageInArabic ??
                                                    notification.message ??
                                                    ""
                                              : notification.message ?? "",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.grey4Color,
                                          lines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        ConstPadding.sizeBoxWithHeight(
                                          height: 10,
                                        ),

                                        /// TAGS / CHIPS (OPTIONAL – SAFE)
                                        if (chips.isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: chips
                                                .map(_goldChip)
                                                .toList(),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }

  Widget _goldChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2418),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBBA473),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFFBBA473),
        ),
      ),
    );
  }

  // Dynamic font size calculation for title based on text length
  double _getTitleFontSize(String text, AppSizes sizes) {
    if (text.length > 60) {
      return sizes.responsiveFont(phoneVal: 14, tabletVal: 16);
    } else if (text.length > 40) {
      return sizes.responsiveFont(phoneVal: 15, tabletVal: 17);
    } else {
      return sizes.responsiveFont(phoneVal: 16, tabletVal: 18);
    }
  }

  // Dynamic font size calculation for message based on text length
  double _getMessageFontSize(String text, AppSizes sizes) {
    if (text.length > 200) {
      return sizes.responsiveFont(phoneVal: 12, tabletVal: 14);
    } else if (text.length > 100) {
      return sizes.responsiveFont(phoneVal: 13, tabletVal: 15);
    } else {
      return sizes.responsiveFont(phoneVal: 14, tabletVal: 16);
    }
  }
}
