import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/news_models/NewsAllResponseModel.dart';

import '../../../../../data/models/ErrorResponse.dart';

class NewsAllState {
  final List<Allnews> newsList;
  final bool isLoading;
  final ErrorResponse? errorResponse;
  final SuccessResponse? successResponse;

  NewsAllState({
    this.newsList = const [],
    this.isLoading = false,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  NewsAllState copyWith({
    List<Allnews>? newsList,
    bool? isLoading,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
  }) {
    return NewsAllState(
      newsList: newsList ?? this.newsList,
      isLoading: isLoading ?? this.isLoading,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
    );
  }
}
