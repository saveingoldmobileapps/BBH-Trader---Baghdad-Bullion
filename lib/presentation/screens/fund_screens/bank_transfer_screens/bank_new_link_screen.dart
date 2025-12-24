import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_arrow_button.dart';

import '../../../../core/core_export.dart';

class BankNewLinkScreen extends ConsumerStatefulWidget {
  const BankNewLinkScreen({super.key});

  @override
  ConsumerState createState() => _BankNewLinkScreenState();
}

class _BankNewLinkScreenState extends ConsumerState<BankNewLinkScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: Column(
            children: [
              ConstPadding.sizeBoxWithHeight(height: 24),
              SvgPicture.asset("assets/svg/bank_illustrate.svg"),
              ConstPadding.sizeBoxWithHeight(height: 44),
              GetGenericText(
                text: "Easy Bank Transfer",
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AppColors.grey6Color,
              ).getAlign(),
              ConstPadding.sizeBoxWithHeight(height: 4),
              GetGenericText(
                text:
                    "Connect your bank account to SaveInGold Wallet and enjoy near instant top-ups anytime without leading your app.",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
                lines: 4,
              ).getAlign(),
              ConstPadding.sizeBoxWithHeight(height: 24),
              LoaderArrowButton(
                title: "Connect Your Account",
                onTap: () {
                  Toasts.getWarningToast(text: "Try it later");
                },
              ),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
