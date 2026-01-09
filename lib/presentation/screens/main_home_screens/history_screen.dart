import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/history_screens/metal_statement_screen.dart';
import 'package:saveingold_fzco/presentation/screens/history_screens/money_statement_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../notification_screens/notification_screen.dart';

enum HistoryType {
  metal,
  money,
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState createState() => _MetalScreenState();
}

class _MetalScreenState extends ConsumerState<HistoryScreen> {
  var historyType = HistoryType.metal;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => Navigator.pop(context),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF53482A), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. New Header with Profile, Search, and Notification
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState!.openDrawer(),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          "assets/images/profile_placeholder.png",
                        ), // Replace with your image logic
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Search",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/notify_icon.svg",
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Title Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.history,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Your existing export logic
                      },
                    ),
                  ],
                ),
              ),

              // 3. Redesigned Tabs
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab(l10n.metal, HistoryType.metal),
                    _buildTab(l10n.money, HistoryType.money),
                  ],
                ),
              ),

              // 4. Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (historyType == HistoryType.metal)
                        const MetalStatementScreen(),
                      if (historyType == HistoryType.money)
                        const MoneyStatementScreen(),
                    ],
                  ).get16HorizontalPadding(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, HistoryType type) {
    bool isSelected = historyType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => historyType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xff90722f), // left
                      Color(0xff74540e), // center (different)
                      Color(0xff90722f), // right
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
