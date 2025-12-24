import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field.dart';

class BankCardDetailScreen extends ConsumerStatefulWidget {
  const BankCardDetailScreen({super.key});

  @override
  ConsumerState createState() => _BankCardDetailScreenState();
}

class _BankCardDetailScreenState extends ConsumerState<BankCardDetailScreen> {
  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final cvvController = TextEditingController();
  final expiryDateController = TextEditingController();

  bool isCardSaved = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    cardNameController.dispose();
    cardNumberController.dispose();
    cvvController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Card Details",
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
          child: Column(
            children: [
              ConstPadding.sizeBoxWithHeight(height: 12),
              CommonTextFormField(
                title: "title",
                hintText: "Amro Jabbar",
                labelText: "Name on Card",
                controller: cardNameController,
                textInputType: TextInputType.text,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),
              CommonTextFormField(
                title: "title",
                hintText: "2341 5666 8881 2239",
                labelText: "Card Number",
                controller: cardNameController,
                textInputType: TextInputType.number,
              ),
              ConstPadding.sizeBoxWithHeight(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: sizes!.widthRatio * 160,
                    child: CommonTextFormField(
                      title: "title",
                      hintText: "MM/YY",
                      labelText: "Expiry",
                      controller: cardNameController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: sizes!.widthRatio * 160,
                    child: CommonTextFormField(
                      title: "title",
                      hintText: "***",
                      labelText: "CVV",
                      controller: cvvController,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 8),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: AppColors.primaryGold500,
                    value: isCardSaved,
                    onChanged: (value) {
                      setState(() {
                        isCardSaved = value!;
                      });
                    },
                  ),
                  GetGenericText(
                    text: "Save Details",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ).getAlign(),
              const Spacer(),
              LoaderButton(
                title: "Confirm Payment",
                onTap: () {},
              ),
              ConstPadding.sizeBoxWithHeight(height: 20),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
