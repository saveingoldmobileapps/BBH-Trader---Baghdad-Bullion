import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/language_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        // title: GetGenericText(
        //   text: AppLocalizations.of(context)!.app_lang, // "Language Settings"
        //   fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
        //   fontWeight: FontWeight.w400,
        //   color: AppColors.grey6Color,
        // ),
      ),
      body: Stack(
        children: [
          Container(
            height: sizes!.height,
            width: sizes!.width,
            color: AppColors.greyScale1000,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: isRtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    isRtl
                        ? GetGenericText(
                            text: AppLocalizations.of(context)!.settings_language,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 26,
                              tabletVal: 32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ).getAlignRight()
                        : GetGenericText(
                            text: AppLocalizations.of(context)!.settings_language,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 26,
                              tabletVal: 32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor,
                          ).getAlign(),

                    isRtl
                        ? GetGenericText(
                            text:
                                AppLocalizations.of(context)!.settings_language_desc,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 20,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ).getAlignRight()
                        : GetGenericText(
                            text:
                                AppLocalizations.of(context)!.settings_language_desc,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 20,
                            ),
                            fontWeight: FontWeight.normal,
                            color: AppColors.whiteColor,
                          ).getAlign(),
                    ConstPadding.sizeBoxWithHeight(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 16,
                        ), // Optional: extra top padding after the subtitle
                        itemCount: LanguageList.values.length,
                        itemBuilder: (context, index) {
                          final language = LanguageList.values[index];
                          final isSelected =
                              languageState.languageCode == language.localeCode;

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ), // Space between items
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Ripple follows rounded corners
                              onTap: () {
                                languageNotifier.updateLanguage(
                                  language: language.localeCode,
                                  context: context,
                                  isDashboard: false,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff262929),
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Rounded corners
                                  border: Border.all(
                                    color: AppColors
                                        .greyScale900, // Subtle border for extra separation
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      language.flagIconPath,
                                      height: sizes!.responsiveFont(
                                        phoneVal: 28,
                                        tabletVal: 36,
                                      ),
                                      width: sizes!.responsiveFont(
                                        phoneVal: 28,
                                        tabletVal: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: GetGenericText(
                                        text: language.displayName,
                                        fontSize: sizes!.responsiveFont(
                                          phoneVal: 16,
                                          tabletVal: 20,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.grey6Color,
                                      ),
                                    ),
                                    Container(
                                      height: sizes!.responsiveFont(
                                        phoneVal: 20,
                                        tabletVal: 24,
                                      ),
                                      width: sizes!.responsiveFont(
                                        phoneVal: 20,
                                        tabletVal: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primaryGold500
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryGold500
                                              : AppColors.greyScale700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (languageState.isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}
