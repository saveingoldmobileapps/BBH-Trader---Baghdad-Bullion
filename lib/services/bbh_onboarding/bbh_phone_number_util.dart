/// Normalizes onboarding contact phone numbers for API submission.
class BbhPhoneNumberUtil {
  BbhPhoneNumberUtil._();

  /// Strips spaces/dashes for validation and API calls.
  static String compact(String input) =>
      input.trim().replaceAll(RegExp(r'[\s\-()]'), '');

  /// Converts user input (+ / 00 / local) to API `00` international format.
  static String toApiFormat(String input) {
    var phone = compact(input);
    if (phone.isEmpty) return phone;

    if (phone.startsWith('+')) {
      phone = '00${phone.substring(1)}';
    }

    // Iraq local mobile — 07XXXXXXXXX
    if (phone.startsWith('07') && phone.length == 11) {
      return '00964${phone.substring(1)}';
    }

    return phone;
  }

  /// Accepts `00…`, `+…`, or Iraqi local `07…`.
  static bool isValidInput(String input) {
    final phone = compact(input);
    if (phone.isEmpty) return false;
    if (RegExp(r'^00\d{10,15}$').hasMatch(phone)) return true;
    if (RegExp(r'^\+\d{10,15}$').hasMatch(phone)) return true;
    if (RegExp(r'^07\d{9}$').hasMatch(phone)) return true;
    return false;
  }
}
