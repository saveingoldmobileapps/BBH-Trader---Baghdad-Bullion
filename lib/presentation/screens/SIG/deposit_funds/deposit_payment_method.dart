import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/SIG/deposit_funds/sig_payment_method_ui.dart';

class SigSelectPaymentMethod extends ConsumerStatefulWidget {
  const SigSelectPaymentMethod({super.key});

  @override
  ConsumerState createState() => _SigHomePageState();
}

class _SigHomePageState extends ConsumerState<SigSelectPaymentMethod> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    //final languageState = ref.watch(languageProvider);
    //final languageNotifier = ref.read(languageProvider.notifier);
    // Determine the direction of the arrow based on the current locale
    //bool isRtl = languageNotifier.isRtl();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "SIG Card",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.00, 0.01),
              end: Alignment(-1, -0.01),
              colors: [
                Color(0xFF463D28),
                Color(0xFF2F2C25),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Makes gradient visible
        elevation: 0, // Removes shadow
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/png/bg_start.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GetGenericText(
                text: "How would you like to deposit funds into your card?",
                fontSize: sizes!.isPhone ? 20 : 22,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ).getAlign(),
              ConstPadding.sizeBoxWithHeight(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SigPaymentMethod(),
                        ),
                      );
                    },
                    child: Container(
                      width: sizes!.isPhone
                          ? sizes!.widthRatio * 160
                          : sizes!.width / 2.1,
                      height: sizes!.isPhone
                          ? sizes!.heightRatio * 160
                          : sizes!.heightRatio * 280,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF232323),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Ensure center alignment
                        children: [
                          // Icon
                          SvgPicture.asset(
                            "assets/svg/gold_balance.svg",
                            height: sizes!.isPhone ? 40 : 60,
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 12),
                          GetGenericText(
                            text: "Bank Transfer",
                            fontSize: sizes!.isPhone
                                ? 18
                                : 22, // Slightly larger for better readability
                            fontWeight: FontWeight.w500, // Medium weight
                            color: AppColors.whiteColor,
                            textAlign: TextAlign.center,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          GetGenericText(
                            text: "Transfer funds from your bank account.",
                            fontSize: sizes!.isPhone ? 12 : 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteColor.withValues(alpha: 0.8),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SigPaymentMethod(),
                        ),
                      );
                    },
                    child: Container(
                      width: sizes!.isPhone
                          ? sizes!.widthRatio * 160
                          : sizes!.width / 2.1,
                      height: sizes!.isPhone
                          ? sizes!.heightRatio * 160
                          : sizes!.heightRatio * 280,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF232323),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Ensure center alignment
                        children: [
                          // Icon
                          SvgPicture.asset(
                            "assets/svg/gram_balance.svg",
                            height: sizes!.isPhone ? 40 : 60,
                          ),

                          ConstPadding.sizeBoxWithHeight(height: 12),
                          GetGenericText(
                            text: "Gram Balance",
                            fontSize: sizes!.isPhone
                                ? 18
                                : 22, // Slightly larger for better readability
                            fontWeight: FontWeight.w500, // Medium weight
                            color: AppColors.whiteColor,
                            textAlign: TextAlign.center,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          GetGenericText(
                            text: "Deposit funds using your gram balance.",
                            fontSize: sizes!.isPhone ? 12 : 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteColor.withValues(alpha: 0.8),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
