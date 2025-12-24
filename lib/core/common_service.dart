import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveingold_fzco/core/push_notification_service/firebase_push_notification_service.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart'
    show LocalDatabase;
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/main.dart';
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

  /// calculate weight price
  static double calculateWeightPrice({
    required String? weightFactor,
    required double oneGramSellingPrice,
  }) {
    final weight = double.tryParse(weightFactor ?? "0.0") ?? 0.0;
    return double.parse((weight * oneGramSellingPrice).toStringAsFixed(2));
  }

  /// format currency
  static String formatCurrency({
    required String amount,
  }) {
    final amountInDouble = double.tryParse(amount) ?? 0.0;
    if (amountInDouble >= 10000) {
      return "${(amountInDouble / 1000).toStringAsFixed(2)}K"; // Keep 3 decimal places in large values
    }

    final formatter = NumberFormat("#,##0.00", "en_US");
    return formatter.format(amountInDouble);
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
      userType: userType ==true? "Demo": "Real"
    );
  }

  static String formatDateTime(BuildContext context, String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate).toLocal();
      String locale = Localizations.localeOf(context).languageCode == 'ar'
          ? 'ar'
          : 'en';
      DateFormat formatter = DateFormat("dd MMM yyyy HH:mm", locale);
      return formatter.format(parsedDate);
    } catch (e) {
      return isoDate;
    }
  }

  /// get once gram price in aed
  static double getOneGramPriceInAED({
    required double ounceDollarPrice,
    required double dirham,
    required double ounce,
  }) {
    return ((ounceDollarPrice * dirham) / ounce);
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
    if (num < 1000) {
      return num.toStringAsFixed(
        2,
      ); // Ensures two decimal places for smaller numbers
    } else if (num < 1000000) {
      return '${(num / 1000).toStringAsFixed(2)}K'; // Three decimal places for thousands
    } else if (num < 1000000000) {
      return '${(num / 1000000).toStringAsFixed(2)}M'; // Three decimal places for millions
    } else {
      return num.toStringAsFixed(2); // Shows full value for numbers < 1M
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
      return '${num.toStringAsFixed(2)} ${AppLocalizations.of(context)!.metal_g}';
    } else {
      return '${(num / 1000).toStringAsFixed(1)} kg';
    }
  }

  /// convert weight
  static String convertWeight({
    required double grams,
  }) {
    if (grams < 3.8) {
      // 1 tola is approximately equal to 11.66 grams, but in gold, 1 tola is equal to 11.66/1000 = 0.01166 kg, that is 11.66 grams
      return (grams * 1000 / 11.66).toStringAsFixed(2);
    } else if (grams < 28.35) {
      // 1 ounce is equal to 28.35 grams
      return (grams / 28.35).toStringAsFixed(2);
    } else if (grams < 1000) {
      return grams.toStringAsFixed(2);
    } else {
      // return grams.toStringAsFixed(2);
      return (grams / 1000).toStringAsFixed(2);
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
    if (number >= 1e9) {
      // Convert to billions (B)
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      // Convert to millions (M)
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      // Convert to thousands (K)
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      // Return the number as is if it's less than 1,000
      return number.toStringAsFixed(1);
    }
  }
}
