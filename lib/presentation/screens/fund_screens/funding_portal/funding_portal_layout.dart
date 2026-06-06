import 'package:flutter/material.dart';

import 'funding_portal_theme.dart';

/// Prototype `.app` padding: 14px 22px 24px 22px on cream background + [SafeArea].
class FundingPortalScreenShell extends StatelessWidget {
  const FundingPortalScreenShell({
    super.key,
    required this.body,
    this.bottom,
  });

  final Widget body;
  final Widget? bottom;

  static const horizontal = 22.0;
  static const top = 14.0;
  static const bottomPad = 24.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FundingPortalColors.cream,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: top),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: body,
                ),
              ),
              if (bottom != null) ...[
                bottom!,
                const SizedBox(height: bottomPad),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-height centered screen (loading / some success states).
class FundingPortalCenteredShell extends StatelessWidget {
  const FundingPortalCenteredShell({
    super.key,
    required this.child,
    this.bottom,
  });

  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FundingPortalColors.cream,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FundingPortalScreenShell.horizontal,
          ),
          child: Column(
            children: [
              const SizedBox(height: FundingPortalScreenShell.top),
              Expanded(child: Center(child: child)),
              if (bottom != null) ...[
                bottom!,
                const SizedBox(height: FundingPortalScreenShell.bottomPad),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FundingPortalBtnStack extends StatelessWidget {
  const FundingPortalBtnStack({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}
