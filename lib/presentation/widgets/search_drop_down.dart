import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field_with_icon.dart';

import '../../core/theme/const_colors.dart';
import '../../core/theme/get_generic_text_widget.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String title;
  final String hint;
  final String label;
  final String iconString;
  final String? selectedItem;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Key? fieldKey;
  final TextStyle? textStyle;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.title,
    required this.hint,
    required this.label,
    required this.iconString,
    required this.onChanged,
    this.selectedItem,
    this.textStyle,
    this.validator,
    this.fieldKey,
  });

  @override
  SearchableDropdownState createState() => SearchableDropdownState();
}

class SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _controller;
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedItem);
    _selectedItem = widget.selectedItem;
  }

  void _openFullScreenDialog() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenDropdown(
          items: widget.items,
          title: widget.label,
          initialValue: _selectedItem,
        ),
      ),
    );

    if (selected != null && selected is String) {
      setState(() {
        _selectedItem = selected;
        _controller.text = selected;
      });
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormFieldWithIcon(
      title: widget.label,
      hintText: widget.hint,
      textColor: AppColors.whiteColor,
      validator: (value) => widget.validator?.call(_selectedItem),
      labelText: widget.label,
      iconString: widget.iconString,
      controller: _controller,
      textStyle: widget.textStyle,
      readOnly: true,
      onTap: _openFullScreenDialog,
      
    );
  }
}

class FullScreenDropdown extends StatefulWidget {
  final List<String> items;
  final String title;
  final String? initialValue;

  const FullScreenDropdown({
    super.key,
    required this.items,
    required this.title,
    this.initialValue,
  });

  @override
  FullScreenDropdownState createState() => FullScreenDropdownState();
}

class FullScreenDropdownState extends State<FullScreenDropdown> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _selectedItem = widget.initialValue;
  }

  /// filter items
  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectItem(String item) {
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: AppColors.primaryGold500,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                          "assets/svg/close_icon.svg",
                          height: sizes!.responsiveHeight(
                            phoneVal: 20,
                            tabletVal: 24,
                          ),
                          width: sizes!.responsiveWidth(
                            phoneVal: 20,
                            tabletVal: 24,
                          ),
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left:16.0,right: 16.0, bottom: 16,),
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
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.greyScale1000,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                  labelText: AppLocalizations.of(context)!.gift_search_here,//"Search",
                  hintText: AppLocalizations.of(context)!.gift_search_here,//"Search here",
                  labelStyle: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                  ),
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: GetGenericText(
                            text: _filteredItems[index],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey6Color,
                          ),
                          onTap: () => _selectItem(_filteredItems[index]),
                        );
                      },
                    )
                  : Center(
                      child: GetGenericText(
                        text: "No item found",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey6Color,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
