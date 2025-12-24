import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class GramFilterItem extends StatelessWidget {
  final String text;
  final bool isChecked;
  final VoidCallback onTap;

  const GramFilterItem({
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
              height: sizes!.heightRatio * 20,
              width: sizes!.widthRatio * 20,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.greyScale900 : null,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.greyScale900,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: isChecked
                    ? Icon(
                        Icons.check_outlined,
                        color: AppColors.grey6Color,
                        size: 18,
                      )
                    : null,
              ),
            ),
            ConstPadding.sizeBoxWithWidth(width: 4),
            GetGenericText(
              text: text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.greyScale900,
            ),
          ],
        ),
      ),
    );
  }
}
