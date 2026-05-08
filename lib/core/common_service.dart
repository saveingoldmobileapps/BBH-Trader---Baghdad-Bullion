import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baghdad_bullion_house/core/push_notification_service/firebase_push_notification_service.dart';
import 'package:baghdad_bullion_house/core/sound_services.dart';
import 'package:baghdad_bullion_house/core/sounds/app_sounds.dart';
import 'package:baghdad_bullion_house/data/data_sources/local_database/local_database.dart'
    show LocalDatabase;
import 'package:baghdad_bullion_house/l10n/app_localizations.dart';
import 'package:baghdad_bullion_house/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../presentation/screens/get_started_screen.dart';
import 'core_export.dart';
import 'services/socket_services.dart';

class CommonService {
  //static final _logger = Logger();
  static bool? hasFingerHardWare;
  static bool? hasFaceHardWare;
  static String lang = "en";
  static bool isMaintenancePopupVisible = false;

  /// calculate loss or profit
  // static num calculateLossOrProfit({
  //   required num? buyingPrice,
  //   required num? livePrice,
  //   required num tradeMetalFactor,
  // }) {
  //   return (((livePrice ?? 0) - (buyingPrice ?? 0)) * tradeMetalFactor);
  // }

  static num calculateLossOrProfit({
    required num? buyingPrice,
    required num? livePrice,
    required num tradeMetalFactor,
  }) {
    final bp = buyingPrice ?? 0;
    final lp = livePrice ?? 0;

    return (lp - bp) * tradeMetalFactor;
  }

  ///
  static String calculateAfterTax({required String amount}) {
    var amountInDouble = double.parse(amount);
    const double taxRate = 0.03; // 3% tax rate
    double tax = amountInDouble * taxRate;
    return (amountInDouble - tax).toString();
  }

  /// calculate amount
  static String calculateAmount({required String amount}) {
    final calculatedAmount = (double.tryParse(amount) ?? 0) * 100;
    return calculatedAmount.toInt().toString();
  }
  static double calculateWeightPrice({
  required String? weightFactor,
  required double oneGramSellingPrice,
}) {
  final weight = double.tryParse(weightFactor ?? "0.0") ?? 0.0;

  final value = weight * oneGramSellingPrice;
  final roundedValue = value.round();

  final lastTwoDigits = roundedValue % 100;
  final base = roundedValue - lastTwoDigits;

  final finalValue = lastTwoDigits >= 50
      ? base + 100
      : base;

  return finalValue.toDouble();
}
  /// calculate weight price
  // static double calculateWeightPrice({
  //   required String? weightFactor,
  //   required double oneGramSellingPrice,
  // }) {
  //   final weight = double.tryParse(weightFactor ?? "0.0") ?? 0.0;
  //   return double.parse((weight * oneGramSellingPrice).toStringAsFixed(3));
  // }

  /// format currency
  // static String formatCurrency({
  //   required String amount,
  // }) {
  //   final amountInDouble = double.tryParse(amount) ?? 0.0;
  //   if (amountInDouble >= 10000) {
  //     return "${(amountInDouble / 1000).toStringAsFixed(3)..round()}K"; // Keep 3 decimal places in large values
  //   }

  //   final formatter = NumberFormat("#,##0.00", "en_US");
  //   return formatter.format(amountInDouble);
  // }
 

  /// Parses a string amount (e.g. from inputs) with fixed 3 decimal places.
  /// Prefer [formatIqdCurrency] when the value is already numeric.
  static String formatCurrency({
    required String amount,
    bool useArabic = false,
  }) {
    final amountInDouble = double.tryParse(amount) ?? 0.0;
    final rounded = amountInDouble.round();

    final formatter = NumberFormat(
      "#,##0",
      useArabic ? "ar_IQ" : "en_US",
    );

    return formatter.format(rounded);
  }

