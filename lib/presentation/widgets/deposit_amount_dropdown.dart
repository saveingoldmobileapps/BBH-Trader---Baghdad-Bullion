import 'package:flutter/material.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';

class CommonDropdownFormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final List<String> items;
  /// Optional map from [items] value to user-visible label (e.g. localized text).
  /// Dropdown [value] and [onChanged] still use the canonical [items] strings.
  final Map<String, String>? itemDisplayLabels;
  Color? hineClr;
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  CommonDropdownFormField({
    super.key,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.itemDisplayLabels,
    this.hineClr,
    this.hintText,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        floatingLabelAlignment: FloatingLabelAlignment.start,
        alignLabelWithHint: !isRtl,
        labelText: labelText,
        hint: Text(
          hintText ?? '', // Default hint if hintText is null
          style: AppFonts.text(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: hineClr ?? AppColors.whiteColor.withOpacity(0.7),
          ),
        ),
        labelStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.english,
        ),
        hintStyle: AppFonts.text(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: hineClr ?? AppColors.whiteColor.withOpacity(0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.whiteColor),
      dropdownColor: AppColors.primaryGold500,
      style: AppFonts.text(
        fontSize: 16,
        color: AppColors.whiteColor,
        fontWeight: FontWeight.w400,
      ),
      validator: validator,
      items: items.map((String itemValue) {
        final displayText =
            itemDisplayLabels?[itemValue] ?? itemValue;
        return DropdownMenuItem<String>(
          value: itemValue,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              displayText,
              style: AppFonts.text(
                color: AppColors.whiteColor,
                // overflow: TextOverflow.visible,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
