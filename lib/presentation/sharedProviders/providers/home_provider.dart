import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/models/AppUpdateResponseModel.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:saveingold_fzco/data/models/user_models/GetUserProfileResponse.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/language_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../data/data_sources/network_sources/network_export.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../screens/setting_screens/support_screen.dart';
import '../../widgets/pop_up_widget.dart';
import 'states/home_state.dart';

part 'home_provider.g.dart';

@riverpod
class Home extends _$Home {
  @override
  HomeState build() {
    init();
    return HomeState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("HomeProvider Initialized");
    final accountId = await LocalDatabase.instance.read(
      key: Strings.userAccountID,
    );
    final firstName = await LocalDatabase.instance.read(
      key: Strings.userFirstName,
    );
    final surname = await LocalDatabase.instance.read(key: Strings.userSurname);
    final phoneNumber = await LocalDatabase.instance.read(
      key: Strings.userPhoneNumber,
    );

    state = state.copyWith(
      accountId: accountId ?? "Unknown Id",
      firstName: firstName ?? "Unknown",
      surname: surname ?? "Unknown",
      phoneNumber: phoneNumber ?? "Unknown",
    );
  }

  /// set button state
  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  /// set upload image state
  void setUploadImageState(bool imageState) {
    state = state.copyWith(isImageState: imageState);
  }

  /// set loading state
  void setLoadingState(LoadingState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  /// get home feed
  /// @param {}
  ///
  Future<void> getHomeFeed({
    required BuildContext context,
    required bool showLoading,
  }) async {
    int maxRetries = 2; // how many times to retry
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        if (showLoading && attempt == 0) {
          setLoadingState(LoadingState.loading);
        }

        final token = await LocalDatabase.instance.getLoginToken();
        final userId = await LocalDatabase.instance.getUserId();
        getLocator<Logger>()
            .i("Attempt $attempt | userId: $userId | token: $token");

        final headers = {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        };

        final body = {
          "userId": userId,
        };

        ServerResponse serverResponse = await DioNetworkManager().callAPI(
          url: ApiEndpoints.getHomeFeedApiUrl,
          headers: headers,
          body: body,
          httpMethod: HttpMethod.get,
        );

        switch (serverResponse.responseType) {
          case ServerResponseType.success:
            GetHomeFeedResponse getHomeFeedResponse =
                GetHomeFeedResponse.fromJson(serverResponse.resultData);

            // update state
            state = state.copyWith(
              getHomeFeedResponse: getHomeFeedResponse,
              isEmailVerified: getHomeFeedResponse.payload?.isEmailVerified,
              isPhoneVerified: getHomeFeedResponse.payload?.isPhoneVerified,
              isUserKYCVerified: getHomeFeedResponse.payload?.isUserKYCVerified,
              isDemo: getHomeFeedResponse.payload?.userType == "Demo"
                  ? true
                  : false,
              isBasicUserVerified:
                  getHomeFeedResponse.payload?.isBasicUserVerified,
            );

            LocalDatabase.instance.setIsEmailVerified(
              isVerified: getHomeFeedResponse.payload?.isEmailVerified ?? false,
            );
            LocalDatabase.instance.setIsDemo(
              isDemo: getHomeFeedResponse.payload?.userType == "Demo"
                  ? true
                  : false,
            );
            LocalDatabase.instance.setIsUserBasicKycVerified(
              isVerified:
                  getHomeFeedResponse.payload?.isBasicUserVerified ?? false,
            );
            LocalDatabase.instance.setIsUsertemporaryCreditStatus(
              temporaryCreditStatusIsVerified:
                  getHomeFeedResponse.payload?.temporaryCreditStatus ?? false,
            );
            LocalDatabase.instance.setIsUserKycVerified(
              isVerified:
                  getHomeFeedResponse.payload?.isUserKYCVerified ?? false,
            );

            if (showLoading) {
              getLocator<Logger>().i(
                "getHomeFeedResponse: ${getHomeFeedResponse.payload?.toJson()}",
              );
            }

            setLoadingState(LoadingState.data);
            checkFreeze(context,getHomeFeedResponse.payload!.isFrozen??false);
            return; // ✅ stop loop on success

          case ServerResponseType.error:
            if (showLoading) {
              ErrorResponse errorResponse =
                  ErrorResponse.fromJson(serverResponse.resultData);
              state = state.copyWith(errorResponse: errorResponse);
              getLocator<Logger>().e(
                "error: ${errorResponse.payload?.message.toString()}",
              );
              Toasts.getErrorToast(
                text: "${errorResponse.payload?.message.toString()}",
              );

              if (errorResponse.code == 401) {
                if (!context.mounted) return;
                await CommonService.logoutUser(context: context);
                return;
              }
              setLoadingState(LoadingState.error);
            }
            break; //  try again if attempt < maxRetries

          case ServerResponseType.exception:
            if (showLoading) {
              getLocator<Logger>().e(
                "ExceptionError: ${serverResponse.resultData}",
              );
              setLoadingState(LoadingState.error);
            }
            break; //  try again
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(e, stackTrace: stackTrace);
        if (showLoading) {
          getLocator<Logger>().e("onError: $e");
          setLoadingState(LoadingState.error);
        }
      }

      attempt++;
      if (attempt < maxRetries) {
        getLocator<Logger>()
            .w("Retrying getHomeFeed... attempt ${attempt + 1}");
        await Future.delayed(const Duration(seconds: 2)); // wait before retry
      }
    }
  }