  /// **App-wide IQD amount formatting** — thousand separators, rounded to whole IQD (no decimals).
  /// Use this (or [formatIQDForDisplay]) for every IQD number shown in the UI.
  static String formatIqdCurrency(num? value, {bool useArabic = false}) {
    final rounded = (value ?? 0).round();
    return NumberFormat("#,##0", useArabic ? "ar_IQ" : "en_US").format(rounded);
  }

//   static String roundingFormatIqdCurrency(num? value, {bool useArabic = false}) {
//   final val = (value ?? 0).round();

//   final lastTwoDigits = val % 100;
//   final base = val - lastTwoDigits;

//   final rounded = lastTwoDigits >= 50
//       ? base + 100
//       : base;

//   return NumberFormat("#,##0", useArabic ? "ar_IQ" : "en_US")
//       .format(rounded);
// }
static String roundingFormatIqdCurrency(
  num? value, {
  bool useArabic = false,
}) {
  final val = (value ?? 0).round();

  int rounded;

  // 🔹 Less than 100 → round to nearest 10
  if (val < 100) {
    final tens = (val ~/ 10) * 10;
    final remainder = val % 10;

    rounded = remainder < 5 ? tens : tens + 10;
  }

  // 🔹 100 and above → round based on last 2 digits
  else {
    final lastTwoDigits = val % 100;
    final base = val - lastTwoDigits;

    rounded = lastTwoDigits < 50
        ? base
        : base + 100;
  }

  return NumberFormat(
    "#,##0",
    useArabic ? "ar_IQ" : "en_US",
  ).format(rounded);
}
// static String roundingFormatIqdCurrency(
//   num? value, {
//   bool useArabic = false,
// }) {
//   final val = (value ?? 0).round();

//   int rounded;
//   if (val < 100) {
//   final tens = (val ~/ 10) * 10;
//   final remainder = val % 10;

//   rounded = remainder < 5 ? tens : tens + 10;
// }

//   // 🔹 Handle 100+
//   else {
//     final remainder = val % 100;

//     if (val >= 150) {
//       // force jump rule
//       rounded = ((val / 100).ceil()) * 100;
//     } else {
//       // normal 100 rounding
//       rounded = val - remainder;
//     }
//   }

//   return NumberFormat(
//     "#,##0",
//     useArabic ? "ar_IQ" : "en_US",
//   ).format(rounded);
// }

  /// Same as [formatIqdCurrency]; kept for existing call sites.
  static String formatIQDForDisplay(num? value) => roundingFormatIqdCurrency(value);
static String roundingformatIQDForDisplay(num? value) => roundingFormatIqdCurrency(value);

  /// Normalize IQD numeric value for API payloads using the same app rounding policy.
  /// - < 100  => nearest 10
  /// - >= 100 => nearest 100
  /// Returns a number (no locale formatting / no separators) safe for JSON payloads.
  static num normalizeIqdForApi(num? value) {
    final val = (value ?? 0).round();
    if (val < 100) {
      final tens = (val ~/ 10) * 10;
      final remainder = val % 10;
      return remainder < 5 ? tens : tens + 10;
    }

    final lastTwoDigits = val % 100;
    final base = val - lastTwoDigits;
    return lastTwoDigits < 50 ? base : base + 100;
  }

  /// Format price for compact display (e.g. 2K, 1M) — based on rounded whole units.
  static String formatPriceCompact(num? value) {
    final rounded = (value ?? 0).round();
    if (rounded == 0) return "0";
    final compact = NumberFormat.compact(locale: "en_US").format(rounded);
    return compact.replaceAll('k', 'K').replaceAll('m', 'M').replaceAll('b', 'B');
  }

