import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart' show genericPopUpWidget;

class UpgradeAccountPopup {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    await genericPopUpWidget(
      isLoadingState: false,
      context: context,
      heading: AppLocalizations.of(context)!.upgrade_to_real_account,//"Upgrade to Real Account",
      subtitle: AppLocalizations.of(context)!.upgrade_real_account_msg,
          // "This feature requires a verified real account. "
          // "Please convert your demo account to a real account to access all features.",
      noButtonTitle: AppLocalizations.of(context)!.upgrade_real_account_later,//"Not Now",
      yesButtonTitle: AppLocalizations.of(context)!.upgrade_real_account_now,//"Upgrade Now",
      onNoPress: () async {
        Navigator.pop(context);
        // if (!context.mounted) return;
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const SettingScreen(),
        //   ),
        // );
        // Navigator.pop(context);
      },
      onYesPress: () async {
        Navigator.pop(context);
        if (!context.mounted) return;
        // All verifications passed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingScreen(),
          ),
        );
      },
    );
  }
}
