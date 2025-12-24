import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/screens/SIG/creating_card_screen/almost_there_screen.dart';

import '../../../widgets/text_form_field.dart';

class PhysicalCardScreen extends ConsumerStatefulWidget {
  const PhysicalCardScreen({super.key});

  @override
  ConsumerState createState() => _PhysicalCardScreenState();
}

class _PhysicalCardScreenState extends ConsumerState<PhysicalCardScreen> {
  final TextEditingController _addressController = TextEditingController();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstPadding.sizeBoxWithHeight(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                GetGenericText(
                  text: "Physical Card",
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey6Color,
                ),
                ConstPadding.sizeBoxWithHeight(height: 10),
                GetGenericText(
                  text:
                      "Enter the information below to order your physical card.",
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppColors.grey6Color,
                ),
                ConstPadding.sizeBoxWithHeight(height: 20),
                _buildAddressField(),
                Spacer(),
                _buildContinueButton(),
                ConstPadding.sizeBoxWithHeight(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return CommonTextFormField(
      title: "Enter Full Address Here",
      hintText: "1 Street 8A Za'abeel 2 Dubai DU ARE",
      labelText: "Enter Full Address Here",
      controller: _addressController,
      textInputType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter Address';
        }

        return null;
      },
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AlmostThereScreen(),
          ),
        );
      },
      child: Container(
        width: sizes!.width,
        height:
            sizes!.isPhone ? sizes!.heightRatio * 50 : sizes!.heightRatio * 64,
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
            text: "Continue",
            fontSize: sizes!.isPhone ? 18 : 22,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
    // GestureDetector(
    //   onTap: () {},
    //   child: Container(
    //     width: sizes!.width,
    //     height: sizes!.heightRatio * 50,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       gradient: LinearGradient(
    //         begin: Alignment(1.00, 0.01),
    //         end: Alignment(-1, -0.01),
    //         colors: [
    //           AppColors.goldColor,
    //           AppColors.goldLightColor,
    //         ],
    //       ),
    //     ),
    //     child: Center(
    //       child: GetGenericText(
    //         text: "Continue",
    //         fontSize: 16,
    //         fontWeight: FontWeight.w500,
    //         color: AppColors.whiteColor,
    //       ),
    //     ),
    //   ),
    // );
  }
}
