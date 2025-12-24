import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/history_model/GetMetalStatementsResponse.dart';


import '../../l10n/app_localizations.dart';

class MetalStatementCard extends StatelessWidget {
  final VoidCallback onTap;
  final MetalHistoryList statement;final bool rtl;

  const MetalStatementCard({
    super.key,
    required this.onTap,
    required this.statement,

    required this.rtl,
  });

  @override
  Widget build(BuildContext context) {
    const kGiftReceived = "Gift Received";
    const kGiftSent = "Gift Sent";
    const kSigWallet = "SIG Wallet";
    const kMetalReleased = "Advance Settlement";
    const kMetalHold = "Advance Payment";

    return GestureDetector(
      onTap: onTap,
      child: switch (statement.paymentModel) {
        kMetalHold => _metalHold(context),
        kMetalReleased => _metalReleased(context),
        kGiftSent => _giftSentCard(context),
        kGiftReceived => _giftSentCard(context),
        kSigWallet => _sigWalletCard(context),
        _ => _tradeCard(context),
      },
    );
  }

  /// Sell or Buy
  Widget _tradeCard(BuildContext context) {
    final isOpened = statement.status == "Opened";

    /// Sell or Buy
    final kSell = "Sell";
    return Container(
      width: sizes!.widthRatio * 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Top: Transaction ID
          rtl?
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlignRight():
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          rtl?
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlignRight():
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          Divider(
            color: AppColors.grey2Color,
            height: sizes!.heightRatio * 10,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Transaction Type, Rate, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: (statement.paymentModel == "Invest" &&
                            statement.tradeType == kSell)
                        ? AppLocalizations.of(context)!.sold//"Sold"
                        : AppLocalizations.of(context)!.history_bought_label,//"Bought",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey5Color,
                  ),
                  GetGenericText(
                    text:
                    "${AppLocalizations.of(context)!.metal_rate_aed} ${statement.paymentModel == "Invest" && statement.tradeType == kSell ? statement.sellingPrice?.toStringAsFixed(2) : statement.buyingPrice?.toStringAsFixed(2)}",
                        // "Rate: AED ${statement.paymentModel == "Invest" && statement.tradeType == kSell ? statement.sellingPrice?.toStringAsFixed(2) : statement.buyingPrice?.toStringAsFixed(2)}",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              const Spacer(),
              if (statement.transactionType == "Invest") ...[
                _buildPnlText(context),
                ConstPadding.sizeBoxWithWidth(width: isOpened ? 6 : 0),
              ],
              if (isOpened) _buildOpenedStatusContainer(context),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),

          /// Gold Debit or Gold Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: (statement.paymentModel == "Invest" &&
                        statement.tradeType == kSell)
                    ? AppLocalizations.of(context)!.goldDebit
                    : AppLocalizations.of(context)!.goldCredit,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: (statement.paymentModel == "Invest" &&
                        statement.tradeType == kSell)
                    ? "${statement.debit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}"
                    : "${statement.credit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Balance After Trade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.balanceAfterTransaction,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text:
                    "${statement.metalBalance != null ? statement.metalBalance!.toStringAsFixed(2) : AppLocalizations.of(context)!.not_available} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Transaction Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.transactionType,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              rtl?
              GetGenericText(
                text: statement.paymentModelInArabic ?? "",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ):
              GetGenericText(
                text: statement.paymentModel ?? "",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),

          /// Date
          ConstPadding.sizeBoxWithHeight(height: 6),
          // GetGenericText(
          //   text:
          //       "Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm a').format(DateTime.parse(statement.date.toString())) : 'N/A'}",
          //   fontSize: sizes!.responsiveFont(
          //     phoneVal: 12,
          //     tabletVal: 14,
          //   ),
          //   fontWeight: FontWeight.w500,
          //   color: AppColors.grey4Color,
          // ).getAlign(),
          rtl?
          GetGenericText(
            text:
            "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
            // "${AppLocalizations.of(context)!.grams_card_date_label} ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
                // "Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlignRight()
          :GetGenericText(
            text: "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
            // "Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlign(),
        ],
      ),
    );
  }

  Widget _metalHold(BuildContext context) {
    const kMetalHold = "Advance Payment";
    return Container(
      width: sizes!.widthRatio * 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Top: Transaction ID
          rtl?

          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlignRight():
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          rtl?

          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlignRight():
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          Divider(
            color: AppColors.grey2Color,
            height: sizes!.heightRatio * 10,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Transaction Type, Rate, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.metal_holder,//"Metal Holder",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 18,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),

          /// Gold Debit or Gold Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text:
                    (statement.paymentModel == kMetalHold) ? AppLocalizations.of(context)!.debit : AppLocalizations.of(context)!.credit,
                    // (statement.paymentModel == kMetalHold) ? "Debit" : "Credit",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: (statement.paymentModel == kMetalHold)
                    ? "${statement.debit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}"
                    : "${statement.credit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Balance After Trade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.balanceAfterTransaction,//"Balance after transaction",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text:
                    "${statement.metalBalance != null ? statement.metalBalance!.toStringAsFixed(2) : "N/A"} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Transaction Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.transactionType,//"Transaction Type",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              rtl?
              GetGenericText(
                text: statement.paymentModelInArabic ?? AppLocalizations.of(context)!.na,//"N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ):
              GetGenericText(
                text: statement.paymentModel ?? AppLocalizations.of(context)!.na,//"N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),

          /// Date
          ConstPadding.sizeBoxWithHeight(height: 6),
          rtl?
          GetGenericText(
            text: "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
            // text:"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlignRight():
          GetGenericText(
            text: "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
            // text:"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlign(),
        ],
      ),
    );
  }

  Widget _metalReleased(context) {
    const kMetalReleased = "Advance Settlement";
    return Container(
      width: sizes!.widthRatio * 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Top: Transaction ID
          rtl?
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlignRight():
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          rtl?
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlignRight():
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          Divider(
            color: AppColors.grey2Color,
            height: sizes!.heightRatio * 10,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Transaction Type, Rate, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.metal_released,//"Metal Released",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 18,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),

          /// Gold Debit or Gold Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: (statement.paymentModel == kMetalReleased)
                    ? AppLocalizations.of(context)!.credit//"Credit"
                    : AppLocalizations.of(context)!.debit,//"Debit",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: (statement.paymentModel == kMetalReleased)
                    ? "${statement.credit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}"
                    : "${statement.debit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Balance After Trade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.balanceAfterTransaction,//"Balance after transaction",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text:
                    "${statement.metalBalance != null ? statement.metalBalance!.toStringAsFixed(2) : AppLocalizations.of(context)!.na} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Transaction Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.transactionType,//"Transaction Type",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              rtl?
              GetGenericText(
                text: statement.paymentModelInArabic ?? AppLocalizations.of(context)!.na,//"N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ):
              GetGenericText(
                text: statement.paymentModel ?? AppLocalizations.of(context)!.na,//"N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),

          /// Date
          ConstPadding.sizeBoxWithHeight(height: 6),
          rtl?
          GetGenericText(
            text:"${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
                //"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlignRight():
          GetGenericText(
            text:"${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
                //"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlign(),
        ],
      ),
    );
  }

  /// gift sent card
  Widget _giftSentCard(context) {
    const kGiftSent = "Gift Sent";
    return Container(
      width: sizes!.widthRatio * 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Top: Transaction ID
          rtl?
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlignRight():
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          rtl?
          GetGenericText(
            text: statement.transactionId ?? "N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlignRight():
          GetGenericText(
            text: statement.transactionId ?? "N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          Divider(
            color: AppColors.grey2Color,
            height: sizes!.heightRatio * 10,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Transaction Type, Rate, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.gift,//"Gift",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 18,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),

          /// Gold Debit or Gold Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text:
                    (statement.paymentModel == kGiftSent) ? AppLocalizations.of(context)!.debit : AppLocalizations.of(context)!.credit,
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: (statement.paymentModel == kGiftSent)
                    ? "${statement.debit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}"
                    : "${statement.credit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Balance After Trade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.balanceAfterTransaction,//"Balance after transaction",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text:
                    "${statement.metalBalance != null ? statement.metalBalance!.toStringAsFixed(2) : AppLocalizations.of(context)!.na} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Transaction Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.transactionType,//"Transaction Type",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              rtl?
              GetGenericText(
                text: statement.paymentModelInArabic ?? "N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ):
              GetGenericText(
                text: statement.paymentModel ?? "N/A",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),

          /// Date
          ConstPadding.sizeBoxWithHeight(height: 6),
          rtl?GetGenericText(
            text:"${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
                //"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlignRight():
          GetGenericText(
            text:"${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
                //"Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlign(),
        ],
      ),
    );
  }

  /// SIG Wallet Card
  Widget _sigWalletCard(context) {
    return Container(
      width: sizes!.widthRatio * 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Top: Transaction ID
          rtl?
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlignRight():
          GetGenericText(
            text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
            fontSize: sizes!.responsiveFont(
              phoneVal: 14,
              tabletVal: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          rtl?
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,//"N/A",
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlignRight():
          GetGenericText(
            text: statement.transactionId ?? AppLocalizations.of(context)!.na,
            fontSize: sizes!.responsiveFont(
              phoneVal: 18,
              tabletVal: 20,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.grey6Color,
          ).getAlign(),
          ConstPadding.sizeBoxWithHeight(height: 2),
          Divider(
            color: AppColors.grey2Color,
            height: sizes!.heightRatio * 10,
          ),
          ConstPadding.sizeBoxWithHeight(height: 4),

          /// Transaction Type, Rate, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.esouqPayment,//"Esouq Payment",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),

          /// Gold Debit or Gold Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.goldDebit,//"Gold Debit",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text: "${statement.debit!.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Balance After Trade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.balanceAfterTransaction,//"Balance after Trade",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              GetGenericText(
                text:
                    "${statement.metalBalance != null ? statement.metalBalance!.toStringAsFixed(2) : AppLocalizations.of(context)!.na} ${AppLocalizations.of(context)!.metal_g}",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),
          ConstPadding.sizeBoxWithHeight(height: 6),

          /// Transaction Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(context)!.transactionType,//"Transaction Type",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 12,
                  tabletVal: 14,
                ),
                fontWeight: FontWeight.w400,
                color: AppColors.grey3Color,
              ),
              rtl?
              GetGenericText(
                text: statement.paymentModelInArabic ?? "",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ):
              GetGenericText(
                text: statement.paymentModel ?? "",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 14,
                  tabletVal: 16,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.grey5Color,
              ),
            ],
          ),

          /// Date
          ConstPadding.sizeBoxWithHeight(height: 6),
          rtl?
          GetGenericText(
            text:

            "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
               // "Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlignRight():
          GetGenericText(
            text:

            "${AppLocalizations.of(context)!.grams_card_date_label} "
"${statement.date != null 
  ? DateFormat('EEEE, dd MMM yyyy, HH:mm', 
      Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en')
      .format(DateTime.parse(statement.date.toString()).toLocal()) 
  : 'N/A'}",
               // "Date: ${statement.date != null ? DateFormat('EEEE, dd MMM yyyy, HH:mm').format(DateTime.parse(statement.date.toString()).toLocal()) : 'N/A'}",
            fontSize: sizes!.responsiveFont(
              phoneVal: 12,
              tabletVal: 14,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.grey4Color,
          ).getAlign(),
        ],
      ),
    );
  }

  /// build opened status container
  Widget _buildOpenedStatusContainer(context) {
    return Container(
      width: sizes!.isPhone ? sizes!.widthRatio * 65 : sizes!.widthRatio * 80,
      height: sizes!.responsiveLandscapeHeight(
        phoneVal: 24,
        tabletVal: 32,
        tabletLandscapeVal: 44,
        isLandscape: sizes!.isLandscape(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0x33BBA473),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFBBA473)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Center(
        child: GetGenericText(
          text: AppLocalizations.of(context)!.grams_card_opened,//"OPENED",
          fontSize: sizes!.responsiveFont(phoneVal: 10, tabletVal: 12),
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  /// build pnl text
  Widget _buildPnlText(context) {
    final pnl = statement.pnl;
    final hasValidPnl = pnl != null && pnl != 0;
    debugPrint("statementPNL:${statement.pnl} | status: ${statement.status}");
    return GetGenericText(
      text: hasValidPnl ? "${AppLocalizations.of(context)!.aed_currency} ${pnl.toStringAsFixed(2)}" : "AED 0.000",
      // text: hasValidPnl ? "AED ${pnl.toStringAsFixed(2)}" : "AED 0.000",
      fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
      fontWeight: FontWeight.w500,
      color: hasValidPnl
          ? (pnl > 0 ? AppColors.green800Color : AppColors.red900Color)
          : AppColors.grey500Color, // Added fallback color
    );
  }
}
