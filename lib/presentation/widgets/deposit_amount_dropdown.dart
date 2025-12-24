import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class CommonDropdownFormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final List<String> items;
  Color? hineClr;
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  CommonDropdownFormField({
    super.key,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.hineClr,
    this.hintText,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        hint: Text(
          hintText ?? '', // Default hint if hintText is null
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: hineClr ?? AppColors.whiteColor.withOpacity(0.7),
          ),
        ),
        labelStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.roboto().fontFamily,
        ),
        hintStyle: GoogleFonts.roboto(
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
      style: GoogleFonts.roboto(
        fontSize: 16,
        color: AppColors.whiteColor,
        fontWeight: FontWeight.w400,
      ),
      validator: validator,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: GoogleFonts.roboto(
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
