import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';

class DotBullet extends StatelessWidget {
  const DotBullet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes!.responsiveFont(
        phoneVal: 12,
        tabletVal: sizes!.isLandscape() ? 18 : 16,
      ),
      height: sizes!.responsiveHeight(
        phoneVal: 12,
        tabletVal: sizes!.isLandscape() ? 18 : 16,
      ),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(1.00, 0.01),
          end: Alignment(-1, -0.01),
          colors: [
            Color(0xFF675A3D),
            Color(0xFFBBA473),
          ],
        ),
        shape: CircleBorder(),
      ),
    );
  }
}
