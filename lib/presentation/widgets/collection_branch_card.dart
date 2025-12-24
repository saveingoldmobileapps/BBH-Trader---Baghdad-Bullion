import 'package:flutter/cupertino.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class CollectionBranchCard extends StatelessWidget {
  final String branchName;
  final String fullBranchAddress;
  final num initialSelectedIndex;
  final num changedIndex;
  final VoidCallback onTap;

  const CollectionBranchCard({
    super.key,
    required this.branchName,
    required this.fullBranchAddress,
    required this.initialSelectedIndex,
    required this.changedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.greyScale900,
          borderRadius: BorderRadius.circular(10),
          border: initialSelectedIndex == changedIndex
              ? Border.all(
                  color: AppColors.primaryGold500,
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetGenericText(
                  text: "Collect at:",
                  fontSize: sizes!.isPhone ? 16 : 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey3Color,
                ),
                GetGenericText(
                  text: branchName,
                  fontSize: sizes!.isPhone ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey5Color,
                ),
              ],
            ),
            ConstPadding.sizeBoxWithHeight(height: 6),
            GetGenericText(
              text: fullBranchAddress,
              fontSize: sizes!.isPhone ? 14 : 18,
              fontWeight: FontWeight.w400,
              color: AppColors.grey3Color,
            ),
          ],
        ),
      ),
    );
  }
}
