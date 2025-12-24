import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/setting_provider/check_device_security.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart' show LocalDatabase;

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
    // await LocalDatabase.instance.getFingerEnable() ?? false;
    bool deviceHasFinger = await BiometricUtils.isFingerprintAvailable();
    setState(() {
      if (deviceHasFinger && faceIDEnabled) {
        isFaceID = true;
      } else {
        isFaceID = false;
      }
    });
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.biometric_title,//"Biometric",
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
          child: Column(
            children: [
              ConstPadding.sizeBoxWithHeight(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.biometric_unlock,//"Biometric Unlock",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  Switch.adaptive(
                    activeColor: AppColors.primaryGold500,
                    thumbColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.orange.withValues(alpha: .48);
                      }
                      return Colors.white;
                    }),
                    value: isFaceID,
                    onChanged: (value) async {
                      if (value) {
                        // User trying to enable biometric
                        final result =
                            await BiometricUtils.checkAndEnableBiometric(
                              context,
                            );
                        if (result) {
                          setState(() {
                            isFaceID = true;
                          });
                          // await LocalDatabase.instance.storeFingerEnable(
                          //   isEnable: true,
                          // );
                          await LocalDatabase.instance.storeFingerEnable(
                            isEnable: true,
                          );
                        } else {
                          // User did not enable biometric
                          setState(() {
                            isFaceID = false;
                          });
                        }
                      } else {
                        // User disabling biometric
                        setState(() {
                          isFaceID = false;
                        });
                        // await LocalDatabase.instance.storeFingerEnable(
                        //   isEnable: false,
                        // );
                        await LocalDatabase.instance.storeFingerEnable(
                          isEnable: false,
                        );
                      }
                    },
                  ),
                ],
              ),
              Divider(
                color: AppColors.greyScale900,
                thickness: 1.5,
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              GestureDetector(
                onTap: () async {
                  await genericPopUpWidget(
                    context: context,
                    heading: AppLocalizations.of(context)!.remove_biometric,//"Remove Biometric?",
                    subtitle: AppLocalizations.of(context)!.data_remove,//"Your Biometric data will be removed.",
                    noButtonTitle: AppLocalizations.of(context)!.cancel,//"Cancel",
                    yesButtonTitle: AppLocalizations.of(context)!.remove_title,//"Remove",
                    isLoadingState: false,
                    onNoPress: () {
                      Navigator.pop(context);
                    },
                    onYesPress: () async {
                      Navigator.pop(context);
                      setState(() {
                        isFaceID = false;
                      });
                      // LocalDatabase.instance.storeFingerEnable(isEnable: false);
                      await LocalDatabase.instance.storeFingerEnable(
                        isEnable: false,
                      );
                    },
                  );
                },
                child: GetGenericText(
                  text: AppLocalizations.of(context)!.remove_biometric,//"Remove Biometric",
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 16,
                    tabletVal: 18,
                  ),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ).getAlign(),
              ),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
