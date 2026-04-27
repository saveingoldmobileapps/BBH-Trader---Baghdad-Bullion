import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Format ISO date to device local time
  static String formatLocalDateTime(
    String? isoDate,
    BuildContext context, {
    String pattern = 'dd/MM/yyyy, HH:mm',
  }) {
    if (isoDate == null || isoDate.isEmpty) return '-';

    try {
      final parsed = _tryParseDateTime(isoDate);
      if (parsed == null) return isoDate;

      // Convert to device local time
      final localTime = parsed.toLocal();

      final locale = Localizations.localeOf(context).languageCode == 'ar'
          ? 'ar'
          : 'en';

      return DateFormat(pattern, locale).format(localTime);
    } catch (_) {
      return isoDate;
    }
  }

  static DateTime? _tryParseDateTime(String input) {
    // 1) Standard ISO-8601 / "yyyy-MM-dd HH:mm:ss" etc.
    try {
      return DateTime.parse(input);
    } catch (_) {}

    // 2) Common backend / UI formats that may include AM/PM.
    // We try a small set to avoid heavy parsing cost.
    const patterns = <String>[
      "dd/MM/yyyy, hh:mm a",
      "dd/MM/yyyy hh:mm a",
      "MM/dd/yyyy, hh:mm a",
      "MM/dd/yyyy hh:mm a",
      "yyyy-MM-dd hh:mm a",
      "yyyy-MM-dd, hh:mm a",
      "dd-MM-yyyy, hh:mm a",
      "dd-MM-yyyy hh:mm a",
    ];

    for (final p in patterns) {
      try {
        return DateFormat(p, "en_US").parseLoose(input);
      } catch (_) {}
    }

    return null;
  }
}
