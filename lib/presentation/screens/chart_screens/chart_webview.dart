import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/extensions/extensions.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/res_sizes/res.dart';
import '../../../core/theme/const_colors.dart';
import '../../../core/theme/get_generic_text_widget.dart';

class GoldPriceChartPage extends StatefulWidget {
  const GoldPriceChartPage({super.key});

  @override
  _GoldPriceChartPageState createState() => _GoldPriceChartPageState();
}

class _GoldPriceChartPageState extends State<GoldPriceChartPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://saveingold-chart.vercel.app/',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        title: GetGenericText(
          text: "Gold Price Chart",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
                child: ShimmerLoader(
                  loop: 5,
                ),
              ).get20HorizontalPadding(),
        ],
      ),
    );
  }
}
