import 'package:baghdad_bullion_house/core/res_sizes/res.dart';
import 'package:baghdad_bullion_house/core/theme/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;
  final VoidCallback onMore;

  const HomeQuickActions({
    super.key,
    required this.onAddFunds,
    required this.onWithdraw,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            context,
            iconPath:
                "assets/svg/money_add.svg", // Replace with your actual path
            label: l10n.add_funds,
            onTap: onAddFunds,
          ),
          _buildActionItem(
            context,
            iconPath:
            "assets/png/iqd_icon.png",
                //"assets/svg/withdraw_icon.svg", // Replace with your actual path
            label: l10n.quick_action_withdraw,
            onTap: onWithdraw,
          ),
          _buildActionItem(
            context,
            iconPath: "assets/svg/more.svg", // Replace with your actual path
            label: l10n.more,
            onTap: onMore,
          ),
        ],
      ),
    );
  }
  Widget _buildActionItem(
  BuildContext context, {
  required String iconPath,
  required String label,
  required VoidCallback onTap,
}) {
  final isSvg = iconPath.toLowerCase().endsWith('.svg');

  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.all(isSvg ? 18 : 10),
          child: isSvg
              ? SvgPicture.asset(
                  iconPath,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
  // Widget _buildActionItem(
  //   BuildContext context, {
  //   required String iconPath,
  //   required String label,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           width: 65,
  //           height: 65,
  //           decoration: BoxDecoration(
  //             color: Colors
  //                 .grey
  //                 .shade900, // Match the dark background of the buttons
  //             borderRadius: BorderRadius.circular(18),
  //           ),
  //           padding: const EdgeInsets.all(18),
  //           child: SvgPicture.asset(
  //             iconPath,
  //             colorFilter: const ColorFilter.mode(
  //               Colors.white, // Match the light gold/cream icon color
  //               BlendMode.srcIn,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 14,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

}