  /// Gram / metal amounts for UI — whole grams with grouping, no decimals.
  static String formatGramForDisplay(num? value) {
    final amount = (value ?? 0).toDouble();
    if (amount == 0) return "0.00";
    if (amount.abs() >= 1000) {
      return NumberFormat("#,##0.00", "en_US").format(amount);
    }
    return amount.toStringAsFixed(3);
  }
  //  static String formatGramForDisplay(num? value) {
  //   final rounded = (value ?? 0).round();
  //   if (rounded == 0) return "0";
  //   return NumberFormat("#,##0", "en_US").format(rounded);
  // }
  static String formatIraqDateTime(
  String? isoDate,
  BuildContext context, {
  bool withTime = true,
}) {
  if (isoDate == null || isoDate.isEmpty) return '-';

  try {
    final parsed = _tryParseDateTime(isoDate);
    if (parsed == null) return isoDate;
    final iraqTime = parsed.toUtc().add(const Duration(hours: 3));

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    // English fallback
    if (!isArabic) {
      return DateFormat(
        withTime ? 'dd MMM yyyy, HH:mm' : 'dd MMM yyyy',
        'en_US',
      ).format(iraqTime);
    }

    // Iraqi Arabic month names
    const iraqiMonths = [
      'كانون الثاني',
      'شباط',
      'آذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول',
    ];

    final day = iraqTime.day;
    final month = iraqiMonths[iraqTime.month - 1];
    final year = iraqTime.year;
    final time = DateFormat('HH:mm').format(iraqTime);

    String result = withTime
        ? '$day $month $year، $time'
        : '$day $month $year';

    // Optional: convert digits to Arabic
    return CommonService.toArabicDigits(result);
  } catch (_) {
    return isoDate;
  }
}

