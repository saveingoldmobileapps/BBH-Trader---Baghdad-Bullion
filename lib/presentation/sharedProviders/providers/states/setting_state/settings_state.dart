import 'package:saveingold_fzco/data/models/SuccessResponse.dart';

import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/time_zone/time_zone_model.dart';

class SettingsState {
  final bool isLoading;
  final bool isTimeZoneLoading;
  final ErrorResponse? errorResponse;
  final SuccessResponse? successResponse;
  final List<KAllTimezones>? timeZoneList;

  SettingsState({
    this.isLoading = false,
    this.isTimeZoneLoading = false,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.timeZoneList,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  SettingsState copyWith({
    bool? isLoading,
    bool? isTimeZoneLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    List<KAllTimezones>? timeZoneList,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isTimeZoneLoading: isTimeZoneLoading ?? this.isTimeZoneLoading,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      timeZoneList: timeZoneList ?? this.timeZoneList,
    );
  }
}
