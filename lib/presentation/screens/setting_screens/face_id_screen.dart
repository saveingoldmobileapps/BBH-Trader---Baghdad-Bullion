import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/setting_provider/check_device_security.dart';
import 'package:baghdad_bullion_house/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart'
    show LocalDatabase;

class FaceIDScreen extends ConsumerStatefulWidget {
  const FaceIDScreen({super.key});

  @override
  ConsumerState createState() => _FaceIDScreenState();
}

class _FaceIDScreenState extends ConsumerState<FaceIDScreen> {
  bool isFaceID = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getState();
    });
  }

  Future<void> getState() async {
    bool faceIDEnabled = await LocalDatabase.instance.getFaceEnable() ?? false;
    bool deviceHasFace = await BiometricUtils.isFaceLockAvailable();
    setState(() {
      isFaceID = deviceHasFace && faceIDEnabled;
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
        title: GetGenericText(
          text: AppLocalizations.of(context)!.face_id_title,
          fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
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
                text: AppLocalizations.of(context)!.face_unlock,
                fontSize: sizes!.responsiveFont(phoneVal: 26, tabletVal: 32),
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ).getAlign(),

              GetGenericText(
                text: AppLocalizations.of(context)!.settings_biometric_desc, // You may want to create a specific description for Face ID
                fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 20),
                fontWeight: FontWeight.normal,
                color: AppColors.whiteColor,
              ).getAlign(),

              ConstPadding.sizeBoxWithHeight(height: 16),

              /// Rounded Face ID Container (Same style as BiometricScreen)
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
                            text: AppLocalizations.of(context)!.face_unlock,
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
                                final result = await BiometricUtils.checkAndEnableBiometric(
                                  context,
                                );
                                if (result) {
                                  setState(() => isFaceID = true);
                                  await LocalDatabase.instance.storeFaceEnable(
                                    isEnable: true,
                                  );
                                }
                              } else {
                                setState(() => isFaceID = false);
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
                          heading: AppLocalizations.of(context)!.remove_face_id,
                          subtitle: AppLocalizations.of(context)!.wont_able_f_id,
                          noButtonTitle: AppLocalizations.of(context)!.cancel,
                          yesButtonTitle: AppLocalizations.of(context)!.remove_title,
                          isLoadingState: false,
                          onNoPress: () => Navigator.pop(context),
                          onYesPress: () async {
                            Navigator.pop(context);
                            setState(() => isFaceID = false);
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
                            text: AppLocalizations.of(context)!.remove_face_id,
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