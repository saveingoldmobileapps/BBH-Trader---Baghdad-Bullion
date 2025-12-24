import 'package:flutter/widgets.dart';
import 'package:saveingold_fzco/core/extensions/extensions.dart';
import 'package:saveingold_fzco/main.dart';

import '../l10n/app_localizations.dart';

class ValidatorUtils {
  // static String? validateEmailOrPhone(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return AppLocalizations.of(
  //       navigatorKey.currentContext!,
  //     )!.please_enter_password;
  //     //  'Please enter email or phone number';
  //   }

  //   // Digits only: treat as phone number
  //   if (RegExp(r'^[0-9]+$').hasMatch(value)) {
  //     String phone = value;

  //     // UAE
  //     if (phone.startsWith('00971')) {
  //       if (phone.length != 14) {
  //         return 'Enter 14-digit UAE number starting with 00971';
  //       }
  //       return null;
  //     }
  //     if (phone.startsWith('00964')) {
  //       if (phone.length != 15) {
  //         return 'Enter 15-digit IRAQ number starting with 00964';
  //       }
  //     }
  //     if (phone.startsWith('05')) {
  //       if (phone.length != 10) {
  //         return 'Enter 10-digit UAE number starting with 05';
  //       }
  //       return null;
  //     }

  //     // Jordan
  //     if (phone.startsWith('00962')) {
  //       if (phone.length != 14) {
  //         return 'Enter 14-digit Jordan number starting with 00962';
  //       }
  //       return null;
  //     }
  //     if (phone.startsWith('07')) {
  //       if (phone.length != 10 || !RegExp(r'^07[789]').hasMatch(phone)) {
  //         return 'Enter 10-digit Jordan number starting with 07 followed by 7, 8 or 9';
  //       }
  //       return null;
  //     }

  //     // Iraq
  //     if (phone.startsWith('00964')) {
  //       if (phone.length != 14) {
  //         return 'Enter 14-digit Iraq number starting with 00964';
  //       }
  //       return null;
  //     }
  //     if (phone.startsWith('07')) {
  //       if (phone.length != 10) {
  //         return 'Enter 10-digit Iraq number starting with 07';
  //       }
  //       return null;
  //     }

  //     return 'Please Use 05 or 07 for local and 009 intl. format';
  //   }

  //   // Validate email
  //   if (!value.validateEmail()) {
  //     return 'Invalid email format';
  //   }

  //   return null;
  // }
  // static String? validateEmailOrPhone(String? value) {
  // if (value == null || value.isEmpty) {
  //   return AppLocalizations.of(
  //     navigatorKey.currentContext!,
  //   )!
  //       .enter_email_phone;
  // }

  //   // 🔹 Normalize: remove spaces/dashes and replace + with 00
  //   String phone = value.replaceAll(RegExp(r'[\s-]'), '');
  //   if (phone.startsWith('+')) {
  //     phone = phone.replaceFirst('+', '00');
  //   }

  //   // Digits only → treat as phone number
  //   if (RegExp(r'^[0-9]+$').hasMatch(phone)) {
  //     // -------- UAE --------
  //     if (phone.startsWith('00971')) {
  //       return phone.length == 14
  //           ? null
  //           : AppLocalizations.of(navigatorKey.currentContext!)!
  //       .uae_num_14;//'Enter UAE number starting with 00971 or +971.';
  //     }
  //     // if (phone.startsWith('05')) {
  //     //   return phone.length == 10
  //     //       ? null
  //     //       : 'Enter 10-digit UAE number starting with 05';
  //     // }

  //     // -------- Jordan (International) --------
  //     if (phone.startsWith('00962')) {
  //       return phone.length == 14
  //           ? null
  //           : AppLocalizations.of(navigatorKey.currentContext!)!
  //       .jordan_num_14;//'Enter Jordan number starting with 00962 or +962.';
  //     }
  //     // -------- Saudi Arabia (International) --------
  //     if (phone.startsWith('00966') || phone.startsWith('+966')) {
  //       return phone.length == 14
  //           ? null
  //           : AppLocalizations.of(navigatorKey.currentContext!)!
  //       .saudia_num_14;//'Enter Saudi number starting with 00966 or +966.';
  //     }
  //     // -------- Iraq (International) --------
  //     if (phone.startsWith('00964')) {
  //       return phone.length == 15
  //           ? null
  //           : AppLocalizations.of(navigatorKey.currentContext!)!
  //       .iraq_num_15;//'Enter Iraq number starting with 00964 or +964.';
  //     }

  //     // -------- Local numbers for Jordan & Iraq --------
  //     if (phone.startsWith('07 || 05 || 0')) {
  //       if (phone.length == 10 || phone.length == 11) {
  //         return null; // ✅ Accept both Jordan(10) and Iraq(11)
  //       } else {
  //         return AppLocalizations.of(navigatorKey.currentContext!)!
  //       .phone_format_note;//'Please use +9XX or 009XXX..  format';
  //       }
  //     }

  //     return AppLocalizations.of(navigatorKey.currentContext!)!
  //       .phone_format_note;//'Please use +9XX or 009XXX..  format';
  //   }

  //   // -------- Email --------
  //   if (!value.validateEmail()) {
  //     return AppLocalizations.of(navigatorKey.currentContext!)!
  //       .invalid_email;//'Invalid email format';
  //   }

