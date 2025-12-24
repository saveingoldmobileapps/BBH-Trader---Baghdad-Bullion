import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/news_provider/news_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/all_home_news_card.dart';

import '../../widgets/no_data_widget.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsAllProvider.notifier).fetchNews();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsAllProvider);
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
          text: AppLocalizations.of(context)!.news,//"News",
          fontSize: sizes!.responsiveFont(phoneVal: 20, tabletVal: 24),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        color: AppColors.greyScale1000,
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: AppColors.primaryGold500,
            color: AppColors.whiteColor,
            onRefresh: () async {
              if (!context.mounted) return;
              await ref.read(newsAllProvider.notifier).fetchNews();
            },
            child: Column(
              children: [
                Expanded(
                  child: newsState.isLoading
                      ? Center(
                          child: ShimmerLoader(loop: 6),
                        ).get16HorizontalPadding()
                      : newsState.newsList.isEmpty
                      ? Center(
                          child: NoDataWidget(
                            title: AppLocalizations.of(context)!.no_news,//"No News Available",
                            description: AppLocalizations.of(context)!.check_back,//"Check back later for updates",
                          ),
                        )
                      : ListView.builder(
                          itemCount: newsState.newsList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final news = newsState.newsList[index];
                            return AllHomeNewsCard(
                              newsUpdates: news,
                            ).get6VerticalPadding();
                          },
                        ),
                ),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }
}