  Future<void> checkFreeze(BuildContext context, bool isFrozen) async {
    if (isFrozen == true) {
      if (!context.mounted) return;

      await temporaryCreditFreezedPopUpWidget(
        context: context,
        heading: AppLocalizations.of(context)!.temporary_freezed,
        subtitle: AppLocalizations.of(context)!.temporary_freezed_account_desc,
        buttonTitle: AppLocalizations.of(
          context,
        )!.temporary_credit_contact_support,
        icon: Icons.account_balance_wallet_outlined,
        isForce: true, // <<< IMPORTANT
        onButtonPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupportScreen()),
          );
        },
        oncloseButtonPress: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }

          //Navigator.pop(context);
        },
      );
    }
  }

  // Future<void> getHomeFeed({
  //   required BuildContext context,
  //   required bool showLoading,
  // }) async {
  //   try {
  //     if (showLoading) {
  //       setLoadingState(LoadingState.loading);
  //     }

  //     final token = await LocalDatabase.instance.getLoginToken();
  //     final userId = await LocalDatabase.instance.getUserId();
  //     getLocator<Logger>().i("userId: $userId | token: $token");

  //     final headers = {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //     };
  //     final body = {
  //       "userId": userId,
  //     };

  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.getHomeFeedApiUrl,
  //       headers: headers,
  //       body: body,
  //       httpMethod: HttpMethod.get,
  //     );

  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         GetHomeFeedResponse getHomeFeedResponse =
  //             GetHomeFeedResponse.fromJson(
  //               serverResponse.resultData,
  //             );
  //         // update state
  //         state = state.copyWith(
  //           getHomeFeedResponse: getHomeFeedResponse,
  //           isEmailVerified: getHomeFeedResponse.payload?.isEmailVerified,
  //           isPhoneVerified: getHomeFeedResponse.payload?.isPhoneVerified,
  //           isUserKYCVerified: getHomeFeedResponse.payload?.isUserKYCVerified,
  //           isDemo: getHomeFeedResponse.payload?.userType == "Demo"
  //               ? true
  //               : false,
  //           isBasicUserVerified:
  //               getHomeFeedResponse.payload?.isBasicUserVerified,
  //         );

  //         LocalDatabase.instance.setIsEmailVerified(
  //           isVerified: getHomeFeedResponse.payload?.isEmailVerified ?? false,
  //         );
  //         LocalDatabase.instance.setIsDemo(
  //           isDemo: getHomeFeedResponse.payload?.userType == "Demo"
  //               ? true
  //               : false,
  //         );
  //         LocalDatabase.instance.setIsUserBasicKycVerified(
  //           isVerified:
  //               getHomeFeedResponse.payload?.isBasicUserVerified ?? false,
  //         );
  //         LocalDatabase.instance.setIsUserKycVerified(
  //           isVerified: getHomeFeedResponse.payload?.isUserKYCVerified ?? false,
  //         );
  //         if (showLoading) {
  //           getLocator<Logger>().i(
  //             "getHomeFeedResponse: ${getHomeFeedResponse.payload?.toJson()}",
  //           );
  //         }
  //         setLoadingState(LoadingState.data);

  //         break;

  //       case ServerResponseType.error:
  //         if (showLoading) {
  //           ErrorResponse errorResponse = ErrorResponse.fromJson(
  //             serverResponse.resultData,
  //           );
  //           state = state.copyWith(
  //             errorResponse: errorResponse,
  //           );
  //           getLocator<Logger>().e(
  //             "error: ${errorResponse.payload?.message.toString()}",
  //           );
  //           Toasts.getErrorToast(
  //             text: "${errorResponse.payload?.message.toString()}",
  //           );
  //           //HANDLED IN DIO NETWORK
  //           // if (errorResponse.code == 429) {

  //           // }
  //           // if (errorResponse.code == 401 || errorResponse.code == 400) {
  //           if (errorResponse.code == 401) {
  //             if (!context.mounted) return;
  //             await CommonService.logoutUser(context: context);
  //             return;
  //           }
  //           setLoadingState(LoadingState.error);
  //         }

  //         break;
  //       case ServerResponseType.exception:
  //         if (showLoading) {
  //           getLocator<Logger>().e(
  //             "ExceptionError: ${serverResponse.resultData}",
  //           );
  //           setLoadingState(LoadingState.error);
  //         }
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     if (showLoading) {
  //       getLocator<Logger>().e("onError: $e");
  //       setLoadingState(LoadingState.error);
  //     }
  //   }
  // }

  /// get user profile
  /// @param {}
  Future<void> getUserProfile() async {
    int maxRetries = 2; // how many times to retry
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        if (attempt == 0) {
          setLoadingState(LoadingState.loading);
        }

        final token = await LocalDatabase.instance.getLoginToken();
        getLocator<Logger>().i("Attempt $attempt | token: $token");

        final userId = await LocalDatabase.instance.getUserId();
        getLocator<Logger>().i("userId: $userId");

        final headers = {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        };
        final body = {
          "userId": userId,
        };

        ServerResponse serverResponse = await DioNetworkManager().callAPI(
          url: ApiEndpoints.getUserProfileApiUrl,
          headers: headers,
          body: body,
          httpMethod: HttpMethod.get,
        );

        switch (serverResponse.responseType) {
          case ServerResponseType.success:
            GetUserProfileResponse getUserProfileResponse =
                GetUserProfileResponse.fromJson(
              serverResponse.resultData,
            );

            /// update state
            state = state.copyWith(
              getUserProfileResponse: getUserProfileResponse,
              isEmailVerified:
                  getUserProfileResponse.payload?.userProfile?.isEmailVerified,
              isPhoneVerified:
                  getUserProfileResponse.payload?.userProfile?.isPhoneVerified,
              isUserKYCVerified: getUserProfileResponse
                  .payload?.userProfile?.isUserKYCVerified,
              isDemo: getUserProfileResponse.payload?.userProfile?.userType ==
                      "Demo"
                  ? true
                  : false,
              userEmail: getUserProfileResponse.payload?.userProfile?.email,
            );
            LocalDatabase.instance.storeUserProfile(
              profile:
                  getUserProfileResponse.payload?.userProfile?.imageUrl ?? "",
            );
            LocalDatabase.instance.storeUserName(
              name: getUserProfileResponse.payload?.userProfile?.firstName!.en ?? "",
            );
            LocalDatabase.instance.storeUserLastName(
              name: getUserProfileResponse.payload?.userProfile?.surname!.en ??
                  "",
            );
            LocalDatabase.instance.saveUserAccountID(
              userId:
                  getUserProfileResponse.payload?.userProfile?.accountId ?? "",
            );
            if (getUserProfileResponse.payload!.userProfile!.language !=
                CommonService.lang) {
              final languageNotifier = ref.read(languageProvider.notifier);
              languageNotifier.updateLanguage(
                  language: CommonService.lang,
                  context: navigatorKey.currentContext!,
                  isDashboard: false);
            }
            getLocator<Logger>().i(
              "getUserProfileResponse: ${getUserProfileResponse.payload?.toJson()}",
            );
            setLoadingState(LoadingState.data);
            CommonService.connectSocket();
            return; //  success, stop retrying

          case ServerResponseType.error:
            ErrorResponse errorResponse =
                ErrorResponse.fromJson(serverResponse.resultData);
            state = state.copyWith(errorResponse: errorResponse);

            getLocator<Logger>().e(
              "error: ${errorResponse.payload?.message.toString()}",
            );
            Toasts.getErrorToast(
              text: "${errorResponse.payload?.message.toString()}",
            );
            setLoadingState(LoadingState.error);
            break; //  retry if attempts left

          case ServerResponseType.exception:
            getLocator<Logger>().e(
              "ExceptionError: ${serverResponse.resultData}",
            );
            setLoadingState(LoadingState.error);
            break; //  retry if attempts left
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(e, stackTrace: stackTrace);
        getLocator<Logger>().e("onError: $e");
        setLoadingState(LoadingState.error);
      }

      attempt++;
      if (attempt < maxRetries) {
        getLocator<Logger>()
            .w("Retrying getUserProfile... attempt ${attempt + 1}");
        await Future.delayed(const Duration(seconds: 2)); // wait before retry
      }
    }
  }

  // Future<void> getUserProfile() async {
  //   try {
  //     setLoadingState(LoadingState.loading);

  //     final token = await LocalDatabase.instance.getLoginToken();
  //     getLocator<Logger>().i("token: $token");

  //     final userId = await LocalDatabase.instance.getUserId();
  //     getLocator<Logger>().i("userId: $userId");

  //     final headers = {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //     };
  //     final body = {
  //       "userId": userId,
  //     };

  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.getUserProfileApiUrl,
  //       headers: headers,
  //       body: body,
  //       httpMethod: HttpMethod.get,
  //     );

  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         GetUserProfileResponse getUserProfileResponse =
  //             GetUserProfileResponse.fromJson(
  //           serverResponse.resultData,
  //         );

  //         /// update state
  //         state = state.copyWith(
  //           getUserProfileResponse: getUserProfileResponse,
  //           isEmailVerified:
  //               getUserProfileResponse.payload?.userProfile?.isEmailVerified,
  //           isPhoneVerified:
  //               getUserProfileResponse.payload?.userProfile?.isPhoneVerified,
  //           isUserKYCVerified:
  //               getUserProfileResponse.payload?.userProfile?.isUserKYCVerified,
  //           isDemo:
  //               getUserProfileResponse.payload?.userProfile?.userType == "Demo"
  //                   ? true
  //                   : false,
  //           userEmail: getUserProfileResponse.payload?.userProfile?.email,
  //         );
  //         getLocator<Logger>().i(
  //           "getUserProfileResponse: ${getUserProfileResponse.payload?.toJson()}",
  //         );
  //         setLoadingState(LoadingState.data);

  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(
  //           errorResponse: errorResponse,
  //         );
  //         getLocator<Logger>().e(
  //           "error: ${errorResponse.payload?.message.toString()}",
  //         );
  //         Toasts.getErrorToast(
  //           text: "${errorResponse.payload?.message.toString()}",
  //         );
  //         setLoadingState(LoadingState.error);
  //         break;
  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e(
  //           "ExceptionError: ${serverResponse.resultData}",
  //         );
  //         setLoadingState(LoadingState.error);
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(e, stackTrace: stackTrace);
  //     getLocator<Logger>().e("onError: $e");
  //     setLoadingState(LoadingState.error);
  //   }
  // }

  Future<void> checkAppUpdate() async {
    try {
      final token = await LocalDatabase.instance.getLoginToken();
      getLocator<Logger>().i("token: $token");

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
      final body = {
        "version": "v2",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.appUpdateApiUrl,
        headers: headers,
        body: body,
        httpMethod: HttpMethod.get,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          AppUpdateResponseModel appUpdateResponse =
              AppUpdateResponseModel.fromJson(
            serverResponse.resultData,
          );

          /// update state
          state = state.copyWith(appUpdateResponse: appUpdateResponse);
          getLocator<Logger>().i(
            "appUpdateResponse: ${appUpdateResponse.payload?.toJson()}",
          );
          setLoadingState(LoadingState.data);

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );

          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );

          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e("onError: $e");
    }
  }
}
