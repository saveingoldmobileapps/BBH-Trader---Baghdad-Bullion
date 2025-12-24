import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/setting_provider/settings_provider.dart';

import '../../../data/data_sources/local_database/local_database.dart';
import '../../../data/models/time_zone/time_zone_model.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../widgets/search_drop_down.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class TimezoneScreen extends ConsumerStatefulWidget {
  const TimezoneScreen({super.key});

  @override
  ConsumerState createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends ConsumerState<TimezoneScreen> {
  String? _selectedTimezone;
  String? storedCountry;
  bool isEditable = false;
  bool foundTimeZone = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingProvider = ref.read(settingsProvider.notifier);

      // Fetch timezones if not already loaded
      if ((ref.read(settingsProvider).timeZoneList?.isEmpty ?? true)) {
        await settingProvider.fetchAllTimezones();
      }

      // Read the updated list after fetch
      final timezoneList = ref.read(settingsProvider).timeZoneList ?? [];

      final storedTimezone =
          await LocalDatabase.instance.read(
                key: Strings.userTimezone,
              )
              as String?;

      storedCountry =
          await LocalDatabase.instance.read(
                key: Strings.userTimezoneCountry,
              )
              as String?;

      final matchedTimezone = timezoneList.firstWhere(
        (tz) =>
            tz.timezone?.toLowerCase().trim() ==
                storedTimezone?.toLowerCase().trim() &&
            tz.name?.toLowerCase().trim() ==
                storedCountry?.toLowerCase().trim(),
        orElse: () {
          foundTimeZone = false;
          return timezoneList.firstWhere(
            (tz) =>
                tz.name?.toLowerCase().contains('united arab emirates') ??
                false,
            orElse: () => timezoneList.first,
          );
        },
      );

      setState(() {
        _selectedTimezone = matchedTimezone.timezone;
        storedCountry = matchedTimezone.name;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    final settingState = ref.watch(settingsProvider);
    final settingProvider = ref.read(settingsProvider.notifier);
    final homeState = ref.read(homeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.settings_timezone, //"Timezone",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
        actions: [
          Directionality.of(context) == TextDirection.rtl
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditable = !isEditable;
                      });
                    },
                    child: Container(
                      width: sizes!.responsiveWidth(
                        phoneVal: 60,
                        tabletVal: 80,
                      ),
                      height: sizes!.responsiveLandscapeHeight(
                        phoneVal: 24,
                        tabletVal: 34,
                        tabletLandscapeVal: 44,
                        isLandscape: sizes!.isLandscape(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Color(0xFFBBA473),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Center(
                        child: GetGenericText(
                          text: isEditable
                              ? AppLocalizations.of(context)!.cancel
                              : AppLocalizations.of(context)!.edit,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 12,
                            tabletVal: 14,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditable = !isEditable;
                      });
                    },
                    child: Container(
                      width: sizes!.responsiveWidth(
                        phoneVal: 60,
                        tabletVal: 80,
                      ),
                      height: sizes!.responsiveLandscapeHeight(
                        phoneVal: 24,
                        tabletVal: 34,
                        tabletLandscapeVal: 44,
                        isLandscape: sizes!.isLandscape(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Color(0xFFBBA473),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Center(
                        child: GetGenericText(
                          text: isEditable
                              ? AppLocalizations.of(context)!.cancel
                              : AppLocalizations.of(context)!.edit,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 12,
                            tabletVal: 14,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (settingState.isTimeZoneLoading) ...[
                Center(
                  child: ShimmerLoader(
                    loop: 3,
                  ),
                ),
              ],

              if (settingState.isTimeZoneLoading == false) ...[
                Visibility(
                  visible: !foundTimeZone,
                  child: ConstPadding.sizeBoxWithHeight(height: 10),
                ),
                Visibility(
                  visible: !foundTimeZone,
                  child: Directionality.of(context) == TextDirection.rtl
                      ? GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.timezone_error, //"Timezone not selected please select timezone",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.red900Color,
                        ).getAlignRight()
                      : GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.timezone_error, //"Timezone not selected please select timezone",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.red900Color,
                        ).getAlign(),
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                if (settingState.timeZoneList != null)
                  AbsorbPointer(
                    absorbing: !isEditable,
                    child: SearchableDropdown(
                      iconString: "assets/svg/arrow_down.svg",
                      title: "Select Timezone",
                      items: settingState.timeZoneList!.map<String>((tz) {
                        return "${tz.timezone ?? ""} - ${tz.name ?? ""}";
                      }).toList(),
                      label: AppLocalizations.of(
                        context,
                      )!.settings_timezone, //"Timezone",
                      hint: "Select Timezone",
                      selectedItem: () {
                        if (_selectedTimezone == null) return "";

                        final selectedTz = settingState.timeZoneList!
                            .firstWhere(
                              (tz) =>
                                  tz.timezone?.toLowerCase().trim() ==
                                      _selectedTimezone?.toLowerCase().trim() &&
                                  tz.name?.toLowerCase().trim() ==
                                      storedCountry?.toLowerCase().trim(),
                              orElse: () => KAllTimezones(
                                timezone: _selectedTimezone!,
                                name: storedCountry ?? "",
                              ),
                            );

                        return "${selectedTz.timezone} - ${selectedTz.name}";
                      }(),

                      textStyle: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                      ),
                      validator: (value) =>
                          value == null ? 'Please select timezone' : null,
                      // onChanged: isEditable
                      //     ? (String selected) {
                      //         final selectedOffset = selected
                      //             .split(' - ')
                      //             .first;
                      //         final selectedCountry = selected
                      //             .split(' - ')
                      //             .last;
                      //         homeState
                      //                 .getUserProfileResponse
                      //                 .payload
                      //                 ?.userProfile
                      //                 ?.timezone =
                      //             selectedOffset;
                      //         setState(() {
                      //           _selectedTimezone = selectedOffset;
                      //           foundTimeZone = true;
                      //           isEditable = false;
                      //         });
                      //         settingProvider.updateTimeZone(
                      //           selectedOffset,
                      //           selectedCountry,
                      //         );
                      //       }
                      //     : (String _) {},
                      onChanged: isEditable
                          ? (String selected) {
                              final parts = selected.split(' - ');
                              final selectedOffset = parts.first.trim();
                              final selectedCountry = parts.length > 1
                                  ? parts.last.trim()
                                  : '';

                              //  Log the selection clearly
                              print("🕒 Selected Timezone: $selectedOffset");
                              print("🌍 Selected Country: $selectedCountry");

                              // Update local user profile (if exists)
                              homeState
                                      .getUserProfileResponse
                                      .payload
                                      ?.userProfile
                                      ?.timezone =
                                  selectedOffset;

                              setState(() {
                                _selectedTimezone = selectedOffset;
                                storedCountry = selectedCountry;
                                foundTimeZone = true;
                                isEditable = false;
                              });

                              //  Log before sending to API
                              print(
                                " Sending to API: timezone='$selectedOffset', country='$selectedCountry'",
                              );

                              settingProvider.updateTimeZone(
                                selectedOffset,
                                selectedCountry,
                              );
                            }
                          : (String _) {},
                    ),
                  ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                Visibility(
                  visible: settingState.isLoading,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold500,
                    ),
                  ),
                ),
              ],
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
