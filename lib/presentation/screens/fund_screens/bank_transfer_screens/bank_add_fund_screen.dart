import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_arrow_button.dart';

import '../../../../core/core_export.dart';
import '../success_placeholder_screen.dart';

class BankAddFundScreen extends ConsumerStatefulWidget {
  const BankAddFundScreen({super.key});

  @override
  ConsumerState createState() => _BankAddFundScreenState();
}

class _BankAddFundScreenState extends ConsumerState<BankAddFundScreen> {
  final TextEditingController _controller = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat("#,##0.00", "en_US");
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");

  final _formKey = GlobalKey<FormState>();

  String formatted = "0.00";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    String raw = _controller.text.replaceAll(",", "");
    if (raw.isEmpty) {
      setState(() => formatted = "0.00");
      return;
    }

    double? value = double.tryParse(raw);
    if (value != null) {
      if (value > 99999.99) {
        value = 99999.99;
      }
      setState(() {
        formatted = _currencyFormat.format(value);
      });
    } else {
      setState(() {
        formatted = "0.00";
      });
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GetGenericText(
                  text: "Payment Details",
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 28,
                    tabletVal: 30,
                  ),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey6Color,
                ).getAlign(),
                GetGenericText(
                  text: "Enter the amount below to transfer",
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 16,
                    tabletVal: 18,
                  ),
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey3Color,
                ).getAlign(),
                ConstPadding.sizeBoxWithHeight(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GetGenericText(
                      text: "AED",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    ConstPadding.sizeBoxWithWidth(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(signed: true,
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done, 
                        cursorColor: Colors.white30,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontSize: sizes!.fontRatio * 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(
                            color: Colors.white30,
                            fontSize: sizes!.fontRatio * 56,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,9}(\.\d{0,2})?$'),
                          ),
                        ],
                        onChanged: (value) {
                          // _formatInput();
                        },
                      ),
                    ),
                  ],
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                const Spacer(),
                LoaderArrowButton(
                  title: "Continue",
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessPlaceholderScreen(
                            amount: _controller.text.toString().trim(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Spacer(),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
