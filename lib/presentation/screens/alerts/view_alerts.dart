import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/presentation/screens/alerts/add_alert.dart';

import '../../../core/enums/loading_state.dart';
import '../../../core/res_sizes/res.dart';
import '../../../core/theme/const_colors.dart';
import '../../../core/theme/get_generic_text_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/alert_provider/alert_provider.dart';

class ActiveAlertsScreen extends ConsumerStatefulWidget {
  const ActiveAlertsScreen({super.key});

  @override
  ConsumerState<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends ConsumerState<ActiveAlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(alertAllProvider.notifier).fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertAllProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold500,
        child: Icon(
          Icons.add_rounded,
          color: AppColors.greyScale900,
          size: 32,
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateAlertScreen()),
          ).then((_) {
            // Refresh list after adding new alert
            ref.read(alertAllProvider.notifier).fetchAlerts();
          });
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.active_alerts,
          fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
          isInter: true,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: Builder(
          builder: (_) {
            if (alertState.loadingState == LoadingState.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (alertState.loadingState == LoadingState.error) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.no_active_alerts,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final alerts = alertState.alerts ?? [];

            if (alerts.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.no_active_alerts,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];

                return Dismissible(
                  key: Key(alert.id.toString()),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.green,
                    alignment: AlignmentDirectional.centerStart, // changed
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd, // changed
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe → Edit
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateAlertScreen(alert: alert),
                        ),
                      ).then((_) {
                        ref.read(alertAllProvider.notifier).fetchAlerts();
                      });
                      return false; // prevent auto dismiss
                    } else if (direction == DismissDirection.endToStart) {
                      // Swipe → Delete
                      bool confirmDelete = false;

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.greyScale900,
                          title: Text(
                            AppLocalizations.of(context)!.delete_alert,
                            style: const TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.delete_alert_message,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                confirmDelete = true;
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete) {
                        await ref
                            .read(alertAllProvider.notifier)
                            .deleteAlert(alertId: alert.id.toString());
                      }

                      return false;
                    }
                    return false;
                  },
                  child: Card(
                    color: const Color(0xFF333333),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Directionality.of(context) == TextDirection.rtl
                        ? ListTile(
                            leading: Icon(
                              Icons.notifications_active,
                              color: AppColors.primaryGold500,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.gram_price_script ??
                                  "",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${_getArabicAlertType(alert.alertType)} | ${_getArabicCondition(alert.condition)} ${alert.price!.toStringAsFixed(2) ?? ""} ${AppLocalizations.of(context)!.aed_currency}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListTile(
                            leading: Icon(
                              Icons.notifications_active,
                              color: AppColors.primaryGold500,
                            ),
                            title: Text(
                              alert.script ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${alert.alertType ?? ""} | ${alert.condition ?? ""} ${alert.price!.toStringAsFixed(2) ?? ""} ${AppLocalizations.of(context)!.aed_currency}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                  ),
                );

                // Dismissible(
                //   key: Key(alert.id.toString()),
                //   direction: DismissDirection.horizontal,
                //   background: Container(
                //     color: Colors.green,
                //     alignment: Alignment.centerLeft,
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     child: const Icon(Icons.edit, color: Colors.white),
                //   ),
                //   secondaryBackground: Container(
                //     color: Colors.red,
                //     alignment: Alignment.centerRight,
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     child: const Icon(Icons.delete, color: Colors.white),
                //   ),
                //   confirmDismiss: (direction) async {
                //     if (direction == DismissDirection.startToEnd) {
                //       // Swipe Right → Edit
                //       await Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => CreateAlertScreen(
                //             alert: alert,
                //           ),
                //         ),
                //       ).then((_) {
                //         ref.read(alertAllProvider.notifier).fetchAlerts();
                //       });
                //       return false; // prevent auto dismiss
                //     } else if (direction == DismissDirection.endToStart) {
                //       // Swipe Left → Delete
                //       bool confirmDelete = false;

                //       await showDialog(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           backgroundColor: AppColors.greyScale900,
                //           title: Text(
                //             AppLocalizations.of(context)!.delete_alert,
                //             style: TextStyle(color: Colors.white),
                //           ),
                //           content: Text(
                //             AppLocalizations.of(context)!.delete_alert_message,
                //             style: TextStyle(color: Colors.white70),
                //           ),
                //           actions: [
                //             TextButton(
                //               onPressed: () => Navigator.pop(context),
                //               child: Text(
                //                 AppLocalizations.of(context)!.cancel,
                //                 style: TextStyle(color: Colors.white70),
                //               ),
                //             ),
                //             TextButton(
                //               onPressed: () {
                //                 confirmDelete = true;
                //                 Navigator.pop(context);
                //               },
                //               child: Text(
                //                 AppLocalizations.of(context)!.delete,
                //                 style: TextStyle(color: Colors.red),
                //               ),
                //             ),
                //           ],
                //         ),
                //       );

                //       if (confirmDelete) {
                //         await ref
                //             .read(alertAllProvider.notifier)
                //             .deleteAlert(alertId: alert.id.toString());
                //       }

                //       return false; // prevent auto dismiss
                //     }

                //     return false;
                //   },
                //   child: Card(
                //     color: const Color(0xFF333333),
                //     margin: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 6,
                //     ),
                //     child: ListTile(
                //       leading: Icon(
                //         Icons.notifications_active,
                //         color: AppColors.primaryGold500,
                //       ),
                //       title: Text(
                //         alert.script ?? "",
                //         style: const TextStyle(color: Colors.white),
                //       ),
                //       subtitle: Text(
                //         "${alert.alertType ?? ""} | ${alert.condition ?? ""} ${alert.price ?? ""}",
                //         style: const TextStyle(color: Colors.white70),
                //       ),
                //     ),
                //   ),
                // );
              },
            );
          },
        ),
      ),
    );
  }

  String _getArabicAlertType(String? type) {
    switch (type?.toLowerCase()) {
      case "buy":
        return "شراء";
      case "sell":
        return "بيع";
      default:
        return type ?? "";
    }
  }

  String _getArabicCondition(String? condition) {
    switch (condition?.toLowerCase()) {
      case "less":
        return "أقل";
      case "more":
        return "أكثر";
      default:
        return condition ?? "";
    }
  }
}
