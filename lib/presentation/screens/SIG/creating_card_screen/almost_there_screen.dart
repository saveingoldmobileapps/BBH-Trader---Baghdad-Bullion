import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/SIG/creating_card_screen/setup_pin.dart';

class AlmostThereScreen extends ConsumerStatefulWidget {
  const AlmostThereScreen({super.key});

  @override
  ConsumerState createState() => _AlmostThereScreenState();
}

class _AlmostThereScreenState extends ConsumerState<AlmostThereScreen> {
  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    return Scaffold(
        body: Container(
            height: sizes!.height,
            width: sizes!.width,
            color: AppColors.greyScale1000,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstPadding.sizeBoxWithHeight(height: 100),
                    _buildCurvedCard(),
                    ConstPadding.sizeBoxWithHeight(height: 40),
                    _buildTextSection(),
                    Spacer(),
                    _buildBottomButtons(),
                    ConstPadding.sizeBoxWithHeight(height: 20),
                  ],
                ),
              ),
            )));
  }

  Widget _buildCurvedCard() {
    return Center(
      child: Transform.rotate(
        angle: 0.2,
        child: Container(
          width: sizes!.isPhone
              ? sizes!.widthRatio * 310
              : sizes!.widthRatio * 800,
          height: sizes!.isPhone
              ? sizes!.heightRatio * 200
              : sizes!.heightRatio * 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                AppColors.goldColor,
                AppColors.goldLightColor,
                AppColors.goldMoreLightColor
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available balance",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.greyScale1000,
                    fontSize: sizes!.isPhone
                        ? sizes!.fontRatio * 15
                        : sizes!.fontRatio * 18,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w400,
                    height: 0.9,
                  ),
                ),
                Text(
                  "1000.00",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.greyScale1000,
                    fontSize: sizes!.isPhone
                        ? sizes!.fontRatio * 25
                        : sizes!.fontRatio * 30,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 0.9,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "1234  5678  9012  3456",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.greyScale1000,
                        fontSize: sizes!.isPhone
                            ? sizes!.fontRatio * 16
                            : sizes!.fontRatio * 26,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.w300,
                        height: 0.9,
                      ),
                    ),
                    ConstPadding.sizeBoxWithWidth(width: 15),
                    Icon(
                      Icons.copy,
                      size: 15,
                      color: AppColors.greyScale1000,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expiry",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.greyScale1000,
                            fontSize: sizes!.isPhone
                                ? sizes!.fontRatio * 12
                                : sizes!.fontRatio * 16,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 5),
                        Text(
                          "XX/XX",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.greyScale1000,
                            fontSize: sizes!.isPhone
                                ? sizes!.fontRatio * 12
                                : sizes!.fontRatio * 16,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            fontWeight: FontWeight.w600,
                            height: 0.9,
                          ),
                        ),
                      ],
                    ),
                    ConstPadding.sizeBoxWithWidth(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CVV",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.greyScale1000,
                            fontSize: sizes!.isPhone
                                ? sizes!.fontRatio * 12
                                : sizes!.fontRatio * 16,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 5),
                        Text(
                          "XXX",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.greyScale1000,
                            fontSize: sizes!.isPhone
                                ? sizes!.fontRatio * 12
                                : sizes!.fontRatio * 16,
                            fontFamily: GoogleFonts.roboto().fontFamily,
                            fontWeight: FontWeight.w600,
                            height: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amro Jabbar",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.greyScale1000,
                        fontSize: sizes!.isPhone
                            ? sizes!.fontRatio * 16
                            : sizes!.fontRatio * 26,
                        fontFamily: GoogleFonts.roboto().fontFamily,
                        fontWeight: FontWeight.w500,
                        height: 0.9,
                      ),
                    ),
                    GetGenericText(
                      text: "VISA",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyScale1000,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Almost there!",
          style: GoogleFonts.roboto(
            fontSize: sizes!.fontRatio * 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ConstPadding.sizeBoxWithHeight(height: 10),
        Text(
          "Let’s just set a pin code for your card for security purposes.",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: sizes!.fontRatio * 14,
            fontWeight: FontWeight.w400,
            color: AppColors.grey6Color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SetPinScreen(),
              ),
            );
          },
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
                text: "Get Started",
                fontSize: sizes!.isPhone ? 18 : 22,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
        ConstPadding.sizeBoxWithHeight(height: 10),
        InkWell(
          onTap: () {},
          child: GetGenericText(
            text: "I’ll do it later",
            fontSize: sizes!.isPhone ? 15 : 18,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGold500,
          ),
        ),
      ],
    );
  }
}
