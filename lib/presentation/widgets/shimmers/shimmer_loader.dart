import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final num loop;

  const ShimmerLoader({
    super.key,
    this.loop = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Color(0xFF333333),
        highlightColor: const Color(0xFFBBA473),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < loop; i++) ...[
              ConstPadding.sizeBoxWithHeight(height: 8),
              Container(
                width: sizes!.isPhone? sizes!.widthRatio * 318:sizes!.width,
                height: sizes!.heightRatio * 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFBBA473),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 8),
              Container(
                width: sizes!.widthRatio * 280,
                height: sizes!.heightRatio * 26,
                decoration: const BoxDecoration(
                  color: Color(0xFFBBA473),
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
              ),
              ConstPadding.sizeBoxWithHeight(height: 8),
              Container(
                width: sizes!.widthRatio * 180,
                height: sizes!.heightRatio * 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFBBA473),
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
              ).getAlign(),
            ],
          ],
        ),
      ),
    );
  }
}
