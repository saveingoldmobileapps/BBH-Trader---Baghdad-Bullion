import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/AppUpdateResponseModel.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:saveingold_fzco/data/models/user_models/GetUserProfileResponse.dart';
class HomeState {
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final AppUpdateResponseModel appUpdateResponse;
  final GetHomeFeedResponse getHomeFeedResponse;
  final GetUserProfileResponse getUserProfileResponse;

  /// variable and enum
  final LoadingState loadingState;
  final bool isButtonState;
  final bool isImageState;

  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isUserKYCVerified;
  final bool isBasicUserVerified;
  final bool isDemo;

  /// Updated: firstName and surname as Map<String, String>
  final Map<String, String> firstName;
  final Map<String, String> surname;

  final String accountId;
  final String userEmail;
  final String phoneNumber;

  final String deviceName;
  final String deviceType;
  final String operatingSystem;

  HomeState({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetHomeFeedResponse? getHomeFeedResponse,
    GetUserProfileResponse? getUserProfileResponse,
    AppUpdateResponseModel? appUpdateResponse,

    /// variables and enums
    this.loadingState = LoadingState.loading,
    this.isButtonState = false,
    this.isImageState = false,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isUserKYCVerified = false,
    this.isBasicUserVerified = false,
    this.isDemo = false,
    this.userEmail = '',
    this.phoneNumber = '',
    this.accountId = '',
    this.deviceName = '',
    this.deviceType = '',
    this.operatingSystem = '',

    /// Updated fields
    Map<String, String>? firstName,
    Map<String, String>? surname,
  })  : errorResponse = errorResponse ?? ErrorResponse(),
        appUpdateResponse = appUpdateResponse ?? AppUpdateResponseModel(),
        successResponse = successResponse ?? SuccessResponse(),
        getHomeFeedResponse = getHomeFeedResponse ?? GetHomeFeedResponse(),
        getUserProfileResponse =
            getUserProfileResponse ?? GetUserProfileResponse(),
        firstName = firstName ?? {'en': '', 'ar': ''},
        surname = surname ?? {'en': '', 'ar': ''};

  HomeState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetHomeFeedResponse? getHomeFeedResponse,
    GetUserProfileResponse? getUserProfileResponse,
    AppUpdateResponseModel? appUpdateResponse,

    /// variables and enums
    LoadingState? loadingState,
    bool? isButtonState,
    bool? isImageState,
    bool? isDemo,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isUserKYCVerified,
    bool? isBasicUserVerified,
    String? userEmail,
    String? phoneNumber,
    String? accountId,
    String? deviceName,
    String? deviceType,
    String? operatingSystem,

    /// Updated fields
    Map<String, String>? firstName,
    Map<String, String>? surname,
  }) {
    return HomeState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      getHomeFeedResponse: getHomeFeedResponse ?? this.getHomeFeedResponse,
      getUserProfileResponse:
          getUserProfileResponse ?? this.getUserProfileResponse,
      appUpdateResponse: appUpdateResponse ?? this.appUpdateResponse,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isImageState: isImageState ?? this.isImageState,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isUserKYCVerified: isUserKYCVerified ?? this.isUserKYCVerified,
      isBasicUserVerified: isBasicUserVerified ?? this.isBasicUserVerified,
      userEmail: userEmail ?? this.userEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountId: accountId ?? this.accountId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      isDemo: isDemo ?? this.isDemo,
    );
  }
}

// class HomeState {
//   final ErrorResponse errorResponse;
//   final SuccessResponse successResponse;
//   final AppUpdateResponseModel appUpdateResponse;
//   final GetHomeFeedResponse getHomeFeedResponse;
//   final GetUserProfileResponse getUserProfileResponse;

//   /// variable and enum
//   final LoadingState loadingState;
//   final bool isButtonState;
//   final bool isImageState;

