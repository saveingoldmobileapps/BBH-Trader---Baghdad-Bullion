// Created by Tayyab Mughal on 03/11/2023.
// Tayyab Mughal
// tayyabmughal676@gmail.com
// © 2022-2023  - All Rights Reserved
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

/// pop up widget
Future<void> popUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required String noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress, // Changed to async function
}) async {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  width: sizes!.width,
                  // height: sizes!.heightRatio * 300,
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes!.heightRatio * 20,
                      horizontal: sizes!.widthRatio * 20,
                    ),
                    child: Column(
                      children: [
                        ///Title
                        GetGenericText(
                          text: heading,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyScale1000,
                          lines: 2,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 6),
                        GetGenericText(
                          text: subtitle,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.greyScale1000,
                          lines: 6,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 20),

                        GestureDetector(
                          onTap: () async {
                            setModalState(() {
                              isLoadingState = true; // Show loading
                            });
                            await onYesPress.call();
                            setModalState(() {
                              isLoadingState = false; // Hide loading
                            });
                            // if (context.mounted) {
                            //   Navigator.pop(context); // Close the dialog
                            // }
                          },
                          child: Container(
                            height: sizes!.fontRatio * 50,
                            width: sizes!.widthRatio * 350,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isLoadingState == false
                                  ? GetGenericText(
                                      text: yesButtonTitle,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    )
                                  : SizedBox(
                                      height: sizes!.heightRatio * 16,
                                      width: sizes!.widthRatio * 16,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 10),
                        GestureDetector(
                          onTap: onNoPress,
                          child: Container(
                            height: sizes!.fontRatio * 40,
                            width: sizes!.widthRatio * 120,
                            decoration: BoxDecoration(
                              // color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Center(
                              child: GetGenericText(
                                text: noButtonTitle,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyScale1000,
                              ),
                            ),
                          ),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     GestureDetector(
                        //       onTap: onNoPress,
                        //       child: Container(
                        //         height: sizes!.fontRatio * 48,
                        //         width: sizes!.widthRatio * 140,
                        //         decoration: BoxDecoration(
                        //           color: Colors.black,
                        //           borderRadius: BorderRadius.circular(10),
                        //           border: Border.all(
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         child: Center(
                        //           child: GetGenericText(
                        //             text: noButtonTitle,
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w600,
                        //             color: Colors.white,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () async {
                        //         setModalState(() {
                        //           isLoadingState = true; // Show loading
                        //         });
                        //         await onYesPress.call();
                        //         setModalState(() {
                        //           isLoadingState = false; // Hide loading
                        //         });
                        //         if (context.mounted) {
                        //           Navigator.pop(context); // Close the dialog
                        //         }
                        //       },
                        //       child: Container(
                        //         height: sizes!.fontRatio * 48,
                        //         width: sizes!.widthRatio * 140,
                        //         decoration: BoxDecoration(
                        //           color: AppColors.primaryBlue900,
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Center(
                        //           child: isLoadingState == false
                        //               ? GetGenericText(
                        //                   text: yesButtonTitle,
                        //                   fontSize: 14,
                        //                   fontWeight: FontWeight.w600,
                        //                   color: Colors.white,
                        //                 )
                        //               : SizedBox(
                        //                   height: sizes!.heightRatio * 16,
                        //                   width: sizes!.widthRatio * 16,
                        //                   child:
                        //                       const CircularProgressIndicator(
                        //                     color: Colors.white,
                        //                     strokeWidth: 2.0,
                        //                   ),
                        //                 ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> liveFarePopupWidget({
  required BuildContext context,
  required String heading,
  required ValueNotifier<String> subtitleNotifier, // 👈 live-updating subtitle
  String? noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress,
}) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    width: sizes!.isPhone ? sizes!.width : sizes!.width / 1.5,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232323),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFBBA473),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes!.heightRatio * 16,
                        horizontal: sizes!.widthRatio * 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstPadding.sizeBoxWithHeight(height: 10),
                          GetGenericText(
                            text: heading,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 20,
                              tabletVal: 24,
                            ),
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                            lines: 2,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),
                          ConstPadding.sizeBoxWithHeight(height: 12),

                          /// 👇 This updates live whenever subtitleNotifier.value changes
                          ValueListenableBuilder<String>(
                            valueListenable: subtitleNotifier,
                            builder: (context, value, _) {
                              return GetGenericText(
                                text: value,
                                fontSize: sizes!.responsiveFont(
                                  phoneVal: 16,
                                  tabletVal: 18,
                                ),
                                fontWeight: FontWeight.w300,
                                color: AppColors.grey4Color,
                                lines: 6,
                                textAlign: TextAlign.center,
                              ).getChildCenter();
                            },
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 20),

                          // Yes Button
                          GestureDetector(
                            onTap: () async {
                              setModalState(() => isLoadingState = true);
                              await onYesPress.call();
                              setModalState(() => isLoadingState = false);
                            },
                            child: Container(
                              height: sizes!.responsiveHeight(
                                phoneVal: 48,
                                tabletVal: 56,
                              ),
                              width: sizes!.responsiveWidth(
                                phoneVal: 300,
                                tabletVal: 350,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFF675A3D),
                                    Color(0xFFBBA473),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: isLoadingState == false
                                    ? GetGenericText(
                                        text: yesButtonTitle,
                                        fontSize: sizes!.responsiveFont(
                                          phoneVal: 14,
                                          tabletVal: 16,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )
                                    : SizedBox(
                                        height: sizes!.heightRatio * 16,
                                        width: sizes!.widthRatio * 16,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          if (noButtonTitle != null) ...[
                            ConstPadding.sizeBoxWithHeight(height: 10),
                            GestureDetector(
                              onTap: onNoPress,
                              child: SizedBox(
                                height: sizes!.responsiveHeight(
                                  phoneVal: 48,
                                  tabletVal: 56,
                                ),
                                width: sizes!.responsiveWidth(
                                  phoneVal: 300,
                                  tabletVal: 350,
                                ),
                                child: Center(
                                  child: GetGenericText(
                                    text: noButtonTitle ?? "",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 14,
                                      tabletVal: 16,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> genericPopUpLivePriceWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  String? noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress, // async function
  Widget? livePriceWidget, // Optional live price section
  int? autoCloseAfterSeconds, // 👈 Optional countdown seconds
}) async {
  Timer? timer;
  int remainingSeconds = autoCloseAfterSeconds ?? 0;

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            //  Start timer only once, if countdown is enabled
            if (autoCloseAfterSeconds != null && timer == null) {
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (remainingSeconds <= 1) {
                  t.cancel();
                  if (Navigator.canPop(context)) Navigator.pop(context);
                } else {
                  remainingSeconds--;
                  setModalState(() {});
                }
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    width: sizes!.isPhone ? sizes!.width : sizes!.width / 1.5,
                    margin: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF232323),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFBBA473),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes!.heightRatio * 16,
                        horizontal: sizes!.widthRatio * 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstPadding.sizeBoxWithHeight(height: 10),

                          /// Title with optional countdown
                          GetGenericText(
                            text: autoCloseAfterSeconds != null
                                ? heading
                                : heading,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 20,
                              tabletVal: 24,
                            ),
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                            lines: 2,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),

                          ConstPadding.sizeBoxWithHeight(height: 12),

                          /// Subtitle
                          GetGenericText(
                            text: subtitle,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4Color,
                            lines: 6,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),

                          /// Live price widget (if provided)
                          if (livePriceWidget != null) ...[
                            ConstPadding.sizeBoxWithHeight(height: 16),
                            livePriceWidget,
                          ],

                          ConstPadding.sizeBoxWithHeight(height: 10),
                          TweenAnimationBuilder<double>(
                            key: ValueKey(remainingSeconds), // rebuild per tick
                            tween: Tween(
                              begin: 1.0,
                              end: 0.8,
                            ), // subtle scale animation
                            duration: const Duration(milliseconds: 500),
                            builder: (context, scale, child) {
                              // Change color based on remaining seconds
                              Color textColor;
                              if (remainingSeconds <= 3) {
                                textColor = Colors.redAccent; // urgent
                              } else if (remainingSeconds <= 5) {
                                textColor = const Color(0xFFBBA473); // gold
                              } else {
                                textColor = const Color(
                                  0xFFBBA473,
                                ); // default elegant gold
                              }

                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity:
                                    0.8 +
                                    (remainingSeconds % 2) *
                                        0.2, // soft breathing effect
                                child: Transform.scale(
                                  scale: scale,
                                  child: GetGenericText(
                                    text: autoCloseAfterSeconds != null
                                        ? '${remainingSeconds.toString().padLeft(2, '0')} ${AppLocalizations.of(context)!.sec}'
                                        : heading,
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 20,
                                      tabletVal: 24,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    lines: 2,
                                    textAlign: TextAlign.center,
                                  ).getChildCenter(),
                                ),
                              );
                            },
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 20),

                          /// Yes Button
                          GestureDetector(
                            onTap: () async {
                              timer?.cancel();
                              setModalState(() => isLoadingState = true);
                              await onYesPress.call();
                              setModalState(() => isLoadingState = false);
                            },
                            child: Container(
                              height: sizes!.responsiveHeight(
                                phoneVal: 48,
                                tabletVal: 56,
                              ),
                              width: sizes!.responsiveWidth(
                                phoneVal: 300,
                                tabletVal: 350,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFF675A3D),
                                    Color(0xFFBBA473),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: !isLoadingState
                                    ? GetGenericText(
                                        text: yesButtonTitle,
                                        fontSize: sizes!.responsiveFont(
                                          phoneVal: 14,
                                          tabletVal: 16,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )
                                    : SizedBox(
                                        height: sizes!.heightRatio * 16,
                                        width: sizes!.widthRatio * 16,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          Visibility(
                            visible: noButtonTitle != null,
                            child: ConstPadding.sizeBoxWithHeight(height: 10),
                          ),

                          /// No Button
                          Visibility(
                            visible: noButtonTitle != null,
                            child: GestureDetector(
                              onTap: () {
                                timer?.cancel();
                                onNoPress();
                              },
                              child: Container(
                                height: sizes!.responsiveHeight(
                                  phoneVal: 48,
                                  tabletVal: 56,
                                ),
                                width: sizes!.responsiveWidth(
                                  phoneVal: 300,
                                  tabletVal: 350,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: GetGenericText(
                                    text: noButtonTitle ?? "",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 14,
                                      tabletVal: 16,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  ).then((_) {
    timer?.cancel();
  });
}

// Future<void> genericPopUpLivePriceWidget({
//   required BuildContext context,
//   required String heading,
//   required String subtitle,
//   String? noButtonTitle,
//   required String yesButtonTitle,
//   required bool isLoadingState,
//   required VoidCallback onNoPress,
//   required Future<void> Function() onYesPress, // async function
//   Widget? livePriceWidget, // 👈 NEW optional widget
// }) async {
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: StatefulBuilder(
//           builder: (context, setModalState) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Material(
//                   color: Colors.transparent,
//                   child: Container(
//                     width: sizes!.isPhone ? sizes!.width : sizes!.width / 1.5,
//                     margin: const EdgeInsets.all(16),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF232323),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: const Color(0xFFBBA473),
//                         width: 1,
//                       ),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         vertical: sizes!.heightRatio * 16,
//                         horizontal: sizes!.widthRatio * 16,
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ConstPadding.sizeBoxWithHeight(height: 10),

//                           /// Title
//                           GetGenericText(
//                             text: heading,
//                             fontSize: sizes!.responsiveFont(
//                               phoneVal: 20,
//                               tabletVal: 24,
//                             ),
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.grey6Color,
//                             lines: 2,
//                             textAlign: TextAlign.center,
//                           ).getChildCenter(),

//                           ConstPadding.sizeBoxWithHeight(height: 12),

//                           /// Subtitle
//                           GetGenericText(
//                             text: subtitle,
//                             fontSize: sizes!.responsiveFont(
//                               phoneVal: 16,
//                               tabletVal: 18,
//                             ),
//                             fontWeight: FontWeight.w300,
//                             color: AppColors.grey4Color,
//                             lines: 6,
//                             textAlign: TextAlign.center,
//                           ).getChildCenter(),

//                           /// 👇 Add Live Price Widget (if provided)
//                           if (livePriceWidget != null) ...[
//                             ConstPadding.sizeBoxWithHeight(height: 16),
//                             livePriceWidget,
//                           ],

//                           ConstPadding.sizeBoxWithHeight(height: 20),

//                           /// Yes Button
//                           GestureDetector(
//                             onTap: () async {
//                               setModalState(() {
//                                 isLoadingState = true;
//                               });
//                               await onYesPress.call();
//                               setModalState(() {
//                                 isLoadingState = false;
//                               });
//                             },
//                             child: Container(
//                               height: sizes!.responsiveHeight(
//                                 phoneVal: 48,
//                                 tabletVal: 56,
//                               ),
//                               width: sizes!.responsiveWidth(
//                                 phoneVal: 300,
//                                 tabletVal: 350,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 gradient: const LinearGradient(
//                                   begin: Alignment(1.00, 0.01),
//                                   end: Alignment(-1, -0.01),
//                                   colors: [
//                                     Color(0xFF675A3D),
//                                     Color(0xFFBBA473),
//                                   ],
//                                 ),
//                               ),
//                               child: Center(
//                                 child: isLoadingState == false
//                                     ? GetGenericText(
//                                         text: yesButtonTitle,
//                                         fontSize: sizes!.responsiveFont(
//                                           phoneVal: 14,
//                                           tabletVal: 16,
//                                         ),
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       )
//                                     : SizedBox(
//                                         height: sizes!.heightRatio * 16,
//                                         width: sizes!.widthRatio * 16,
//                                         child: const CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2.0,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ),

//                           Visibility(
//                             visible: noButtonTitle != null,
//                             child: ConstPadding.sizeBoxWithHeight(height: 10),
//                           ),

//                           /// No Button
//                           Visibility(
//                             visible: noButtonTitle != null,
//                             child: GestureDetector(
//                               onTap: onNoPress,
//                               child: Container(
//                                 height: sizes!.responsiveHeight(
//                                   phoneVal: 48,
//                                   tabletVal: 56,
//                                 ),
//                                 width: sizes!.responsiveWidth(
//                                   phoneVal: 300,
//                                   tabletVal: 350,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Center(
//                                   child: GetGenericText(
//                                     text: noButtonTitle ?? "",
//                                     fontSize: sizes!.responsiveFont(
//                                       phoneVal: 14,
//                                       tabletVal: 16,
//                                     ),
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     },
//   );
// }

/// pop up widget
Future<void> genericPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  String? noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress, // Changed to async function
}) async {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    width: sizes!.isPhone ? sizes!.width : sizes!.width / 1.5,
                    // height: sizes!.heightRatio * 300,
                    margin: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      color: Color(0xFF232323),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        // color: Colors.white,
                        color: Color(0xFFBBA473),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes!.heightRatio * 16,
                        horizontal: sizes!.widthRatio * 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstPadding.sizeBoxWithHeight(height: 10),

                          ///Title
                          GetGenericText(
                            text: heading,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 20,
                              tabletVal: 24,
                            ),
                            //20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey6Color,
                            lines: 2,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),
                          ConstPadding.sizeBoxWithHeight(height: 12),
                          GetGenericText(
                            text: subtitle,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 16,
                              tabletVal: 18,
                            ),
                            //16,
                            fontWeight: FontWeight.w300,
                            color: AppColors.grey4Color,
                            lines: 6,
                            textAlign: TextAlign.center,
                          ).getChildCenter(),
                          ConstPadding.sizeBoxWithHeight(height: 20),

                          // Yes Button
                          GestureDetector(
                            onTap: () async {
                              setModalState(() {
                                isLoadingState = true; // Show loading
                              });
                              await onYesPress.call();
                              setModalState(() {
                                isLoadingState = false; // Hide loading
                              });
                            },
                            child: Container(
                              height: sizes!.responsiveHeight(
                                phoneVal: 48,
                                tabletVal: 56,
                              ),
                              width: sizes!.responsiveWidth(
                                phoneVal: 300,
                                tabletVal: 350,
                              ),
                              decoration: BoxDecoration(
                                //color: AppColors.primaryGold500,
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment(1.00, 0.01),
                                  end: Alignment(-1, -0.01),
                                  colors: [
                                    Color(0xFF675A3D),
                                    Color(0xFFBBA473),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: isLoadingState == false
                                    ? GetGenericText(
                                        text: yesButtonTitle,
                                        fontSize: sizes!.responsiveFont(
                                          phoneVal: 14,
                                          tabletVal: 16,
                                        ), //14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )
                                    : SizedBox(
                                        height: sizes!.heightRatio * 16,
                                        width: sizes!.widthRatio * 16,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: noButtonTitle != null,
                            child: ConstPadding.sizeBoxWithHeight(height: 10),
                          ),
                          // No Button
                          Visibility(
                            visible: noButtonTitle != null,
                            child: GestureDetector(
                              onTap: onNoPress,
                              child: Container(
                                height: sizes!.responsiveHeight(
                                  phoneVal: 48,
                                  tabletVal: 56,
                                ),
                                width: sizes!.responsiveWidth(
                                  phoneVal: 300,
                                  tabletVal: 350,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: GetGenericText(
                                    text: noButtonTitle ?? "",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 14,
                                      tabletVal: 16,
                                    ), //14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
Future<void> temporaryCreditFreezedPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  String? buttonTitle,
  required VoidCallback onButtonPress,

  required VoidCallback oncloseButtonPress,
  IconData? icon,
  Color iconColor = const Color(0xFFBBA473),

  bool isForce = true, // <<< NEW FLAG
}) async {
  showDialog(
    barrierDismissible: !isForce, // cannot tap outside if force = true
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => !isForce, // disable back button if force=true
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: Material(
                  color: Colors.black.withOpacity(0.75),
                  child: _AnimatedPopupBody(
                    heading: heading,
                    subtitle: subtitle,
                    buttonTitle: buttonTitle,
                    onButtonPress: onButtonPress,
                    oncloseButtonPress:oncloseButtonPress,
                    icon: icon,
                    iconColor: iconColor,
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

// TemporaryCredit or freeaze account
Future<void> temporaryCreditPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  String? buttonTitle,
  required VoidCallback onButtonPress,
  required VoidCallback? oncloseButtonPress,

  // Optional animated icon
  IconData? icon,
  Color iconColor = const Color(0xFFBBA473),
}) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Material(
                color: Colors.black.withOpacity(0.75),
                child: _AnimatedPopupBody(
                  heading: heading,
                  subtitle: subtitle,
                  buttonTitle: buttonTitle,
                  onButtonPress: onButtonPress,
                  oncloseButtonPress: oncloseButtonPress!,
                  icon: icon,
                  iconColor: iconColor,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
class AnimatedCloseButton extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedCloseButton({
    super.key,
    this.color = Colors.white,
    this.size = 26,
  });

  @override
  State<AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<AnimatedCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.close_rounded,
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}

class _AnimatedPopupBody extends StatefulWidget {
  final String heading;
  final String subtitle;
  final String? buttonTitle;
  final VoidCallback onButtonPress;
  final VoidCallback oncloseButtonPress;
  final IconData? icon;
  final Color iconColor;

  const _AnimatedPopupBody({
    super.key,
    required this.heading,
    required this.subtitle,
    this.buttonTitle,
    required this.onButtonPress,
    required this.oncloseButtonPress,
    this.icon,
    required this.iconColor,
  });

  @override
  State<_AnimatedPopupBody> createState() => _AnimatedPopupBodyState();
}

class _AnimatedPopupBodyState extends State<_AnimatedPopupBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Continuous pulse animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.12)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes!.isPhone ? sizes!.width * 0.88 : 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBA473), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///  Animated Icon (looping)
          if (widget.icon != null)
            ScaleTransition(
              scale: _pulse,
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 60,
              ),
            ),

          if (widget.icon != null) const SizedBox(height: 12),

          /// TITLE
          GetGenericText(
            text: widget.heading,
            fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            lines: 2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          /// SUBTITLE
          GetGenericText(
            text: widget.subtitle,
            fontSize: sizes!.responsiveFont(phoneVal: 15, tabletVal: 18),
            fontWeight: FontWeight.w300,
            color: Colors.white70,
            lines: 6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          /// BUTTON
          GestureDetector(
            onTap: widget.onButtonPress,
            child: Container(
              height: sizes!.responsiveHeight(phoneVal: 48, tabletVal: 56),
              width: sizes!.responsiveWidth(phoneVal: 260, tabletVal: 340),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment(1.00, 0.01),
                  end: Alignment(-1, -0.01),
                  colors: [
                    Color(0xFF675A3D),
                    Color(0xFFBBA473),
                  ],
                ),
              ),
              child: Center(
                child: GetGenericText(
                  text: widget.buttonTitle ?? "OK",
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: widget.oncloseButtonPress,
            child: Container(
              height: sizes!.responsiveHeight(phoneVal: 48, tabletVal: 56),
              width: sizes!.responsiveWidth(phoneVal: 260, tabletVal: 340),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment(1.00, 0.01),
                  end: Alignment(-1, -0.01),
                  colors: [
                    Color(0xFF675A3D),
                    Color(0xFFBBA473),
                  ],
                ),
              ),
              child: Center(
                child: GetGenericText(
                  text: AppLocalizations.of(context)!.close,//"Close",
                  fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}


// Modified showMaintenancePopup function with animation
Future<void> showMaintenancePopup({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required VoidCallback onExitPress,
  required VoidCallback onWebsitePress,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: true,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Color(0xFF232323),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.goldLightColor, width: 1.2),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          title: Column(
            children: [
              // Animated shimmering "Save In Gold"
              GoldShimmerText(
                text: "Save In Gold",
                //fontSize: 26,
                //fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 18),

              Text(
                heading,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
SizedBox(
  height: 140,
  child: Lottie.asset(
    'assets/lottie/Presize_Maintenance.json',
    fit: BoxFit.contain,
    delegates: LottieDelegates(
      values: [
        ValueDelegate.colorFilter(
          const ['*'], // apply to ALL layers
          value: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcATop,
          ),
        )
      ],
    ),
  ),
),



              const SizedBox(height: 12),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExitPress,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Directionality.of(context) == TextDirection.rtl? 
                    Text(
                      AppLocalizations.of(context)!.exit_app,//'Exit App',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ):
                    Text(
                      'Exit App',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onWebsitePress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldLightColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                    child: Directionality.of(context) == TextDirection.rtl? 
                    Text(
                      AppLocalizations.of(context)!.visit_website,//'Visit Website',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ):
                     Text(
                      'Visit Website',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Typewriter animation for "Save In Gold"
class TypewriterAnimatedText extends StatefulWidget {
  final String text;
  final Duration duration;

  const TypewriterAnimatedText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<TypewriterAnimatedText> createState() => _TypewriterAnimatedTextState();
}

class _TypewriterAnimatedTextState extends State<TypewriterAnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final text = widget.text.substring(0, _animation.value);
        return Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        );
      },
    );
  }
}

class GoldShimmerText extends StatefulWidget {
  final String text;
  final Duration duration;

  const GoldShimmerText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<GoldShimmerText> createState() => _GoldShimmerTextState();
}

class _GoldShimmerTextState extends State<GoldShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.orange.shade700,
                Colors.amber.shade300,
              ],
              stops: [0, _animation.value, 1],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // This will be overridden by shader
            ),
          ),
        );
      },
    );
  }
}

Future<void> updateAppPopupWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required bool isForceUpdate, // true = force, false = normal
  required Future<void> Function() onUpdatePress,
  required VoidCallback onClosePress,
  bool isLoadingState = false,
}) async {
  showDialog(
    barrierDismissible: !isForceUpdate, // can't tap outside if force update
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => !isForceUpdate, // disables back button
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: sizes!.isPhone ? sizes!.width : sizes!.width / 1.5,
                      margin: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFBBA473),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: sizes!.heightRatio * 16,
                          horizontal: sizes!.widthRatio * 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstPadding.sizeBoxWithHeight(height: 10),

                            /// Title
                            GetGenericText(
                              text: heading,
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 20,
                                tabletVal: 24,
                              ),
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey6Color,
                              lines: 2,
                              textAlign: TextAlign.center,
                            ).getChildCenter(),

                            ConstPadding.sizeBoxWithHeight(height: 12),

                            /// Subtitle
                            GetGenericText(
                              text: subtitle,
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 16,
                                tabletVal: 18,
                              ),
                              fontWeight: FontWeight.w300,
                              color: AppColors.grey4Color,
                              lines: 6,
                              textAlign: TextAlign.center,
                            ).getChildCenter(),

                            ConstPadding.sizeBoxWithHeight(height: 20),

                            /// Update Button
                            GestureDetector(
                              onTap: () async {
                                setModalState(() {
                                  isLoadingState = true;
                                });
                                await onUpdatePress.call();
                                setModalState(() {
                                  isLoadingState = false;
                                });
                              },
                              child: Container(
                                height: sizes!.responsiveHeight(
                                  phoneVal: 48,
                                  tabletVal: 56,
                                ),
                                width: sizes!.responsiveWidth(
                                  phoneVal: 300,
                                  tabletVal: 350,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    begin: Alignment(1.00, 0.01),
                                    end: Alignment(-1, -0.01),
                                    colors: [
                                      Color(0xFF675A3D),
                                      Color(0xFFBBA473),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: isLoadingState == false
                                      ? Directionality.of(context) == TextDirection.rtl?
                                      GetGenericText(
                                          text: AppLocalizations.of(context)!.update,//"Update",
                                          fontSize: sizes!.responsiveFont(
                                            phoneVal: 14,
                                            tabletVal: 16,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ):
                                       GetGenericText(
                                          text: AppLocalizations.of(context)!.update,//"Update",
                                          fontSize: sizes!.responsiveFont(
                                            phoneVal: 14,
                                            tabletVal: 16,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        )
                                      : SizedBox(
                                          height: sizes!.heightRatio * 16,
                                          width: sizes!.widthRatio * 16,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              ),
                                        ),
                                ),
                              ),
                            ),

                            /// Close Button (only if NOT force update)
                            if (!isForceUpdate) ...[
                              ConstPadding.sizeBoxWithHeight(height: 10),
                              GestureDetector(
                                onTap: onClosePress,
                                child: Container(
                                  height: sizes!.responsiveHeight(
                                    phoneVal: 48,
                                    tabletVal: 56,
                                  ),
                                  width: sizes!.responsiveWidth(
                                    phoneVal: 300,
                                    tabletVal: 350,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Directionality.of(context) == TextDirection.rtl?
                                     GetGenericText(
                                      text: AppLocalizations.of(context)!.exit_app,//"Close",
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ):
                                    GetGenericText(
                                      text: AppLocalizations.of(context)!.exit_app,
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

/// pop up widget
Future<void> genericTransactionPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required String noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required bool isAddingFriendState,
  required VoidCallback onNoPress,
  required bool alreadyFriend,
  // required Future<void> Function() onAddFriendPress,
  required Future<void> Function() onDeleteFriendPress,
  required Future<void> Function() onYesPress, // Changed to async function
}) async {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      bool localAlreadyFriend = alreadyFriend;
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  width: sizes!.width,
                  // height: sizes!.heightRatio * 300,
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    color: Color(0xFF232323),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      // color: Colors.white,
                      color: Color(0xFFBBA473),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes!.heightRatio * 16,
                      horizontal: sizes!.widthRatio * 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/success_tick_icon.svg",
                          height: sizes!.heightRatio * 48,
                          width: sizes!.widthRatio * 48,
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 10),

                        ///Title
                        GetGenericText(
                          text: heading,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey6Color,
                          lines: 2,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        GetGenericText(
                          text: subtitle,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.grey4Color,
                          lines: 6,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 20),

                        // Yes Button
                        GestureDetector(
                          onTap: () async {
                            setModalState(() {
                              isLoadingState = true; // Show loading
                            });
                            await onYesPress.call();
                            setModalState(() {
                              isLoadingState = false; // Hide loading
                            });
                          },
                          child: Container(
                            height: sizes!.fontRatio * 48,
                            width: sizes!.widthRatio * 300,
                            decoration: BoxDecoration(
                              //color: AppColors.primaryGold500,
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment(1.00, 0.01),
                                end: Alignment(-1, -0.01),
                                colors: [
                                  Color(0xFF675A3D),
                                  Color(0xFFBBA473),
                                ],
                              ),
                            ),
                            child: Center(
                              child: isLoadingState == false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GetGenericText(
                                          text: yesButtonTitle,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        ConstPadding.sizeBoxWithWidth(
                                          width: 10,
                                        ),
                                        SvgPicture.asset(
                                          'assets/svg/forward_arrow.svg',
                                          height: sizes!.heightRatio * 20,
                                          width: sizes!.widthRatio * 20,
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      height: sizes!.heightRatio * 16,
                                      width: sizes!.widthRatio * 16,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 10),
                        // Visibility(
                        //   visible: !localAlreadyFriend,
                        //   child: GestureDetector(
                        //     onTap: () async {
                        //       setModalState(() {
                        //         isAddingFriendState = true;
                        //       });
                        //       await onAddFriendPress.call();
                        //       setModalState(() {
                        //         isAddingFriendState = false;
                        //         localAlreadyFriend = true;
                        //       });
                        //     },
                        //     child: isAddingFriendState
                        //         ? Center(
                        //             child: CircularProgressIndicator(
                        //               valueColor: AlwaysStoppedAnimation<Color>(
                        //                 AppColors.whiteColor,
                        //               ),
                        //             ),
                        //           )
                        //         : GetGenericText(
                        //             text: "Save receiver as Friend",
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.w700,
                        //             color: AppColors.primaryGold500,
                        //             isUnderline: true,
                        //           ),
                        //   ),
                        // ),
                        Visibility(
                          visible: localAlreadyFriend,
                          child: GestureDetector(
                            onTap: () async {
                              setModalState(() {
                                isAddingFriendState = true;
                              });
                              await onDeleteFriendPress.call();
                              setModalState(() {
                                isAddingFriendState = false;
                              });
                            },
                            child: isAddingFriendState
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                : GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.deleteReceiverFriend, //"Delete receiver as Friend",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGold500,
                                    isUnderline: true,
                                  ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 10),
                        // No Button
                        GestureDetector(
                          onTap: onNoPress,
                          child: Container(
                            height: sizes!.fontRatio * 48,
                            width: sizes!.widthRatio * 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: GetGenericText(
                                text: noButtonTitle,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// pop up widget
Future<void> transactionFailedPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required String noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress, // Changed to async function
}) async {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  width: sizes!.width,
                  // height: sizes!.heightRatio * 300,
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    color: Color(0xFF232323),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      // color: Colors.white,
                      color: Color(0xFFBBA473),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes!.heightRatio * 16,
                      horizontal: sizes!.widthRatio * 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/fail_tick_icon.svg",
                          height: sizes!.heightRatio * 48,
                          width: sizes!.widthRatio * 48,
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 10),

                        ///Title
                        GetGenericText(
                          text: heading,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey6Color,
                          lines: 2,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        GetGenericText(
                          text: subtitle,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.grey4Color,
                          lines: 6,
                          textAlign: TextAlign.center,
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 20),

                        // Yes Button
                        GestureDetector(
                          onTap: () async {
                            setModalState(() {
                              isLoadingState = true; // Show loading
                            });
                            await onYesPress.call();
                            setModalState(() {
                              isLoadingState = false; // Hide loading
                            });
                          },
                          child: Container(
                            height: sizes!.fontRatio * 48,
                            width: sizes!.widthRatio * 300,
                            decoration: BoxDecoration(
                              //color: AppColors.primaryGold500,
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment(1.00, 0.01),
                                end: Alignment(-1, -0.01),
                                colors: [
                                  Color(0xFF675A3D),
                                  Color(0xFFBBA473),
                                ],
                              ),
                            ),
                            child: Center(
                              child: isLoadingState == false
                                  ? GetGenericText(
                                      text: yesButtonTitle,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    )
                                  : SizedBox(
                                      height: sizes!.heightRatio * 16,
                                      width: sizes!.widthRatio * 16,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// pop up widget
Future<void> historyFilterPopUpWidget({
  required BuildContext context,
  required TextEditingController fromController,
  required TextEditingController toController,
  required VoidCallback onPopUpCloseTap,
  required VoidCallback onClearFiltersTap,
  required String selectedFilter,
  required Function(String filter, String? dateFrom, String? dateTo)
  onApplyFilterTap,
}) async {
  String? dateFrom;
  String? dateTo;

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  width: sizes!.width,
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFF232323),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFFBBA473),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes!.heightRatio * 16,
                      horizontal: sizes!.widthRatio * 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.history_filters_title, //"Filters",
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            // Close popup
                            GestureDetector(
                              onTap: onPopUpCloseTap,
                              child: Container(
                                color: Colors.transparent,
                                child: SvgPicture.asset(
                                  "assets/svg/close_icon.svg",
                                  height: sizes!.heightRatio * 20,
                                  width: sizes!.widthRatio * 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 24),
                        Directionality.of(context) == TextDirection.rtl
                            ? GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.history_filters_show_from, //"Show History from",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ).getAlignRight()
                            : GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.history_filters_show_from, //"Show History from",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ).getAlign(),
                        ConstPadding.sizeBoxWithHeight(height: 4),
                        // All filter
                        CheckboxItem(
                          text: AppLocalizations.of(
                            context,
                          )!.history_filters_all, //"All",
                          isChecked: selectedFilter == "All",
                          onTap: () {
                            setModalState(() {
                              selectedFilter = "All";
                              dateFrom = null;
                              dateTo = null;
                            });
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // Today filter
                        CheckboxItem(
                          text: AppLocalizations.of(
                            context,
                          )!.history_filters_today, //"Today",
                          isChecked: selectedFilter == "Today",
                          onTap: () {
                            setModalState(() {
                              selectedFilter = "Today";
                              final now = DateTime.now();
                              dateFrom = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                0,
                                0,
                                0,
                              ).toIso8601String();
                              dateTo = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                23,
                                59,
                                59,
                              ).toIso8601String();
                            });
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // This Week filter
                        CheckboxItem(
                          text: AppLocalizations.of(
                            context,
                          )!.history_filters_this_week, //"This Week",
                          isChecked: selectedFilter == "This Week",
                          onTap: () {
                            setModalState(() {
                              selectedFilter = "This Week";
                              final now = DateTime.now();
                              final startOfWeek = now.subtract(
                                Duration(days: now.weekday - 1),
                              );
                              dateFrom = DateTime(
                                startOfWeek.year,
                                startOfWeek.month,
                                startOfWeek.day,
                                0,
                                0,
                                0,
                              ).toIso8601String();
                              dateTo = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                23,
                                59,
                                59,
                              ).toIso8601String();
                            });
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // This Month filter
                        CheckboxItem(
                          text: AppLocalizations.of(
                            context,
                          )!.history_filters_this_month, //"This Month",
                          isChecked: selectedFilter == "This Month",
                          onTap: () {
                            setModalState(() {
                              selectedFilter = "This Month";
                              final now = DateTime.now();
                              dateFrom = DateTime(
                                now.year,
                                now.month,
                                1,
                                0,
                                0,
                                0,
                              ).toIso8601String();
                              dateTo = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                23,
                                59,
                                59,
                              ).toIso8601String();
                            });
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        // Custom filter
                        Directionality.of(context) == TextDirection.rtl
                            ? GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.history_filters_custom, //"Custom"
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ).getAlignRight()
                            : GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.history_filters_custom, //"Custom",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey5Color,
                              ).getAlign(),
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        Directionality.of(context) == TextDirection.rtl
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: sizes!.widthRatio * 140,
                                    child: TextFormFieldWithIcon(
                                      title: "title",
                                      hintText: "DD/MM/YYYY",
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.history_filters_to, //"To",
                                      controller: toController,
                                      iconString: "assets/svg/date_icon.svg",
                                      onTap: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                        if (selectedDate != null) {
                                          toController.text =
                                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                          dateTo = DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            23,
                                            59,
                                            59,
                                          ).toIso8601String();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: sizes!.widthRatio * 140,
                                    child: TextFormFieldWithIcon(
                                      title: "title",
                                      hintText: "DD/MM/YYYY",
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.history_filters_from, //"From",
                                      controller: fromController,
                                      iconString: "assets/svg/date_icon.svg",
                                      onTap: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                        if (selectedDate != null) {
                                          fromController.text =
                                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                          dateFrom = DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            0,
                                            0,
                                            0,
                                          ).toIso8601String();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: sizes!.widthRatio * 140,
                                    child: TextFormFieldWithIcon(
                                      title: "title",
                                      hintText: "DD/MM/YYYY",
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.history_filters_from, //"From",
                                      controller: fromController,
                                      iconString: "assets/svg/date_icon.svg",
                                      onTap: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                        if (selectedDate != null) {
                                          fromController.text =
                                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                          dateFrom = DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            0,
                                            0,
                                            0,
                                          ).toIso8601String();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: sizes!.widthRatio * 140,
                                    child: TextFormFieldWithIcon(
                                      title: "title",
                                      hintText: "DD/MM/YYYY",
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.history_filters_to, //"To",
                                      controller: toController,
                                      iconString: "assets/svg/date_icon.svg",
                                      onTap: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                        if (selectedDate != null) {
                                          toController.text =
                                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                          dateTo = DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day,
                                            23,
                                            59,
                                            59,
                                          ).toIso8601String();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                        ConstPadding.sizeBoxWithHeight(height: 16),
                        // Apply filter button
                        GestureDetector(
                          onTap: () {
                            if (fromController.text != "" &&
                                toController.text != "") {
                              selectedFilter = "";
                            }
                            onApplyFilterTap(selectedFilter, dateFrom, dateTo);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: sizes!.heightRatio * 314,
                            height: sizes!.heightRatio * 48,
                            decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(1.00, 0.01),
                                end: Alignment(-1, -0.01),
                                colors: [
                                  Color(0xFF675A3D),
                                  Color(0xFFBBA473),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  context,
                                )!.history_filters_apply_btn, //"Apply Filters",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 10),
                        // Clear filters button
                        GestureDetector(
                          onTap: () {
                            onClearFiltersTap();
                            Navigator.pop(context);
                          },
                          child: GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.history_filters_clear_btn, //"Clear Filters",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey4Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
// Future<void> historyFilterPopUpWidget({
//   required BuildContext context,
//   required TextEditingController fromController,
//   required TextEditingController toController,
//   required VoidCallback onPopUpCloseTap,
//   required VoidCallback onClearFiltersTap,
//   required VoidCallback onApplyFilterTap,
//   // Changed to async function
// }) async {
//   // show the dialog
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setModalState) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   width: sizes!.width,
//                   // height: sizes!.heightRatio * 300,
//                   margin: const EdgeInsets.all(16),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     // color: Colors.white,
//                     color: Color(0xFF232323),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       // color: Colors.white,
//                       color: Color(0xFFBBA473),
//                       width: 1,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       vertical: sizes!.heightRatio * 16,
//                       horizontal: sizes!.widthRatio * 16,
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             GetGenericText(
//                               text: "Filters",
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),

//                             /// close popup
//                             GestureDetector(
//                               onTap: onPopUpCloseTap,
//                               child: Container(
//                                 color: Colors.transparent,
//                                 child: SvgPicture.asset(
//                                   "assets/svg/close_icon.svg",
//                                   height: sizes!.heightRatio * 20,
//                                   width: sizes!.widthRatio * 20,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 24),
//                         GetGenericText(
//                           text: "Show History from",
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey5Color,
//                         ).getAlign(),
//                         ConstPadding.sizeBoxWithHeight(height: 4),
//                         CheckboxItem(
//                           text: "All",
//                           isChecked: true,
//                           onTap: () {},
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 8),
//                         CheckboxItem(
//                           text: "Today",
//                           isChecked: true,
//                           onTap: () {},
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 8),
//                         CheckboxItem(
//                           text: "This Week",
//                           isChecked: true,
//                           onTap: () {},
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 8),
//                         CheckboxItem(
//                           text: "This Month",
//                           isChecked: true,
//                           onTap: () {},
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 8),
//                         GetGenericText(
//                           text: "Custom",
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey5Color,
//                         ).getAlign(),
//                         ConstPadding.sizeBoxWithHeight(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(
//                               width: sizes!.widthRatio * 140,
//                               child: TextFormFieldWithIcon(
//                                 title: "title",
//                                 hintText: "DD/MM/YYYY",
//                                 labelText: "From",
//                                 controller: fromController,
//                                 iconString: "assets/svg/date_icon.svg",
//                                 onTap: () {},
//                               ),
//                             ),
//                             SizedBox(
//                               width: sizes!.widthRatio * 140,
//                               child: TextFormFieldWithIcon(
//                                 title: "title",
//                                 hintText: "DD/MM/YYYY",
//                                 labelText: "To",
//                                 controller: toController,
//                                 iconString: "assets/svg/date_icon.svg",
//                                 onTap: () {},
//                               ),
//                             ),
//                           ],
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 16),
//                         // apply filter button
//                         GestureDetector(
//                           onTap: onApplyFilterTap,
//                           child: Container(
//                             width: sizes!.heightRatio * 314,
//                             height: sizes!.heightRatio * 48,
//                             decoration: ShapeDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment(1.00, 0.01),
//                                 end: Alignment(-1, -0.01),
//                                 colors: [
//                                   Color(0xFF675A3D),
//                                   Color(0xFFBBA473),
//                                 ],
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: Center(
//                               child: GetGenericText(
//                                 text: "Apply Filters",
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         ConstPadding.sizeBoxWithHeight(height: 10),
//                         // clear filters button
//                         GestureDetector(
//                           onTap: onClearFiltersTap,
//                           child: GetGenericText(
//                             text: "Clear Filters",
//                             fontSize: 14,
//                             fontWeight: FontWeight.w400,
//                             color: AppColors.grey4Color,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

/// pop up widget
Future<void> addCustomerCommentPopUpWidget({
  required BuildContext context,
  required String heading,
  required String subtitle,
  required String noButtonTitle,
  required String yesButtonTitle,
  required bool isLoadingState,
  required GlobalKey<FormState> formKey,
  required TextEditingController controller,
  String? Function(String? value)? validator,
  required VoidCallback onNoPress,
  required Future<void> Function() onYesPress, // Changed to async function
}) async {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: sizes!.width,
                      // height: sizes!.heightRatio * 300,
                      margin: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: sizes!.heightRatio * 20,
                          horizontal: sizes!.widthRatio * 20,
                        ),
                        child: Column(
                          children: [
                            ///Title
                            GetGenericText(
                              text: heading,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyScale1000,
                              lines: 2,
                              textAlign: TextAlign.center,
                            ),
                            ConstPadding.sizeBoxWithHeight(height: 12),

                            TextFormField(
                              validator: validator,
                              controller: controller,
                              style: const TextStyle(
                                color: AppColors.greyScale1000,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.greyScale30,
                                  ),
                                ),
                                // errorBorder: InputBorder.none,
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                hintText: "Comment",
                                hintStyle: const TextStyle(
                                  color: AppColors.greyScale700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            // GetGenericText(
                            //   text: subtitle,
                            //   fontSize: 16,
                            //   fontWeight: FontWeight.w300,
                            //   color: AppColors.greyScale1000,
                            //   lines: 6,
                            //   textAlign: TextAlign.center,
                            // ),
                            // ConstPadding.sizeBoxWithHeight(height: 20),
                            ConstPadding.sizeBoxWithHeight(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: onNoPress,
                                  child: Container(
                                    height: sizes!.fontRatio * 48,
                                    width: sizes!.widthRatio * 140,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Center(
                                      child: GetGenericText(
                                        text: noButtonTitle,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setModalState(() {
                                      isLoadingState = true; // Show loading
                                    });
                                    await onYesPress.call();
                                    setModalState(() {
                                      isLoadingState = false; // Hide loading
                                    });
                                    // if (context.mounted) {
                                    //   Navigator.pop(context); // Close the dialog
                                    // }
                                  },
                                  child: Container(
                                    height: sizes!.fontRatio * 48,
                                    width: sizes!.widthRatio * 140,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold500,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: isLoadingState == false
                                          ? GetGenericText(
                                              text: yesButtonTitle,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            )
                                          : SizedBox(
                                              height: sizes!.heightRatio * 16,
                                              width: sizes!.widthRatio * 16,
                                              child:
                                                  const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.0,
                                                  ),
                                            ),
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
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
