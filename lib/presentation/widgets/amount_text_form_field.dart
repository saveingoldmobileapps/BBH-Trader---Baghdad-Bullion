import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/core/decimal_text_input_formatter.dart';

class AmountTextFormField extends StatelessWidget {
  final String title;
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final String? Function(String? value)? validator;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;

  const AmountTextFormField({
    super.key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.inputFormatters = const [],
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Center(
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        inputFormatters: [
          DecimalTextInputFormatter(decimalRange: 3),
          ...(inputFormatters ?? const []),
        ],
        cursorColor: AppColors.secondaryColor,
        keyboardType: textInputType,
        readOnly: readOnly,
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.roboto().fontFamily,
        ),
        decoration: InputDecoration(
          floatingLabelAlignment: FloatingLabelAlignment.start,
          alignLabelWithHint: !isRtl,
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
          suffixStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryColor,
          ),
          suffixText: "IQD",
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              child: SvgPicture.asset(
                "assets/svg/iraq.svg",
                height: sizes!.heightRatio * 18,
                width: sizes!.widthRatio * 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