//   final bool isPhoneVerified;
//   final bool isEmailVerified;
//   final bool isUserKYCVerified;
//   final bool isBasicUserVerified;
//   final bool isDemo;
//   final String firstName;
//   final String surname;
//   final String accountId;
//   final String userEmail;
//   final String phoneNumber;

//   final String deviceName;
//   final String deviceType;
//   final String operatingSystem;

//   // Constructor with optional named parameters and default values using null-aware operators.
//   HomeState({
//     ErrorResponse? errorResponse,
//     SuccessResponse? successResponse,
//     GetHomeFeedResponse? getHomeFeedResponse,
//     GetUserProfileResponse? getUserProfileResponse,
//     AppUpdateResponseModel? appUpdateResponse,

//     /// variables and enums
//     this.loadingState = LoadingState.loading,
//     this.isButtonState = false,
//     this.isImageState = false,
//     this.isPhoneVerified = false,
//     this.isEmailVerified = false,
//     this.isUserKYCVerified = false,
//     this.isBasicUserVerified = false,
//     this.isDemo = false,
//     this.userEmail = '',
//     this.firstName = '',
//     this.phoneNumber = '',
//     this.surname = '',
//     this.accountId = '',
//     this.deviceName = '',
//     this.deviceType = '',
//     this.operatingSystem = '',
//   })  : errorResponse = errorResponse ?? ErrorResponse(),
//         appUpdateResponse = appUpdateResponse ?? AppUpdateResponseModel(),
//         successResponse = successResponse ?? SuccessResponse(),
//         getHomeFeedResponse = getHomeFeedResponse ?? GetHomeFeedResponse(),
//         getUserProfileResponse =
//             getUserProfileResponse ?? GetUserProfileResponse();

//   // copyWith method to create a new instance with updated values
//   HomeState copyWith({
//     ErrorResponse? errorResponse,
//     SuccessResponse? successResponse,
//     GetHomeFeedResponse? getHomeFeedResponse,
//     GetUserProfileResponse? getUserProfileResponse,
//     AppUpdateResponseModel? appUpdateResponse,

//     /// variables and enums
//     LoadingState? loadingState,
//     bool? isButtonState,
//     bool? isImageState,
//     bool? isDemo,
//     bool? isPhoneVerified,
//     bool? isEmailVerified,
//     bool? isUserKYCVerified,
//     bool? isBasicUserVerified,
//     String? userEmail,
//     String? firstName,
//     String? phoneNumber,
//     String? surname,
//     String? accountId,
//     String? deviceName,
//     String? deviceType,
//     String? operatingSystem,
//   }) {
//     return HomeState(
//       errorResponse: errorResponse ?? this.errorResponse,
//       successResponse: successResponse ?? this.successResponse,
//       getHomeFeedResponse: getHomeFeedResponse ?? this.getHomeFeedResponse,
//       getUserProfileResponse:
//           getUserProfileResponse ?? this.getUserProfileResponse,
//       appUpdateResponse: appUpdateResponse ?? this.appUpdateResponse,

//       ///variables and enums
//       loadingState: loadingState ?? this.loadingState,
//       isButtonState: isButtonState ?? this.isButtonState,
//       isImageState: isImageState ?? this.isImageState,

//       isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
//       isEmailVerified: isEmailVerified ?? this.isEmailVerified,
//       isUserKYCVerified: isUserKYCVerified ?? this.isUserKYCVerified,
//       isBasicUserVerified: isBasicUserVerified ?? this.isBasicUserVerified,

//       userEmail: userEmail ?? this.userEmail,
//       firstName: firstName ?? this.firstName,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       surname: surname ?? this.surname,
//       accountId: accountId ?? this.accountId,
//       deviceName: deviceName ?? this.deviceName,
//       deviceType: deviceType ?? this.deviceType,
//       isDemo: isDemo ?? this.isDemo,
//       operatingSystem: operatingSystem ?? this.operatingSystem,
//     );
//   }
// }
