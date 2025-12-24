import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class TextFormFieldWithIcon extends StatelessWidget {
  final String title;
  final String hintText;
  final String labelText;
  final String iconString;
  final TextEditingController controller;
  final String? Function(String? value)? validator;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool readOnly;
  final VoidCallback onTap;
  final ValueChanged<String>? onChanged;

  const TextFormFieldWithIcon({
    super.key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.iconString,
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.inputFormatters = const [],
    this.validator,
    this.onChanged,
    this.textColor,
    required this.onTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextFormField(
        onTap: onTap,
        onChanged: onChanged,
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        cursorColor: AppColors.secondaryColor,
        keyboardType: textInputType,
        textInputAction: TextInputAction.done, 
        readOnly: readOnly,
        style:
            textStyle ??
            TextStyle(
              color: textColor ?? AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: GoogleFonts.roboto().fontFamily,
            ),

        // TextStyle(
        //   color: textColor ?? AppColors.whiteColor,
        //   fontSize: 16,
        //   fontWeight: FontWeight.w400,
        //   fontFamily: GoogleFonts.roboto().fontFamily,
        // ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.secondaryColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
          hintStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryColor,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              color: Colors.transparent,
              child: SizedBox(
                child: SvgPicture.asset(
                  iconString,
                  height: sizes!.heightRatio * 18,
                  width: sizes!.widthRatio * 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