  static DateTime? _tryParseDateTime(String input) {
    try {
      return DateTime.parse(input);
    } catch (_) {}

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


  static String getGreeting(String name, BuildContext context) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return '${AppLocalizations.of(context)!.good_morning}, $name'; //'Good Morning, $name';
    } else if (hour < 17) {
      return '${AppLocalizations.of(context)!.good_afternoon}, $name'; //'Good Afternoon, $name';
    } else {
      return '${AppLocalizations.of(context)!.good_evening}, $name'; //'Good Evening, $name';
    }
  }

  static String toArabicDigits(String input) {
    const digitMap = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
      ',': '٬', // Arabic comma
      '.': '٫', // Arabic decimal point
    };

    final buffer = StringBuffer();
    for (var char in input.characters) {
      buffer.write(digitMap[char] ?? char);
    }
    return buffer.toString();
  }

  // static String formatDateTime(String isoDate) {
  //   try {
  //     DateTime parsedDate = DateTime.parse(isoDate).toLocal();
  //     DateFormat formatter = DateFormat("dd MMM yyyy HH:mm");
  //     return formatter.format(parsedDate);
  //   } catch (e) {
  //     return isoDate;
  //   }
  // }
  static Future<void> connectSocket() async {
    final SocketService socketService = SocketService();
    final userId = await LocalDatabase.instance.getUserId() ?? "";
    final username = await LocalDatabase.instance.getUserName() ?? "";
    final lastName = await LocalDatabase.instance.getUserLastName() ?? "";
    String? email = await LocalDatabase.instance.read(
      key: Strings.userEmail,
    );
    final userType = await LocalDatabase.instance.getIsDemo() ?? false;

    String? accountId = await LocalDatabase.instance.read(
      key: Strings.userAccountID,
    );
    socketService.connect(
      userId,
      "$username $lastName",
      email: email,
      avatar: await LocalDatabase.instance.getUserProfileImage() ?? "",
      accountId: accountId,
      userType: userType ? "Demo": "Real"
    );
  }

  static String formatDateTime(BuildContext context, String isoDate) {
    try {
      final parsedDate = _tryParseDateTime(isoDate)?.toLocal();
      if (parsedDate == null) return isoDate;
      String locale = Localizations.localeOf(context).languageCode == 'ar'
          ? 'ar'
          : 'en';
      DateFormat formatter = DateFormat("dd MMM yyyy HH:mm", locale);
      return formatter.format(parsedDate);
    } catch (e) {
      return isoDate;
    }
  }

  /// Troy ounces → grams (FIX/FICC convention).
  static const double gramsPerTroyOunce = 31.10347;

  /// get once gram price in IQD
  static double getOneGramPriceInIQD({
    required double ounceDollarPrice,
    required double dirham,
    required double ounce,
  }) {
    return ((ounceDollarPrice / ounce)* dirham);
  }

  /// One gram **buy** IQD: \((ounceUSD / G) + buyingMargin\) × exchangeBuyRate.
  static double oneGramBuyingPriceInIqd({
    required double ounceUsd,
    required double buyingMargin,
    required double exchangeBuyRate,
    double gramsPerOunce = gramsPerTroyOunce,
  }) {
    return ((ounceUsd / gramsPerOunce) + buyingMargin) * exchangeBuyRate;
  }

  /// One gram **sell** IQD: \((ounceUSD / G) - sellingMargin\) × exchangeSellingRate.
  static double oneGramSellingPriceInIqd({
    required double ounceUsd,
    required double sellingMargin,
    required double exchangeSellingRate,
    double gramsPerOunce = gramsPerTroyOunce,
  }) {
    return ((ounceUsd / gramsPerOunce) - sellingMargin) * exchangeSellingRate;
  }

  /// One troy ounce **buy** IQD (consistent with [oneGramBuyingPriceInIqd] × G).
  static double oneOunceBuyingPriceInIqd({
    required double ounceUsd,
    required double buyingMargin,
    required double exchangeBuyRate,
    double gramsPerOunce = gramsPerTroyOunce,
  }) {
    return (ounceUsd + buyingMargin * gramsPerOunce) * exchangeBuyRate;
  }

  /// One troy ounce **sell** IQD (consistent with [oneGramSellingPriceInIqd] × G).
  static double oneOunceSellingPriceInIqd({
    required double ounceUsd,
    required double sellingMargin,
    required double exchangeSellingRate,
    double gramsPerOunce = gramsPerTroyOunce,
  }) {
    return (ounceUsd - sellingMargin * gramsPerOunce) * exchangeSellingRate;
  }

  /// mask email address
  static String maskEmailAddress(String emailAddress) {
    int atIndex = emailAddress.indexOf('@');
    String localPart = emailAddress.substring(0, atIndex);
    String domain = emailAddress.substring(atIndex + 1);

    // Mask all but the first two characters of the local part
    String maskedLocalPart =
        localPart.substring(0, 2) + '*' * (localPart.length - 2);

    return '$maskedLocalPart@$domain';
  }
  // static String maskEmailAddress(String emailAddress) {
  // int atIndex = emailAddress.indexOf('@');
  // String localPart = emailAddress.substring(0, atIndex);
  // String domain = emailAddress.substring(atIndex + 1);

  // // Find index of first digit (if any)
  // int digitIndex = localPart.indexOf(RegExp(r'\d'));

  // // If no digit, just show first and last character
  // if (digitIndex == -1) {
  //   if (localPart.length <= 2) return localPart + '@' + domain;
  //   return localPart[0] +
  //       '*' * (localPart.length - 2) +
  //       localPart[localPart.length - 1] +
  //       '@' +
  //       domain;
  // }

  // If digit exists
  //   String firstChar = localPart[0];
  //   String lastCharBeforeDigit = localPart[digitIndex - 1];
  //   String digitsAndRest = localPart.substring(digitIndex);

  //   return '$firstChar*****$lastCharBeforeDigit$digitsAndRest@$domain';
  // }

  /// logout user
  static Future<void> logoutUser({
    required BuildContext context,
  }) async {
    bool faceIDEnabled = await LocalDatabase.instance.getFaceEnable() ?? false;
    bool isFingerPrintEnabled =
        await LocalDatabase.instance.getFingerEnable() ?? false;
    await LocalDatabase.instance.storeFaceEnable(
      isEnable: faceIDEnabled,
    );

    //  LocalDatabase.instance.storeFaceEnable(
    //   isEnable: faceIDEnabled,
    // );
    // await SecureStorageService.instance.storeAutoLogin(
    //   autoLogin: false,
    // );
    await LocalDatabase.instance.storeAutoLogin(
      autoLogin: false,
    );
    await LocalDatabase.instance.storeFingerEnable(
      isEnable: isFingerPrintEnabled,
    );
    String? email = await LocalDatabase.instance.read(
      key: Strings.userEmail,
    );
    try {
      await FirebasePushNotificationService.unsubscribeFromTopic(email: email!);
    } catch (e) {
      debugPrint(e.toString());
    }

    /// logout user
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
      ((route) => false),
    );
    await SoundPlayer().playSound(AppSounds.loginSound);
  }

  // static String formatTimeAgo(String timestamp) {
  //   final DateTime parsedTime = DateTime.parse(timestamp);
  //   final DateTime now = DateTime.now();
  //   final Duration difference = now.difference(parsedTime);

  //   if (difference.inDays > 0) {
  //     return "${parsedTime.day}/${parsedTime.month}/${parsedTime.year}";
  //   } else if (difference.inHours > 0) {
  //     return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
  //   } else if (difference.inMinutes > 0) {
  //     return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
  //   } else {
  //     return "${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago";
  //   }
  // }
  static String formatTimeAgo(String timestamp, {bool isArabic = false}) {
    final DateTime parsedTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(parsedTime);

    if (difference.inDays > 0) {
      return "${parsedTime.day}/${parsedTime.month}/${parsedTime.year}";
    } else if (difference.inHours > 0) {
      if (isArabic) {
        return "قبل ${difference.inHours} ساعة${difference.inHours > 1 ? '' : ''}";
      } else {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      }
    } else if (difference.inMinutes > 0) {
      if (isArabic) {
        return "قبل ${difference.inMinutes} دقيقة${difference.inMinutes > 1 ? '' : ''}";
      } else {
        return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      }
    } else {
      if (isArabic) {
        return "قبل ${difference.inSeconds} ثانية${difference.inSeconds > 1 ? '' : ''}";
      } else {
        return "${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago";
      }
    }
  }

  /// mask phone number
  static String maskPhoneNumber({
    required String phoneNumber,
  }) {
    RegExp regExp = RegExp(r'(\d{3})\s?(\d{2})\s?(\d{4})');
    Match match = regExp.firstMatch(phoneNumber) as Match;

    String firstPart = match.group(1) ?? '';
    String secondPart = match.group(2) ?? '';
    String lastPart = match.group(3) ?? '';

    return "$firstPart $secondPart** ${lastPart.substring(0, 1)}**";
  }

  /// get address
  static String getAddress({required dynamic allBookings}) {
    final location = allBookings.userId?.location;
    final address = [
      allBookings.userId?.houseNumber,
      allBookings.userId?.streetAddress,
      allBookings.userId?.area,
      allBookings.userId?.emirate,
    ].where((value) => value != null && value.isNotEmpty).join(', ');

    return address.isEmpty
        ? location ?? "Dubai - United Arab Emirates"
        : address;
  }

  static String convertToShortNum({required double num}) {
    final n = num.round();
    if (n < 1000) {
      return n.toString();
    } else if (n < 1000000) {
      return '${(n / 1000).round()}K';
    } else if (n < 1000000000) {
      return '${(n / 1000000).round()}M';
    } else {
      return n.toString();
    }
  }

  static String shortenNumber(num value) {
    if (value >= 1000000) {
      // Convert to M (millions)
      double inMillions = value / 1000000;
      if (inMillions == inMillions.toInt()) {
        // If it's a whole number (like 1.0), return without decimal
        return '${inMillions.toInt()}M';
      }
    }
    // Return as-is if not >= 1M or not a round million
    return value.toString();
  }

  static String convertToWeight({
    required double num,
    required BuildContext context,
  }) {
    if (num < 1000) {
      return '${num.round()} ${AppLocalizations.of(context)!.metal_g}';
    } else {
      return '${(num / 1000).round()} kg';
    }
  }

  /// convert weight
  static String convertWeight({
    required double grams,
  }) {
    if (grams < 3.8) {
      return (grams * 1000 / 11.66).round().toString();
    } else if (grams < 28.35) {
      return (grams / 28.35).round().toString();
    } else if (grams < 1000) {
      return grams.round().toString();
    } else {
      return (grams / 1000).round().toString();
    }
  }

  /// convert weight unit
  static String convertWeightUnit({
    required double grams,
  }) {
    return AppLocalizations.of(navigatorKey.currentContext!)!.grams; //'Grams';
  }

  static Future<void> openServiceUrl({
    required String serviceUrl,
  }) async {
    try {
      final Uri url = Uri.parse(serviceUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Toasts.getWarningToast(text: "Could not launch $url");
      }
    } catch (e) {
      Toasts.getWarningToast(text: "Could not launch $e");
    }
  }

  /// open whatsapp url
  static Future<void> openWhatsappUrl({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final link = WhatsAppUnilink(
        phoneNumber: phoneNumber,
        text: message,
      );

      if (!await launchUrl(
        link.asUri(),
        mode: LaunchMode.externalApplication,
      )) {
        Toasts.getWarningToast(text: "Could not launch $link");
      }
    } catch (e) {
      Toasts.getWarningToast(text: "Could not launch $e");
    }
  }

  static Future<void> openEmailApp({
    required String emailAddress,
    String subject = '',
    String body = '',
  }) async {
    // Validate email address
    if (emailAddress.isEmpty ||
        !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailAddress)) {
      Toasts.getWarningToast(text: 'Invalid email address');
      return;
    }
    final emailUri = Uri.parse(
      "mailto:$emailAddress?subject=$subject&body=$body",
    );

    try {
      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch');
      }
    } catch (e, stackTrace) {
      debugPrint('Error opening email app: $e\n$stackTrace');
      Toasts.getWarningToast(
        text: 'Failed to open email app. Please try again.',
      );
    }
  }

  /// open calling url
  static Future<void> openCallingUrl({
    required String phoneNumber,
  }) async {
    try {
      final Uri url = Uri.parse("tel:$phoneNumber");
      if (!await launchUrl(url)) {
        Toasts.getWarningToast(text: "Could not launch $url");
      }
    } catch (e) {
      Toasts.getWarningToast(text: "Could not launch $e");
    }
  }

  /// share content
  // static Future<void> shareContent({
  //   required String content,
  // }) async {
  //   try {
  //     final result = await Share.share(content);
  //     if (result.status == ShareResultStatus.success) {
  //       debugPrint('Thank you for sharing my website!');
  //     }
  //   } catch (e) {
  //     Toasts.getWarningToast(text: "Could not share $e");
  //   }
  // }

  /// Opens Google Maps or Apple Maps depending on the platform.
  static Future<void> openMap({
    required double currentLatitude,
    required double currentLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$currentLatitude,$currentLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';

    String appleUrl =
        'https://maps.apple.com/?saddr=$currentLatitude,$currentLongitude&daddr=$destinationLatitude,$destinationLongitude';

    try {
      if (Platform.isIOS) {
        final Uri url = Uri.parse(appleUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          Toasts.getWarningToast(text: "Could not launch $url");
        }
      } else {
        final Uri url = Uri.parse(googleUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          Toasts.getWarningToast(text: "Could not launch $url");
        }
      }
    } catch (e) {
      Toasts.getWarningToast(text: "Could not launch $e");
    }
  }

  /// calculate distance in miles
  static double calculateDistanceInMiles({
    required double startLatitude,
    required double startLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    /// Radius of the Earth in miles
    const int radiusOfEarthInMiles = 3958;

    /// Convert latitude and longitude from degrees to radians
    double startLatRad = startLatitude * (math.pi / 180);
    double startLngRad = startLongitude * (math.pi / 180);
    double destLatRad = destinationLatitude * (math.pi / 180);
    double destLngRad = destinationLongitude * (math.pi / 180);

    /// Haversine formula
    double latDiff = destLatRad - startLatRad;
    double lngDiff = destLngRad - startLngRad;

    double a =
        math.sin(latDiff / 2) * math.sin(latDiff / 2) +
        math.cos(startLatRad) *
            math.cos(destLatRad) *
            math.sin(lngDiff / 2) *
            math.sin(lngDiff / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    /// Distance in miles
    return radiusOfEarthInMiles * c;
  }

  static String formatNumber({required double number}) {
    final n = number.round();
    if (n >= 1e9) {
      return '${(n / 1e9).round()}B';
    } else if (n >= 1e6) {
      return '${(n / 1e6).round()}M';
    } else if (n >= 1e3) {
      return '${(n / 1e3).round()}K';
    } else {
      return n.toString();
    }
  }
}
