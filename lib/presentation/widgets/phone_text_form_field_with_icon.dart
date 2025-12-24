import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/const_padding.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';

class PhoneTextFormFieldWithIcon extends StatelessWidget {
  final String title;
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final String? flagEmoji;
  final bool readOnly;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PhoneTextFormFieldWithIcon({
    super.key,
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.flagEmoji,
    required this.readOnly,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetGenericText(
          text: labelText,
          fontSize: sizes!.responsiveFont(
            phoneVal: 14,
            tabletVal: 16,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
        ConstPadding.sizeBoxWithHeight(height: 8),

        /// ✅ FormField wrapper for error display
        FormField<String>(
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: sizes!.responsiveLandscapeHeight(
                    phoneVal: 48,
                    tabletVal: 56,
                    tabletLandscapeVal: 76,
                    isLandscape: sizes!.isLandscape(),
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.greyScale1000,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: AppColors.greyScale800,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Container(
                      //   width: 56,
                      //   alignment: Alignment.center,
                      //   child: flagEmoji != null
                      //       ? Text(
                      //           flagEmoji!,
                      //           style: const TextStyle(
                      //             fontSize: 24,
                      //             height: 1.0,
                      //           ),
                      //         )
                     const SizedBox(width: 10,),
                      // ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          readOnly: readOnly,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done, 
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: sizes!.responsiveFont(
                                phoneVal: 14,
                                tabletVal: 16,
                              ),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            errorStyle: const TextStyle(
                              height: 0,
                            ), // Hide internal error
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (value) {
                            field.didChange(value);
                            onChanged?.call(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 12,
                          tabletVal: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
