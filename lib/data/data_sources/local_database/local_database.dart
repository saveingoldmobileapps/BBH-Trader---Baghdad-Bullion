import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/LoginResponse.dart';
import 'package:saveingold_fzco/data/models/RegisterDetailResponse.dart';
import 'package:saveingold_fzco/data/models/RegisterResponse.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LocalDatabase {
  final _logger = Logger();
  final getStorageInstance = GetStorage();

  static final LocalDatabase _localDatabase = LocalDatabase();

  static LocalDatabase get instance => _localDatabase;

  /// save user login data
  Future<void> saveUserLoginData({
    required LoginResponse loginResponse,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.loginUserData, loginResponse.toJson())
          .then(
            (value) => _logger.i(
              "loginResponseStored: ${loginResponse.toJson()}",
            ),
          );
    } catch (e) {
      getLocator<Logger>().e("saveUserLoginDataError: $e");
    }
  }

  /// save register data
  Future<void> saveRegisterData({
    required RegisterResponse registerResponse,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.loginUserData, registerResponse.toJson())
          .then(
            (value) => _logger.i(
              "registerResponseStored: ${registerResponse.toJson()}",
            ),
          );
    } catch (e) {
      getLocator<Logger>().e("saveUserLoginDataError: $e");
    }
  }

  /// save register data
  Future<void> saveRegisterDetailData({
    required RegisterDetailResponse registerDetailResponse,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.loginUserData, registerDetailResponse.toJson())
          .then(
            (value) => _logger.i(
              "registerDetailResponseStored: ${registerDetailResponse.toJson()}",
            ),
          );
    } catch (e) {
      getLocator<Logger>().e("saveUserLoginDataError: $e");
    }
  }

  Future<bool> areCredentialsSaved() async {
    try {
      final email = await LocalDatabase.instance.read(
        key: Strings.userEmail,
      );
      final password = await getUserPassword();

      final isSaved = email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty;
      _logger.i("areCredentialsSaved: $isSaved");

      return isSaved;
    } catch (e) {
      _logger.e("areCredentialsSavedError: $e");
      return false;
    }
  }

  /// get login user from storage
  Future<LoginResponse?> getLoginUserFromStorage() async {
    try {
      final result = await getStorageInstance.read(Strings.loginUserData);
      _logger.i("getLoginUserStorage: $result");
      return LoginResponse.fromJson(result);
    } catch (e) {
      _logger.e("onGetRegisterUserStorageError: $e");
      return null;
    }
  }

  /// get login token from storage
  Future<String?> getLoginToken() async {
    try {
      final result = await getStorageInstance.read(Strings.userToken);
      _logger.i("getLoginToken: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorLoginToken: $e");
      return null;
    }
  }

  Future<String?> getUserProfileImage() async {
    try {
      final result = await getStorageInstance.read(Strings.profileImage);
      _logger.i("getUerImage: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorGetUerImage: $e");
      return null;
    }
  }

  /// save user login token
  Future<void> saveUserLoginToken({
    required String token,
  }) async {
    try {
      await getStorageInstance.write(Strings.userToken, token).then(
            (value) => _logger.i("loginTokenStored: $token"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<void> storeFaceEnable({
    required bool isEnable,
  }) async {
    try {
      await getStorageInstance.write(Strings.isFaceEnable, isEnable).then(
            (value) => _logger.i("faceIdStored: $isEnable"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<void> storeAutoLogin({
    required bool autoLogin,
  }) async {
    try {
      await getStorageInstance.write(Strings.autoLogin, autoLogin).then(
            (value) => _logger.i("autoLoginStore: $autoLogin"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<void> storeFingerEnable({
    required bool isEnable,
  }) async {
    try {
      await getStorageInstance.write(Strings.isFingerEnable, isEnable).then(
            (value) => _logger.i("fingerIdStored: $isEnable"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<bool?> getFingerEnable() async {
    try {
      final result = await getStorageInstance.read(Strings.isFingerEnable);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  Future<void> setIsEmailVerified({
    required bool isVerified,
  }) async {
    try {
      await getStorageInstance.write(Strings.isEmailVerified, isVerified).then(
            (value) => _logger.i("isEmailVerified: $isVerified"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  } //setIsUserBasicKycVerified

  Future<bool?> getIsEmailVerified() async {
    try {
      final result = await getStorageInstance.read(Strings.isEmailVerified);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  Future<void> setIsDemo({
    required bool isDemo,
  }) async {
    try {
      await getStorageInstance.write(Strings.isDemo, isDemo).then(
            (value) => _logger.i("isEmailVerified: $isDemo"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  } //setIsUserBasicKycVerified

  Future<bool?> getIsDemo() async {
    try {
      final result = await getStorageInstance.read(Strings.isDemo);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  Future<void> setIsUserBasicKycVerified({
    required bool isVerified,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.isUserBasicKycVerified, isVerified)
          .then(
            (value) => _logger.i("isUserBasicKycVerified: $isVerified"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<bool?> getIsUserBasicKycVerified() async {
    try {
      final result = await getStorageInstance.read(
        Strings.isUserBasicKycVerified,
      );
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }
  Future<void> setIsUsertemporaryCreditStatus({
    required bool temporaryCreditStatusIsVerified,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.temporaryCreditStatus, temporaryCreditStatusIsVerified)
          .then(
            (value) => _logger.i("isUserBasicKycVerified: $temporaryCreditStatusIsVerified"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<bool?> getIsUsertemporaryCreditStatus() async {
    try {
      final result = await getStorageInstance.read(
        Strings.temporaryCreditStatus,
      );
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }



  Future<void> setIsUserKycVerified({
    required bool isVerified,
  }) async {
    try {
      await getStorageInstance
          .write(Strings.isUserKycVerified, isVerified)
          .then(
            (value) => _logger.i("isUserKycVerified: $isVerified"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
    }
  }

  Future<bool?> getIsUserKycVerified() async {
    try {
      final result = await getStorageInstance.read(Strings.isUserKycVerified);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  Future<bool?> getAutoLogin() async {
    try {
      final result = await getStorageInstance.read(Strings.autoLogin);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  Future<bool?> getFaceEnable() async {
    try {
      final result = await getStorageInstance.read(Strings.isFaceEnable);
      return result;
    } catch (e) {
      getLocator<Logger>().e("errorToken: $e");
      return null;
    }
  }

  /// get user id from storage
  Future<String?> getUserId() async {
    try {
      final result = await getStorageInstance.read(Strings.userID);
      _logger.i("getUserId: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorUserId: $e");
      return null;
    }
  }

  Future<String?> getUserAccountId() async {
    try {
      final result = await getStorageInstance.read(Strings.userAccountID);
      _logger.i("getUserId: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorUserId: $e");
      return null;
    }
  }

  Future<String?> getUserPassword() async {
    try {
      final result = await getStorageInstance.read(Strings.userPassword);
      _logger.i("getUserPassword: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorUserId: $e");
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      final result = await getStorageInstance.read(Strings.firstName);
      _logger.i("getUserPassword: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorUserId: $e");
      return null;
    }
  }

  Future<String?> getUserLastName() async {
    try {
      final result = await getStorageInstance.read(Strings.lastName);
      _logger.i("getUserPassword: $result");
      return result;
    } catch (e) {
      _logger.e("onErrorUserId: $e");
      return null;
    }
  }

  Future<void> saveUserAccountID({
    required String userId,
  }) async {
    try {
      await getStorageInstance.write(Strings.userAccountID, userId).then(
            (value) => _logger.i("userIDStored: $userId"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  Future<void> storeUserProfile({
    required String profile,
  }) async {
    try {
      await getStorageInstance.write(Strings.profileImage, profile).then(
            (value) => _logger.i("userImageStore: $profile"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  Future<void> storeUserName({
    required String name,
  }) async {
    try {
      await getStorageInstance.write(Strings.firstName, name).then(
            (value) => _logger.i("userImageStore: $name"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  Future<void> storeUserLastName({
    required String name,
  }) async {
    try {
      await getStorageInstance.write(Strings.lastName, name).then(
            (value) => _logger.i("userImageStore: $name"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  Future<void> storeUserId({
    required String id,
  }) async {
    try {
      await getStorageInstance.write(Strings.userId, id).then(
            (value) => _logger.i("userImageStore: $id"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  /// save user id
  Future<void> saveUserIDToken({
    required String userId,
  }) async {
    try {
      await getStorageInstance.write(Strings.userID, userId).then(
            (value) => _logger.i("userIDStored: $userId"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  Future<void> saveUserPassword({
    required String password,
  }) async {
    try {
      await getStorageInstance.write(Strings.userPassword, password).then(
            (value) => _logger.i("passwordStore: $password"),
          );
    } catch (e) {
      getLocator<Logger>().e("errorUserID: $e");
    }
  }

  /// get register user from storage
  Future<RegisterResponse?> getRegisterUserFromStorage() async {
    try {
      final result = await getStorageInstance.read(Strings.loginUserData);
      _logger.i("getRegisterUserStorage: $result");
      return RegisterResponse.fromJson(result);
    } catch (e) {
      _logger.e("onGetRegisterUserStorageError: $e");
      return null;
    }
  }

  /// is User Authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      final result = await getStorageInstance.read(Strings.loginUserData);
      _logger.i("isUserAuthenticated: $result");
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e("isUserAuthenticatedError: $e");
      return false;
    }
  }

  /// read
  Future<dynamic> read({
    required String key,
  }) async {
    final result = await getStorageInstance.read(key);
    _logger.i('$key value is $result');
    return result;
  }

  /// write
  Future<void> write({
    required String key,
    required dynamic value,
  }) async {
    await getStorageInstance.write(key, value);
    _logger.i('$key stored with $value successfully');
    return;
  }

  /// unset
  Future<void> unset({
    required String key,
  }) async {
    await getStorageInstance.remove(key);
    _logger.i('$key removed Successfully');
    return;
  }

  // Future<void> unsetErase() async {
  //   // To Handle all incomplete request that return 401: unauthorize error
  //   // Disable error message for 401 error for 5 sec
  //   // apiUtils.isTokenExpired = true;
  //   Future.delayed(
  //     const Duration(seconds: 5),
  //     () {
  //       // Enable 401 error message after 5 sec
  //       // apiUtils.isTokenExpired = false;
  //     },
  //   );
  //
  //   // await unset(key: Strings.loginUserId);
  //   // await unset(key: Strings.loginEmail);
  //   // await unset(key: Strings.loginFirstName);
  //   // await unset(key: Strings.loginLastName);
  //   // await unset(key: Strings.loginProfilePicture);
  //   // await unset(key: Strings.loginUserToken);
  //   // await unset(key: Strings.loginUserType);
  //   // await unset(key: Strings.loginUserSubscriptionExpiredAt);
  //   return;
  // }

  Future<void> clearAllUserData() async {
    try {
      // Clear biometric-related data
      await unset(key: Strings.isFingerEnable);
      await unset(key: Strings.isFaceEnable);
      await unset(key: Strings.autoLogin);

      // Clear login & register data
      await unset(key: Strings.loginUserData);
      await unset(key: Strings.userToken);
      await unset(key: Strings.userID);
      await unset(key: Strings.userAccountID);
      await unset(key: Strings.userPassword);

      _logger.i("All user and biometric data cleared successfully.");
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      _logger.e("clearAllUserDataError: $e");
    }
  }
}
