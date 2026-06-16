import 'package:flutter/material.dart';

/// Scroll anchors for required fields — scroll into view on validation errors.
class BbhOnboardingFieldScroll {
  BbhOnboardingFieldScroll._();

  static final _keys = <String, GlobalKey>{};

  /// Highlights the first invalid field after validation fails.
  static String? activeErrorField;

  static void clearError() => activeErrorField = null;

  static void markError(String fieldId) => activeErrorField = fieldId;

  static bool isError(String? fieldId) =>
      fieldId != null && activeErrorField == fieldId;

  static GlobalKey keyFor(String fieldId) =>
      _keys.putIfAbsent(fieldId, GlobalKey.new);

  static Widget anchor(String fieldId, Widget child) =>
      KeyedSubtree(key: keyFor(fieldId), child: child);

  static Future<void> scrollTo(String? fieldId) async {
    if (fieldId == null) return;
    final context = _keys[fieldId]?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      alignment: 0.22,
    );
  }
}
