import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

AppSizes? sizes;

bool _isInitialized = false;

void initializeResources({required BuildContext context}) {
  AppSizes().initializeSize(context);
  if (_isInitialized) {
    /**
     * this is to prevent
     * multiple initialization calls.
     */
    return;
  }
  sizes = AppSizes()..initializeSize(context);
}
