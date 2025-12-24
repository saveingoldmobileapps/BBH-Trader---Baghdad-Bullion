import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/setting_provider/check_device_security.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../data/data_sources/local_database/local_database.dart'
    show LocalDatabase;

class FaceIDScreen extends ConsumerStatefulWidget {
  const FaceIDScreen({super.key});

  @override
  ConsumerState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<FaceIDScreen> {
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
    // await LocalDatabase.instance.getFaceEnable() ?? false;
    bool deviceHasFinger = await BiometricUtils.isFaceLockAvailable();
    setState(() {
      if (deviceHasFinger && faceIDEnabled) {
        isFaceID = true;
      } else {
        isFaceID = false;
      }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.face_id_title,//"Face ID",
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
                    text: AppLocalizations.of(context)!.face_unlock,//"Face Unlock",
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
                      // Use the BiometricUtils to check and enable.
                      final bool canEnable =
                          await BiometricUtils.checkAndEnableBiometric(context);
                      if (canEnable) {
                        setState(() {
                          isFaceID = value;
                        });
                        await LocalDatabase.instance.storeFaceEnable(
                          isEnable: value,
                        );
                        // LocalDatabase.instance.storeFaceEnable(
                        //   isEnable: value,
                        // );
                      } else {
                        //  The switch should not change if they cancelled.
                        if (mounted) {
                          setState(() {
                            isFaceID =
                                false; // Keep the switch in its original state
                          });
                        }
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
                    heading: AppLocalizations.of(context)!.rem_fa_id,//"Remove Face ID?",
                    subtitle:
                        AppLocalizations.of(context)!.wont_able_f_id,

                        //"You won’t be able to login through Face recognition.",
                    noButtonTitle: AppLocalizations.of(context)!.cancel,//"Cancel",
                    yesButtonTitle: AppLocalizations.of(context)!.remove_title, //"Remove",
                    isLoadingState: false,
                    onNoPress: () {
                      Navigator.pop(context);
                    },
                    onYesPress: () async {
                      Navigator.pop(context);
                      setState(() {
                        isFaceID = false;
                      });
                      await LocalDatabase.instance.storeFaceEnable(
                        isEnable: false,
                      );
                      // LocalDatabase.instance.storeFaceEnable(
                      //   isEnable: false,
                      // );
                    },
                  );
                },
                child: GetGenericText(
                  text: AppLocalizations.of(context)!.remove_face_id,//"Remove Face ID",
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
