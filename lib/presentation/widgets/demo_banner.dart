import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class AccountModeBanner extends StatelessWidget {
  final bool isDemo;
  final VoidCallback? onGoLive;

  const AccountModeBanner({
    super.key,
    required this.isDemo,
    this.onGoLive,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDemo) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.goldLightColor,
          width: 1.2,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1C1C1C),
            Color(0xFF2A2A2A),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Info icon in circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldLightColor,
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

          // Text
          Expanded(
            child: Text(
              // AppLocalizations.of(context)!.demo_mode_note,
              "Note: You are in Demo mode",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Go Live button
          TextButton(
            onPressed: onGoLive,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.goldLightColor,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.goldLightColor,
                  width: 1.2,
                ),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.demo_mode_go_live,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
