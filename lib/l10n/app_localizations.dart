import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @wealth.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get wealth;

  /// No description provided for @gs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Seamlessly buy, sell, and grow your gold portfolio with the platform you trust.'**
  String get gs_subtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @app_lang.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get app_lang;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome_back;

  /// No description provided for @welcome_back1.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome_back1;

  /// No description provided for @gateway_text.
  ///
  /// In en, this message translates to:
  /// **'Your gateway to secure and seamless gold trading.'**
  String get gateway_text;

  /// No description provided for @gateway_text2.
  ///
  /// In en, this message translates to:
  /// **'Trade Gold Securely, Anytime, Anywhere.'**
  String get gateway_text2;

  /// No description provided for @email_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get email_or_phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Dont have an account?'**
  String get dont_have_account;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// No description provided for @forgotPassword_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword_title;

  /// No description provided for @instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number below to receive the instructions to change your password'**
  String get instruction;

  /// No description provided for @change_passwordbtn.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_passwordbtn;

  /// No description provided for @demo_mode.
  ///
  /// In en, this message translates to:
  /// **'Note: You are in Demo mode'**
  String get demo_mode;

  /// No description provided for @createAccount_title.
  ///
  /// In en, this message translates to:
  /// **'Start Your Gold Journey'**
  String get createAccount_title;

  /// No description provided for @createAccount_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your gateway to secure and seamless gold trading.'**
  String get createAccount_subtitle;

  /// No description provided for @createAccount_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning: For quick verification, please ensure that your documents first name, surname, and date of birth match the details you provide. Otherwise, face verification may fail.'**
  String get createAccount_warning;

  /// No description provided for @real_accountToggle.
  ///
  /// In en, this message translates to:
  /// **'Real Account'**
  String get real_accountToggle;

  /// No description provided for @demo_accountToggle.
  ///
  /// In en, this message translates to:
  /// **'Demo Account'**
  String get demo_accountToggle;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name (Legal Name)'**
  String get first_name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname (Legal Name)'**
  String get surname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @select_amount.
  ///
  /// In en, this message translates to:
  /// **'Select Amount'**
  String get select_amount;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Combine uppercase/lowercase letters, numbers and special characters.'**
  String get password_hint;

  /// No description provided for @create_accountbtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_accountbtn;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @loginlink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginlink;

  /// No description provided for @agreement_text.
  ///
  /// In en, this message translates to:
  /// **'By Creating Account, I agree to SaveInGold Terms & Conditions and Privacy Policy'**
  String get agreement_text;

  /// No description provided for @uae_num_reg.
  ///
  /// In en, this message translates to:
  /// **'UAE number must be 9 digit.'**
  String get uae_num_reg;

  /// No description provided for @uae_num_str.
  ///
  /// In en, this message translates to:
  /// **'UAE number must start with 5.'**
  String get uae_num_str;

  /// No description provided for @saudia_num.
  ///
  /// In en, this message translates to:
  /// **'Saudia Arabia number must be 9 digit.'**
  String get saudia_num;

  /// No description provided for @saudia_num_str.
  ///
  /// In en, this message translates to:
  /// **'Saudia Arabia number must start with 5.'**
  String get saudia_num_str;

  /// No description provided for @jordan_num.
  ///
  /// In en, this message translates to:
  /// **'Jordan number must be 9 digits.'**
  String get jordan_num;

  /// No description provided for @jordan_num_str.
  ///
  /// In en, this message translates to:
  /// **'Jordan number must start with 7.'**
  String get jordan_num_str;

  /// No description provided for @iraq_num.
  ///
  /// In en, this message translates to:
  /// **'Iraq number must be 10 digits.'**
  String get iraq_num;

  /// No description provided for @iraq_num_str.
  ///
  /// In en, this message translates to:
  /// **'Iraq number must start with 7.'**
  String get iraq_num_str;

  /// No description provided for @invalid_message_phone.
  ///
  /// In en, this message translates to:
  /// **'Invalid country code.'**
  String get invalid_message_phone;

  /// No description provided for @kyc_tell_us_about_ur.
  ///
  /// In en, this message translates to:
  /// **'Tell us about Yourself'**
  String get kyc_tell_us_about_ur;

  /// No description provided for @kyc_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get kyc_refresh;

  /// No description provided for @kyc_information.
  ///
  /// In en, this message translates to:
  /// **'Following information should match the information on the document you provide.'**
  String get kyc_information;

  /// No description provided for @kyc_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get kyc_dob;

  /// No description provided for @kyc_enter_dob.
  ///
  /// In en, this message translates to:
  /// **'Please enter date of birth'**
  String get kyc_enter_dob;

  /// No description provided for @kyc_res_cont.
  ///
  /// In en, this message translates to:
  /// **'Country of Residence'**
  String get kyc_res_cont;

  /// No description provided for @kyc_plz_select_resd.
  ///
  /// In en, this message translates to:
  /// **'Please select residency'**
  String get kyc_plz_select_resd;

  /// No description provided for @kyc_nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get kyc_nationality;

  /// No description provided for @kyc_plz_select_cont.
  ///
  /// In en, this message translates to:
  /// **'Please select nationality'**
  String get kyc_plz_select_cont;

  /// No description provided for @kyc_doc_success.
  ///
  /// In en, this message translates to:
  /// **'Document added successfully!'**
  String get kyc_doc_success;

  /// No description provided for @kyc_upload_proof.
  ///
  /// In en, this message translates to:
  /// **'Upload residency proof (Optional)'**
  String get kyc_upload_proof;

  /// No description provided for @kyc_utility_bill.
  ///
  /// In en, this message translates to:
  /// **'Utility Bill or Bank Statement'**
  String get kyc_utility_bill;

  /// No description provided for @kyc_allowed_format.
  ///
  /// In en, this message translates to:
  /// **'Allowed Format PDF'**
  String get kyc_allowed_format;

  /// No description provided for @kyc_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get kyc_select;

  /// No description provided for @kyc_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit KYC:'**
  String get kyc_failed;

  /// No description provided for @kyc_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get kyc_skip;

  /// No description provided for @kyc_identity.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kyc_identity;

  /// No description provided for @kyc_na_id.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get kyc_na_id;

  /// No description provided for @kyc_em_id.
  ///
  /// In en, this message translates to:
  /// **'Emirates ID'**
  String get kyc_em_id;

  /// No description provided for @kyc_driving.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get kyc_driving;

  /// No description provided for @kyc_passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get kyc_passport;

  /// No description provided for @kyc_get_st.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get kyc_get_st;

  /// No description provided for @kyc_country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get kyc_country;

  /// No description provided for @kyc_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload a'**
  String get kyc_upload;

  /// No description provided for @kyc_govt.
  ///
  /// In en, this message translates to:
  /// **'government'**
  String get kyc_govt;

  /// No description provided for @kyc_issue.
  ///
  /// In en, this message translates to:
  /// **'issued ID to verify your identity securely. Following documents are accepted:'**
  String get kyc_issue;

  /// No description provided for @ky_selec_cont.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get ky_selec_cont;

  /// No description provided for @kyc_select_either.
  ///
  /// In en, this message translates to:
  /// **'Select either'**
  String get kyc_select_either;

  /// No description provided for @kyc_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get kyc_or;

  /// No description provided for @kyc_select_nat.
  ///
  /// In en, this message translates to:
  /// **'Select your nationality'**
  String get kyc_select_nat;

  /// No description provided for @kyc_selct_res.
  ///
  /// In en, this message translates to:
  /// **'Select your residency'**
  String get kyc_selct_res;

  /// No description provided for @kyc_cancellled.
  ///
  /// In en, this message translates to:
  /// **'Your Kyc Cancelled'**
  String get kyc_cancellled;

  /// No description provided for @kyc_update_info.
  ///
  /// In en, this message translates to:
  /// **'Update Your Information'**
  String get kyc_update_info;

  /// No description provided for @kyc_some_detail.
  ///
  /// In en, this message translates to:
  /// **'Some of your details are invalid. Please make sure your'**
  String get kyc_some_detail;

  /// No description provided for @kyc_match_official.
  ///
  /// In en, this message translates to:
  /// **'match your official records.'**
  String get kyc_match_official;

  /// No description provided for @kyc_uhave_cancelled.
  ///
  /// In en, this message translates to:
  /// **'You have cancelled the verification,\nGo to home screen and start KYC again.'**
  String get kyc_uhave_cancelled;

  /// No description provided for @kyc_go_home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get kyc_go_home;

  /// No description provided for @kyc_update_inf.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get kyc_update_inf;

  /// No description provided for @kyc_first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get kyc_first_name;

  /// No description provided for @kyc_enter_firstname.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get kyc_enter_firstname;

  /// No description provided for @kyc_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get kyc_last_name;

  /// No description provided for @kyc_enter_lastname.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get kyc_enter_lastname;

  /// No description provided for @name_does_not_match.
  ///
  /// In en, this message translates to:
  /// **'Name does not match KYC records (English:'**
  String get name_does_not_match;

  /// No description provided for @arabic_n.
  ///
  /// In en, this message translates to:
  /// **'Arabic:'**
  String get arabic_n;

  /// No description provided for @name_kyc.
  ///
  /// In en, this message translates to:
  /// **'Name does not match KYC records:'**
  String get name_kyc;

  /// No description provided for @name_native.
  ///
  /// In en, this message translates to:
  /// **'Name does not match KYC records:'**
  String get name_native;

  /// No description provided for @dob_kyc.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth does not match KYC records:'**
  String get dob_kyc;

  /// No description provided for @residency_kyc.
  ///
  /// In en, this message translates to:
  /// **'Country of Residence does not match KYC records:'**
  String get residency_kyc;

  /// No description provided for @nationality_kyc.
  ///
  /// In en, this message translates to:
  /// **'Nationality does not match KYC records:'**
  String get nationality_kyc;

  /// No description provided for @no_change_detected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected. Please update information if needed.'**
  String get no_change_detected;

  /// No description provided for @please_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get please_enter_password;

  /// No description provided for @invalid_email_or_password.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalid_email_or_password;

  /// No description provided for @please_enter_email_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter email or phone number'**
  String get please_enter_email_or_phone;

  /// No description provided for @please_enter_first_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get please_enter_first_name;

  /// No description provided for @please_enter_surname.
  ///
  /// In en, this message translates to:
  /// **'Please enter surname'**
  String get please_enter_surname;

  /// No description provided for @please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get please_enter_email;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalid_email;

  /// No description provided for @please_enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get please_enter_phone_number;

  /// No description provided for @password_complexity_requirement.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, including capital letter, digit, and special character'**
  String get password_complexity_requirement;

  /// No description provided for @incorrect_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrect_password;

  /// No description provided for @please_select_amount.
  ///
  /// In en, this message translates to:
  /// **'Please select an amount'**
  String get please_select_amount;

  /// No description provided for @confirm_pwd.
  ///
  /// In en, this message translates to:
  /// **'Password do not match, Please re-enter confirm paswword.'**
  String get confirm_pwd;

  /// No description provided for @agreement_prefix.
  ///
  /// In en, this message translates to:
  /// **'By Creating Account, I agree to SaveInGold '**
  String get agreement_prefix;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_and_conditions;

  /// No description provided for @agreement_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get agreement_and;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @my_account.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account;

  /// No description provided for @hide_balance.
  ///
  /// In en, this message translates to:
  /// **'Hide Balance'**
  String get hide_balance;

  /// No description provided for @show_balance.
  ///
  /// In en, this message translates to:
  /// **'Show Balance'**
  String get show_balance;

  /// No description provided for @total_gold_grams.
  ///
  /// In en, this message translates to:
  /// **'Total Gold ( Grams )'**
  String get total_gold_grams;

  /// No description provided for @total_funds_aed.
  ///
  /// In en, this message translates to:
  /// **'Total Funds (AED)'**
  String get total_funds_aed;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @latest_news.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latest_news;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @oops_no_news.
  ///
  /// In en, this message translates to:
  /// **'Oops! No news available'**
  String get oops_no_news;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @no_news.
  ///
  /// In en, this message translates to:
  /// **'No News Available'**
  String get no_news;

  /// No description provided for @check_back.
  ///
  /// In en, this message translates to:
  /// **'Check back later for updates'**
  String get check_back;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @investTab.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get investTab;

  /// No description provided for @gramsTab.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get gramsTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @account_details.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get account_details;

  /// No description provided for @deposit_funds.
  ///
  /// In en, this message translates to:
  /// **'Deposit Funds'**
  String get deposit_funds;

  /// No description provided for @withdraw_requests.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Requests'**
  String get withdraw_requests;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @esouq.
  ///
  /// In en, this message translates to:
  /// **'E-Souq'**
  String get esouq;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @e_souq.
  ///
  /// In en, this message translates to:
  /// **'Esouq'**
  String get e_souq;

  /// No description provided for @customer_support_title.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customer_support_title;

  /// No description provided for @email_us_title.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get email_us_title;

  /// No description provided for @email_us_desc.
  ///
  /// In en, this message translates to:
  /// **'Need instant help? Start an Email Us with our team, available 24/7!'**
  String get email_us_desc;

  /// No description provided for @email_now.
  ///
  /// In en, this message translates to:
  /// **'Email Now'**
  String get email_now;

  /// No description provided for @call_us_title.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get call_us_title;

  /// No description provided for @call_us_desc.
  ///
  /// In en, this message translates to:
  /// **'Speak directly with one of our support representatives, available Monday to Saturday, 10:00 AM - 6:00 PM (UAE Time).'**
  String get call_us_desc;

  /// No description provided for @call_now.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get call_now;

  /// No description provided for @whatsapp_title.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsapp_title;

  /// No description provided for @whatsapp_desc.
  ///
  /// In en, this message translates to:
  /// **'Message us on WhatsApp for quick and easy support, available 24/7.'**
  String get whatsapp_desc;

  /// No description provided for @message_on_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Message on Whatsapp'**
  String get message_on_whatsapp;

  /// No description provided for @whatsapp_inbox.
  ///
  /// In en, this message translates to:
  /// **'Hi Save In Gold Sales Team, \n\nTo confirm and process your payment, please attach a copy of the payment receipt to this WhatsApp message. \n\nThis will help us verify the transaction and update your account accordingly.\nYou can simply reply to this email with the receipt attached. If you have any questions or concerns, feel free to reach out to us.\n\nRegards,\nSave In Gold Team.'**
  String get whatsapp_inbox;

  /// No description provided for @email_message.
  ///
  /// In en, this message translates to:
  /// **'Hi Save In Gold Sales Team, \n\nTo confirm and process your payment, please attach a copy of the payment receipt to this email. \n\nThis will help us verify the transaction and update your account accordingly.\nYou can simply reply to this email with the receipt attached. If you have any questions or concerns, feel free to reach out to us.\n\nRegards,\nSave In Gold Team.'**
  String get email_message;

  /// No description provided for @email_url_title.
  ///
  /// In en, this message translates to:
  /// **'Direct Bank Transfer Payment Receipt'**
  String get email_url_title;

  /// No description provided for @biometric_title.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric_title;

  /// No description provided for @biometric_unlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometric_unlock;

  /// No description provided for @remove_biometric.
  ///
  /// In en, this message translates to:
  /// **'Remove Biometric'**
  String get remove_biometric;

  /// No description provided for @face_id_title.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get face_id_title;

  /// No description provided for @face_unlock.
  ///
  /// In en, this message translates to:
  /// **'Face Unlock'**
  String get face_unlock;

  /// No description provided for @remove_face_id.
  ///
  /// In en, this message translates to:
  /// **'Remove Face ID'**
  String get remove_face_id;

  /// No description provided for @remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove_title;

  /// No description provided for @data_remove.
  ///
  /// In en, this message translates to:
  /// **'Your Biometric data will be removed.'**
  String get data_remove;

  /// No description provided for @rem_fa_id.
  ///
  /// In en, this message translates to:
  /// **'Remove Face ID?'**
  String get rem_fa_id;

  /// No description provided for @wont_able_f_id.
  ///
  /// In en, this message translates to:
  /// **'You won\'\'t be able to login through Face recognition.'**
  String get wont_able_f_id;

  /// No description provided for @timezone_title.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone_title;

  /// No description provided for @timezone_error.
  ///
  /// In en, this message translates to:
  /// **'Timezone not selected please select timezone'**
  String get timezone_error;

  /// No description provided for @timezone_label.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone_label;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @personalInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo_title;

  /// No description provided for @pi_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Updating personal info will temporarily restrict transactions until approved by our support team.'**
  String get pi_warning;

  /// No description provided for @pi_first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name (Legal Name)'**
  String get pi_first_name;

  /// No description provided for @pi_surname.
  ///
  /// In en, this message translates to:
  /// **'Surname (Legal Name)'**
  String get pi_surname;

  /// No description provided for @pi_email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get pi_email;

  /// No description provided for @pi_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get pi_phone_number;

  /// No description provided for @pi_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get pi_update;

  /// No description provided for @pi_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pi_cancel;

  /// No description provided for @pi_phone_exists.
  ///
  /// In en, this message translates to:
  /// **'Phone number already exists, Try a new one!'**
  String get pi_phone_exists;

  /// No description provided for @pi_email_exists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists, Try a new one!'**
  String get pi_email_exists;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get good_evening;

  /// No description provided for @request_sent.
  ///
  /// In en, this message translates to:
  /// **'The OTP sent successfully'**
  String get request_sent;

  /// No description provided for @delete_account_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account_title;

  /// No description provided for @delete_account_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Deleting your account is permanent. All of your data will be permanently erased and cannot be restored. Are you sure you want to continue?'**
  String get delete_account_warning;

  /// No description provided for @delete_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account_btn;

  /// No description provided for @delete_account_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get delete_account_cancel;

  /// No description provided for @logout_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_popup_title;

  /// No description provided for @logout_popup_desc.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out of your account.'**
  String get logout_popup_desc;

  /// No description provided for @logout_yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get logout_yes;

  /// No description provided for @logout_no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get logout_no;

  /// No description provided for @update_password_title.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password_title;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Enter Current Password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_new_password;

  /// No description provided for @update_password_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password_btn;

  /// No description provided for @val_enter_current_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get val_enter_current_password;

  /// No description provided for @val_enter_new_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get val_enter_new_password;

  /// No description provided for @val_enter_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm password'**
  String get val_enter_confirm_password;

  /// No description provided for @val_password_rules.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, and must include a capital letter, a number, and a special character.'**
  String get val_password_rules;

  /// No description provided for @val_passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Please re-enter confirm password.'**
  String get val_passwords_do_not_match;

  /// No description provided for @val_invalid_current_password.
  ///
  /// In en, this message translates to:
  /// **'Invalid Current Password'**
  String get val_invalid_current_password;

  /// No description provided for @moneytab.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneytab;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @noFriendsFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found.'**
  String get noFriendsFound;

  /// No description provided for @receiverAccNum.
  ///
  /// In en, this message translates to:
  /// **'Receiver Account Number'**
  String get receiverAccNum;

  /// No description provided for @valReceiverAccNum.
  ///
  /// In en, this message translates to:
  /// **'Please enter receiver account number'**
  String get valReceiverAccNum;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get receiverName;

  /// No description provided for @valReceiverName.
  ///
  /// In en, this message translates to:
  /// **'Please enter receiver name'**
  String get valReceiverName;

  /// No description provided for @receiverAccEmail.
  ///
  /// In en, this message translates to:
  /// **'Receiver Email/Phone'**
  String get receiverAccEmail;

  /// No description provided for @valReceiverAccEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter receiver email.'**
  String get valReceiverAccEmail;

  /// No description provided for @enter_gram.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount (grams) here'**
  String get enter_gram;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount (AED) here'**
  String get enter_amount;

  /// No description provided for @enter_amount_plz.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount.'**
  String get enter_amount_plz;

  /// No description provided for @enter_metal_plz.
  ///
  /// In en, this message translates to:
  /// **'Please enter metal in grams.'**
  String get enter_metal_plz;

  /// No description provided for @enter_correct_amount.
  ///
  /// In en, this message translates to:
  /// **'Please add correct amount.'**
  String get enter_correct_amount;

  /// No description provided for @no_deals_available.
  ///
  /// In en, this message translates to:
  /// **'No gram deals selected.'**
  String get no_deals_available;

  /// No description provided for @valid_quantitty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity.'**
  String get valid_quantitty;

  /// No description provided for @requested_quntity.
  ///
  /// In en, this message translates to:
  /// **'Requested quantity exceeds available grams.'**
  String get requested_quntity;

  /// No description provided for @gift_select_gram.
  ///
  /// In en, this message translates to:
  /// **'Select Gram Deal'**
  String get gift_select_gram;

  /// No description provided for @gift_gram_deal.
  ///
  /// In en, this message translates to:
  /// **'Gram Deal'**
  String get gift_gram_deal;

  /// No description provided for @gift_enter_qu.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity first'**
  String get gift_enter_qu;

  /// No description provided for @gift_please_choose.
  ///
  /// In en, this message translates to:
  /// **'Please choose a deal (Available :'**
  String get gift_please_choose;

  /// No description provided for @gift_leave_comment.
  ///
  /// In en, this message translates to:
  /// **'Leave a Comment'**
  String get gift_leave_comment;

  /// No description provided for @gift_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get gift_comment;

  /// No description provided for @gift_no_deal_selected.
  ///
  /// In en, this message translates to:
  /// **'No Gram Deals Selected, Please select at least one deal to continue.'**
  String get gift_no_deal_selected;

  /// No description provided for @gift_gram_deal_no.
  ///
  /// In en, this message translates to:
  /// **'Gram deals no selected.Please select deals'**
  String get gift_gram_deal_no;

  /// No description provided for @gift_account_not_found.
  ///
  /// In en, this message translates to:
  /// **'Account Details Not Found!'**
  String get gift_account_not_found;

  /// No description provided for @gift_account_not_match.
  ///
  /// In en, this message translates to:
  /// **'The account details you entered do not match our records. Please check your information and try again.'**
  String get gift_account_not_match;

  /// No description provided for @gift_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get gift_close;

  /// No description provided for @gift_go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get gift_go_back;

  /// No description provided for @gift_inavalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get gift_inavalid_amount;

  /// No description provided for @gitf_valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get gitf_valid_amount;

  /// No description provided for @gift_insufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get gift_insufficient;

  /// No description provided for @gift_add_fund.
  ///
  /// In en, this message translates to:
  /// **'Please add funds into your account to send money.'**
  String get gift_add_fund;

  /// No description provided for @gift_account_detail_found.
  ///
  /// In en, this message translates to:
  /// **'Account Details Found!'**
  String get gift_account_detail_found;

  /// No description provided for @gift_click_btn.
  ///
  /// In en, this message translates to:
  /// **'Click on the button below to complete this transaction.'**
  String get gift_click_btn;

  /// No description provided for @gift_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get gift_back;

  /// No description provided for @gift_friend_del_warning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to delete'**
  String get gift_friend_del_warning;

  /// No description provided for @gift_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get gift_search;

  /// No description provided for @gift_search_here.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get gift_search_here;

  /// No description provided for @gift_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get gift_selected;

  /// No description provided for @gift_target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get gift_target;

  /// No description provided for @gift_no_item.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get gift_no_item;

  /// No description provided for @gift_to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get gift_to;

  /// No description provided for @insufficient_gram_title.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Gram Selection'**
  String get insufficient_gram_title;

  /// No description provided for @ins_firt.
  ///
  /// In en, this message translates to:
  /// **'The selected gram deals ('**
  String get ins_firt;

  /// No description provided for @ins_sec.
  ///
  /// In en, this message translates to:
  /// **'g) don\'\'t cover the entered amount ('**
  String get ins_sec;

  /// No description provided for @ins_th.
  ///
  /// In en, this message translates to:
  /// **'g). Please select more deals or reduce the amount.'**
  String get ins_th;

  /// No description provided for @add_fund_to_buy.
  ///
  /// In en, this message translates to:
  /// **'Please add funds into your account to buy gold.'**
  String get add_fund_to_buy;

  /// No description provided for @enter_email_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter email or phone number'**
  String get enter_email_phone;

  /// No description provided for @phAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get phAmount;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @continu.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continu;

  /// No description provided for @accDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'Account Details Found!'**
  String get accDetailsFound;

  /// No description provided for @completeTransaction.
  ///
  /// In en, this message translates to:
  /// **'Complete Transaction'**
  String get completeTransaction;

  /// No description provided for @saveReceiverFriend.
  ///
  /// In en, this message translates to:
  /// **'Save receiver as Friend'**
  String get saveReceiverFriend;

  /// No description provided for @deleteReceiverFriend.
  ///
  /// In en, this message translates to:
  /// **'Delete receiver as Friend'**
  String get deleteReceiverFriend;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added successfully'**
  String get friendAdded;

  /// No description provided for @giftSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Gift Sent Successfully.'**
  String get giftSentSuccess;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @giftSentMsg.
  ///
  /// In en, this message translates to:
  /// **'You have successfully sent'**
  String get giftSentMsg;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnHome;

  /// No description provided for @dep_selectBank_title.
  ///
  /// In en, this message translates to:
  /// **'Select a bank'**
  String get dep_selectBank_title;

  /// No description provided for @dep_selectBank_sub.
  ///
  /// In en, this message translates to:
  /// **'Choose which bank to transfer the amount'**
  String get dep_selectBank_sub;

  /// No description provided for @dep_method_header.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get dep_method_header;

  /// No description provided for @dep_method_sub.
  ///
  /// In en, this message translates to:
  /// **'Select a Method'**
  String get dep_method_sub;

  /// No description provided for @dep_method_direct.
  ///
  /// In en, this message translates to:
  /// **'Direct Transfer'**
  String get dep_method_direct;

  /// No description provided for @dep_method_noFees.
  ///
  /// In en, this message translates to:
  /// **'No Fees'**
  String get dep_method_noFees;

  /// No description provided for @dep_method_card.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get dep_method_card;

  /// No description provided for @dep_method_google.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get dep_method_google;

  /// No description provided for @dep_fee_instantNote.
  ///
  /// In en, this message translates to:
  /// **'Instant Deposit, bank fees apply.'**
  String get dep_fee_instantNote;

  /// No description provided for @dep_amount_title.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount'**
  String get dep_amount_title;

  /// No description provided for @dep_min_amount_note.
  ///
  /// In en, this message translates to:
  /// **'Minimum deposit amount is AED 100, charges will apply'**
  String get dep_min_amount_note;

  /// No description provided for @dep_dt_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Direct Transfer'**
  String get dep_dt_intro_title;

  /// No description provided for @dep_dt_intro_desc.
  ///
  /// In en, this message translates to:
  /// **'A direct transfer works just like sending money through your banking app. The transaction typically takes 24 to 48 hours to be confirmed.'**
  String get dep_dt_intro_desc;

  /// No description provided for @dep_copyDetails.
  ///
  /// In en, this message translates to:
  /// **'Copy Details'**
  String get dep_copyDetails;

  /// No description provided for @dep_label_accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get dep_label_accountName;

  /// No description provided for @dep_label_accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get dep_label_accountNumber;

  /// No description provided for @dep_label_iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN Number'**
  String get dep_label_iban;

  /// No description provided for @dep_label_swift.
  ///
  /// In en, this message translates to:
  /// **'Swift'**
  String get dep_label_swift;

  /// No description provided for @dep_share_title.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get dep_share_title;

  /// No description provided for @dep_share_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose any of the options below to share the receipt once you’ve transferred the funds in Save In Gold FZCO account.'**
  String get dep_share_desc;

  /// No description provided for @dep_share_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share on Whatsapp'**
  String get dep_share_whatsapp;

  /// No description provided for @dep_share_email.
  ///
  /// In en, this message translates to:
  /// **'Send via Email'**
  String get dep_share_email;

  /// No description provided for @dep_toast_txSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully'**
  String get dep_toast_txSaved;

  /// No description provided for @dip_min_100.
  ///
  /// In en, this message translates to:
  /// **'Minimum deposit amount is AED 100'**
  String get dip_min_100;

  /// No description provided for @wait_please.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get wait_please;

  /// No description provided for @no_banks_available.
  ///
  /// In en, this message translates to:
  /// **'No banks available'**
  String get no_banks_available;

  /// No description provided for @withdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Funds'**
  String get withdrawTitle;

  /// No description provided for @amountReq.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountReq;

  /// No description provided for @bankReq.
  ///
  /// In en, this message translates to:
  /// **'Bank name is required'**
  String get bankReq;

  /// No description provided for @beneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Name'**
  String get beneficiary;

  /// No description provided for @beneficiaryReq.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary name is required'**
  String get beneficiaryReq;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN Number'**
  String get iban;

  /// No description provided for @ibanReq.
  ///
  /// In en, this message translates to:
  /// **'IBAN Account number is required'**
  String get ibanReq;

  /// No description provided for @ibanLength.
  ///
  /// In en, this message translates to:
  /// **'IBAN number must be between 23 and 30 characters'**
  String get ibanLength;

  /// No description provided for @withdrawBtn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawBtn;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Funds withdrawn successfully'**
  String get withdrawSuccess;

  /// No description provided for @withdrawSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get withdrawSuccessTitle;

  /// No description provided for @withdrawSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve successfully submitted your withdrawal request'**
  String get withdrawSuccessMsg;

  /// No description provided for @withdrawHomeBtn.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get withdrawHomeBtn;

  /// No description provided for @noWithdrawData.
  ///
  /// In en, this message translates to:
  /// **'Not found list of withdrawals'**
  String get noWithdrawData;

  /// No description provided for @enter_withdraw_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to be withdrawn'**
  String get enter_withdraw_amount;

  /// No description provided for @withdraw_digit.
  ///
  /// In en, this message translates to:
  /// **'Amount must be digits only'**
  String get withdraw_digit;

  /// No description provided for @withdraw_enter_bank_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Bank Name'**
  String get withdraw_enter_bank_name;

  /// No description provided for @withdraw_bank_name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get withdraw_bank_name;

  /// No description provided for @withdraw_only_alphabet.
  ///
  /// In en, this message translates to:
  /// **'Only alphabets are allowed'**
  String get withdraw_only_alphabet;

  /// No description provided for @withdraw_benf_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Beneficiary Name'**
  String get withdraw_benf_name;

  /// No description provided for @withdraw_only_alphabets.
  ///
  /// In en, this message translates to:
  /// **'Only alphabets are allowed'**
  String get withdraw_only_alphabets;

  /// No description provided for @withdraw_alphabet_char.
  ///
  /// In en, this message translates to:
  /// **'Must include both letters and digits'**
  String get withdraw_alphabet_char;

  /// No description provided for @withdraw_add_fund.
  ///
  /// In en, this message translates to:
  /// **'Please add funds into your account.'**
  String get withdraw_add_fund;

  /// No description provided for @bank_charge_message.
  ///
  /// In en, this message translates to:
  /// **'A bank fee of AED 25 plus VAT will be applied.'**
  String get bank_charge_message;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @edit_bank_card.
  ///
  /// In en, this message translates to:
  /// **'Edit Bank Card'**
  String get edit_bank_card;

  /// No description provided for @save_card_detail.
  ///
  /// In en, this message translates to:
  /// **'Save Card Details'**
  String get save_card_detail;

  /// No description provided for @no_save_card_found.
  ///
  /// In en, this message translates to:
  /// **'No Saved Card Found'**
  String get no_save_card_found;

  /// No description provided for @card_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Card created successfully'**
  String get card_created_successfully;

  /// No description provided for @card_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully'**
  String get card_updated_successfully;

  /// No description provided for @card_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully'**
  String get card_deleted_successfully;

  /// No description provided for @card_with_draw_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal cancelled successfully'**
  String get card_with_draw_cancelled;

  /// No description provided for @failed_to_create_card.
  ///
  /// In en, this message translates to:
  /// **'Failed to update card'**
  String get failed_to_create_card;

  /// No description provided for @failed_to_update_card.
  ///
  /// In en, this message translates to:
  /// **'Failed to create card'**
  String get failed_to_update_card;

  /// No description provided for @sure_to_cancel_withdraw.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this withdrawal request?'**
  String get sure_to_cancel_withdraw;

  /// No description provided for @sure_want_to_delete_account_detail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your saved bank account details?'**
  String get sure_want_to_delete_account_detail;

  /// No description provided for @gram_price_script.
  ///
  /// In en, this message translates to:
  /// **'Gram Price 1'**
  String get gram_price_script;

  /// No description provided for @first_abudhabi.
  ///
  /// In en, this message translates to:
  /// **'First Abu Dhabi Bank'**
  String get first_abudhabi;

  /// No description provided for @mashriq_bank.
  ///
  /// In en, this message translates to:
  /// **'Mashreq Bank'**
  String get mashriq_bank;

  /// No description provided for @save_inGold.
  ///
  /// In en, this message translates to:
  /// **'Save in Gold FZCO'**
  String get save_inGold;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @productCode.
  ///
  /// In en, this message translates to:
  /// **'Product Code'**
  String get productCode;

  /// No description provided for @purity.
  ///
  /// In en, this message translates to:
  /// **'Purity'**
  String get purity;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightCategory.
  ///
  /// In en, this message translates to:
  /// **'Weight Category'**
  String get weightCategory;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @inStoreCollection.
  ///
  /// In en, this message translates to:
  /// **'In Store Collection'**
  String get inStoreCollection;

  /// No description provided for @deliveryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Delivery Available'**
  String get deliveryAvailable;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @shippingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Shipping and Delivery'**
  String get shippingDelivery;

  /// No description provided for @shippingFees.
  ///
  /// In en, this message translates to:
  /// **'Shipping Fees'**
  String get shippingFees;

  /// No description provided for @deliveryIdentifiedPerson.
  ///
  /// In en, this message translates to:
  /// **'Delivery to Identified Person'**
  String get deliveryIdentifiedPerson;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @esouqCart.
  ///
  /// In en, this message translates to:
  /// **'E-souq Cart'**
  String get esouqCart;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @metal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get metal;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @charges.
  ///
  /// In en, this message translates to:
  /// **'Charges'**
  String get charges;

  /// No description provided for @goldPrice.
  ///
  /// In en, this message translates to:
  /// **'Gold Price'**
  String get goldPrice;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @making.
  ///
  /// In en, this message translates to:
  /// **'Making'**
  String get making;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// No description provided for @totalCharges.
  ///
  /// In en, this message translates to:
  /// **'Total Charges'**
  String get totalCharges;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @buyNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNowBtn;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @houseNumber.
  ///
  /// In en, this message translates to:
  /// **'House Number'**
  String get houseNumber;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @roadingStreet.
  ///
  /// In en, this message translates to:
  /// **'Roding Street'**
  String get roadingStreet;

  /// No description provided for @enter_street_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter a street address'**
  String get enter_street_address;

  /// No description provided for @enterHouseNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter a house number'**
  String get enterHouseNo;

  /// No description provided for @emiratesHill.
  ///
  /// In en, this message translates to:
  /// **'Emirates Hill First'**
  String get emiratesHill;

  /// No description provided for @please_enter_area.
  ///
  /// In en, this message translates to:
  /// **'Please enter an area'**
  String get please_enter_area;

  /// No description provided for @dubai_title.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get dubai_title;

  /// No description provided for @list_of_emirates.
  ///
  /// In en, this message translates to:
  /// **'Please enter an emirate'**
  String get list_of_emirates;

  /// No description provided for @nominate_recipient.
  ///
  /// In en, this message translates to:
  /// **'Nominate a Recipient'**
  String get nominate_recipient;

  /// No description provided for @nominee_name.
  ///
  /// In en, this message translates to:
  /// **'Nominee Name'**
  String get nominee_name;

  /// No description provided for @upload_residency_esoq.
  ///
  /// In en, this message translates to:
  /// **'Upload residency Proof'**
  String get upload_residency_esoq;

  /// No description provided for @nominee_id.
  ///
  /// In en, this message translates to:
  /// **'Please upload the Emirates Id of Your Nominee'**
  String get nominee_id;

  /// No description provided for @branch_name.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branch_name;

  /// No description provided for @no_branch_available.
  ///
  /// In en, this message translates to:
  /// **'No branches available.'**
  String get no_branch_available;

  /// No description provided for @will_notify_via_email.
  ///
  /// In en, this message translates to:
  /// **'You will be notified via email once your order is ready for collection'**
  String get will_notify_via_email;

  /// No description provided for @upload_req_doc.
  ///
  /// In en, this message translates to:
  /// **'Please upload required document'**
  String get upload_req_doc;

  /// No description provided for @enter_nom_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter Nominee Name'**
  String get enter_nom_name;

  /// No description provided for @select_collection_branch.
  ///
  /// In en, this message translates to:
  /// **'Please select collection branch first'**
  String get select_collection_branch;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @emirate.
  ///
  /// In en, this message translates to:
  /// **'Emirate'**
  String get emirate;

  /// No description provided for @nominateRecipient.
  ///
  /// In en, this message translates to:
  /// **'Nominate a Recipient'**
  String get nominateRecipient;

  /// No description provided for @deliveryCharges.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charges'**
  String get deliveryCharges;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @confirmPaymentBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPaymentBtn;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @gramDeal.
  ///
  /// In en, this message translates to:
  /// **'Gram Deal'**
  String get gramDeal;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target:'**
  String get target;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneBtn;

  /// No description provided for @in_store.
  ///
  /// In en, this message translates to:
  /// **'In-store pickup is available for all products. Pickups are available \'Monday to Friday, 11:00 AM to 6:00 PM\' (Timezone, Gulf Standard Time). An email confirmation will be sent to you when your order is ready for pickup'**
  String get in_store;

  /// No description provided for @no_gram_deal_available.
  ///
  /// In en, this message translates to:
  /// **'No gram deals available'**
  String get no_gram_deal_available;

  /// No description provided for @plz_choose_deal.
  ///
  /// In en, this message translates to:
  /// **'Please choose a deal'**
  String get plz_choose_deal;

  /// No description provided for @select_deal_for_checkout.
  ///
  /// In en, this message translates to:
  /// **'Please select deals for checkout'**
  String get select_deal_for_checkout;

  /// No description provided for @all_additional_charge.
  ///
  /// In en, this message translates to:
  /// **'Note: All the additional charges (AED'**
  String get all_additional_charge;

  /// No description provided for @will_deducted.
  ///
  /// In en, this message translates to:
  /// **') will be deducted from your Money Balance'**
  String get will_deducted;

  /// No description provided for @esouq_gram_balance.
  ///
  /// In en, this message translates to:
  /// **'Gram Balance'**
  String get esouq_gram_balance;

  /// No description provided for @select_checkout_deal.
  ///
  /// In en, this message translates to:
  /// **'Please select deals for checkout'**
  String get select_checkout_deal;

  /// No description provided for @g_less_than_req.
  ///
  /// In en, this message translates to:
  /// **'g is less than required'**
  String get g_less_than_req;

  /// No description provided for @my_orders_title.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders_title;

  /// No description provided for @order_no.
  ///
  /// In en, this message translates to:
  /// **'Order No.'**
  String get order_no;

  /// No description provided for @order_status.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get order_status;

  /// No description provided for @delivery_method.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get delivery_method;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @branch_address.
  ///
  /// In en, this message translates to:
  /// **'Branch Address'**
  String get branch_address;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @customer_address.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customer_address;

  /// No description provided for @metal_released.
  ///
  /// In en, this message translates to:
  /// **'Metal Released'**
  String get metal_released;

  /// No description provided for @metal_holder.
  ///
  /// In en, this message translates to:
  /// **'Metal Holder'**
  String get metal_holder;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get money;

  /// No description provided for @transactionID.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionID;

  /// No description provided for @esouqPayment.
  ///
  /// In en, this message translates to:
  /// **'Esouq Payment'**
  String get esouqPayment;

  /// No description provided for @goldDebit.
  ///
  /// In en, this message translates to:
  /// **'Gold Debit'**
  String get goldDebit;

  /// No description provided for @goldCredit.
  ///
  /// In en, this message translates to:
  /// **'Gold Credit'**
  String get goldCredit;

  /// No description provided for @balanceAfterTrade.
  ///
  /// In en, this message translates to:
  /// **'Balance after Trade'**
  String get balanceAfterTrade;

  /// No description provided for @balanceAfterTransaction.
  ///
  /// In en, this message translates to:
  /// **'Balance after Transaction'**
  String get balanceAfterTransaction;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @invest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get invest;

  /// No description provided for @sigWallet.
  ///
  /// In en, this message translates to:
  /// **'SIG Wallet'**
  String get sigWallet;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money In'**
  String get moneyIn;

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money Out'**
  String get moneyOut;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @transactionMethod.
  ///
  /// In en, this message translates to:
  /// **'Transaction Method'**
  String get transactionMethod;

  /// No description provided for @metal_st.
  ///
  /// In en, this message translates to:
  /// **'Metal Statement'**
  String get metal_st;

  /// No description provided for @money_st.
  ///
  /// In en, this message translates to:
  /// **'Money Statement'**
  String get money_st;

  /// No description provided for @metal_rate_aed.
  ///
  /// In en, this message translates to:
  /// **'Rate: AED'**
  String get metal_rate_aed;

  /// No description provided for @metal_g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get metal_g;

  /// No description provided for @withdraw_success.
  ///
  /// In en, this message translates to:
  /// **'An amount of {amount} (AED) has been debited from your account.'**
  String withdraw_success(Object amount);

  /// No description provided for @deposit_success.
  ///
  /// In en, this message translates to:
  /// **'Your account has been credited with AED {amount}.'**
  String deposit_success(Object amount);

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in to your account.'**
  String get login_success;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged out of your account.'**
  String get logout_success;

  /// No description provided for @gift_sent.
  ///
  /// In en, this message translates to:
  /// **'You’ve successfully sent (AED {amount}) gift to {recipient}.'**
  String gift_sent(Object amount, Object recipient);

  /// No description provided for @esouq_order.
  ///
  /// In en, this message translates to:
  /// **'Your Esouq order has been placed and will be processed soon.'**
  String get esouq_order;

  /// No description provided for @buy_order_filled.
  ///
  /// In en, this message translates to:
  /// **'You bought {quantity} gram(s) of gold at price {price} AED. Deal Id: {dealId}.'**
  String buy_order_filled(Object dealId, Object price, Object quantity);

  /// No description provided for @no_notification.
  ///
  /// In en, this message translates to:
  /// **'No Notification found'**
  String get no_notification;

  /// No description provided for @invest_title.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get invest_title;

  /// No description provided for @selling_price.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get selling_price;

  /// No description provided for @buying_price.
  ///
  /// In en, this message translates to:
  /// **'Buying Price'**
  String get buying_price;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low:'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High:'**
  String get high;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price '**
  String get price;

  /// No description provided for @max_grams_note.
  ///
  /// In en, this message translates to:
  /// **'Max grams you can buy:'**
  String get max_grams_note;

  /// No description provided for @buy_at_price.
  ///
  /// In en, this message translates to:
  /// **'Buy at Price'**
  String get buy_at_price;

  /// No description provided for @buy_gold_btn.
  ///
  /// In en, this message translates to:
  /// **'Buy Gold'**
  String get buy_gold_btn;

  /// No description provided for @buy_gold_pop.
  ///
  /// In en, this message translates to:
  /// **'Gold Price:'**
  String get buy_gold_pop;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @invest_invalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount. Please enter a valid number.'**
  String get invest_invalid_amount;

  /// No description provided for @invest_price_less_than_buying.
  ///
  /// In en, this message translates to:
  /// **'Enter a price that is less than or equal to the current buying price.'**
  String get invest_price_less_than_buying;

  /// No description provided for @invest_insufficient_balance_title.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get invest_insufficient_balance_title;

  /// No description provided for @invest_insufficient_balance_desc.
  ///
  /// In en, this message translates to:
  /// **'Your balance (AED {balance}) is less than the required amount (AED {required}). Please add funds.'**
  String invest_insufficient_balance_desc(Object balance, Object required);

  /// No description provided for @invest_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get invest_confirmation_title;

  /// No description provided for @invest_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy {grams} grams of gold now?'**
  String invest_confirmation_message(String grams);

  /// No description provided for @invest_filled_oreder.
  ///
  /// In en, this message translates to:
  /// **'Buy Order Filled'**
  String get invest_filled_oreder;

  /// No description provided for @invest_successfully_submitted.
  ///
  /// In en, this message translates to:
  /// **'Your buy order has been successfully submitted for processing.'**
  String get invest_successfully_submitted;

  /// No description provided for @invest_sell_order_placed.
  ///
  /// In en, this message translates to:
  /// **'Sell Order Placed'**
  String get invest_sell_order_placed;

  /// No description provided for @invest_sell_order_filled.
  ///
  /// In en, this message translates to:
  /// **'Sell Order Filled'**
  String get invest_sell_order_filled;

  /// No description provided for @invest_sell_order_submitted_success.
  ///
  /// In en, this message translates to:
  /// **'Your sell order has been successfully submitted for processing.'**
  String get invest_sell_order_submitted_success;

  /// No description provided for @invest_order_placed.
  ///
  /// In en, this message translates to:
  /// **'Buy Order Placed'**
  String get invest_order_placed;

  /// No description provided for @insufficient_balance_message.
  ///
  /// In en, this message translates to:
  /// **'Your balance (AED {walletBalance}) is less than the required amount (AED {inputAmount}). Please add funds.'**
  String insufficient_balance_message(String walletBalance, String inputAmount);

  /// No description provided for @invest_confirm_purchase_btn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get invest_confirm_purchase_btn;

  /// No description provided for @invest_add_funds_btn.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get invest_add_funds_btn;

  /// No description provided for @re_submit_document.
  ///
  /// In en, this message translates to:
  /// **'Resubmit Documents'**
  String get re_submit_document;

  /// No description provided for @dealDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Deal Details'**
  String get dealDetails_title;

  /// No description provided for @deal_buy_order.
  ///
  /// In en, this message translates to:
  /// **'Buy Order'**
  String get deal_buy_order;

  /// No description provided for @deal_at_price.
  ///
  /// In en, this message translates to:
  /// **'at Price'**
  String get deal_at_price;

  /// No description provided for @deal_id_label.
  ///
  /// In en, this message translates to:
  /// **'Deal ID'**
  String get deal_id_label;

  /// No description provided for @deal_buy_order_title.
  ///
  /// In en, this message translates to:
  /// **'Buy Order {grams}g Gold'**
  String deal_buy_order_title(Object grams);

  /// No description provided for @deal_buy_at_price.
  ///
  /// In en, this message translates to:
  /// **'Buy at Price'**
  String get deal_buy_at_price;

  /// No description provided for @deal_current_sell_price.
  ///
  /// In en, this message translates to:
  /// **'Current Sell Price'**
  String get deal_current_sell_price;

  /// No description provided for @deal_current_buy_price.
  ///
  /// In en, this message translates to:
  /// **'Current Buy Price'**
  String get deal_current_buy_price;

  /// No description provided for @deal_invest_money.
  ///
  /// In en, this message translates to:
  /// **'Invest Money'**
  String get deal_invest_money;

  /// No description provided for @deal_manage_section.
  ///
  /// In en, this message translates to:
  /// **'Manage Deal'**
  String get deal_manage_section;

  /// No description provided for @deal_take_profit.
  ///
  /// In en, this message translates to:
  /// **'Take Profit'**
  String get deal_take_profit;

  /// No description provided for @deal_sell_at_price.
  ///
  /// In en, this message translates to:
  /// **'Sell at Price'**
  String get deal_sell_at_price;

  /// No description provided for @deal_update_position_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Deal Position'**
  String get deal_update_position_btn;

  /// No description provided for @deal_close_section.
  ///
  /// In en, this message translates to:
  /// **'Close Deal'**
  String get deal_close_section;

  /// No description provided for @deal_amount_gram.
  ///
  /// In en, this message translates to:
  /// **'Amount Gram'**
  String get deal_amount_gram;

  /// No description provided for @deal_val_enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get deal_val_enter_amount;

  /// No description provided for @metal_after_trade.
  ///
  /// In en, this message translates to:
  /// **'Metal After Trade'**
  String get metal_after_trade;

  /// No description provided for @metal_profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get metal_profit;

  /// No description provided for @metal_plus_na.
  ///
  /// In en, this message translates to:
  /// **'+ AED N/A'**
  String get metal_plus_na;

  /// No description provided for @deal_cant_close.
  ///
  /// In en, this message translates to:
  /// **'You can\'\'t close this deal at a loss.'**
  String get deal_cant_close;

  /// No description provided for @deal_price_greater_or_equal_buy_at.
  ///
  /// In en, this message translates to:
  /// **'Enter a price that is greater than or equal to the buy at price ({price}).'**
  String deal_price_greater_or_equal_buy_at(Object price);

  /// No description provided for @deal_cannot_close_at_loss.
  ///
  /// In en, this message translates to:
  /// **'You can\'\'t close this deal at loss'**
  String get deal_cannot_close_at_loss;

  /// No description provided for @deal_enter_valid_profit_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid profit price.'**
  String get deal_enter_valid_profit_price;

  /// No description provided for @greater_or_equal_buy.
  ///
  /// In en, this message translates to:
  /// **'Enter a price greater than or equal to the buy at price ('**
  String get greater_or_equal_buy;

  /// No description provided for @greater_or_equal_sell.
  ///
  /// In en, this message translates to:
  /// **'Enter a price greater than or equal to the current sell at price ('**
  String get greater_or_equal_sell;

  /// No description provided for @cant_close_at_loss.
  ///
  /// In en, this message translates to:
  /// **'You can\'\'t close this deal at loss'**
  String get cant_close_at_loss;

  /// No description provided for @deal_update_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get deal_update_confirm_title;

  /// No description provided for @deal_update_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update deal position?'**
  String get deal_update_confirm_message;

  /// No description provided for @gramsBalance_title.
  ///
  /// In en, this message translates to:
  /// **'Grams Balance'**
  String get gramsBalance_title;

  /// No description provided for @grams_card_buy_at_price_order.
  ///
  /// In en, this message translates to:
  /// **'Buy at Price Order'**
  String get grams_card_buy_at_price_order;

  /// No description provided for @grams_card_invest_money.
  ///
  /// In en, this message translates to:
  /// **'Invest Money:'**
  String get grams_card_invest_money;

  /// No description provided for @grams_card_invest_status.
  ///
  /// In en, this message translates to:
  /// **'Invest Status:'**
  String get grams_card_invest_status;

  /// No description provided for @grams_card_opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get grams_card_opened;

  /// No description provided for @grams_card_date_label.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get grams_card_date_label;

  /// No description provided for @gram_bar_nmbr.
  ///
  /// In en, this message translates to:
  /// **'Bar Number :'**
  String get gram_bar_nmbr;

  /// No description provided for @invest_buy_at_price_update_success.
  ///
  /// In en, this message translates to:
  /// **'You have successfully update your Buy at price order'**
  String get invest_buy_at_price_update_success;

  /// No description provided for @buy_order_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Buy order updated!'**
  String get buy_order_updated_title;

  /// No description provided for @buy_order_updated_desc.
  ///
  /// In en, this message translates to:
  /// **'You have successfully update your Buy at price order'**
  String get buy_order_updated_desc;

  /// No description provided for @history_statement_exported.
  ///
  /// In en, this message translates to:
  /// **'Statement exported successfully'**
  String get history_statement_exported;

  /// No description provided for @history_bought_label.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get history_bought_label;

  /// No description provided for @history_rate_label.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get history_rate_label;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification;

  /// No description provided for @history_create_money_st.
  ///
  /// In en, this message translates to:
  /// **'Please create new money statement or try again later'**
  String get history_create_money_st;

  /// No description provided for @history_create_metal_st.
  ///
  /// In en, this message translates to:
  /// **'Please create new metal statement or try again later'**
  String get history_create_metal_st;

  /// No description provided for @history_filters_title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get history_filters_title;

  /// No description provided for @history_filters_show_from.
  ///
  /// In en, this message translates to:
  /// **'Show History from'**
  String get history_filters_show_from;

  /// No description provided for @history_filters_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get history_filters_all;

  /// No description provided for @history_filters_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get history_filters_today;

  /// No description provided for @history_filters_this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get history_filters_this_week;

  /// No description provided for @history_filters_this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get history_filters_this_month;

  /// No description provided for @history_filters_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get history_filters_custom;

  /// No description provided for @history_filters_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get history_filters_from;

  /// No description provided for @history_filters_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get history_filters_to;

  /// No description provided for @history_filters_apply_btn.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get history_filters_apply_btn;

  /// No description provided for @history_filters_clear_btn.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get history_filters_clear_btn;

  /// No description provided for @empty_no_data.
  ///
  /// In en, this message translates to:
  /// **'No Data To Show'**
  String get empty_no_data;

  /// No description provided for @empty_email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified'**
  String get empty_email_not_verified;

  /// No description provided for @empty_no_gram_balance.
  ///
  /// In en, this message translates to:
  /// **'No gram balance found'**
  String get empty_no_gram_balance;

  /// No description provided for @email_verification_required.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get email_verification_required;

  /// No description provided for @email_verification_msg.
  ///
  /// In en, this message translates to:
  /// **'You must verify your email first. Do you want to verify now?'**
  String get email_verification_msg;

  /// No description provided for @email_verification_verify_btn.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get email_verification_verify_btn;

  /// No description provided for @email_verification_cancel_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get email_verification_cancel_btn;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get settings_title;

  /// No description provided for @settings_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get settings_personal_info;

  /// No description provided for @settings_personal_info_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal details and preferences.'**
  String get settings_personal_info_desc;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get settings_language;

  /// No description provided for @settings_language_desc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app.'**
  String get settings_language_desc;

  /// No description provided for @settings_switch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get settings_switch;

  /// No description provided for @settings_switch_desc.
  ///
  /// In en, this message translates to:
  /// **'Switch Demo user to Real'**
  String get settings_switch_desc;

  /// No description provided for @settings_biometric.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get settings_biometric;

  /// No description provided for @settings_biometric_desc.
  ///
  /// In en, this message translates to:
  /// **'Log in securely using Touch ID or fingerprint.'**
  String get settings_biometric_desc;

  /// No description provided for @settings_timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get settings_timezone;

  /// No description provided for @settings_timezone_desc.
  ///
  /// In en, this message translates to:
  /// **'Adjust your timezone to match your location.'**
  String get settings_timezone_desc;

  /// No description provided for @settings_password.
  ///
  /// In en, this message translates to:
  /// **'Password Settings'**
  String get settings_password;

  /// No description provided for @settings_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Update or change your account password.'**
  String get settings_password_desc;

  /// No description provided for @settings_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_delete;

  /// No description provided for @settings_delete_desc.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get settings_delete_desc;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// No description provided for @settings_logout_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account securely.'**
  String get settings_logout_desc;

  /// No description provided for @account_warning.
  ///
  /// In en, this message translates to:
  /// **'Please verify your {kycStatus} to get access to all the features.'**
  String account_warning(String kycStatus);

  /// No description provided for @verify_account.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verify_account;

  /// No description provided for @demo_mode_banner.
  ///
  /// In en, this message translates to:
  /// **'You are in Demo Mode'**
  String get demo_mode_banner;

  /// No description provided for @demo_mode_go_live.
  ///
  /// In en, this message translates to:
  /// **'Go Live'**
  String get demo_mode_go_live;

  /// No description provided for @upgrade_real_account_title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Real Account'**
  String get upgrade_real_account_title;

  /// No description provided for @upgrade_real_account_msg.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a verified real account. Please convert your demo account to a real account to access all features.'**
  String get upgrade_real_account_msg;

  /// No description provided for @upgrade_real_account_now.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgrade_real_account_now;

  /// No description provided for @upgrade_real_account_later.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get upgrade_real_account_later;

  /// No description provided for @delete_warning_full.
  ///
  /// In en, this message translates to:
  /// **'Warning: Deleting your account is permanent. All of your data will be permanently erased and cannot be restored. Are you sure you want to continue?'**
  String get delete_warning_full;

  /// No description provided for @faceid_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable Face ID'**
  String get faceid_enable;

  /// No description provided for @faceid_desc.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID for quick and secure access.'**
  String get faceid_desc;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get app_version;

  /// No description provided for @staging.
  ///
  /// In en, this message translates to:
  /// **'Staging'**
  String get staging;

  /// No description provided for @production.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning:'**
  String get warning;

  /// No description provided for @pi_update_warning.
  ///
  /// In en, this message translates to:
  /// **'Updating personal info will temporarily restrict transactions until approved by our support team.'**
  String get pi_update_warning;

  /// No description provided for @pending_approval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pending_approval;

  /// No description provided for @uae_num_14.
  ///
  /// In en, this message translates to:
  /// **'Enter UAE number starting with 00971 or +971'**
  String get uae_num_14;

  /// No description provided for @saudia_num_14.
  ///
  /// In en, this message translates to:
  /// **'Enter Saudia Arabia number starting with 00966 or +966'**
  String get saudia_num_14;

  /// No description provided for @uae_num_10.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit UAE number starting with 05'**
  String get uae_num_10;

  /// No description provided for @jordan_num_14.
  ///
  /// In en, this message translates to:
  /// **'Enter Jordan number starting with 00962 or +962'**
  String get jordan_num_14;

  /// No description provided for @iraq_num_15.
  ///
  /// In en, this message translates to:
  /// **'Enter Iraq number starting with 00964 or +964'**
  String get iraq_num_15;

  /// No description provided for @jordan_iraq_local.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit Jordan number (07..) or 11-digit Iraq number (07..)'**
  String get jordan_iraq_local;

  /// No description provided for @phone_format_note.
  ///
  /// In en, this message translates to:
  /// **'Enter full phone number with + or 00 (e.g. +971 or 00971)'**
  String get phone_format_note;

  /// No description provided for @update_profile_first.
  ///
  /// In en, this message translates to:
  /// **'Please update profile information before submitting.'**
  String get update_profile_first;

  /// No description provided for @update_required.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get update_required;

  /// No description provided for @update_message.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue.'**
  String get update_message;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'documents'**
  String get documents;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @residency_document_required.
  ///
  /// In en, this message translates to:
  /// **'Residency Document Required'**
  String get residency_document_required;

  /// No description provided for @residency_verification_message.
  ///
  /// In en, this message translates to:
  /// **'To continue, please complete your residency document verification. Would you like to proceed now?'**
  String get residency_verification_message;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @kyc_verification_required.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification Required'**
  String get kyc_verification_required;

  /// No description provided for @kyc_verification_message.
  ///
  /// In en, this message translates to:
  /// **'To continue, please complete your KYC verification. Would you like to proceed now?'**
  String get kyc_verification_message;

  /// No description provided for @no_news_available.
  ///
  /// In en, this message translates to:
  /// **'Oops! No news available'**
  String get no_news_available;

  /// No description provided for @masked_balance.
  ///
  /// In en, this message translates to:
  /// **'*****'**
  String get masked_balance;

  /// No description provided for @total_gold.
  ///
  /// In en, this message translates to:
  /// **'Total Gold'**
  String get total_gold;

  /// No description provided for @total_funds.
  ///
  /// In en, this message translates to:
  /// **'Total Funds (AED)'**
  String get total_funds;

  /// No description provided for @upgrade_to_real_account.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Real Account'**
  String get upgrade_to_real_account;

  /// No description provided for @upgrade_feature_message.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a verified real account. Please convert your demo account to a real account to access all features.'**
  String get upgrade_feature_message;

  /// No description provided for @not_now.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get not_now;

  /// No description provided for @upgrade_now.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgrade_now;

  /// No description provided for @title_not_available.
  ///
  /// In en, this message translates to:
  /// **'Title Not Available'**
  String get title_not_available;

  /// No description provided for @description_not_available.
  ///
  /// In en, this message translates to:
  /// **'Description Not Available'**
  String get description_not_available;

  /// No description provided for @read_more.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get read_more;

  /// No description provided for @link_not_available.
  ///
  /// In en, this message translates to:
  /// **'Link Not Available'**
  String get link_not_available;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get grams;

  /// No description provided for @wallet_empty.
  ///
  /// In en, this message translates to:
  /// **'Wallet empty. Add funds to buy gold.'**
  String get wallet_empty;

  /// No description provided for @per_gram_aed.
  ///
  /// In en, this message translates to:
  /// **'Per Gram AED'**
  String get per_gram_aed;

  /// No description provided for @buy_gold.
  ///
  /// In en, this message translates to:
  /// **'Buy Gold'**
  String get buy_gold;

  /// No description provided for @please_enter_valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get please_enter_valid_amount;

  /// No description provided for @email_verification_message.
  ///
  /// In en, this message translates to:
  /// **'To continue, please verify your email address. Do you want to verify now?'**
  String get email_verification_message;

  /// No description provided for @verify_now.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verify_now;

  /// No description provided for @residency_verification_required.
  ///
  /// In en, this message translates to:
  /// **'Residency Verification Required'**
  String get residency_verification_required;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @select_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get select_gallery;

  /// No description provided for @select_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get select_camera;

  /// No description provided for @insufficient_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get insufficient_balance;

  /// No description provided for @add_funds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get add_funds;

  /// No description provided for @insufficient_demo_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Demo Balance'**
  String get insufficient_demo_balance;

  /// No description provided for @demo_balance_message.
  ///
  /// In en, this message translates to:
  /// **'Your demo balance is insufficient. Funds are provided only once and cannot be replenished. Please invest within your balance, switch to a real account, or create a new demo account.'**
  String get demo_balance_message;

  /// No description provided for @please_add_grams.
  ///
  /// In en, this message translates to:
  /// **'Please add grams amount.'**
  String get please_add_grams;

  /// No description provided for @unable_to_fetch_data.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch latest data. Please try again.'**
  String get unable_to_fetch_data;

  /// No description provided for @data_loading.
  ///
  /// In en, this message translates to:
  /// **'Data is loading. Please wait.'**
  String get data_loading;

  /// No description provided for @invalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount. Please enter a valid value.'**
  String get invalid_amount;

  /// No description provided for @please_enter_valid_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price.'**
  String get please_enter_valid_price;

  /// No description provided for @price_limit_message.
  ///
  /// In en, this message translates to:
  /// **'Enter a price that is less than or equal to the current buying price.'**
  String get price_limit_message;

  /// No description provided for @enter_valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount to proceed.'**
  String get enter_valid_amount;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @place_order_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to place this pending order?'**
  String get place_order_confirm;

  /// No description provided for @place_order.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get place_order;

  /// No description provided for @confirm_purchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirm_purchase;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get gram;

  /// No description provided for @aed_currency.
  ///
  /// In en, this message translates to:
  /// **' AED'**
  String get aed_currency;

  /// No description provided for @amountVar.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountVar;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get not_available;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @enter_first_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name.'**
  String get enter_first_name;

  /// No description provided for @enter_surname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your surname.'**
  String get enter_surname;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enter_phone_number;

  /// No description provided for @enter_sa_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter saudia number starting with 0096 or +966.'**
  String get enter_sa_number;

  /// No description provided for @enter_intl_number.
  ///
  /// In en, this message translates to:
  /// **'Please use 009XX or +9XXXX for intl. format'**
  String get enter_intl_number;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get update_profile;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @forgot_password_instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number below to receive the instructions to change your password.'**
  String get forgot_password_instruction;

  /// No description provided for @new_password_different.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get new_password_different;

  /// No description provided for @profile_update_warning.
  ///
  /// In en, this message translates to:
  /// **'Your profile information will be updated. Please review your details carefully before proceeding.'**
  String get profile_update_warning;

  /// No description provided for @profile_verified_warning.
  ///
  /// In en, this message translates to:
  /// **'Once your profile is verified, you will be logged out automatically. Are you sure you want to continue?'**
  String get profile_verified_warning;

  /// No description provided for @enter_verify_code.
  ///
  /// In en, this message translates to:
  /// **'Enter the verify code you received on your'**
  String get enter_verify_code;

  /// No description provided for @enter_pin.
  ///
  /// In en, this message translates to:
  /// **'Please enter pin'**
  String get enter_pin;

  /// No description provided for @didnt_receive_code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'\'t receive the code?'**
  String get didnt_receive_code;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @enter_verify_code_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter the verify code you received on your phone number:'**
  String get enter_verify_code_phone;

  /// No description provided for @gram_take_profit.
  ///
  /// In en, this message translates to:
  /// **'Take Profit'**
  String get gram_take_profit;

  /// No description provided for @gram_gift_received.
  ///
  /// In en, this message translates to:
  /// **'Gift Recieved'**
  String get gram_gift_received;

  /// No description provided for @gram_buy_at_price.
  ///
  /// In en, this message translates to:
  /// **'Buy at Price Order'**
  String get gram_buy_at_price;

  /// No description provided for @gram_invest_money.
  ///
  /// In en, this message translates to:
  /// **'Invest Money: AED'**
  String get gram_invest_money;

  /// No description provided for @gram_invest_status.
  ///
  /// In en, this message translates to:
  /// **'Invest Status:'**
  String get gram_invest_status;

  /// No description provided for @gram_date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get gram_date;

  /// No description provided for @gram_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get gram_total;

  /// No description provided for @gram_no_change.
  ///
  /// In en, this message translates to:
  /// **'No Change'**
  String get gram_no_change;

  /// No description provided for @gram_buy_word.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get gram_buy_word;

  /// No description provided for @gram_sell_word.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get gram_sell_word;

  /// No description provided for @g_Gold.
  ///
  /// In en, this message translates to:
  /// **'g Gold'**
  String get g_Gold;

  /// No description provided for @trade_order_message.
  ///
  /// In en, this message translates to:
  /// **'{tradeType} {grams}g Gold @ {price}'**
  String trade_order_message(Object tradeType, Object grams, Object price);

  /// No description provided for @trade_sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get trade_sell;

  /// No description provided for @deal_bought_at_price.
  ///
  /// In en, this message translates to:
  /// **'Bought at Price'**
  String get deal_bought_at_price;

  /// No description provided for @deal_edit_price.
  ///
  /// In en, this message translates to:
  /// **'Edit Price'**
  String get deal_edit_price;

  /// No description provided for @deal_price_per_gram.
  ///
  /// In en, this message translates to:
  /// **'Price per gram (AED)'**
  String get deal_price_per_gram;

  /// No description provided for @deal_gram_price.
  ///
  /// In en, this message translates to:
  /// **'Gram Price'**
  String get deal_gram_price;

  /// No description provided for @deal_enter_amount_aed.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount in AED'**
  String get deal_enter_amount_aed;

  /// No description provided for @deal_valid_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get deal_valid_number;

  /// No description provided for @deal_zero_value_validation.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount greater than zero'**
  String get deal_zero_value_validation;

  /// No description provided for @deal_edit_gram.
  ///
  /// In en, this message translates to:
  /// **'Edit Gram Amount'**
  String get deal_edit_gram;

  /// No description provided for @deal_gram_amount.
  ///
  /// In en, this message translates to:
  /// **'Gram Amount'**
  String get deal_gram_amount;

  /// No description provided for @deal_update_order.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get deal_update_order;

  /// No description provided for @deal_enter_valid_gram.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid gram amount'**
  String get deal_enter_valid_gram;

  /// No description provided for @deal_sell_greater_than_bought.
  ///
  /// In en, this message translates to:
  /// **'Please enter a sell price greater than the bought at price (AED'**
  String get deal_sell_greater_than_bought;

  /// No description provided for @deal_pending_sell_greater_with_zero_buying_than_current_sell.
  ///
  /// In en, this message translates to:
  /// **'Please enter a sell price greater than or equal to the current sell price (AED'**
  String get deal_pending_sell_greater_with_zero_buying_than_current_sell;

  /// No description provided for @deal_buy_price_less.
  ///
  /// In en, this message translates to:
  /// **'Please enter a buy price less than the current buy price (AED'**
  String get deal_buy_price_less;

  /// No description provided for @deal_sure_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to Update this order?'**
  String get deal_sure_confirm;

  /// No description provided for @deal_cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get deal_cancel_order;

  /// No description provided for @deal_cance_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get deal_cance_title;

  /// No description provided for @deal_manage_deal.
  ///
  /// In en, this message translates to:
  /// **'Manage Deal'**
  String get deal_manage_deal;

  /// No description provided for @deal_close.
  ///
  /// In en, this message translates to:
  /// **'You can\'\'t close this deal at loss'**
  String get deal_close;

  /// No description provided for @deal_amount_must_less.
  ///
  /// In en, this message translates to:
  /// **'Amount must be less than or equal to'**
  String get deal_amount_must_less;

  /// No description provided for @is_below_buy.
  ///
  /// In en, this message translates to:
  /// **'is below your buying price (AED'**
  String get is_below_buy;

  /// No description provided for @deal_confirm_loss.
  ///
  /// In en, this message translates to:
  /// **'Confirm Loss'**
  String get deal_confirm_loss;

  /// No description provided for @deal_confirm_deal_closure.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deal Closure'**
  String get deal_confirm_deal_closure;

  /// No description provided for @deal_about_to_close.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re about to close this deal at a loss. Are you sure?'**
  String get deal_about_to_close;

  /// No description provided for @deal_sure_want_to_close.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close'**
  String get deal_sure_want_to_close;

  /// No description provided for @deal_g_of_deal.
  ///
  /// In en, this message translates to:
  /// **'g of this deal?'**
  String get deal_g_of_deal;

  /// No description provided for @deal_close_anyway.
  ///
  /// In en, this message translates to:
  /// **'Close Anyway'**
  String get deal_close_anyway;

  /// No description provided for @deal_enter_valid_nmbr.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get deal_enter_valid_nmbr;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @finger_print_warning.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint authentication failed.'**
  String get finger_print_warning;

  /// No description provided for @invalid_otp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP:Please enter valid otp'**
  String get invalid_otp;

  /// No description provided for @user_firstName.
  ///
  /// In en, this message translates to:
  /// **'Amro'**
  String get user_firstName;

  /// No description provided for @user_lastName.
  ///
  /// In en, this message translates to:
  /// **'Jaber'**
  String get user_lastName;

  /// No description provided for @upgrade_to_real_message.
  ///
  /// In en, this message translates to:
  /// **'Please note, upgrading to a real account will result in the deletion of your existing demo account data.'**
  String get upgrade_to_real_message;

  /// No description provided for @update_Account.
  ///
  /// In en, this message translates to:
  /// **'Update Account'**
  String get update_Account;

  /// No description provided for @active_alerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get active_alerts;

  /// No description provided for @no_active_alerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts'**
  String get no_active_alerts;

  /// No description provided for @please_enter_target_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter target price'**
  String get please_enter_target_price;

  /// No description provided for @unable_to_fetch_current_prices.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch current prices'**
  String get unable_to_fetch_current_prices;

  /// No description provided for @buy_alert_below_current_price.
  ///
  /// In en, this message translates to:
  /// **'Buy alert price must be below current buying price'**
  String get buy_alert_below_current_price;

  /// No description provided for @sell_alert_above_current_price.
  ///
  /// In en, this message translates to:
  /// **'Sell alert price must be above current selling price'**
  String get sell_alert_above_current_price;

  /// No description provided for @add_alert.
  ///
  /// In en, this message translates to:
  /// **'Add Alert'**
  String get add_alert;

  /// No description provided for @alert_type.
  ///
  /// In en, this message translates to:
  /// **'Alert Type'**
  String get alert_type;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @select_script.
  ///
  /// In en, this message translates to:
  /// **'Select Script'**
  String get select_script;

  /// No description provided for @target_price.
  ///
  /// In en, this message translates to:
  /// **'Target Price'**
  String get target_price;

  /// No description provided for @enter_price.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enter_price;

  /// No description provided for @must_be_below.
  ///
  /// In en, this message translates to:
  /// **'Must be below'**
  String get must_be_below;

  /// No description provided for @must_be_above.
  ///
  /// In en, this message translates to:
  /// **'Must be above'**
  String get must_be_above;

  /// No description provided for @loading_current_prices.
  ///
  /// In en, this message translates to:
  /// **'Loading current prices...'**
  String get loading_current_prices;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// No description provided for @one_gm_price.
  ///
  /// In en, this message translates to:
  /// **'1 Gram Price'**
  String get one_gm_price;

  /// No description provided for @price_alert.
  ///
  /// In en, this message translates to:
  /// **'Price Alert'**
  String get price_alert;

  /// No description provided for @price_below.
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get price_below;

  /// No description provided for @price_above.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get price_above;

  /// No description provided for @order_list.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get order_list;

  /// No description provided for @alert_title.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert_title;

  /// No description provided for @no_data_to_show.
  ///
  /// In en, this message translates to:
  /// **'No Data To Show'**
  String get no_data_to_show;

  /// No description provided for @no_order_available.
  ///
  /// In en, this message translates to:
  /// **'No Order Available'**
  String get no_order_available;

  /// No description provided for @are_you_sure_want_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to delete'**
  String get are_you_sure_want_to_delete;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @aed.
  ///
  /// In en, this message translates to:
  /// **'AED'**
  String get aed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @comment_here.
  ///
  /// In en, this message translates to:
  /// **'Comment here'**
  String get comment_here;

  /// No description provided for @some_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'Some Error Occurred'**
  String get some_error_occurred;

  /// No description provided for @buy_now.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buy_now;

  /// No description provided for @verify_email_message.
  ///
  /// In en, this message translates to:
  /// **'To continue, please verify your email address. Do you want to verify now?'**
  String get verify_email_message;

  /// No description provided for @residency_document_message.
  ///
  /// In en, this message translates to:
  /// **'To continue, please complete your residency document verification. Would you like to proceed now?'**
  String get residency_document_message;

  /// No description provided for @product_code.
  ///
  /// In en, this message translates to:
  /// **'Product Code'**
  String get product_code;

  /// No description provided for @weight_category.
  ///
  /// In en, this message translates to:
  /// **'Weight Category'**
  String get weight_category;

  /// No description provided for @in_store_collection.
  ///
  /// In en, this message translates to:
  /// **'In Store Collection'**
  String get in_store_collection;

  /// No description provided for @delivery_available.
  ///
  /// In en, this message translates to:
  /// **'Delivery Available'**
  String get delivery_available;

  /// No description provided for @you_already_have.
  ///
  /// In en, this message translates to:
  /// **'You already have'**
  String get you_already_have;

  /// No description provided for @which_meet_or_exceed.
  ///
  /// In en, this message translates to:
  /// **'g, which meets or exceeds your target of'**
  String get which_meet_or_exceed;

  /// No description provided for @shipping_and_delivery.
  ///
  /// In en, this message translates to:
  /// **'Shipping and Delivery'**
  String get shipping_and_delivery;

  /// No description provided for @in_store_collection_detail.
  ///
  /// In en, this message translates to:
  /// **'In-store pickup is available for all products. Pickups are available \'Monday to Friday, 11:00 AM to 6:00 PM\' (Timezone, Gulf Standard Time). An email confirmation will be sent to you when your order is ready for pickup.'**
  String get in_store_collection_detail;

  /// No description provided for @shipping_fees.
  ///
  /// In en, this message translates to:
  /// **'Shipping Fees'**
  String get shipping_fees;

  /// No description provided for @shipping_fees_detail.
  ///
  /// In en, this message translates to:
  /// **'We offer shipping at the following rates:\nNext day delivery from '**
  String get shipping_fees_detail;

  /// No description provided for @delivery_identified_person.
  ///
  /// In en, this message translates to:
  /// **'Delivery to Identified Person:'**
  String get delivery_identified_person;

  /// No description provided for @delivery_identified_person_detail.
  ///
  /// In en, this message translates to:
  /// **'Customer must enter the correct details of Consignee / Recipient Name (as it appears on their government-approved photo ID) with complete address, nearby landmark, postal code, and contact number for hassle-free delivery.'**
  String get delivery_identified_person_detail;

  /// No description provided for @delivery_location.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location: '**
  String get delivery_location;

  /// No description provided for @delivery_location_detail.
  ///
  /// In en, this message translates to:
  /// **'Orders can be delivered only to Residential and Commercial locations.'**
  String get delivery_location_detail;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @monday_to_friday.
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday, 11:00 AM to 6:00 PM (Timezone, Gulf Standard Time) will be cost'**
  String get monday_to_friday;

  /// No description provided for @once_order_ready.
  ///
  /// In en, this message translates to:
  /// **'Once your order is ready, we will send an email with your tracking information.'**
  String get once_order_ready;

  /// No description provided for @no_metal_statement_title.
  ///
  /// In en, this message translates to:
  /// **'Enter Verify Code'**
  String get no_metal_statement_title;

  /// No description provided for @no_metal_statement_description.
  ///
  /// In en, this message translates to:
  /// **'Please create new metal statement or try again later'**
  String get no_metal_statement_description;

  /// No description provided for @no_data_title.
  ///
  /// In en, this message translates to:
  /// **'No Data To Show'**
  String get no_data_title;

  /// No description provided for @error_description.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get error_description;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @customer_have_enter.
  ///
  /// In en, this message translates to:
  /// **'Customer have to enter the correct details of Consignee / Recipient Name (as it is stated in their photo identification that is approved by the Government) with complete Address, nearby landmark, postal code and contact number for hassle free delivery.'**
  String get customer_have_enter;

  /// No description provided for @oops_not_found.
  ///
  /// In en, this message translates to:
  /// **'Oops! Not found'**
  String get oops_not_found;

  /// No description provided for @no_money_statement_description.
  ///
  /// In en, this message translates to:
  /// **'Please create new money statement or try again later'**
  String get no_money_statement_description;

  /// No description provided for @order_can_be_delivered.
  ///
  /// In en, this message translates to:
  /// **'Orders can be delivered to only Residential & Commercial Location only.'**
  String get order_can_be_delivered;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @enter_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enter_valid_phone;

  /// No description provided for @weight_1_gram.
  ///
  /// In en, this message translates to:
  /// **'1 Gram'**
  String get weight_1_gram;

  /// No description provided for @weight_2_grams.
  ///
  /// In en, this message translates to:
  /// **'2 Grams'**
  String get weight_2_grams;

  /// No description provided for @weight_2_5_grams.
  ///
  /// In en, this message translates to:
  /// **'2.5 Grams'**
  String get weight_2_5_grams;

  /// No description provided for @weight_5_grams.
  ///
  /// In en, this message translates to:
  /// **'5 Grams'**
  String get weight_5_grams;

  /// No description provided for @weight_10_grams.
  ///
  /// In en, this message translates to:
  /// **'10 Grams'**
  String get weight_10_grams;

  /// No description provided for @weight_20_grams.
  ///
  /// In en, this message translates to:
  /// **'20 Grams'**
  String get weight_20_grams;

  /// No description provided for @weight_half_ounce.
  ///
  /// In en, this message translates to:
  /// **'1/2 Ounce'**
  String get weight_half_ounce;

  /// No description provided for @weight_1_ounce.
  ///
  /// In en, this message translates to:
  /// **'1 Ounce'**
  String get weight_1_ounce;

  /// No description provided for @weight_50_grams.
  ///
  /// In en, this message translates to:
  /// **'50 Grams'**
  String get weight_50_grams;

  /// No description provided for @weight_100_grams.
  ///
  /// In en, this message translates to:
  /// **'100 Grams'**
  String get weight_100_grams;

  /// No description provided for @weight_10_tola.
  ///
  /// In en, this message translates to:
  /// **'10 Tola'**
  String get weight_10_tola;

  /// No description provided for @weight_250_grams.
  ///
  /// In en, this message translates to:
  /// **'250 Grams'**
  String get weight_250_grams;

  /// No description provided for @weight_500_grams.
  ///
  /// In en, this message translates to:
  /// **'500 Grams'**
  String get weight_500_grams;

  /// No description provided for @weight_1_kilogram.
  ///
  /// In en, this message translates to:
  /// **'1 Kilogram'**
  String get weight_1_kilogram;

  /// No description provided for @apply_filters_description.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters to quickly view your\ndesired products.'**
  String get apply_filters_description;

  /// No description provided for @casting.
  ///
  /// In en, this message translates to:
  /// **'Casting'**
  String get casting;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @minting.
  ///
  /// In en, this message translates to:
  /// **'Minting'**
  String get minting;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @delete_alert.
  ///
  /// In en, this message translates to:
  /// **'Delete Alert'**
  String get delete_alert;

  /// No description provided for @delete_alert_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this alert?'**
  String get delete_alert_message;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update_alert.
  ///
  /// In en, this message translates to:
  /// **'Update Alert'**
  String get update_alert;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @one_gram_price.
  ///
  /// In en, this message translates to:
  /// **'1 Gram Price'**
  String get one_gram_price;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @previous_bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Previous Bank Accounts'**
  String get previous_bank_accounts;

  /// No description provided for @tap_any_account_to_fill_details.
  ///
  /// In en, this message translates to:
  /// **'Tap any account to fill details automatically'**
  String get tap_any_account_to_fill_details;

  /// No description provided for @tap_to_use.
  ///
  /// In en, this message translates to:
  /// **'Tap to use'**
  String get tap_to_use;

  /// No description provided for @bank_fee_notice.
  ///
  /// In en, this message translates to:
  /// **'A bank fee of AED 25 plus VAT will be applied.'**
  String get bank_fee_notice;

  /// No description provided for @bank_name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bank_name;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @image_upload_successfull.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get image_upload_successfull;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied_to_clipboard;

  /// No description provided for @saved_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Saved to clipboard'**
  String get saved_to_clipboard;

  /// No description provided for @shufti_pro_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed, try again.'**
  String get shufti_pro_verification_failed;

  /// No description provided for @shufti_user_auth_issue.
  ///
  /// In en, this message translates to:
  /// **'User authentication error, try again.'**
  String get shufti_user_auth_issue;

  /// No description provided for @kyc_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'KYC verification failed, please try again.'**
  String get kyc_verification_failed;

  /// No description provided for @kyc_error.
  ///
  /// In en, this message translates to:
  /// **'Verification error, try again.'**
  String get kyc_error;

  /// No description provided for @want_to_change_email.
  ///
  /// In en, this message translates to:
  /// **'Want to change Email?'**
  String get want_to_change_email;

  /// No description provided for @submit_kyc_error.
  ///
  /// In en, this message translates to:
  /// **'Submit KYC Data Error:'**
  String get submit_kyc_error;

  /// No description provided for @no_saved_credentials.
  ///
  /// In en, this message translates to:
  /// **'No saved credentials found.'**
  String get no_saved_credentials;

  /// No description provided for @exit_app.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exit_app;

  /// No description provided for @visit_website.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visit_website;

  /// No description provided for @open_setting.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_setting;

  /// No description provided for @please_check_internet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get please_check_internet;

  /// No description provided for @no_internet.
  ///
  /// In en, this message translates to:
  /// **'No Internet'**
  String get no_internet;

  /// No description provided for @maintainance_description.
  ///
  /// In en, this message translates to:
  /// **'Save In Gold is currently undergoing a scheduled system upgrade to enhance security, stability, and real-time gold trading performance'**
  String get maintainance_description;

  /// No description provided for @server_under_maintainance.
  ///
  /// In en, this message translates to:
  /// **'Server Under Maintenance'**
  String get server_under_maintainance;

  /// No description provided for @swift_code.
  ///
  /// In en, this message translates to:
  /// **'Swift Code'**
  String get swift_code;

  /// No description provided for @account_detail.
  ///
  /// In en, this message translates to:
  /// **'Account Detail'**
  String get account_detail;

  /// No description provided for @email_update_des.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out once your email is updated successfully'**
  String get email_update_des;

  /// No description provided for @entered_wrong_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct OTP'**
  String get entered_wrong_otp;

  /// No description provided for @scan_finger_print.
  ///
  /// In en, this message translates to:
  /// **'Scan your fingerprint to update your email'**
  String get scan_finger_print;

  /// No description provided for @plz_update_email.
  ///
  /// In en, this message translates to:
  /// **'Please update your email'**
  String get plz_update_email;

  /// No description provided for @are_u_sure_to_update_email.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update email to'**
  String get are_u_sure_to_update_email;

  /// No description provided for @change_email.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get change_email;

  /// No description provided for @temporary_credit_title.
  ///
  /// In en, this message translates to:
  /// **'Temporary Credit Active'**
  String get temporary_credit_title;

  /// No description provided for @temporary_credit_message.
  ///
  /// In en, this message translates to:
  /// **'You currently have a temporary credit balance. You cannot send a gift at the moment. Please contact the support team for assistance.'**
  String get temporary_credit_message;

  /// No description provided for @temporary_credit_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get temporary_credit_contact_support;

  /// No description provided for @temperory_credit_detect.
  ///
  /// In en, this message translates to:
  /// **'You currently have a temporary credit balance. You cannot withdraw at the moment. Please contact the support team for assistance.'**
  String get temperory_credit_detect;

  /// No description provided for @temperory_credit_detect_esouq.
  ///
  /// In en, this message translates to:
  /// **'You currently have a temporary credit balance. You cannot buy at the moment. Please contact the support team for assistance.'**
  String get temperory_credit_detect_esouq;

  /// No description provided for @temporary_freezed.
  ///
  /// In en, this message translates to:
  /// **'Account Temporarily Frozen'**
  String get temporary_freezed;

  /// No description provided for @temporary_freezed_account_desc.
  ///
  /// In en, this message translates to:
  /// **'Your account has been temporarily frozen. To restore access, please contact our support team for assistance.'**
  String get temporary_freezed_account_desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