  //   return null;
  // }
static String? validateEmailOrPhone(String? value) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(
      navigatorKey.currentContext!,
    )!
        .enter_email_phone;
  }

  // 🔹 Normalize: remove spaces/dashes and replace + with 00
  String phone = value.replaceAll(RegExp(r'[\s-]'), '');
  if (phone.startsWith('+')) {
    phone = phone.replaceFirst('+', '00');
  }

  // 🔹 Digits only → treat as phone number
  if (RegExp(r'^[0-9]+$').hasMatch(phone)) {
    // -------- Allow all international formats --------
    if (phone.startsWith('00')) {
      // Accept numbers starting with 00 followed by country code (min length 8 to max 15 digits)
      if (phone.length >= 8 && phone.length <= 16) {
        return null;
      } else {
        return AppLocalizations.of(navigatorKey.currentContext!)!
            .phone_format_note; // "Please enter a valid international number starting with 00 or +"
      }
    }

    // -------- Local formats (like 05, 07, or 0) --------
    if (phone.startsWith('05') || phone.startsWith('07') || phone.startsWith('0')) {
      if (phone.length >= 9 && phone.length <= 11) {
        return null;
      } else {
        return AppLocalizations.of(navigatorKey.currentContext!)!
            .phone_format_note; // "Please use +9XX or 009XXX format"
      }
    }

    // -------- Default fallback for phone --------
    return AppLocalizations.of(navigatorKey.currentContext!)!
        .phone_format_note; // "Please use +9XX or 009XXX format"
  }

  // -------- Email validation --------
  if (!value.validateEmail()) {
    return AppLocalizations.of(navigatorKey.currentContext!)!
        .invalid_email; // "Invalid email format"
  }

  return null;
}

  static String? validateGiftEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter email or phone number";
    }

    // 🔹 Normalize + to 00
    String normalizedValue =
        value.startsWith('+') ? value.replaceFirst('+', '00')
        : value;

    // Digits only → must start with 009
    if (RegExp(r'^[0-9]+$').hasMatch(normalizedValue)) {
      if (!normalizedValue.startsWith('009')) {
        return 'Please enter number in international format starting with 009 or +9XX';
      }

      // UAE (00971XXXXXXXXX → 14 digits)
      if (normalizedValue.startsWith('00971') && normalizedValue.length != 14) {
        return 'Enter UAE number starting with 00971 or +971';
      }

      // Saudia (00971XXXXXXXXX → 14 digits)
      if (normalizedValue.startsWith('00966') && normalizedValue.length != 14) {
        return 'Enter Saudia number starting with 00966 or +966';
      }

      // Jordan (00962XXXXXXXXX → 14 digits)
      if (normalizedValue.startsWith('00962') && normalizedValue.length != 14) {
        return 'Enter Jordan number starting with 00962 or +962';
      }

      // Iraq (00964XXXXXXXXX → 15 digits)
      if (normalizedValue.startsWith('00964') && normalizedValue.length != 15) {
        return 'Enter Iraq number starting with 00964 or +964';
      }

      return null; // ✅ valid international format
    }

    // Otherwise → Validate email
    if (!value.validateEmail()) {
      return 'Invalid email format';
    }

    return null; // ✅ valid email
  }

  // ---------------- EMAIL ----------------
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(
        navigatorKey.currentContext!,
      )!.please_enter_email;
    }

    if (!value.validateEmail()) {
      return "Invalid Email";
    }

    return null;
  }

  // ---------------- PHONE ----------------
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please Enter phone number";
    }

    // 🔹 Normalize: remove spaces/dashes and replace + with 00
    String phone = value.replaceAll(RegExp(r'[\s-]'), '');
    if (phone.startsWith('+')) {
      phone = phone.replaceFirst('+', '00');
    }

    // Digits only
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return "Invalid phone number";
    }

    // -------- UAE --------
    if (phone.startsWith('00971')) {
      return phone.length == 14
          ? null
          : 'Enter UAE number starting with 00971 or +971.';
    }

    // -------- Jordan --------
    if (phone.startsWith('00962')) {
      return phone.length == 14
          ? null
          : 'Enter Jordan number starting with 00962 or +962.';
    }

    // -------- Iraq --------
    if (phone.startsWith('00964')) {
      return phone.length == 15
          ? null
          : 'Enter 15-digit Iraq number starting with 00964 or +964.';
    }

    // -------- Saudi Arabia --------
    if (phone.startsWith('00966')) {
      return phone.length == 14
          ? null
          : 'Enter Saudi number starting with 00966 or +966.';
    }

    // -------- Local numbers (Jordan, Iraq, Saudi, UAE) --------
    if (phone.startsWith('07') ||
        phone.startsWith('05') ||
        phone.startsWith('0')) {
      if (phone.length == 10 || phone.length == 11) {
        return null;
      } else {
        return 'Please use +9XX or 009XXX.. format';
      }
    }

    return 'Please use +9XX or 009XXX.. format';
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your name";
    }

    // Remove extra spaces
    String name = value.trim();

    // Allow only letters (English/Arabic) and spaces, min 2 chars, max 50
    final nameRegex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s]{2,50}$");

    if (!nameRegex.hasMatch(name)) {
      return "Name should only contain letters and spaces (2–50 characters)";
    }

    return null; 
  }
}
