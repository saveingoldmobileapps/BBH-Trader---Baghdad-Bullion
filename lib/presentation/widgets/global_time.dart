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
      final parsed = DateTime.parse(isoDate);

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
}
