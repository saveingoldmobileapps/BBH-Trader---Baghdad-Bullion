import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';

import '../../../core/theme/const_colors.dart';
import '../../../core/theme/get_generic_text_widget.dart';
import '../../../data/models/alert_model/AlertModelResponse.dart';
import '../../../l10n/app_localizations.dart';
import '../../sharedProviders/providers/alert_provider/alert_provider.dart';
import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  final AlertListData? alert;
  const CreateAlertScreen({super.key, this.alert});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String alertTypeLabel = "Buying price";
  String side = "Buy";
  String condition = "Less";
  String selectedScript = "1 Gram Price";
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.alert != null) {
      isEditMode = true;
      final existing = widget.alert!;
      selectedScript = existing.script ?? "1 Gram Price";
      side = existing.alertType ?? "Buy";
      condition = existing.condition!;
      priceController.text = existing.price?.toString() ?? "";
      alertTypeLabel = side == "Buy" ? "Buying price" : "Selling price";
    } else {
      condition = "Less";
    }
  }

  // Restored your original validation logic exactly
  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.please_enter_target_price;
    }

    final enteredPrice = double.tryParse(value);
    if (enteredPrice == null) {
      return AppLocalizations.of(context)!.please_enter_valid_price;
    }

    final goldPriceState = ref.read(goldPriceProvider);
    final currentPrices = goldPriceState.value;

    if (currentPrices == null) {
      return AppLocalizations.of(context)!.unable_to_fetch_current_prices;
    }

    final currentBuyingPrice = currentPrices.oneGramBuyingPriceInIQD;
    final currentSellingPrice = currentPrices.oneGramSellingPriceInIQD;

    if (side == "Buy") {
      if (enteredPrice >= currentBuyingPrice) {
        return "${AppLocalizations.of(context)!.buy_alert_below_current_price} (${currentBuyingPrice.toStringAsFixed(3)})";
      }
    } else {
      if (enteredPrice <= currentSellingPrice) {
        return "${AppLocalizations.of(context)!.sell_alert_above_current_price} (${currentSellingPrice.toStringAsFixed(3)})";
      }
    }
    return null;
  }

  void _updateSide(String? selectedLabel) {
    if (selectedLabel == null) return;
    setState(() {
      alertTypeLabel = selectedLabel;
      side = selectedLabel == "Buying price" ? "Buy" : "Sell";
      condition = side == "Buy" ? "Less" : "More";
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertNotifier = ref.read(alertAllProvider.notifier);
    final alertStateWatch = ref.watch(alertAllProvider);
    final goldPriceState = ref.watch(goldPriceProvider);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        centerTitle: false,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.alert_bar,//"Alerts",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91712F),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleOnSubmit(alertNotifier, alertStateWatch),
            child: alertStateWatch.isCreatingAlert
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditMode ? AppLocalizations.of(context)!.update_alert : AppLocalizations.of(context)!.add_alert,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Market Price Card
              _buildLiveMarketCard(goldPriceState),
              const SizedBox(height: 24),

              // 2. Alert Type Dropdown
              _buildLabel(AppLocalizations.of(context)!.alert_type),
              DropdownButtonFormField<String>(
                // initialValue: 
                value:alertTypeLabel,
                dropdownColor: const Color(0xFF262929),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                items: ["Buying price", "Selling price"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _updateSide,
              ),
              const SizedBox(height: 16),

              // 3. Target Price Field
              _buildLabel(AppLocalizations.of(context)!.target_price),
              TextFormField(
                controller: priceController,
                validator: _validatePrice,
                inputFormatters: [DecimalTextInputFormatter(decimalRange: 3)],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: AppLocalizations.of(context)!.plz_enter_target_price,//"Please enter the target price",
                ),
              ),
              const SizedBox(height: 12),

              // 4. Validation Hint Text (Dynamic)
              goldPriceState.when(
                data: (data) {
                  return Text(
                    side == "Buy"
                        ? "Target buying price must be lower than current buying price"
                        : "Target selling price must be higher than current selling price",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOnSubmit(
    dynamic alertNotifier,
    dynamic alertStateWatch,
  ) async {
    // This triggers the _validatePrice function
    if (_formKey.currentState!.validate()) {
      final enteredPrice = double.tryParse(priceController.text) ?? 0;
      if (isEditMode) {
        await alertNotifier.UpdateAlert(
          id: widget.alert!.id!,
          script: selectedScript,
          alertType: side,
          condition: condition,
          price: enteredPrice,
        );
      } else {
        await alertNotifier.createAlert(
          script: selectedScript,
          alertType: side,
          condition: condition,
          price: enteredPrice,
        );
      }
      Navigator.pop(context, true);
    }
  }

  Widget _buildLiveMarketCard(AsyncValue goldPriceState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262929),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            AppLocalizations.of(context)!.current_market_price,//"Current Market Price",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          goldPriceState.when(
            data: (data) => Column(
              children: [
                // _marketPriceRow("Buying at", data.oneGramBuyingPriceInIQD),
                _marketPriceRow(AppLocalizations.of(context)!.buying_at, data.oneGramBuyingPriceInIQD),
                const SizedBox(height: 16),
                _marketPriceRow(AppLocalizations.of(context)!.selling_at, data.oneGramSellingPriceInIQD),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text(
              "Error loading prices",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketPriceRow(String label, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "${AppLocalizations.of(context)!.idq} ${NumberFormat("#,##0.000").format(price)} ${AppLocalizations.of(context)!.trade_gram}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            "+0.65%",
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
// class CreateAlertScreen extends ConsumerStatefulWidget {
//   final AlertListData? alert;
//   const CreateAlertScreen({super.key, this.alert});

//   @override
//   ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
// }

// class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
//   final TextEditingController priceController = TextEditingController();

//   String alertType = "Price Alert";
//   String side = "Buy"; // Buy or Sell
//   String condition = "Less"; // Less or More
//   String selectedScript = "1 Gram Price";
//   bool isEditMode = false;

//   @override
//   void initState() {
//     super.initState();

//     // Check if we're editing an existing alert
//     if (widget.alert != null) {
//       isEditMode = true;

//       // Prefill data from alert
//       final existing = widget.alert!;
//       selectedScript = existing.script ?? "1 Gram Price";
//       side = existing.alertType ?? "Buy";
//       condition = existing.condition!;
//       priceController.text = existing.price?.toString() ?? "";
//       setState(() {});
//     } else {
//       condition = "Less"; // default for Buy
//     }
//   }

//   void _updateSide(String newSide) {
//     setState(() {
//       side = newSide;
//       condition = newSide == "Buy" ? "Less" : "More";
//     });
//   }

//   String? _validatePrice(String? value) {
//     if (value == null || value.isEmpty) {
//       return AppLocalizations.of(context)!.please_enter_target_price;
//     }

//     final enteredPrice = double.tryParse(value);
//     if (enteredPrice == null) {
//       return AppLocalizations.of(context)!.please_enter_valid_price;
//     }

//     final goldPriceState = ref.read(goldPriceProvider);
//     final currentPrices = goldPriceState.value;

//     if (currentPrices == null) {
//       return AppLocalizations.of(context)!.unable_to_fetch_current_prices;
//     }

//     final currentBuyingPrice = currentPrices.oneGramBuyingPriceInIQD;
//     final currentSellingPrice = currentPrices.oneGramSellingPriceInIQD;

//     if (side == "Buy") {
//       if (enteredPrice >= currentBuyingPrice) {
//         return "${AppLocalizations.of(context)!.buy_alert_below_current_price} (${currentBuyingPrice.toStringAsFixed(2)})";
//       }
//     } else {
//       if (enteredPrice <= currentSellingPrice) {
//         return "${AppLocalizations.of(context)!.sell_alert_above_current_price} (${currentSellingPrice.toStringAsFixed(2)})";
//       }
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final alertNotifier = ref.read(alertAllProvider.notifier);
//     final alertStateWatch = ref.watch(alertAllProvider);
//     final goldPriceState = ref.watch(goldPriceProvider);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: AppColors.greyScale1000,
//         elevation: 0,
//         surfaceTintColor: AppColors.greyScale1000,
//         titleSpacing: 0,
//         title: GetGenericText(
//           text: isEditMode
//               ? AppLocalizations.of(context)!
//                     .add_alert //"Update Alert"
//               : AppLocalizations.of(context)!.add_alert,
//           fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
//           fontWeight: FontWeight.w400,
//           color: Colors.white,
//           isInter: true,
//         ),
//       ),
//       body: Container(
//         height: sizes!.height,
//         width: sizes!.width,
//         decoration: const BoxDecoration(color: AppColors.greyScale1000),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   LivePriceContainer(
//                     title: AppLocalizations.of(context)!.selling_price,
//                     isSelling: true,
//                     todayHighLow: "",
//                   ),
//                   ConstPadding.sizeBoxWithWidth(width: 6),
//                   LivePriceContainer(
//                     title: AppLocalizations.of(context)!.buying_price,
//                     isSelling: false,
//                     todayHighLow: "",
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Live price containers

//                       /// Alert Type
//                       Text(
//                         AppLocalizations.of(context)!.alert_type,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       DropdownButtonFormField<String>(
//                         dropdownColor: AppColors.greyScale1000,
//                         style: const TextStyle(color: Colors.white),
//                         //initialValue: alertType,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintStyle: TextStyle(color: Colors.white70),
//                         ),
//                         items: [
//                           DropdownMenuItem(
//                             value: "Price Alert", // API value
//                             child: Text(
//                               AppLocalizations.of(
//                                 context,
//                               )!.price_alert, // localized text
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                         onChanged: (value) =>
//                             setState(() => alertType = value!),
//                       ),

//                       // DropdownButtonFormField<String>(
//                       //   dropdownColor: AppColors.greyScale1000,
//                       //   style: const TextStyle(color: Colors.white),
//                       //   value: alertType,
//                       //   decoration: const InputDecoration(
//                       //     border: OutlineInputBorder(),
//                       //     hintStyle: TextStyle(color: Colors.white70),
//                       //   ),
//                       //   items: ["Price Alert"].map((value) {
//                       //     return DropdownMenuItem(
//                       //       value: value,
//                       //       child: Text(
//                       //         value,
//                       //         style: const TextStyle(color: Colors.white),
//                       //       ),
//                       //     );
//                       //   }).toList(),
//                       //   onChanged: (value) =>
//                       //       setState(() => alertType = value!),
//                       // ),
//                       const SizedBox(height: 16),

//                       /// Buy / Sell Toggle
//                       Text(
//                         AppLocalizations.of(context)!.side,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: RadioListTile<String>(
//                               activeColor: AppColors.primaryGold500,
//                               title: Text(
//                                 AppLocalizations.of(
//                                   context,
//                                 )!.gram_buy_word, // localized text
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                               value: "Buy", // API value
//                               groupValue: side,
//                               onChanged: (value) => _updateSide(value!),
//                             ),
//                           ),
//                           Expanded(
//                             child: RadioListTile<String>(
//                               activeColor: AppColors.primaryGold500,
//                               title: Text(
//                                 AppLocalizations.of(
//                                   context,
//                                 )!.gram_sell_word, // localized text
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                               value: "Sell", // API value
//                               groupValue: side,
//                               onChanged: (value) => _updateSide(value!),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Row(
//                       //   children: [
//                       //     Expanded(
//                       //       child: RadioListTile<String>(
//                       //         activeColor: AppColors.primaryGold500,
//                       //         title: Text(
//                       //           AppLocalizations.of(context)!.gram_buy_word,
//                       //           style: const TextStyle(color: Colors.white),
//                       //         ),
//                       //         value: "Buy",
//                       //         groupValue: side,
//                       //         onChanged: (value) => _updateSide(value!),
//                       //       ),
//                       //     ),
//                       //     Expanded(
//                       //       child: RadioListTile<String>(
//                       //         activeColor: AppColors.primaryGold500,
//                       //         title: Text(
//                       //           AppLocalizations.of(context)!.gram_sell_word,
//                       //           style: const TextStyle(color: Colors.white),
//                       //         ),
//                       //         value: "Sell",
//                       //         groupValue: side,
//                       //         onChanged: (value) => _updateSide(value!),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       const SizedBox(height: 16),

//                       /// Script Dropdown
//                       Text(
//                         AppLocalizations.of(context)!.select_script,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       DropdownButtonFormField<String>(
//                         dropdownColor: AppColors.greyScale1000,
//                         style: const TextStyle(color: Colors.white),
//                         //initialValue: selectedScript,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintStyle: TextStyle(color: Colors.white70),
//                         ),
//                         items: [
//                           DropdownMenuItem(
//                             value: "1 Gram Price", // API value
//                             child: Text(
//                               AppLocalizations.of(
//                                 context,
//                               )!.one_gram_price, // localized text
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                         onChanged: (value) =>
//                             setState(() => selectedScript = value!),
//                       ),

//                       // DropdownButtonFormField<String>(
//                       //   dropdownColor: AppColors.greyScale1000,
//                       //   style: const TextStyle(color: Colors.white),
//                       //   value: selectedScript,
//                       //   decoration: const InputDecoration(
//                       //     border: OutlineInputBorder(),
//                       //     hintStyle: TextStyle(color: Colors.white70),
//                       //   ),
//                       //   items: ["1 Gram Price"].map((value) {
//                       //     return DropdownMenuItem(
//                       //       value: value,
//                       //       child: Text(
//                       //         value,
//                       //         style: const TextStyle(color: Colors.white),
//                       //       ),
//                       //     );
//                       //   }).toList(),
//                       //   onChanged: (value) =>
//                       //       setState(() => selectedScript = value!),
//                       // ),
//                       const SizedBox(height: 16),

//                       /// Condition Display
//                       Text(
//                         AppLocalizations.of(context)!.condition,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade600),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           condition == "Less"
//                               ? AppLocalizations.of(context)!
//                                     .less // localized “Below”
//                               : AppLocalizations.of(
//                                   context,
//                                 )!.more, // localized “Above”
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       // Container(
//                       //   width: double.infinity,
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 12,
//                       //     vertical: 16,
//                       //   ),
//                       //   decoration: BoxDecoration(
//                       //     border: Border.all(color: Colors.grey.shade600),
//                       //     borderRadius: BorderRadius.circular(4),
//                       //   ),
//                       //   child: Text(
//                       //     condition,
//                       //     style: const TextStyle(
//                       //         color: Colors.white, fontSize: 16),
//                       //   ),
//                       // ),
//                       const SizedBox(height: 16),

//                       /// Price Input
//                       Text(
//                         AppLocalizations.of(context)!.target_price,
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       TextFormField(
//                         controller: priceController,
//                         inputFormatters: [
//                           DecimalTextInputFormatter(decimalRange: 3),
//                         ],
//                         keyboardType: const TextInputType.numberWithOptions(
//                           signed: true,
//                           decimal: true,
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           border: const OutlineInputBorder(),
//                           hintText: AppLocalizations.of(context)!.enter_price,
//                           hintStyle: const TextStyle(color: Colors.white70),
//                           helperText: goldPriceState.when(
//                             data: (data) {
//                               final currentBuying =
//                                   data.oneGramBuyingPriceInIQD;
//                               final currentSelling =
//                                   data.oneGramSellingPriceInIQD;
//                               return side == "Buy"
//                                   ? "${AppLocalizations.of(context)!.must_be_below} ${currentBuying.toStringAsFixed(2)}"
//                                   : "${AppLocalizations.of(context)!.must_be_above} ${currentSelling.toStringAsFixed(2)}";
//                             },
//                             error: (error, stackTrace) =>
//                                 "Unable to fetch current prices",
//                             loading: () => AppLocalizations.of(
//                               context,
//                             )!.loading_current_prices,
//                           ),
//                           helperStyle: TextStyle(
//                             color: AppColors.primaryGold500,
//                             fontSize: 12,
//                           ),
//                         ),
//                         validator: _validatePrice,
//                       ),

//                       const SizedBox(height: 24),

//                       /// Submit Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryGold500,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: () async {
//                             final validationError = _validatePrice(
//                               priceController.text,
//                             );
//                             if (validationError != null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(validationError),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                               return;
//                             }

//                             final enteredPrice =
//                                 double.tryParse(priceController.text) ?? 0;

//                             if (isEditMode) {
//                               await alertNotifier.UpdateAlert(
//                                 id: widget.alert!.id!,
//                                 script: selectedScript,
//                                 alertType: side,
//                                 condition: condition,
//                                 price: enteredPrice,
//                               );
//                             } else {
//                               await alertNotifier.createAlert(
//                                 script: selectedScript,
//                                 alertType: side,
//                                 condition: condition,
//                                 price: enteredPrice,
//                               );
//                             }

//                             Navigator.pop(context, true);
//                           },
//                           child: alertStateWatch.isCreatingAlert
//                               ? const Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : Text(
//                                   isEditMode
//                                       ? AppLocalizations.of(context)!.update
//                                       : AppLocalizations.of(context)!.submit,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 50),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
