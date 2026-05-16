import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class addFundViewScreen extends StatefulWidget {
  const addFundViewScreen({super.key});

  @override
  State<addFundViewScreen> createState() => _addFundViewScreenState();
}

class _addFundViewScreenState extends State<addFundViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadFlutterAsset(
            'assets/html/BBH_Deposit_UI_2.html',
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}