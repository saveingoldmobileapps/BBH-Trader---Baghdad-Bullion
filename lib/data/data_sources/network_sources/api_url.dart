import 'package:saveingold_fzco/core/core_export.dart';

import 'network_export.dart';

class ApiEndpoints {
  // Base URL is fetched dynamically from EnvUtils
  static String get baseUrl => EnvUtils.getBaseUrl();
  static String get playStoreUrl =>
      "https://play.google.com/store/apps/details?id=ae.saveingold.saveingold.fzco";
  static String get appStoreUrl =>
      "https://apps.apple.com/ae/app/save-in-gold-fzco/id6739995185";

  /// endpoints
  static String get loginApiUrl => "$baseUrl/auth/login/${CommonService.lang}";

  static String get deleteUserAccountApiUrl =>
      "$baseUrl/auth/user/delete/${CommonService.lang}";
  static String get changeUserAccountApiUrl =>
      "$baseUrl/service/settings/updateAccountType/${CommonService.lang}";

  static String get loginWithTokenApiUrl =>
      "$baseUrl/auth/refreshLoginCredentials/${CommonService.lang}";

  static String get registerApiUrl =>
      "$baseUrl/auth/register/${CommonService.lang}";

  static String get refreshTokenApiUrl =>
      "$baseUrl/auth/refreshToken/${CommonService.lang}";

  static String get getAllUserApiUrl =>
      "$baseUrl/auth/user/getAllUserIds/${CommonService.lang}";

  static String get updatePasswordUrl =>
      "$baseUrl/auth/userProfile/password/update/${CommonService.lang}";
  static String get updateLanguageUrl =>
      "$baseUrl/service/settings/updateLanguage/${CommonService.lang == "en" ? "ar" : "en"}";

  static String get updateAccountType =>
      "$baseUrl/service/settings/updateAccountType/${CommonService.lang}";

  static String get uploadResidencyPDFApiUrl =>
      "$baseUrl/auth/userProfile/residencyPDF/upload/${CommonService.lang}";
  static String get uploadKycDocApiUrl =>
      "$baseUrl/service/customKYC/uploadFiles/${CommonService.lang}";
  static String get nomineePDFApiUrl =>
      "$baseUrl/service/esouq/nomineeDocument/upload/${CommonService.lang}";
  static String get submitKyc =>
      "$baseUrl/service/customKYC/saveData/${CommonService.lang}";

  ///----
  static String get registerDetailApiUrl =>
      "$baseUrl/auth/register/detail/${CommonService.lang}";

  static String get registerEmailVerifyPasscodeApiUrl =>
      "$baseUrl/auth/verifyOTPWithEmail/${CommonService.lang}";
  static String get updateUserEmail =>
      "$baseUrl/auth/emailUpdate/${CommonService.lang}";
  static String get registerPhoneVerifyPasscodeApiUrl =>
      "$baseUrl/auth/verifyOTPWithPhone/${CommonService.lang}";

  static String get resendPhonePasscodeApiUrl =>
      "$baseUrl/auth/resendOTPForPhone/${CommonService.lang}";

  static String get resendEmailPasscodeApiUrl =>
      "$baseUrl/auth/resendOTPForEmail/${CommonService.lang}";
  static String get allEmailPasscodeApiUrl =>
      "$baseUrl/auth/sendOtpToAnyEmail/${CommonService.lang}";
  static String get preVerifyApiUrl =>
      "$baseUrl/auth/register/preVerify/${CommonService.lang}";
  // kyc
  static String get kycFirstStepApiUrl =>
      "$baseUrl/auth/kyc/firstStep/${CommonService.lang}";

  ///userProfile/kycData/update
  static String get reUploadkycFirstStepApiUrl =>
      "$baseUrl/auth/userProfile/kycData/update/${CommonService.lang}";
  static String get resendVerifyPasscodeApiUrl =>
      "$baseUrl/auth/resendOneTimePassword/${CommonService.lang}";

  static String get addNewPasswordApiUrl =>
      "$baseUrl/auth/addNewPassword/${CommonService.lang}";
  static String get reUploadKycDataUrl =>
      "$baseUrl/auth/userProfile/kycData/update/${CommonService.lang}";
  static String get userChangePasswordApiUrl =>
      "$baseUrl/auth/userProfile/change/password/${CommonService.lang}";

  static String get changeUserProfileImageApiUrl =>
      "$baseUrl/auth/userProfile/update/image/${CommonService.lang}";

  ///
  static String get getHomeFeedApiUrl =>
      "$baseUrl/service/homePageData/getById/${CommonService.lang}";

  static String get getUserProfileApiUrl =>
      "$baseUrl/auth/userProfile/${CommonService.lang}";

  static String get updateProfileApiUrl =>
      "$baseUrl/service/userInfo/update/${CommonService.lang}";
  static String get uploadProfileApiUrl =>
      "$baseUrl/auth/userProfile/profileImage/upload/${CommonService.lang}";
  static String get addCCAvenueTransactionApiUrl =>
      "$baseUrl/service/ccavenue/add/${CommonService.lang}";

  // static String get getNotifications => "$baseUrl/service/notification/getAll";

  static String get getAllBranchesApiUrl =>
      "$baseUrl/service/loanRequest/getAllBranches/${CommonService.lang}";
  static String get getAllBranchesByIdApiUrl =>
      "$baseUrl/service/esouq/getBranchesByProductId/${CommonService.lang}";
  static String get submitLoanRequestUrl =>
      "$baseUrl/service/loanRequest/create//${CommonService.lang}";

  static String get addFriendApiUrl =>
      "$baseUrl/service/friend/add/${CommonService.lang}";

