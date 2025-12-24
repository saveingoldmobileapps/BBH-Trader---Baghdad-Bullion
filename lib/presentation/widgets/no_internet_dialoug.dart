import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../core/theme/const_colors.dart';
import '../../core/theme/get_generic_text_widget.dart';
import '../../main.dart';

Future<void> showNoInternetDialog() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            title: Column(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                  color: AppColors.primaryGold500,
                ),
                const SizedBox(height: 12),
                Directionality.of(context) == TextDirection.rtl?
                GetGenericText(
                  text: AppLocalizations.of(context)!.no_internet,//"No Internet",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGold500,
                  textAlign: TextAlign.center,
                ):
                GetGenericText(
                  text: "No Internet",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryGold500,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality.of(context) == TextDirection.rtl?
                GetGenericText(
                  text: AppLocalizations.of(context)!.please_check_internet,//"Please check your internet connection",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ):
                GetGenericText(
                  text: "Please check your internet connection",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Platform.isAndroid || Platform.isIOS)
                      ElevatedButton.icon(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                            } 
                            else if (Platform.isIOS) {
                              exit(0);
                            }
                        },
                        icon: const Icon(
                          Icons.exit_to_app_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: 
                        
                Directionality.of(context) == TextDirection.rtl?
                GetGenericText(
                          text: AppLocalizations.of(context)!.exit_app,//"Exit App",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ):
                        GetGenericText(
                          text: "Exit App",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    Spacer(), // for Platform

                    ElevatedButton.icon(
                      onPressed: () {
                        if (Platform.isIOS) {
                          // iOS: Only allows opening your app's settings
                          AppSettings.openAppSettings();
                        } else {
                          // Android: Can open specific settings panel (like Wi-Fi)
                          AppSettings.openAppSettingsPanel(
                            AppSettingsPanelType.wifi,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.settings_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: 
                      
                      Directionality.of(context) == TextDirection.rtl?
                      GetGenericText(
                        text: AppLocalizations.of(context)!.open_setting,//"Open Settings",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ):GetGenericText(
                        text: "Open Settings",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Future<void> showNoInternetDialog() async {
//   final context = navigatorKey.currentContext;
//   if (context == null) return;

//   await showDialog(
//     context: context,
//     barrierDismissible: false, // disables tap outside
//     builder: (_) => WillPopScope(
//       onWillPop: () async => false, // disables back button
//       child: AlertDialog(
//         backgroundColor: const Color(0xFF232323),
//         title: GetGenericText(
//           text: "No Internet",
//           fontSize: 24,
//           fontWeight: FontWeight.w500,
//           color: AppColors.primaryGold500,
//           textAlign: TextAlign.center,
//         ),
//         content: GetGenericText(
//           text: "Please check your internet connection",
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//           color: AppColors.primaryGold500,
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           if (Platform.isAndroid)
//             TextButton(
//               onPressed: () {
//                 SystemNavigator.pop();
//               },
//               child: GetGenericText(
//                 text: "Exit App",
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           TextButton(
//             onPressed: () {
//               AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
//             },
//             child: GetGenericText(
//               text: "Open Settings",
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
