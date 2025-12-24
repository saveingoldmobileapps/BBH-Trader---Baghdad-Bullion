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

                            // Calculate if text is long
                            final bool isLongTitle =
                                (notification.title ?? '').length > 40;
                            final bool isLongMessage =
                                (notification.message ?? '').length > 100;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical:
                                    sizes!.heightRatio *
                                    6, // Space between cards
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: sizes!.widthRatio * 16,
                                vertical:
                                    sizes!.heightRatio *
                                    (isLongTitle || isLongMessage ? 16 : 12),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyScale800,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.4,
                                    ), // Subtle shadow
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(
                                      0,
                                      0,
                                    ), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // // Title with dynamic font size
                                  // GetGenericText(
                                  //   text: notification.title ?? "",
                                  //   fontSize: _getTitleFontSize(
                                  //     notification.title ?? "",
                                  //     sizes!,
                                  //   ),
                                  //   fontWeight: FontWeight.w600, // Bolder title
                                  //   color: AppColors.grey6Color,
                                  //   lines: 2,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  GetGenericText(
                                    text:
                                        Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'ar'
                                        ? notification.titleInArabic ??
                                              notification.title ??
                                              ""
                                        : notification.title ?? "",
                                    fontSize: _getTitleFontSize(
                                      Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? notification.titleInArabic ??
                                                notification.title ??
                                                ""
                                          : notification.title ?? "",
                                      sizes!,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey6Color,
                                    lines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  ConstPadding.sizeBoxWithHeight(height: 8),
                                  // Message with dynamic sizing
                                  // GetGenericText(
                                  //   text: notification.message ?? "",
                                  //   fontSize: _getMessageFontSize(
                                  //     notification.message ?? "",
                                  //     sizes!,
                                  //   ),
                                  //   fontWeight: FontWeight.w400,
                                  //   color: AppColors.grey6Color,
                                  //   lines: 4,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
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
                                    fontSize: _getMessageFontSize(
                                      Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? notification.messageInArabic ??
                                                notification.message ??
                                                ""
                                          : notification.message ?? "",
                                      sizes!,
                                    ),
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey6Color,
                                    lines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  ConstPadding.sizeBoxWithHeight(height: 12),
                                  // Timestamp
                                  GetGenericText(
                                    text: CommonService.formatTimeAgo(
                                      notification.createdAt!,
                                      isArabic:
                                          Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'ar',
                                    ),
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 10,
                                      tabletVal: 14,
                                    ),
                                    fontWeight: FontWeight.w400,
                                    color: AppColors
                                        .greyScale10, // Lighter grey for timestamp
                                  ),

                                  // GetGenericText(
                                  //   text: CommonService.formatTimeAgo(
                                  //     notification.createdAt!,
                                  //   ),
                                  //   fontSize: sizes!.responsiveFont(
                                  //     phoneVal: 10,
                                  //     tabletVal: 14,
                                  //   ),
                                  //   fontWeight: FontWeight.w400,
                                  //   color: AppColors
                                  //       .greyScale10, // Lighter grey for timestamp
                                  // ),
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
