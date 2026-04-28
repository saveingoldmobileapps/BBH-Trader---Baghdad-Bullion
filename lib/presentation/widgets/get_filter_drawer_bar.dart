import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../l10n/app_localizations.dart';

class GetFilterDrawerBar extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  final Function(
    String? selectedWeight,
    String? selectedWeightCategory,
    String? shapeType,
    String? shapeSubType,
  )
  onApplyFilter;

  const GetFilterDrawerBar({
    super.key,
    required this.onTap,
    required this.onApplyFilter,
  });

  @override
  ConsumerState<GetFilterDrawerBar> createState() => _GetFilterDrawerBarState();
}

class _GetFilterDrawerBarState extends ConsumerState<GetFilterDrawerBar> {
  static const String _castedBarType = 'Casted';
  static const String _mintedBarType = 'Minted';
  static const String _allmintedAndCast = 'All';
  static const String _castingShapeType = 'Casting';
  static const String _mintingShapeType = 'Minting';
  static const String _shapeSubTypeBar = 'Bar';
  static const String _shapeSubTypeCoin = 'Coin';

  String? selectedUniqueWeight;
  String? selectedWeight;
  String? selectedWeightCategory;
  String? selectedShapeSubType;
  // String selectedBarType = _mintedBarType; // Default to match UI screenshot
  String selectedBarType = _allmintedAndCast; // Default = All
  bool _filtersLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filtersLoaded) return;
    _filtersLoaded = true;
    // Default: no subtype selected, no weights fetched until user chooses type.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final esouqState = ref.watch(esouqProvider);
    final filterOptions = esouqState.filterOptions;

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
                    Text(
                      l10n.filters,
                      style: const TextStyle(
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
                Text(
                  l10n.apply_filters_description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                  Text(
                    l10n.esouq_weight_range,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  esouqState.isFilterLoading
                      ? _buildWeightChipsShimmer(context)
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: filterOptions.map((item) {
                            final uniqueValue =
                                '${item.weightFactor ?? ''}_${item.weightCategory ?? ''}_${item.id ?? ''}';
                            final label =
                                '${item.weightFactor ?? ''} ${item.weightCategory ?? ''}'
                                    .trim();
                            final isSelected = selectedUniqueWeight == uniqueValue;
                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedUniqueWeight = uniqueValue;
                                selectedWeight = item.weightFactor;
                                selectedWeightCategory = item.weightCategory;
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
                                    label.isNotEmpty ? label : l10n.na,
                                    style: TextStyle(
                                      color:
                                          isSelected ? Colors.black : Colors.white,
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
                  Text(
                    l10n.esouq_bar_type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTypeButton(_allmintedAndCast),
                      const SizedBox(width: 12),
                      _buildTypeButton(_mintedBarType),
                      const SizedBox(width: 12),
                      _buildTypeButton(_castedBarType),
                    ],
                  ),

                  if (selectedBarType == _mintedBarType) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Shape Sub Type',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSubTypeButton(_shapeSubTypeBar),
                        const SizedBox(width: 12),
                        _buildSubTypeButton(_shapeSubTypeCoin),
                      ],
                    ),
                  ],

                  // Row(
                  //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children:
                  //       [
                  //         _allmintedAndCast,
                  //         _mintedBarType,
                  //         _castedBarType,
                  //       ].map((type) {
                  //         bool isSelected = selectedBarType == type;
                  //         final label = type == _castedBarType
                  //             ? l10n.casting
                  //             : type == _mintedBarType
                  //             ? l10n.minting
                  //             : l10n.all; // 👈 add this key
                  //         return Expanded(
                  //           child: GestureDetector(
                  //             // onTap: () => setState(() => selectedBarType = type),
                  //             // onTap: () => setState(() {
                  //             //   selectedBarType = type;

                  //             //   /// Reset selection when switching
                  //             //   selectedUniqueWeight = null;
                  //             //   selectedWeight = null;
                  //             //   selectedWeightCategory = null;
                  //             // }),
                  //             onTap: () => setState(() {
                  //               selectedBarType = type;

                  //               selectedUniqueWeight = null;
                  //               selectedWeight = null;
                  //               selectedWeightCategory = null;
                  //             }),
                  //             child: Container(
                  //               margin: EdgeInsets.only(
                  //                 right: type == _castedBarType ? 12 : 0,
                  //               ),
                  //               padding: const EdgeInsets.symmetric(
                  //                 vertical: 14,
                  //               ),
                  //               decoration: BoxDecoration(
                  //                 color: isSelected
                  //                     ? Colors.white.withOpacity(0.1)
                  //                     : const Color(0xFF1E1E1E),
                  //                 borderRadius: BorderRadius.circular(10),
                  //                 border: Border.all(
                  //                   color: isSelected
                  //                       ? Colors.white24
                  //                       : Colors.white.withOpacity(0.05),
                  //                 ),
                  //               ),
                  //               child: Center(
                  //                 child: Text(
                  //                   label,
                  //                   style: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       }).toList(),
                  // ),
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
                final String? shapeType = selectedBarType == _castedBarType
                    ? _castingShapeType
                    : selectedBarType == _mintedBarType
                    ? _mintingShapeType
                    : null;

                final String? shapeSubType =
                    shapeType == _mintingShapeType ? selectedShapeSubType : null;

                widget.onApplyFilter(
                  selectedWeight,
                  selectedWeightCategory,
                  shapeType,
                  shapeSubType,
                );
                Navigator.pop(context);
              },  
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.goldColor,
                      AppColors.goldLightColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.apply_filters,
                    style: TextStyle(
                      color: Colors.black,
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

  Widget _buildTypeButton(String type) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = selectedBarType == type;

    final label = type == _castedBarType
        ? l10n.casting
        : type == _mintedBarType
        ? l10n.minting
        : l10n.all;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedBarType = type;
            selectedUniqueWeight = null;
            selectedWeight = null;
            selectedWeightCategory = null;
            selectedShapeSubType = null;
          });

          if (type == _castedBarType) {
            await ref.read(esouqProvider.notifier).fetchEsouqFilterOptions(
                  subtype: 'casting',
                  shapeSubType: _shapeSubTypeBar,
                );
          } else if (type == _mintedBarType) {
            await ref.read(esouqProvider.notifier).fetchEsouqFilterOptions(
                  subtype: 'minting',
                  shapeSubType: _shapeSubTypeBar,
                );
          } else {
            // All -> clear filter options list
            ref
                .read(esouqProvider.notifier)
                .fetchEsouqFilterOptions(subtype: 'minting', shapeSubType: _shapeSubTypeBar);
            // We still keep list loaded (minting bar) so user can pick weight quickly if needed.
          }
        },
        child: Container(
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
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTypeButton(String subType) {
    final isSelected = selectedShapeSubType == subType;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedShapeSubType = subType;
            selectedUniqueWeight = null;
            selectedWeight = null;
            selectedWeightCategory = null;
          });
          if (selectedBarType == _mintedBarType) {
            await ref.read(esouqProvider.notifier).fetchEsouqFilterOptions(
                  subtype: 'minting',
                  shapeSubType: subType,
                );
          }
        },
        child: Container(
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
              subType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChipsShimmer(BuildContext context) {
    final chipWidth = (MediaQuery.of(context).size.width / 3) - 20;
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: Colors.white24,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(9, (index) {
          return Container(
            width: chipWidth,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
          );
        }),
      ),
    );
  }
}
