import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/core/theme/get_generic_text_widget.dart';

class BuildSwitchOption extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BuildSwitchOption({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GetGenericText(
          text: title,
          fontSize: sizes!.isPhone ? 16 : 22,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        Switch.adaptive(
          activeColor: AppColors.primaryGold500,
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.orange.withValues(alpha: .48);
            }
            return Colors.white;
          }),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
