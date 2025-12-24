import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/history_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/history_provider/history_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/metal_state_card.dart';
import 'package:saveingold_fzco/presentation/widgets/pop_up_widget.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';

import '../../../core/core_export.dart';
import '../../widgets/no_data_widget.dart' show NoDataWidget;

class MetalStatementScreen extends ConsumerStatefulWidget {
  const MetalStatementScreen({super.key});

  @override
  ConsumerState createState() => _MetalStatementScreenState();
}

class _MetalStatementScreenState extends ConsumerState<MetalStatementScreen> {
  var historyType = HistoryType.metal;
  final fromController = TextEditingController();
  final toController = TextEditingController();
  String selectedFilter = "All";

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// metal statements
      ref.read(historyProvider.notifier).fetchUserMetalStatements(reset: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    fromController.dispose();
    toController.dispose();
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
    final historyState = ref.watch(historyProvider);

    return Column(
      children: [
        /// Filter and Download buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// Filter
            GestureDetector(
              onTap: () async {
                await historyFilterPopUpWidget(
                  context: context,
                  fromController: fromController,
                  toController: toController,
                  selectedFilter: selectedFilter,
                  onPopUpCloseTap: () {
                    Navigator.pop(context);
                  },
                  onClearFiltersTap: () async {
                    selectedFilter = "All";
                    fromController.clear();
                    toController.clear();

                    /// fetch user metal statements
                    await ref
                        .read(historyProvider.notifier)
                        .fetchUserMetalStatements(
                          reset: true,
                        );
                  },
                  onApplyFilterTap: (filter, dateFrom, dateTo) async {
                    /// fetch user metal statements
                    await ref
                        .read(historyProvider.notifier)
                        .fetchUserMetalStatements(
                          dateFrom: dateFrom,
                          dateTo: dateTo,
                          reset: true,
                        );
                    selectedFilter = filter;
                  },
                );
              },
              child: Container(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  'assets/svg/filter_icon.svg',
                ),
              ),
            ),
            ConstPadding.sizeBoxWithWidth(width: 10),

            /// Download Button
            GestureDetector(
              onTap: () async {
                /// export user statements
                await ref
                    .read(historyProvider.notifier)
                    .exportUserStatements(
                      statementData: historyState.metalStatements,
                      statementType: "Metal",
                    );
              },
              child: Container(
                color: Colors.transparent,
                child: historyState.isDownloading
                    ? Center(
                        child: SizedBox(
                          height: sizes!.heightRatio * 16,
                          width: sizes!.widthRatio * 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 0.5,
                          ),
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svg/download_icon.svg',
                        height: sizes!.isLandscape()
                            ? sizes!.heightRatio * 32
                            : sizes!.heightRatio * 24,
                        width: sizes!.isLandscape()
                            ? sizes!.widthRatio * 32
                            : sizes!.widthRatio * 24,
                      ),
              ),
            ),
          ],
        ),
        ConstPadding.sizeBoxWithHeight(height: 12),

        historyState.loadingState == LoadingState.data
            ? (historyState.getMetalStatementsResponse.payload == null ||
                      historyState.metalStatements.isEmpty)
                  ? NoDataWidget(
                      title: AppLocalizations.of(context)!.enter_verify_code,
                      description:AppLocalizations.of(context)!.history_create_metal_st,
                          //"Please create new metal statement or try again later",
                    ).get20VerticalPadding()
                  : SizedBox(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = !sizes!.isPhone;

                          /// Child Aspect Ratio
                          final double childAspectRatio = isTablet
                              ? (sizes!.isLandscape() ? 2 : 1.2)
                              : 1.2;

                          return GridView.builder(
                            itemCount: historyState.metalStatements.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isTablet ? 2 : 1,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final statement =
                                  historyState.metalStatements[index];

                              /// metal statement card
                              return MetalStatementCard(
                                statement: statement,
                                rtl: Directionality.of(context) == TextDirection.rtl,
                                onTap: () {
                                  /// If the statement is a trade
                                  // if (statement.paymentModel == "Trade") {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           MetalStatementDetailScreen(
                                  //         statement: statement,
                                  //       ),
                                  //     ),
                                  //   );
                                  // }
                                },
                              ).get6VerticalPadding();
                            },
                          );
                        },
                      ),
                    )
            : historyState.loadingState == LoadingState.error
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child: NoDataWidget(
                    title: AppLocalizations.of(context)!.empty_no_data,//"No Data To Show",
                    description:
                        "${historyState.errorResponse.payload?.message.toString()}",
                  ),
                ),
              )
            : ShimmerLoader(
                loop: sizes!.isPhone ?4:6,
              ),
      ],
    );
  }
}
