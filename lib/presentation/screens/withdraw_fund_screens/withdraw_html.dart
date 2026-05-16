import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class withdrawViewScreen extends StatefulWidget {
  const withdrawViewScreen({super.key});

  @override
  State<withdrawViewScreen> createState() => _withdrawViewScreenState();
}

class _withdrawViewScreenState extends State<withdrawViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadFlutterAsset(
            'assets/html/BBH_Withdrawal_UI_1.html',
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}