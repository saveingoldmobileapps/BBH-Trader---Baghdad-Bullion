import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewScreen extends StatefulWidget {
  const HtmlViewScreen({super.key});

  @override
  State<HtmlViewScreen> createState() => _HtmlViewScreenState();
}

class _HtmlViewScreenState extends State<HtmlViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadFlutterAsset(
            'assets/html/bbh-onboarding-v2.html',
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}