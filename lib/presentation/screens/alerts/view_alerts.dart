import 'package:flutter/cupertino.dart'; // For the iOS style switch
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/presentation/screens/alerts/add_alert.dart';

import '../../../core/enums/loading_state.dart';
import '../../../core/theme/const_colors.dart';
import '../../../core/theme/get_generic_text_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/alert_provider/alert_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart'; // Import live provider
import '../../widgets/no_data_widget.dart';

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
  // Widget build(BuildContext context) {
  //   final alertState = ref.watch(alertAllProvider);
  //   final alerts = alertState.alerts ?? [];

  //   return Scaffold(
  //     backgroundColor: AppColors.greyScale1000,
  //     appBar: AppBar(
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back, color: Colors.white),
  //         onPressed: () => Navigator.of(context).pop(),
  //       ),
  //       backgroundColor: AppColors.greyScale1000,
  //       elevation: 0,
  //       title: GetGenericText(
  //         text: AppLocalizations.of(context)!.active_alerts,
  //         fontSize: 20,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.white,
  //       ),
  //     ),
  //     bottomNavigationBar: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF91712F),
  //             minimumSize: const Size(double.infinity, 56),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //           ),
  //           onPressed: () => _navigateToCreate(context),
  //           child: Text(
  //             AppLocalizations.of(context)!.create_new_alert,
  //             //"Create new alert",
  //             style: TextStyle(color: Colors.white, fontSize: 16),
  //           ),
  //         ),
  //       ),
  //     ),
  //     body: alertState.loadingState == LoadingState.loading
  //         ? const Center(
  //             child: CircularProgressIndicator(color: AppColors.primaryGold500),
  //           )
  //         : alerts.isEmpty
  //         ? Center(
  //             child: NoDataWidget(
  //               title: AppLocalizations.of(context)!.no_active_alert_at_moment,//"No active alert available at the moment.",
  //               description: "",
  //             ),
  //           )
  //         : ListView.builder(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             itemCount: alerts.length,
  //             itemBuilder: (context, index) {
  //               final alert = alerts[index];
  //               return InkWell(
  //                 onTap: () async {
  //                   await Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => CreateAlertScreen(alert: alert),
  //                     ),
  //                   ).then(
  //                     (_) => ref.read(alertAllProvider.notifier).fetchAlerts(),
  //                   );
  //                 },
  //                 child: _AlertItemCard(
  //                   alert: alert,
  //                 ),
  //               ); // Extracted for clean live updates
  //             },
  //           ),
  //   );
  // }
  @override
Widget build(BuildContext context) {
  final alertState = ref.watch(alertAllProvider);

  /// ✅ Clone + Sort Alerts (Latest First)
  final alerts = [...(alertState.alerts ?? [])]
    ..sort((a, b) {
      final dateA = DateTime.tryParse(
            a.createdAt ?? a.updatedAt ?? '',
          ) ??
          DateTime(0);

      final dateB = DateTime.tryParse(
            b.createdAt ?? b.updatedAt ?? '',
          ) ??
          DateTime(0);

      return dateB.compareTo(dateA); // 🔥 latest first
    });

  return Scaffold(
    backgroundColor: AppColors.greyScale1000,

    /// 🔝 APP BAR
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.greyScale1000,
      elevation: 0,
      title: GetGenericText(
        text: AppLocalizations.of(context)!.active_alerts,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    /// 🔽 CREATE ALERT BUTTON
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF91712F),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _navigateToCreate(context),
          child: Text(
            AppLocalizations.of(context)!.create_new_alert,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ),

    /// 📄 BODY
    body: alertState.loadingState == LoadingState.loading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold500,
            ),
          )
        : alerts.isEmpty
            ? Center(
                child: NoDataWidget(
                  title: AppLocalizations.of(context)!
                      .no_active_alert_at_moment,
                  description: "",
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];

                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreateAlertScreen(alert: alert),
                        ),
                      );

                      /// 🔄 Refresh after returning
                      ref.read(alertAllProvider.notifier).fetchAlerts();
                    },
                    child: _AlertItemCard(alert: alert),
                  );
                },
              ),
  );
}
  void _navigateToCreate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateAlertScreen()),
    );
    ref.read(alertAllProvider.notifier).fetchAlerts();
  }
}

class _AlertItemCard extends ConsumerWidget {
  final dynamic alert; // Use your actual Alert Model type here
  const _AlertItemCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldPriceState = ref.watch(goldPriceProvider);
    final isSelling = alert.alertType?.toLowerCase() == 'sell';

    return goldPriceState.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) =>
          const Text("Price error", style: TextStyle(color: Colors.red)),
      data: (liveData) {
        // 1. Get Dynamic Live Price
        final currentPrice = isSelling
            ? liveData.oneGramSellingPriceInIQD
            : liveData.oneGramBuyingPriceInIQD;

        // 2. Calculate Dynamic Difference
        final targetPrice = alert.price ?? 0.0;
        final difference = targetPrice - currentPrice;
        final diffColor = isSelling
            ? (difference >= 0 ? Colors.green : Colors.red)
            : (difference <= 0 ? Colors.red : Colors.red);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF262929),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelling
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isSelling ? Icons.trending_up : Icons.trending_down,
                      color: isSelling ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSelling ? AppLocalizations.of(context)!.alert_selling:AppLocalizations.of(context)!.alert_buying,//"Selling alert" : "Buying alert",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         Text(
                          AppLocalizations.of(context)!.active_alerts,//"Active Alert",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      bool confirm = await _showDeleteDialog(context);
                      if (confirm) {
                        await ref
                            .read(alertAllProvider.notifier)
                            .deleteAlert(alertId: alert.id.toString());
                           ref.read(alertAllProvider.notifier).fetchAlerts();
                      }
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFC5A358),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _row(
                AppLocalizations.of(context)!.gram_current_price,
                //"Current Price",
                "${AppLocalizations.of(context)!.idq_currency} ${NumberFormat("#,##0.000").format(currentPrice)}",
                //"IQD ${NumberFormat("#,##0.00").format(currentPrice)}",
                Colors.white,
              ),
              _row(
                AppLocalizations.of(context)!.gram_target_price,
                //"Target Price",
                "${AppLocalizations.of(context)!.idq_currency} ${NumberFormat("#,##0.000").format(targetPrice)}",
                //"IQD ${NumberFormat("#,##0.000").format(targetPrice)}",
                const Color(0xFFC5A358),
              ),
              _row(
                AppLocalizations.of(context)!.active_difference,
                "${difference >= 0 ? '+' : ''}${AppLocalizations.of(context)!.idq_currency} ${NumberFormat("#,##0.000").format(difference)}",
                diffColor,
              ),
              const Divider(color: Colors.white10, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(AppLocalizations.of(context)!.active_title, style: TextStyle(color: Colors.grey)),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: true,
                      activeTrackColor: const Color(0xFF91712F),
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    bool confirm = false;
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
              confirm = true;
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
    return confirm;
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

void _navigateToCreate(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CreateAlertScreen()),
  );
}

void _confirmDelete(String id) async {
  // Implement your delete logic here as per the original code
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
