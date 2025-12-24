import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

import '../../core/theme/const_colors.dart';
import '../../core/theme/get_generic_text_widget.dart';

class SearchableWithCheckBox extends StatefulWidget {
  final List<String> items;
  final String title;
  final String hint;
  final String label;
  final String iconString;
  final List<String>? selectedItems;
  final Function(List<String>) onChanged;
  final double gramBalanceEqual; // Add gram balance parameter

  const SearchableWithCheckBox({
    super.key,
    required this.items,
    required this.title,
    required this.hint,
    required this.label,
    required this.iconString,
    required this.onChanged,
    required this.gramBalanceEqual, // Make it required
    this.selectedItems,
  });

  @override
  State<SearchableWithCheckBox> createState() => _SearchableWithCheckBoxState();
}

class _SearchableWithCheckBoxState extends State<SearchableWithCheckBox> {
  late TextEditingController _controller;
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedItems = widget.selectedItems ?? [];
  }

  void _openMultiSelectDialog() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenMultiSelect(
          items: widget.items,
          title: widget.label,
          initiallySelected: _selectedItems,
          gramBalanceEqual: widget.gramBalanceEqual, // Pass the balance
        ),
      ),
    );

    if (selected != null && selected is List<String>) {
      setState(() {
        _selectedItems = selected;
        _controller.text = selected.join(', ');
      });
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openMultiSelectDialog,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            suffixIcon: SvgPicture.asset(
              widget.iconString,
              fit: BoxFit.scaleDown,
            ),
            labelStyle: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontFamily: GoogleFonts.roboto().fontFamily,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondaryColor),
            ),
          ),
          style: TextStyle(color: AppColors.whiteColor),
          readOnly: true,
        ),
      ),
    );
  }
}

class FullScreenMultiSelect extends StatefulWidget {
  final List<String> items;
  final String title;
  final List<String> initiallySelected;
  final double gramBalanceEqual; // Add gram balance parameter

  const FullScreenMultiSelect({
    super.key,
    required this.items,
    required this.title,
    required this.initiallySelected,
    required this.gramBalanceEqual, // Make it required
  });

  @override
  State<FullScreenMultiSelect> createState() => _FullScreenMultiSelectState();
}

class _FullScreenMultiSelectState extends State<FullScreenMultiSelect> {
  late List<String> _filteredItems;
  late List<String> _selectedItems;
  late TextEditingController _searchController;
  double _currentTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedItems = List.from(widget.initiallySelected);
    _searchController = TextEditingController();
    _currentTotal = _calculateTotal(_selectedItems);
  }

  double _calculateTotal(List<String> selectedItems) {
    return selectedItems.fold(0.0, (sum, item) {
      final gramMatch = RegExp(r'(\d+(\.\d+)?)g').firstMatch(item);
      if (gramMatch != null) {
        return sum + double.parse(gramMatch.group(1)!);
      }
      return sum;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSelection(String item) {
    final gramMatch = RegExp(r'(\d+(\.\d+)?)g').firstMatch(item);
    if (gramMatch == null) return;

    final itemGrams = double.parse(gramMatch.group(1)!);
    final wouldBeSelected = !_selectedItems.contains(item);

    // Calculate what the new total would be if we add this item
    final potentialTotal = wouldBeSelected
        ? _currentTotal + itemGrams
        : _currentTotal - itemGrams;

    // Check if we already have the target amount or more
    if (wouldBeSelected &&
        (_currentTotal == widget.gramBalanceEqual ||
            _currentTotal >= widget.gramBalanceEqual)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.you_already_have} ${_currentTotal.toStringAsFixed(2)}${AppLocalizations.of(context)!.which_meet_or_exceed} ${widget.gramBalanceEqual.toStringAsFixed(2)}${AppLocalizations.of(context)!.metal_g}',

            // 'You already have ${_currentTotal.toStringAsFixed(2)}g, which meets or exceeds your target of ${widget.gramBalanceEqual.toStringAsFixed(2)}g',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Block selection
    }

    // Allow selection/deselection
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
        _currentTotal -= itemGrams;
      } else {
        _selectedItems.add(item);
        _currentTotal += itemGrams;
      }
    });
  }

  void _submitSelection() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGold500,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold500,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.greyScale900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: AppColors.greyScale900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitSelection,
            child: Text(
              AppLocalizations.of(context)!.doneBtn,
              style: TextStyle(
                color: AppColors.greyScale900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                onChanged: _filterItems,
                controller: _searchController,
                cursorColor: AppColors.secondaryColor,
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.gift_search, //"Search",
                  labelStyle: TextStyle(
                    color: AppColors.greyScale900,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.greyScale900,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.greyScale900,
                    ),
                  ),
                  hintText: AppLocalizations.of(
                    context,
                  )!.gift_search_here, //"Search here",
                  hintStyle: TextStyle(
                    color: AppColors.greyScale900,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.greyScale900,
                  ),
                ),
              ),
            ),
            // Display current and target grams
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.selected}: ${_currentTotal.toStringAsFixed(2)}${AppLocalizations.of(context)!.metal_g}',
                    style: TextStyle(
                      color: AppColors.greyScale900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.target} ${widget.gramBalanceEqual.toStringAsFixed(2)}${AppLocalizations.of(context)!.metal_g}',
                    style: TextStyle(
                      color: AppColors.greyScale900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: LinearProgressIndicator(
                value: _currentTotal / widget.gramBalanceEqual,
                backgroundColor: AppColors.greyScale700,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (_currentTotal - widget.gramBalanceEqual).abs() < 0.001
                      ? AppColors.greyScale900
                      //AppColors.greenColor // Exact match
                      : _currentTotal > widget.gramBalanceEqual
                      ? AppColors
                            .greyScale900 // Over target
                      : AppColors.greyScale900, // Under target
                ),
                minHeight: 6,
              ),
            ),
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return CheckboxListTile(
                          title: GetGenericText(
                            text: item,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.greyScale900,
                          ),
                          value: _selectedItems.contains(item),
                          onChanged: (_) => _toggleSelection(item),
                          activeColor: AppColors.greyScale900,
                          checkColor: AppColors.whiteColor,
                          controlAffinity:
                              Directionality.of(context) == TextDirection.rtl
                              ? ListTileControlAffinity
                                    .leading // checkbox on the right for RTL
                              : ListTileControlAffinity.trailing,
                        );
                      },
                    )
                  : Center(
                      child: GetGenericText(
                        text: AppLocalizations.of(
                          context,
                        )!.gift_no_item, //"No items found",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyScale900,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
