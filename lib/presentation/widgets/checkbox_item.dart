import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class CheckboxItem extends StatelessWidget {
  final String text;
  final bool isChecked;
  final VoidCallback onTap;

  const CheckboxItem({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              height: sizes!.heightRatio * 16,
              width: sizes!.widthRatio * 16,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primaryGold500 : null,
                borderRadius: BorderRadius.circular(1),
                border: Border.all(
                  color: AppColors.primaryGold500,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: isChecked
                    ? Icon(
                        Icons.check_outlined,
                        color: AppColors.grey6Color,
                        size: 14,
                      )
                    : null,
              ),
            ),
            ConstPadding.sizeBoxWithWidth(width: 4),
            GetGenericText(
              text: text,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey5Color,
            ),
          ],
        ),
      ),
    );
  }
}
