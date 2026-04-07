import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/setting_provider/check_device_security.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart'
    show LocalDatabase;

class BiometricScreen extends ConsumerStatefulWidget {
  const BiometricScreen({super.key});

  @override
  ConsumerState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<BiometricScreen> {
  bool isFaceID = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getState();
    });
  }

  Future<void> getState() async {
    bool faceIDEnabled =
        await LocalDatabase.instance.getFingerEnable() ?? false;
    bool deviceHasFinger = await BiometricUtils.isFingerprintAvailable();
    setState(() {
      isFaceID = deviceHasFinger && faceIDEnabled;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        // title: GetGenericText(
        //   text: AppLocalizations.of(context)!.biometric_title,
        //   fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
        //   fontWeight: FontWeight.w400,
        //   color: AppColors.grey6Color,
        // ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        color: AppColors.greyScale1000,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.settings_biometric,
                fontSize: sizes!.responsiveFont(phoneVal: 26, tabletVal: 32),
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ).getAlign(),

              GetGenericText(
                text: AppLocalizations.of(context)!.settings_biometric_desc,
                fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 20),
                fontWeight: FontWeight.normal,
                color: AppColors.whiteColor,
              ).getAlign(),

              ConstPadding.sizeBoxWithHeight(height: 16),

              /// 🔹 Rounded Biometric Container (Like Language Screen)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262929),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.biometric_unlock,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          Switch.adaptive(
                            activeColor: AppColors.goldColor,
                            value: isFaceID,
                            onChanged: (value) async {
                              if (value) {
                                final result =
                                    await BiometricUtils.checkAndEnableBiometric(
                                      context,
                                    );
                                if (result) {
                                  setState(() => isFaceID = true);
                                  await LocalDatabase.instance
                                      .storeFingerEnable(isEnable: true);
                                }
                              } else {
                                setState(() => isFaceID = false);
                                await LocalDatabase.instance.storeFingerEnable(
                                  isEnable: false,
                                );
                                await LocalDatabase.instance.storeFaceEnable(
                                  isEnable: false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      color: AppColors.greyScale900,
                      thickness: 1.5,
                      height: 1,
                    ),

                    InkWell(
                      onTap: () async {
                        await genericPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(
                            context,
                          )!.remove_biometric,
                          subtitle: AppLocalizations.of(context)!.data_remove,
                          noButtonTitle: AppLocalizations.of(context)!.cancel,
                          yesButtonTitle: AppLocalizations.of(
                            context,
                          )!.remove_title,
                          isLoadingState: false,
                          onNoPress: () => Navigator.pop(context),
                          onYesPress: () async {
                            Navigator.pop(context);
                            setState(() => isFaceID = false);
                            await LocalDatabase.instance.storeFingerEnable(
                              isEnable: false,
                            );
                            await LocalDatabase.instance.storeFaceEnable(
                              isEnable: false,
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.remove_biometric,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
