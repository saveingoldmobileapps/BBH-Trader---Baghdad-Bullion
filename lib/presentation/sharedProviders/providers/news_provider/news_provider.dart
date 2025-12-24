import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:saveingold_fzco/data/models/news_models/NewsAllResponseModel.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/states/news_state/news_state.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../feature_injection.dart';

part 'newsProvider.g.dart';

@riverpod
class NewsAll extends _$NewsAll {
  @override
  NewsAllState build() {
    init();
    return NewsAllState();
  }

  /// Init
  Future<void> init() async {
    getLocator<Logger>().i("NewsAllProvider Initialized");
  }

  // fetch news
  Future<void> fetchNews() async {
    try {
      state = state.copyWith(isLoading: true);

      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllNewsApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          NewsAllResponseModel newsResponse = NewsAllResponseModel.fromJson(
            serverResponse.resultData,
          );

          List<Allnews> newsList = newsResponse.payload?.allnews ?? [];

          state = state.copyWith(newsList: newsList);
          getLocator<Logger>().i(
            "Fetched ${newsList.length} news articles successfully.",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(errorResponse: errorResponse);
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch News Error: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