  static String get getAllFriendsApiUrl =>
      "$baseUrl/service/friend/getAll/${CommonService.lang}";

  static String get deleteFriendApiUrl =>
      "$baseUrl/service/friend/delete/${CommonService.lang}";

  static String get getAllEsouqProductsRequestApiUrl =>
      "$baseUrl/service/esouq/products/getAll/${CommonService.lang}";

  static String get getAllEsouqOrdersUrlApiUrl =>
      "$baseUrl/service/esouq/order/getAll/${CommonService.lang}";

  static String get getAllLoanApiUrl => "$baseUrl/service/loanRequest/getAll/${CommonService.lang}";

  static String get updateLoanApiUrl => "$baseUrl/service/loanRequest/update?/${CommonService.lang}";

  static String get deleteLoanApiUrl => "$baseUrl/service/loanRequest/delete/${CommonService.lang}";

  static String get createOrderApiUrl =>
      "$baseUrl/service/esouq/order/create/${CommonService.lang}";

  static String get shuftiProApiUrl =>
      "$baseUrl/service/kyc/saveData/${CommonService.lang}";

  static String get createGiftApiUrl =>
      "$baseUrl/service/gift/create/${CommonService.lang}";
  static String get appUpdateApiUrl =>
      "$baseUrl/service/settings/getVersion/${CommonService.lang}";

  static String get createTradeApiUrl =>
      '$baseUrl/service/trade/create/${CommonService.lang}';

  static String get buyGoldApiUrl =>
      '$baseUrl/service/trade/buyGold/${CommonService.lang}';

  static String get sellGoldApiUrl =>
      '$baseUrl/service/trade/sellGold/${CommonService.lang}';

  static String get closeTradeDealApiUrl =>
      '$baseUrl/service/trade/update/${CommonService.lang}';

  static String get getUserStatementsApiUrl =>
      '$baseUrl/service/user/statement/${CommonService.lang}';

  static String get tradeDeleteApiUrl =>
      '$baseUrl/service/trade/delete/${CommonService.lang}';
  static String get updateByOrderApiUrl =>
      '$baseUrl/service/trade/updateBuyOrder/${CommonService.lang}';
  static String get updateSellOrderApiUrl =>
      '$baseUrl/service/trade/updateSellOrder/${CommonService.lang}';
  static String get getUserMoneyStatementsApiUrl =>
      '$baseUrl/service/user/moneyStatement/${CommonService.lang}';

  static String get getUserGramStatementsApiUrl =>
      '$baseUrl/service/statement/gramBalance/${CommonService.lang}';

  static String get getUserMetalStatementsApiUrl =>
      '$baseUrl/service/user/metalStatement/${CommonService.lang}';

  static String get getOrderByIdApiUrl =>
      "$baseUrl/service/esouq/order/getById/${CommonService.lang}";

  static String get getGoldPriceApiUrl => '$baseUrl/user/fixParser/livePricing';

  static String get getGoldOldPriceApiUrl =>
      '$baseUrl/user/fixParser/liveGoldPrice';

  static String get getNotificationsApiUrl =>
      '$baseUrl/notification/getAll/${CommonService.lang}';

  static String get updateTimeZoneApiUrl =>
      '$baseUrl/auth/userProfile/timezone/${CommonService.lang}';
  static String get logoutUserApiUrl =>
      '$baseUrl/auth/logout/${CommonService.lang}';

  static String get downloadStatementApiUrl =>
      "$baseUrl/service/user/exportStatement/${CommonService.lang}";

  static String get getCurrentGoldPriceApiUrl =>
      "$baseUrl/service/trade/chart/${CommonService.lang}";

  static String get getAllCountriesApiUrl =>
      "$baseUrl/service/countries/getAll/${CommonService.lang}";

  static String get getAllNewsApiUrl =>
      "$baseUrl/service/news/getAll/${CommonService.lang}";
  //
  static String get withdrawApiUrl =>
      "$baseUrl/service/withdraw/create/${CommonService.lang}";
  static String get getAllCardUrl =>
      "$baseUrl/service/card/getAllById/${CommonService.lang}";
  static String get deleteCardUrl =>
      "$baseUrl/service/card/delete/${CommonService.lang}";
  static String get createCardUrl =>
      "$baseUrl/service/card/create/${CommonService.lang}";
  static String get editCardUrl =>
      "$baseUrl/service/card/update/${CommonService.lang}";
  static String get cancelWithdrawApiUrl =>
      "$baseUrl/service/withdraw/cancel/${CommonService.lang}";

  static String get getAllWithdrawalApiUrl =>
      "$baseUrl/service/withdraw/getAll/${CommonService.lang}";

  static String get getAllBanksApiUrl =>
      "$baseUrl/service/banks/getAll/${CommonService.lang}";

  static String get getBankDetailApiUrl =>
      "$baseUrl/service/banks/getBankDetailsById/${CommonService.lang}";
  static String get getAllTimeZoneApiUrl =>
      "$baseUrl/service/countries/getAllTimezones/${CommonService.lang}";
  static String get payLoanBack => "$baseUrl/service/loanReturn/payLoanBack/${CommonService.lang}";

  //alret
  static String get getAllAlert =>
      "$baseUrl/service/alert/getAllById/${CommonService.lang}";
  static String get createAlert =>
      "$baseUrl/service/alert/create/${CommonService.lang}";
  static String get updateAlert =>
      "$baseUrl/service/alert/update/${CommonService.lang}";
  static String get deleteAlert =>
      "$baseUrl/service/alert/delete/${CommonService.lang}";
}
