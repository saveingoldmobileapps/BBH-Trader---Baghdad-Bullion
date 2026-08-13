import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/screens/history_screens/metal_statement_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/history_screens/money_statement_screen.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import '../../sharedProviders/providers/home_provider.dart';
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
    final mainStateWatchProvider = ref.watch(homeProvider);
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    /// Profile Avatar with network/cached image logic
                    FutureBuilder<String?>(
                      future: LocalDatabase.instance.getUserProfileImage(),
                      builder: (context, snapshot) {
                        final cachedImage = snapshot.data ?? '';
                        final networkImage =
                            mainStateWatchProvider
                                .getUserProfileResponse
                                .payload
                                ?.userProfile
                                ?.imageUrl ??
                            '';
                        final imageToShow = networkImage.isNotEmpty
                            ? networkImage
                            : cachedImage;

                        return GestureDetector(
                          onTap: () => _scaffoldKey.currentState!.openDrawer(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: imageToShow.isEmpty
                                  ? Colors.grey.shade400
                                  : null,
                              border: Border.all(
                                color: AppColors.goldLightColor,
                                width: 1.2,
                              ),
                              image: imageToShow.isNotEmpty
                                  ? DecorationImage(
                                      image: imageToShow.startsWith('http')
                                          ? NetworkImage(imageToShow)
                                          : FileImage(File(imageToShow))
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageToShow.isEmpty
                                ? Center(
                                    child: SvgPicture.asset(
                                      "assets/svg/user_icon.svg",
                                      width: 20,
                                      height: 20,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

                    /// Search Bar
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.goldLightColor.withOpacity(0.4),
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2A2A2A),
                              Color(0xFF1E1E1E),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.gift_search_here,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.search,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Notification Icon
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/notify_icon.svg",
                        height: 24,
                        width: 24,
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
