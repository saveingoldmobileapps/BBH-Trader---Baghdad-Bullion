import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/widgets/demo_animated_text.dart';

class AccountModeBanner extends StatelessWidget {
  final bool isDemo;
  final VoidCallback? onGoLive;

  const AccountModeBanner({
    Key? key,
    required this.isDemo,
    this.onGoLive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDemo ? AppColors.greyScale1000 : Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDemo ? AppColors.goldLightColor : Colors.green,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDemo ? Icons.info_outline : Icons.verified_user,
            color: isDemo ? AppColors.goldLightColor : Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: 
            DemoModeAnimatedText(
              text: isDemo? AppLocalizations.of(context)!.demo_mode :"You are in Real Mode — trades affect live balance.",
              
              // text: isDemo? "Note: You are in Demo Mode" :"You are in Real Mode — trades affect live balance.",
              fontSize: 15,
              color:AppColors.goldLightColor,
              fontWeight: FontWeight.normal,
            ),
            
            // Text(
            //   isDemo
            //       ? "You are in Demo Mode"
            //       : "You are in Real Mode — trades affect live balance.",
            //   style: TextStyle(
            //     color: isDemo ? AppColors.goldLightColor : Colors.green[800],
            //     fontSize: 15,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ),
          if (isDemo)
            TextButton(
              onPressed: onGoLive,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:  Text(
                AppLocalizations.of(context)!.demo_mode_go_live,//"Go Live",
                style: TextStyle(
                  fontSize: 12,
                  ),
                
              ),
            ),
        ],
      ),
    );
  }
}
