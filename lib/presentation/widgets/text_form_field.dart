import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';

class CommonTextFormField extends StatefulWidget {
  final String title;
  final String hintText;
  final String? suffixText;
  final String labelText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool isCapitalizationEnabled;
  final bool disableCopyPaste; // new optional param

  const CommonTextFormField({
    super.key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.focusNode,
    this.suffixText,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.textInputType,
    this.inputFormatters = const [],
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.isCapitalizationEnabled = true,
    this.disableCopyPaste = false, // default false
  });

  @override
  CommonTextFormFieldState createState() => CommonTextFormFieldState();
}

class CommonTextFormFieldState extends State<CommonTextFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Center(
      child: TextFormField(
        textCapitalization: widget.isCapitalizationEnabled
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        focusNode: widget.focusNode,
        controller: widget.controller,
        validator: widget.validator,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        inputFormatters: widget.inputFormatters,
        cursorColor: AppColors.secondaryColor,
        keyboardType: widget.textInputType ?? TextInputType.text,
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText ? _obscureText : false,
        enableInteractiveSelection: !widget.disableCopyPaste, // disable copy/paste if true
        toolbarOptions: widget.disableCopyPaste
            ? const ToolbarOptions(copy: false, cut: false, paste: false, selectAll: false)
            : const ToolbarOptions(copy: true, cut: true, paste: true, selectAll: true),
        style: TextStyle(
          color: AppColors.secondaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.roboto().fontFamily,
        ),
        decoration: InputDecoration(
          floatingLabelAlignment: FloatingLabelAlignment.start,
          alignLabelWithHint: !isRtl,
          errorMaxLines: 3,
          helperMaxLines: 2,
          border: _border(AppColors.secondaryColor),
          enabledBorder: _border(AppColors.secondaryColor),
          focusedBorder: _border(AppColors.secondaryColor),
          errorBorder: _border(Colors.redAccent),
          labelText: widget.labelText,
          hintText: widget.hintText,
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
          suffixText: widget.suffixText ?? "",
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.secondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.suffixIcon,
        ),
      ),
    );
  }
}