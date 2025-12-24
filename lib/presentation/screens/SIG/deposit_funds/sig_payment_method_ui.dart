import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';

import '../../../widgets/widget_export.dart';
import '../creating_card_screen/creating_card_screen.dart';

class SigPaymentMethod extends ConsumerStatefulWidget {
  const SigPaymentMethod({super.key});

  @override
  ConsumerState createState() => _SigPaymentMethodState();
}

class _SigPaymentMethodState extends ConsumerState<SigPaymentMethod> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final amountController = TextEditingController();
  bool isChecked = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    //final languageNotifier = ref.read(languageProvider.notifier);
    //bool isRtl = languageNotifier.isRtl();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Deposit Funds",
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey7Color),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Gold Balance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "10.00",
                                style: TextStyle(
                                  fontSize: sizes!.isPhone ? 24 : 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Total Gold (Gram)",
                                style: TextStyle(
                                  fontSize: sizes!.isPhone ? 12 : 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "42000",
                                style: TextStyle(
                                  fontSize: sizes!.isPhone ? 24 : 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Total Fund (AED)",
                                style: TextStyle(
                                  fontSize: sizes!.isPhone ? 12 : 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                CommonTextFormField(
                  title: "",
                  hintText: "123",
                  obscureText: false,
                  labelText: "Enter the Amount to Deposit",
                  controller: amountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    } else if (!value.validatePassword()) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  suffixText: "AED",
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      "assets/svg/ae_text_flag.svg",
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isChecked
                              ? AppColors.primaryGold500
                              : Colors.transparent,
                          border: Border.all(
                            color: isChecked
                                ? AppColors.primaryGold500
                                : AppColors.grey5Color,
                            width: 1.5,
                          ),
                        ),
                        child: isChecked
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 8),
                    GetGenericText(
                      text: "Deposit All my funds into SIG Card",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey5Color,
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatingCardScreen(),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      width: sizes!.width,
                      height: sizes!.isPhone
                          ? sizes!.heightRatio * 50
                          : sizes!.heightRatio * 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment(1.00, 0.01),
                          end: Alignment(-1, -0.01),
                          colors: [
                            Color(0xFFBBA473),
                            Color(0xFF675A3D),
                          ],
                        ),
                      ),
                      child: Center(
                        child: GetGenericText(
                          text: "Create Card Now!",
                          fontSize: sizes!.isPhone ? 16 : 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
