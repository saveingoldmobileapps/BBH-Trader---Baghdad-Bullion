import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';
import 'gram_filter_item.dart';

class GetFilterDrawerBar extends StatefulWidget {
  final VoidCallback onTap;
  final Function(
    String? selectedWeight,
    String? selectedWeightCategory,
  )
  onApplyFilter;

  const GetFilterDrawerBar({
    super.key,
    required this.onTap,
    required this.onApplyFilter,
  });

  @override
  State<GetFilterDrawerBar> createState() => _GetFilterDrawerBarState();
}

class _GetFilterDrawerBarState extends State<GetFilterDrawerBar> {
  String? selectedUniqueWeight;
  String? selectedWeight;
  String? selectedWeightCategory;

  final List<Map<String, dynamic>> weights = [
    {
      "text": AppLocalizations.of(navigatorKey.currentContext!)!.weight_1_gram,
      "uniqueValue": "1Gram",
      "value": "1",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(navigatorKey.currentContext!)!.weight_2_grams,
      "uniqueValue": "2Grams",
      "value": "2",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_2_5_grams,
      "uniqueValue": "2.5Grams",
      "value": "2.5",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(navigatorKey.currentContext!)!.weight_5_grams,
      "uniqueValue": "5Grams",
      "value": "5",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_10_grams,
      "uniqueValue": "10Grams",
      "value": "10",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_20_grams,
      "uniqueValue": "20Grams",
      "value": "20",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_half_ounce,
      "uniqueValue": "1/2Ounce",
      "value": "15.55",
      "category": "Ounce",
    },
    {
      "text": AppLocalizations.of(navigatorKey.currentContext!)!.weight_1_ounce,
      "uniqueValue": "1Ounce",
      "value": "1",
      "category": "Ounce",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_50_grams,
      "uniqueValue": "50Grams",
      "value": "50",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_100_grams,
      "uniqueValue": "100Grams",
      "value": "100",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(navigatorKey.currentContext!)!.weight_10_tola,
      "uniqueValue": "10Tola",
      "value": "10",
      "category": "Tola",
    },
  ];

