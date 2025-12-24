import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/api_url.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/dio_network_manager.dart';
import 'package:saveingold_fzco/data/models/ErrorResponse.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/models/SuccessResponse.dart';
import '../../../../data/models/gift_model/AllFriendsApiResponseModel.dart';
import '../../../../data/models/gift_model/AllUserResponse.dart';
import '../../../feature_injection.dart';
import '../states/gift_state/gift_states.dart';

part 'gift_fund_provider.g.dart';

@riverpod
class Gift extends _$Gift {
  @override
  GiftState build() {
    return GiftState();
  }

  /// fetch all users
  Future<void> fetchAllUsers({
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(allUserLoadingState: LoadingState.loading);

      // Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();

      /// headers
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      /// API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllUserApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      /// server call
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          AllUserResponse allFriendsApiResponse = AllUserResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            allUser: allFriendsApiResponse.payload!.allUsers ?? [],
            allUserLoadingState: LoadingState.data,
          );
          getLocator<Logger>().i(
            "Fetched ${allFriendsApiResponse.payload ?? 0} Users successfully.",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            allUserLoadingState: LoadingState.error,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );

          if (errorResponse.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(context: context);
            return;
          }
          break;

        case ServerResponseType.exception:
          state = state.copyWith(allUserLoadingState: LoadingState.error);
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch All User Error: $e");
      state = state.copyWith(allUserLoadingState: LoadingState.error);
    }
  }

  /// Fetch all friends
  Future<void> fetchAllFriends({
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(loadingState: LoadingState.loading);

      // Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(loadingState: LoadingState.error);
        return;
      }
      state = state.copyWith(friends: [], loadingState: LoadingState.data);
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      /// API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllFriendsApiUrl,
        httpMethod: HttpMethod.get,
        headers: headers,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          // Parse response into `AllFriendsApiResponse` model
          AllFriendsApiResponseModel allFriendsApiResponse =
              AllFriendsApiResponseModel.fromJson(
                serverResponse.resultData,
              );
          state = state.copyWith(
            friends: allFriendsApiResponse.payload ?? [],
            loadingState: LoadingState.data,
          );
          getLocator<Logger>().i(
            "Fetched ${allFriendsApiResponse.payload?.length ?? 0} friends successfully.",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            loadingState: LoadingState.error,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );

          /// logout user
          if (errorResponse.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(context: context);
            return;
          }
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Friends Error: $e");
      state = state.copyWith(loadingState: LoadingState.error);
    }
  }

  /// Add friend
  Future<void> addFriend({
    required String friendId,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isAddingFriend: true);

      // Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isAddingFriend: false);
        return;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      final data = {"_id": friendId};
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.addFriendApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: data,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Friend added successfully.");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          /// reload all friends
          if (!context.mounted) return;
          await fetchAllFriends(context: context);

          state = state.copyWith(isAddingFriend: false);

          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isAddingFriend: false,
          );
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");

          /// logout user
          if (errorResponse.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(
              context: context,
            );
            return;
          }
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            isAddingFriend: false,
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Add Friend Error: $e");
      state = state.copyWith(isAddingFriend: false);
    }
  }

  /// delete friend
  Future<void> deleteFriend({
    required String friendId,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isAddingFriend: true);
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken = await SecureStorageService.instance
          .getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isAddingFriend: false);
        return;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      final data = {
        "_id": friendId,
      };

      /// server response
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.deleteFriendApiUrl,
        httpMethod: HttpMethod.patch,
        headers: headers,
        body: data,
      );

      // Handle API Response
      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          getLocator<Logger>().i("Friend deleted successfully.");
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          /// reload all friends
          if (!context.mounted) return;
          Navigator.pop(context);
          await fetchAllFriends(context: context);

          Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}",
          );

          state = state.copyWith(isAddingFriend: false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isAddingFriend: false,
          );
          getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");

          /// logout user
          if (errorResponse.code == 401) {
            if (!context.mounted) return;
            await CommonService.logoutUser(context: context);
            return;
          }
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
          state = state.copyWith(isAddingFriend: false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("deleted Friend Error: $e");
      state = state.copyWith(isAddingFriend: false);
    }
  }

  /// create gift
  // Future<void> createGift({
  //   required String receiverId,
  //   required String receiverName,
  //   required String receiverEmail,
  //   required String receiverPhoneNumber,
  //   required String giftAmount,
  //   required String paymentMethod,
  //   required String comment,
  //   required BuildContext context,
  //   List<Map<String, dynamic>>? selectedDealsData,
  // }) async {
  //   try {
  //     // Set button loading state
  //     state = state.copyWith(loadingState: LoadingState.loading);

  //     String? userId = await LocalDatabase.instance.getUserId();
  //     String? senderId = await LocalDatabase.instance.getUserAccountId();
  //     // String? refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken = await SecureStorageService.instance
  //         .getRefreshToken();
  //     final headers = {
  //       "Authorization": "Bearer $refreshToken",
  //       "Content-Type": "application/json",
  //     };

  //     final body = {
  //       "userId": userId,
  //       'senderId': senderId,
  //       "receiverId": receiverId,
  //       "receiverName": receiverName,
  //       "receiverEmail": receiverEmail,
  //       "giftAmount": giftAmount,
  //       "receiverPhoneNumber": receiverPhoneNumber,
  //       "paymentMethod": paymentMethod,
  //       "comment": comment,
  //     };
  //     if (paymentMethod == "Metal" &&
  //         selectedDealsData != null &&
  //         selectedDealsData.isNotEmpty) {
  //       // Convert the list to JSON string
  //       body["dealsData"] = json.encode(selectedDealsData);
  //     }
  //     if (refreshToken == null) {
  //       getLocator<Logger>().e("No refresh token found!");
  //       state = state.copyWith(isButtonState: false);
  //       return;
  //     }

  //     /// API call
  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       // url: ApiEndpoints.buyGoldApiUrl,
  //       url: ApiEndpoints.createGiftApiUrl,
  //       httpMethod: HttpMethod.post,
  //       headers: headers,
  //       body: body,
  //     );

  //     // Handle API Response
  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         getLocator<Logger>().i("Gift created successfully!");
  //         SuccessResponse successResponse = SuccessResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(
  //           successResponse: successResponse,
  //           loadingState: LoadingState.data,
  //         );

  //         Toasts.getSuccessToast(
  //           text: "${successResponse.payload?.message.toString()}",
  //         );
  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(
  //           errorResponse: errorResponse,
  //           loadingState: LoadingState.error,
  //         );
  //         getLocator<Logger>().e(
  //           "Error: ${errorResponse.payload?.message}",
  //         );

  //         Toasts.getErrorToast(
  //           text: "${errorResponse.payload?.message.toString()}",
  //         );

  //         // logout user
  //         if (errorResponse.code == 401) {
  //           if (!context.mounted) return;
  //           await CommonService.logoutUser(context: context);
  //           return;
  //         }

  //         if (!context.mounted) return;
  //         Navigator.of(context)
  //           ..pop()
  //           ..pop()
  //           ..pop();

  //         break;

  //       case ServerResponseType.exception:
  //         state = state.copyWith(loadingState: LoadingState.error);
  //         getLocator<Logger>().e(
  //           "Exception: ${serverResponse.resultData}",
  //         );
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(e, stackTrace: stackTrace);
  //     getLocator<Logger>().e(
  //       "Create Gift Error: $e",
  //     );
  //     state = state.copyWith(loadingState: LoadingState.error);
  //   }
  // }
  Future<void> createGift({
  required String receiverId,
  required String receiverName,
  required String receiverEmail,
  required String receiverPhoneNumber,
  required String giftAmount,
  required String paymentMethod,
  required String comment,
  required BuildContext context,
  List<Map<String, dynamic>>? selectedDealsData,
}) async {
  try {
    // Set button loading state
    state = state.copyWith(loadingState: LoadingState.loading);

    // Get user info
    String? userId = await LocalDatabase.instance.getUserId();
    String? senderId = await LocalDatabase.instance.getUserAccountId();
    String? refreshToken =
        await SecureStorageService.instance.getRefreshToken();

    if (refreshToken == null) {
      getLocator<Logger>().e("No refresh token found!");
      state = state.copyWith(loadingState: LoadingState.error);
      return;
    }

    final headers = {
      "Authorization": "Bearer $refreshToken",
      "Content-Type": "application/json",
    };

    // Format giftAmount as double
    final double formattedGiftAmount = double.tryParse(giftAmount) ?? 0;

    // Format dealsData amounts as double
    final List<Map<String, dynamic>>? formattedDealsData =
        selectedDealsData?.map((deal) {
      return {
        "tradeId": deal["tradeId"],
        "dealId": deal["dealId"],
        "amount": double.tryParse(deal["amount"].toString()) ?? 0,
      };
    }).toList();

    final body = {
      "userId": userId,
      "senderId": int.tryParse(senderId ?? "0") ?? 0,
      "receiverId": int.tryParse(receiverId) ?? 0,
      "receiverName": receiverName,
      "receiverEmail": receiverEmail,
      "giftAmount": formattedGiftAmount,
      "receiverPhoneNumber": receiverPhoneNumber,
      "paymentMethod": paymentMethod,
      "comment": comment,
    };

    if (paymentMethod == "Metal" && formattedDealsData != null) {
      body["dealsData"] = formattedDealsData;
    }

    // Print body for debugging (with 2 decimal formatting)
    print("API Body: ${jsonEncode(body)}");
    print("Gift Amount: ${formattedGiftAmount.toStringAsFixed(2)}");
    if (formattedDealsData != null) {
      for (var deal in formattedDealsData) {
        print(
            "Deal ${deal['dealId']} Amount: ${(deal['amount'] as double).toStringAsFixed(2)}");
      }
    }

    // API call
    ServerResponse serverResponse = await DioNetworkManager().callAPI(
      url: ApiEndpoints.createGiftApiUrl,
      httpMethod: HttpMethod.post,
      headers: headers,
      body: body,
    );

    // Handle API response
    switch (serverResponse.responseType) {
      case ServerResponseType.success:
        getLocator<Logger>().i("Gift created successfully!");
        SuccessResponse successResponse =
            SuccessResponse.fromJson(serverResponse.resultData);
        state = state.copyWith(
          successResponse: successResponse,
          loadingState: LoadingState.data,
        );
        Toasts.getSuccessToast(
            text: "${successResponse.payload?.message.toString()}");
        break;

      case ServerResponseType.error:
        ErrorResponse errorResponse =
            ErrorResponse.fromJson(serverResponse.resultData);
        state = state.copyWith(
          errorResponse: errorResponse,
          loadingState: LoadingState.error,
        );
        getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
        Toasts.getErrorToast(text: "${errorResponse.payload?.message.toString()}");

        // logout user if unauthorized
        if (errorResponse.code == 401 && context.mounted) {
          await CommonService.logoutUser(context: context);
          return;
        }

        if (context.mounted) {
          Navigator.of(context)
            ..pop()
            ..pop()
            ..pop();
        }
        break;

      case ServerResponseType.exception:
        state = state.copyWith(loadingState: LoadingState.error);
        getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
        break;
    }
  } catch (e, stackTrace) {
    await Sentry.captureException(e, stackTrace: stackTrace);
    getLocator<Logger>().e("Create Gift Error: $e");
    state = state.copyWith(loadingState: LoadingState.error);
  }
}

}
