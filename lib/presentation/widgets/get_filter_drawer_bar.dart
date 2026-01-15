import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

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
  String selectedBarType = "Minted"; // Default to match UI screenshot

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

  @override
  Widget build(BuildContext context) {
    bool isFilterSelected = selectedWeight != null;
    final allWeights = [...weights, ...castingWeights];

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Apply Filters to quickly view your desired products.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Weight range",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allWeights.map((item) {
                      bool isSelected =
                          selectedUniqueWeight == item['uniqueValue'];
                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedUniqueWeight = item['uniqueValue'];
                          selectedWeight = item['value'];
                          selectedWeightCategory = item["category"];
                        }),
                        child: Container(
                          width: (MediaQuery.of(context).size.width / 3) - 20,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "Bar type",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ["Casted", "Minted"].map((type) {
                      bool isSelected = selectedBarType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedBarType = type),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: type == "Casted" ? 12 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white24
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: GestureDetector(
              onTap: () {
                if (isFilterSelected) {
                  widget.onApplyFilter(selectedWeight, selectedWeightCategory);
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isFilterSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.goldColor,
                            AppColors.goldLightColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: isFilterSelected ? null : const Color(0xFF2A2A2A),
                ),
                child: Center(
                  child: Text(
                    "Apply filters",
                    style: TextStyle(
                      color: isFilterSelected ? Colors.black : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