  final castingWeights = [
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_250_grams,
      "uniqueValue": "250Grams",
      "value": "250",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_500_grams,
      "uniqueValue": "500Grams",
      "value": "500",
      "category": "Gram",
    },
    {
      "text": AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.weight_1_kilogram,
      "uniqueValue": "1Kilogram",
      "value": "1",
      "category": "KG",
    },
  ];

  Widget buildFilterItem(Map<String, dynamic> item) {
    return GramFilterItem(
      text: item["text"],
      isChecked: selectedUniqueWeight == item['uniqueValue'],
      onTap: () {
        setState(() {
          debugPrint("selectedWeight: ${item['value']}");
          selectedUniqueWeight = item['uniqueValue'];
          selectedWeight = item['value'];
          selectedWeightCategory = item["category"];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SizedBox(
  child: Drawer(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1.00, 0.01),
          end: Alignment(-1, -0.01),
          colors: [
            const Color(0xFF675A3D),
            const Color(0xFFBBA473),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: Directionality.of(context) == TextDirection.rtl
              ? EdgeInsets.only(
                  top: sizes!.heightRatio * 16.0,
                  right: sizes!.widthRatio * 16.0,
                )
              : EdgeInsets.only(
                  top: sizes!.heightRatio * 16.0,
                  left: sizes!.widthRatio * 16.0,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header (fixed)
              Row(
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(
                      navigatorKey.currentContext!,
                    )!.filters,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyScale1000,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/svg/menu_close.svg",
                        height: sizes!.heightRatio * 24,
                        width: sizes!.widthRatio * 24,
                      ),
                    ),
                  ),
                  ConstPadding.sizeBoxWithWidth(width: 12),
                ],
              ),
              GetGenericText(
                text: AppLocalizations.of(
                  navigatorKey.currentContext!,
                )!.apply_filters_description,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.greyScale900,
                lines: 4,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),

              /// Scrollable filters from Minting downwards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Minting
                      GetGenericText(
                        text: AppLocalizations.of(
                          navigatorKey.currentContext!,
                        )!.minting,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyScale1000,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 6),
                      ...weights.map(
                        (item) => buildFilterItem(item).get5VerticalPadding(),
                      ),

                      ConstPadding.sizeBoxWithHeight(height: 20),

                      /// Casting
                      GetGenericText(
                        text: AppLocalizations.of(
                          navigatorKey.currentContext!,
                        )!.casting,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyScale1000,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 6),
                      ...castingWeights.map(
                        (item) => buildFilterItem(item).get5VerticalPadding(),
                      ),

                      const SizedBox(height: 24),

                      /// Bottom buttons
                      Padding(
                        padding: Directionality.of(context) == TextDirection.rtl
                            ? EdgeInsets.only(left: 16)
                            : EdgeInsets.only(right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Clear Filter
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedWeight = null;
                                  selectedWeightCategory = null;
                                  widget.onApplyFilter(
                                    selectedWeight,
                                    selectedWeightCategory,
                                  );
                                });
                              },
                              child: GetGenericText(
                                text: AppLocalizations.of(
                                  navigatorKey.currentContext!,
                                )!.clear_filters,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyScale1000,
                              ),
                            ),

                            /// Apply Filters button
                            GestureDetector(
                              onTap: () {
                                if (selectedWeight != null) {
                                  widget.onApplyFilter(
                                    selectedWeight!,
                                    selectedWeightCategory!,
                                  );
                                }
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? const EdgeInsets.only(right: 5.0)
                                    : const EdgeInsets.only(left: 5.0),
                                child: Container(
                                  width: sizes!.widthRatio * 140,
                                  height: sizes!.heightRatio * 45,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF232323),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: GetGenericText(
                                      text: AppLocalizations.of(
                                        navigatorKey.currentContext!,
                                      )!.apply_filters,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      isInter: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
)

      // Drawer(
      //   child: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment(1.00, 0.01),
      //         end: Alignment(-1, -0.01),
      //         colors: [
      //           Color(0xFF675A3D),
      //           Color(0xFFBBA473),
      //         ],
      //       ),
      //     ),
      //     child: SafeArea(
      //       child: Padding(
      //         padding: Directionality.of(context) == TextDirection.rtl
      //             ? EdgeInsets.only(
      //                 top: sizes!.heightRatio * 16.0,

      //                 right: sizes!.widthRatio * 16.0,
      //               )
      //             : EdgeInsets.only(
      //                 top: sizes!.heightRatio * 16.0,
      //                 left: sizes!.widthRatio * 16.0,
      //               ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Row(
      //               children: [
      //                 GetGenericText(
      //                   text: AppLocalizations.of(
      //                     navigatorKey.currentContext!,
      //                   )!.filters,
      //                   fontSize: 22,
      //                   fontWeight: FontWeight.w700,
      //                   color: AppColors.greyScale1000,
      //                 ),
      //                 const Spacer(),
      //                 GestureDetector(
      //                   onTap: widget.onTap,
      //                   child: Container(
      //                     color: Colors.transparent,
      //                     child: SvgPicture.asset(
      //                       "assets/svg/menu_close.svg",
      //                       height: sizes!.heightRatio * 24,
      //                       width: sizes!.widthRatio * 24,
      //                     ),
      //                   ),
      //                 ),
      //                 ConstPadding.sizeBoxWithWidth(width: 12),
      //               ],
      //             ),
      //             GetGenericText(
      //               text: AppLocalizations.of(
      //                 navigatorKey.currentContext!,
      //               )!.apply_filters_description,
      //               fontSize: 12,
      //               fontWeight: FontWeight.w400,
      //               color: AppColors.greyScale900,
      //               lines: 4,
      //             ),
      //             ConstPadding.sizeBoxWithHeight(height: 16),
      //             GetGenericText(
      //               text: AppLocalizations.of(
      //                 navigatorKey.currentContext!,
      //               )!.minting,
      //               fontSize: 16,
      //               fontWeight: FontWeight.w700,
      //               color: AppColors.greyScale1000,
      //             ),
      //             ConstPadding.sizeBoxWithHeight(height: 6),
      //             ...weights.map(
      //               (item) => buildFilterItem(item).get5VerticalPadding(),
      //             ),
      //             ConstPadding.sizeBoxWithHeight(height: 20),
      //             GetGenericText(
      //               text: AppLocalizations.of(
      //                 navigatorKey.currentContext!,
      //               )!.casting,
      //               fontSize: 16,
      //               fontWeight: FontWeight.w700,
      //               color: AppColors.greyScale1000,
      //             ),
      //             ConstPadding.sizeBoxWithHeight(height: 6),
      //             ...castingWeights.map(
      //               (item) => buildFilterItem(item).get5VerticalPadding(),
      //             ),
      //             const Spacer(),
      //             Padding(
      //               padding: Directionality.of(context) == TextDirection.rtl
      //                   ? EdgeInsets.only(left: 16)
      //                   : EdgeInsets.only(right: 16),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   /// Clear Filter
      //                   GestureDetector(
      //                     onTap: () {
      //                       setState(() {
      //                         selectedWeight = null;
      //                         selectedWeightCategory = null;
      //                         widget.onApplyFilter(
      //                           selectedWeight,
      //                           selectedWeightCategory,
      //                         );
      //                       });
      //                     },
      //                     child: GetGenericText(
      //                       text: AppLocalizations.of(
      //                         navigatorKey.currentContext!,
      //                       )!.clear_filters,
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.w500,
      //                       color: AppColors.greyScale1000,
      //                     ),
      //                   ),

      //                   /// Apply Filters button
      //                   GestureDetector(
      //                     onTap: () {
      //                       if (selectedWeight != null) {
      //                         widget.onApplyFilter(
      //                           selectedWeight!,
      //                           selectedWeightCategory!,
      //                         );
      //                       }
      //                       Navigator.pop(context);
      //                     },
      //                     child: Padding(
      //                       padding:
      //                           Directionality.of(context) == TextDirection.rtl
      //                           ? EdgeInsets.only(right: 5.0)
      //                           : EdgeInsets.only(left: 5.0),
      //                       child: Container(
      //                         width: sizes!.widthRatio * 140,
      //                         height: sizes!.heightRatio * 45,
      //                         decoration: ShapeDecoration(
      //                           color: Color(0xFF232323),
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(10),
      //                           ),
      //                         ),
      //                         child: Center(
      //                           child: GetGenericText(
      //                             text: AppLocalizations.of(
      //                               navigatorKey.currentContext!,
      //                             )!.apply_filters,
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.w500,
      //                             color: Colors.white,
      //                             isInter: true,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             ConstPadding.sizeBoxWithHeight(height: 24),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    
    );
  
  }
}
