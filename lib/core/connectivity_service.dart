import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../presentation/widgets/no_internet_dialoug.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _dialogVisible = false;

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((resultList) {
      bool hasInternet = resultList.any((r) => r != ConnectivityResult.none);

      if (!hasInternet && !_dialogVisible) {
        _dialogVisible = true;
        showNoInternetDialog().then((_) {
          _dialogVisible = false;
        });
      } else if (hasInternet && _dialogVisible) {
        final context = navigatorKey.currentContext;
        if (context != null && Navigator.canPop(context)) {
          if (!context.mounted) return;
          Navigator.of(context).pop();
          _dialogVisible = false;
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
