export 'native/bbh_native_onboarding_screen.dart';

import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/native/bbh_native_onboarding_screen.dart';
import 'package:flutter/material.dart';

/// Legacy alias — native onboarding (no WebView).
class HtmlViewScreen extends StatelessWidget {
  const HtmlViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BbhNativeOnboardingScreen();
  }
}
