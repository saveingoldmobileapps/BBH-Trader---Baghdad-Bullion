import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

    final languageState = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    // Determine the direction of the arrow based on the current locale
    bool isRtl = languageNotifier.isRtl();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(
            context,
          )!.app_lang,
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: sizes!.height,
            width: sizes!.width,
            decoration: const BoxDecoration(
              color: AppColors.greyScale1000,
            ),
            child: SafeArea(
              child: ListView.separated(
                itemCount: LanguageList.values.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.greyScale900,
                  thickness: 1.5,
                ),
                itemBuilder: (context, index) {
                  final language = LanguageList.values[index];

                  return GestureDetector(
                    onTap: () {
                      languageNotifier.updateLanguage(
                          language: language.localeCode,
                          context: context,
                          isDashboard: false);
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            language.flagIconPath,
                            height: sizes!.responsiveFont(
                              phoneVal: 18,
                              tabletVal: 28,
                            ),
                            width: sizes!.responsiveFont(
                              phoneVal: 18,
                              tabletVal: 28,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          GetGenericText(
                            text: language.displayName,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 20,
                            ),
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey6Color,
                          ),
                          const Spacer(),
                          Radio<String>(
                            activeColor: AppColors.primaryGold500,
                            value: language.localeCode,
                            groupValue: languageState.languageCode,
                            onChanged: (value) {
                              if (value != null) {
                                languageNotifier.updateLanguage(
                                    language: value,
                                    context: context,
                                    isDashboard: false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).get16HorizontalPadding(),
            ),
          ),
          if (languageState.isLoading) ...{
            Center(
              child: Container(
                width: sizes!.widthRatio * 26,
                height: sizes!.widthRatio * 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
