import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/history_model/GetMetalStatementsResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class MetalStatementDetailScreen extends ConsumerStatefulWidget {
  final MetalHistoryList statement;

  const MetalStatementDetailScreen({
    super.key,
    required this.statement,
  });

  @override
  ConsumerState createState() => _MetalStatementDetailScreenState();
}

class _MetalStatementDetailScreenState
    extends ConsumerState<MetalStatementDetailScreen> {
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
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Details",
          // fontSize: 20,
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.transactionID,//"Transaction ID",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ), //16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: widget.statement.transactionId ?? "",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: "Triggered by",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: widget.statement.date != null
                        ?  DateFormat(
    'EEE, dd MMM yyyy, HH:mm',
    Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en',
  ).format(
    DateTime.parse(widget.statement.date.toString()).toLocal(),
  )
: AppLocalizations.of(context)!.na,
                        // DateFormat('EEE, dd MMM yyyy, HH:mm').format(
                        //     DateTime.parse(
                        //       widget.statement.date.toString(),
                        //     ),
                        //   )
                        // : 'N/A',
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.dateTime,//"Date & Time",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: widget.statement.date != null
                    ? DateFormat(
    'EEE, dd MMM yyyy, HH:mm',
    Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en',
  ).format(
    DateTime.parse(widget.statement.date.toString()).toLocal(),
  )
: AppLocalizations.of(context)!.na,

                        // ? DateFormat('EEE, dd MMM yyyy, HH:mm').format(
                        //     DateTime.parse(
                        //       widget.statement.date.toString(),
                        //     ),
                        //   )
                        // : 'N/A',
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 14,
                      tabletVal: 16,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Divider(
                color: AppColors.greyScale900,
                thickness: 1.5,
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              GetGenericText(
                text: "Transaction Details",
                fontSize: sizes!.responsiveFont(
                  phoneVal: 16,
                  tabletVal: 18,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ).getAlign(),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: "Invest",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text:
                        (widget.statement.paymentModel == "Invest" &&
                            widget.statement.tradeType == "Sell")
                        ? "${widget.statement.tradeType} ${widget.statement.debit} g"
                        : "${widget.statement.tradeType} ${widget.statement.credit} g",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: widget.statement.transactionType ?? "N/A",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text:
                        "${widget.statement.debit ?? widget.statement.credit} g",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: "Opened @",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: AppLocalizations.of(context)!.metal_plus_na,//"AED N/A",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: "Closed @",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: "${AppLocalizations.of(context)!.aed} ${AppLocalizations.of(context)!.na}""AED N/A",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey5Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetGenericText(
                    text: AppLocalizations.of(context)!.metal_profit,//"Profit",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey3Color,
                  ),
                  GetGenericText(
                    text: AppLocalizations.of(context)!.metal_plus_na,//"+ AED N/A",
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.green800Color,
                  ),
                ],
              ),
              ConstPadding.sizeBoxWithHeight(height: 20),
              Container(
                width: sizes!.isPhone ? sizes!.widthRatio * 361 : sizes!.width,
                height: sizes!.heightRatio * 56,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetGenericText(
                      text: AppLocalizations.of(context)!.metal_after_trade,//"Metal After Trade",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey5Color,
                    ),
                    GetGenericText(
                      text: "${widget.statement.metalBalance} ${AppLocalizations.of(context)!.metal_g}",//"${widget.statement.metalBalance} g",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 16,
                        tabletVal: 18,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey5Color,
                    ),
                  ],
                ),
              ),
            ],
          ).get16HorizontalPadding(),
        ),
      ),
    );
  }
}
