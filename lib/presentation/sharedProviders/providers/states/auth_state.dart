import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/LoginResponse.dart';
import 'package:saveingold_fzco/data/models/RefreshTokenResponse.dart';
import 'package:saveingold_fzco/data/models/RegisterResponse.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/UploadResidencyResponse.dart';
import 'package:saveingold_fzco/data/models/get_all_country/GetAllCountryResponseModel.dart';

class AuthState {
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final SuccessResponse otpSuccessResponse;
  final List<KAllCountries> countries;
  final LoginResponse loginResponse;
  final RegisterResponse registerResponse;
  final RefreshTokenResponse refreshTokenResponse;
  final UploadResidencyResponse uploadResidencyResponse;

  /// variables and enum
  final LoadingState loadingState;
  final bool isButtonState;
  final bool isImageState;
  final String deviceName;
  final String deviceType;
  final String operatingSystem;
  final String deviceIpAddress;
  final String deviceUniqueID;
  final String residencyPDFUrl;

  /// OTP received from API (for local verification)
  final String oneTimePassword;

  AuthState({
    ErrorResponse? errorResponse,
    this.countries = const [],
    SuccessResponse? successResponse,
    SuccessResponse? otpSuccessResponse,
    LoginResponse? loginResponse,
    RegisterResponse? registerResponse,
    RefreshTokenResponse? refreshTokenResponse,
    UploadResidencyResponse? uploadResidencyResponse,
    this.loadingState = LoadingState.loading,
    this.isButtonState = false,
    this.isImageState = false,
    this.deviceName = '',
    this.deviceType = '',
    this.operatingSystem = '',
    this.deviceIpAddress = '',
    this.deviceUniqueID = '',
    this.residencyPDFUrl = '',
    this.oneTimePassword = '',
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse(),
       otpSuccessResponse = otpSuccessResponse ?? SuccessResponse(),
       loginResponse = loginResponse ?? LoginResponse(),
       registerResponse = registerResponse ?? RegisterResponse(),
       uploadResidencyResponse =
           uploadResidencyResponse ?? UploadResidencyResponse(),
       refreshTokenResponse = refreshTokenResponse ?? RefreshTokenResponse();

  AuthState copyWith({
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    SuccessResponse? otpSuccessResponse,
    LoginResponse? loginResponse,
    RegisterResponse? registerResponse,
    RefreshTokenResponse? refreshTokenResponse,
    List<KAllCountries>? countries,
    UploadResidencyResponse? uploadResidencyResponse,
    LoadingState? loadingState,
    bool? isButtonState,
    bool? isImageState,
    String? deviceName,
    String? deviceType,
    String? operatingSystem,
    String? deviceIpAddress,
    String? deviceUniqueID,
    String? residencyPDFUrl,
    String? oneTimePassword, // <--- updated copyWith
  }) {
    return AuthState(
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      otpSuccessResponse: otpSuccessResponse ?? this.otpSuccessResponse,
      loginResponse: loginResponse ?? this.loginResponse,
      registerResponse: registerResponse ?? this.registerResponse,
      refreshTokenResponse: refreshTokenResponse ?? this.refreshTokenResponse,
      countries: countries ?? this.countries,
      uploadResidencyResponse:
          uploadResidencyResponse ?? this.uploadResidencyResponse,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isImageState: isImageState ?? this.isImageState,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      deviceIpAddress: deviceIpAddress ?? this.deviceIpAddress,
      deviceUniqueID: deviceUniqueID ?? this.deviceUniqueID,
      residencyPDFUrl: residencyPDFUrl ?? this.residencyPDFUrl,
      oneTimePassword: oneTimePassword ?? this.oneTimePassword, // <--- set OTP here
    );
  }
}
