import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/direct_transfer/select_bank.dart';

import '../../widgets/loader_arrow_button.dart';

class DirectTransferGetStarted extends ConsumerStatefulWidget {
  const DirectTransferGetStarted({
    super.key,
  });

  @override
  ConsumerState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<DirectTransferGetStarted> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstPadding.sizeBoxWithHeight(height: 50),
            Center(
              child: SvgPicture.asset(
                "assets/svg/direct_get_started.svg",
              ),
            ),
            ConstPadding.sizeBoxWithHeight(height: 50),
            GetGenericText(
              text: AppLocalizations.of(context)!.dep_method_direct,//"Direct Transfer",
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.grey6Color,
            ),
            ConstPadding.sizeBoxWithHeight(height: 5),
            GetGenericText(
              text:
                  AppLocalizations.of(context)!.dep_dt_intro_desc,//"A direct transfer works just like sending money through your banking app. The transaction typically takes 24 to 48 hours to be confirmed.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.grey3Color,
              lines: 6,
            ),
            ConstPadding.sizeBoxWithHeight(height: 40),
            LoaderArrowButton(
              title: AppLocalizations.of(context)!.getStarted,//"Get Started",
              isLoadingState: false,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectBankForDirectTransfer(),
                  ),
                );
              },
            ),
          ],
        ).get16HorizontalPadding(),
      ),
    );
  }
}
