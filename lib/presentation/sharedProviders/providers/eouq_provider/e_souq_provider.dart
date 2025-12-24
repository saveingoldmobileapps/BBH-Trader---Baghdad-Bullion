import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saveingold_fzco/core/enums/loading_state.dart';
import 'package:saveingold_fzco/core/sound_services.dart';
import 'package:saveingold_fzco/core/sounds/app_sounds.dart';
import 'package:saveingold_fzco/core/theme/const_toasts.dart';
import 'package:saveingold_fzco/data/models/SuccessResponse.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/data_sources/local_database/local_database.dart';
import '../../../../data/data_sources/local_database/secure_database.dart';
import '../../../../data/data_sources/network_sources/api_url.dart';
import '../../../../data/data_sources/network_sources/dio_network_manager.dart';
import '../../../../data/models/ErrorResponse.dart';
import '../../../../data/models/bank_models/BankBranchResponse.dart';
import '../../../../data/models/esouq_model/GetAllProductResponse.dart';
import '../../../../data/models/esouq_model/GetOrderDetailResponse.dart';
import '../../../feature_injection.dart';
import '../states/e_souq_states.dart';

part 'eSouqProvider.g.dart';

@riverpod
class Esouq extends _$Esouq {
  @override
  EsouqState build() {
    return EsouqState();
  }

  /// set button state
  void setButtonState(bool buttonState) {
    state = state.copyWith(isButtonState: buttonState);
  }

  /// set loading state
  void setLoadingState(LoadingState loadingState) {
    state = state.copyWith(loadingState: loadingState);
  }

  Future<void> fetchBankBranches({required String productId}) async {
    try {
      getLocator<Logger>().i("Starting fetchBankBranches...");
      setLoadingState(LoadingState.loading);
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      getLocator<Logger>().i("Refresh token: $refreshToken");

      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found");
        setLoadingState(LoadingState.error);
        return;
      }

      final headers = {
        "authorization": "Bearer $refreshToken",
      };
      getLocator<Logger>().i(
        "Calling API: ${ApiEndpoints.getAllBranchesByIdApiUrl}",
      );
      final body = {
        "productId": productId,
      };
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllBranchesByIdApiUrl,
        httpMethod: HttpMethod.get,
        body: body,
        headers: headers,
      );

      getLocator<Logger>().i(
        "API Response: ${serverResponse.responseType}, Data: ${serverResponse.resultData}",
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          BankBranchesApiResponseModel getAllBranchesResponse =
              BankBranchesApiResponseModel.fromJson(serverResponse.resultData);
          getLocator<Logger>().i(
            "Parsed branches: ${getAllBranchesResponse.payload!.length} branches",
          );
          setLoadingState(LoadingState.data);
          state = state.copyWith(
            getAllBranchesResponse: getAllBranchesResponse,
            loadingState: LoadingState.data,
          );
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          getLocator<Logger>().e(
            "Error Response: ${errorResponse.payload?.message}",
          );
          setLoadingState(LoadingState.error);
          state = state.copyWith(
            errorResponse: errorResponse,
            loadingState: LoadingState.error,
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception while loading bank branch: ${serverResponse.resultData}",
          );
          setLoadingState(LoadingState.error);
          state = state.copyWith(
            loadingState: LoadingState.error,
          );
          break;
      }
    } catch (e, stackTrace) {
      getLocator<Logger>().e("Fetch Branch Error: $e, StackTrace: $stackTrace");
      await Sentry.captureException(e, stackTrace: stackTrace);
      setLoadingState(LoadingState.error);
      state = state.copyWith(
        loadingState: LoadingState.error,
      );
    }
  }

  void setSelectedBranch({
    required String branchName,
    required String branchId,
  }) {
    debugPrint("setSelectedBranch: $branchName | brandId: $branchId");
    state = state.copyWith(
      selectedBranch: branchName,
      selectedBranchId: branchId,
    );
  }

  /// Fetch Esouq products with pagination
  Future<void> fetchEsouqProducts({
    num paramPage = 1,
    num paramLimit = 30,
    String? paramWeight,
    String? paramWeightCategory,
    // Add this parameter
    bool? reset,
  }) async {
    try {
      // Prevent multiple simultaneous fetches
      if (state.isLoading) return;

      /// Reset products list if reset is true
      if (reset!) {
        state = state.copyWith(isLoading: true);
        state = state.copyWith(products: []);
      }

      /// Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();

      /// Construct query parameters
      final Map<String, dynamic> queryParameters = {
        'paramPage': paramPage,
        'paramLimit': paramLimit,
      };

      // Add paramWeight and paramWeightCategory only if paramWeight is not null
      if (paramWeight != null || paramWeightCategory != null) {
        queryParameters['paramWeight'] = paramWeight;
        queryParameters['paramWeightCategory'] = paramWeightCategory ?? "Gram";
      }

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      getLocator<Logger>().i(
        "paramPage: $paramPage | paramLimit: $paramLimit | paramWeight: $paramWeight | paramWeightCategory: $paramWeightCategory",
      );

      /// API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllEsouqProductsRequestApiUrl,
        parameters: queryParameters,
        headers: headers,
        httpMethod: HttpMethod.get,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          GetAllProductResponse response = GetAllProductResponse.fromJson(
            serverResponse.resultData,
          );

          /// Append new products to the existing list
          final List<AllProducts> updatedProducts = [
            ...state.products,
            ...?response.payload?.allProducts,
          ];

          /// Update state with new products and pagination details
          state = state.copyWith(
            products: updatedProducts,
            page: response.payload!.page!,
            totalPages: response.payload?.totalPages ?? 1,
            hasNextPage: response.payload?.hasNextPage ?? false,
            hasPreviousPage: response.payload?.hasPreviousPage ?? false,
            isLoading: false,
          );

          getLocator<Logger>().i(
            "Fetched ${response.payload?.allProducts?.length ?? 0} products successfully.",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isLoading: false,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            isLoading: false,
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Esouq Products Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// get eSouq order by id
  Future<void> getEsouqOrderById(String orderId) async {
    try {
      // Prevent multiple simultaneous fetches
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);

      /// Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isLoading: false);
        return;
      }

      /// Headers for authentication
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refreshToken",
      };

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getOrderByIdApiUrl,
        body: {"orderId": orderId},
        headers: headers,
        httpMethod: HttpMethod.get,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          GetOrderDetailResponse response = GetOrderDetailResponse.fromJson(
            serverResponse.resultData,
          );

          state = state.copyWith(
            selectedOrder: response,
            isLoading: false,
          );

          getLocator<Logger>().i(
            "Fetched order successfully: ${response.payload?.id}",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isLoading: false,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(isLoading: false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Esouq Order Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetch Esouq products with pagination
  Future<void> getAllEsouqOrders({
    num paramPage = 1,
    num paramLimit = 30,
  }) async {
    try {
      // Prevent multiple simultaneous fetches
      if (state.isLoading) return;
      state = state.copyWith(isLoading: true);

      /// Get refresh token from storage
      // String? refreshToken = await LocalDatabase.instance.read(
      //   key: Strings.userRefreshToken,
      // );
      String? refreshToken =
          await SecureStorageService.instance.getRefreshToken();

      if (refreshToken == null) {
        getLocator<Logger>().e("No refresh token found!");
        state = state.copyWith(isLoading: false);
        return;
      }

      /// Construct query parameters
      final Map<String, dynamic> queryParameters = {
        'paramPage': paramPage,
        'paramLimit': paramLimit,
      };

      final headers = {
        "Content-Type": "application/json",
        "authorization": "Bearer $refreshToken",
      };

      getLocator<Logger>().i(
        "paramPage: $paramPage | paramLimit: $paramLimit",
      );

      /// API call
      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.getAllEsouqOrdersUrlApiUrl,
        parameters: queryParameters,
        headers: headers,
        httpMethod: HttpMethod.get,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          GetAllOrdersResponse response = GetAllOrdersResponse.fromJson(
            serverResponse.resultData,
          );

          /// Append new products to the existing list
          final List<KAllOrders> updatedOrders = [
            ...state.kAllOrders,
            ...?response.payload?.kAllOrders,
          ];

          /// Update state with new products and pagination details
          state = state.copyWith(
            kAllOrders: updatedOrders,
            page: response.payload?.page ?? 1,
            totalPages: response.payload?.totalPages ?? 1,
            hasNextPage: response.payload?.hasNextPage ?? false,
            hasPreviousPage: response.payload?.hasPreviousPage ?? false,
            isLoading: false,
          );

          getLocator<Logger>().i(
            "Fetched ${response.payload?.kAllOrders?.length ?? 0} orders successfully.",
          );

          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
            isLoading: false,
          );
          getLocator<Logger>().e(
            "Error: ${errorResponse.payload?.message}",
          );
          break;

        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "Exception: ${serverResponse.resultData}",
          );
          state = state.copyWith(
            isLoading: false,
          );
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      getLocator<Logger>().e("Fetch Esouq Orders Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load more products for pagination
  Future<void> loadMoreProducts({
    String? paramWeight,
    String? paramWeightCategory,
  }) async {
    getLocator<Logger>().i(
      "LoadMoreProducts: $paramWeight | $paramWeightCategory",
    );
    if (state.hasNextPage && !state.isLoading) {
      await fetchEsouqProducts(
        paramPage: state.page + 1,
        paramWeight: paramWeight,
        paramWeightCategory: paramWeightCategory,
        reset: false,
      );
    }
  }

  /// Load more orders for pagination
  Future<void> loadMoreOrders() async {
    if (state.hasNextPage && !state.isLoading) {
      await getAllEsouqOrders(
        paramPage: state.page + 1,
      );
    }
  }

  // Future<void> userCanBuyGold({
  //   required String productId,
  //   required String goldQuantity,
  //   required String goldPrice,
  //   required String paymentMethod,
  //   required double currentGoldPrice,
  //   required String deliveryAddress,
  //   required bool isNominate,
  //   required String nomineeName,
  //   required String nomineeDocument,
  //   required String? branchId,
  //   required String deliveryMethod,
  //   required String makingCharges,
  //   required String valueAtTax,
  //   required String deliveryCharges,
  //   required String premiumDiscount,
  //   required String totalCharges,
  //   required AllProducts product,
  //   required String payableGrandTotal,
  //   List<Map<String, dynamic>>? selectedDealsData,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     double totalMetal =
  //         double.parse(product.weightFactor!) * double.parse(goldQuantity);
  //       double goldpriceUpdated =
  //         (double.parse(product.weightFactor!) * double.parse(goldQuantity)*currentGoldPrice);
  //     /// Get user id from storage
  //     final userId = await LocalDatabase.instance.getUserId();
  //     // final refreshToken = await LocalDatabase.instance.read(
  //     //   key: Strings.userRefreshToken,
  //     // );
  //     String? refreshToken =
  //         await SecureStorageService.instance.getRefreshToken();

  //     /// Set button loading state
  //     state = state.copyWith(isButtonState: true);
  //     final headers = {
  //       "Authorization": "Bearer $refreshToken",
  //       "Content-Type": "application/json",
  //     };

  //     /// Get refresh token from storage
  //     if (refreshToken == null) {
  //       getLocator<Logger>().e("No refresh token found!");
  //       state = state.copyWith(isButtonState: false);
  //       return;
  //     }

  //     final body = {
  //       "userId": userId,
  //       "tradeMoney": goldpriceUpdated,//double.parse(goldPrice) * totalMetal,//double.parse(goldQuantity),
  //       "tradeMetal": totalMetal,
  //       "buyAtPriceStatus": false,
  //       "buyAtPrice": currentGoldPrice,//null,
  //       "buyingPrice": currentGoldPrice,
  //     };

  //     getLocator<Logger>().i("buyGoldBody: $body");

  //     // API call
  //     ServerResponse serverResponse = await DioNetworkManager().callAPI(
  //       url: ApiEndpoints.buyGoldApiUrl,
  //       httpMethod: HttpMethod.post,
  //       headers: headers,
  //       body: body,
  //     );

  //     // Handle API Response
  //     switch (serverResponse.responseType) {
  //       case ServerResponseType.success:
  //         getLocator<Logger>().i("Trade created successfully!");
  //         SuccessResponse successResponse = SuccessResponse.fromJson(
  //           serverResponse.resultData,
  //         );

  //         if (!context.mounted) return;
  //         String message = successResponse.payload!.message!;
         
  //   RegExp regex = RegExp(r'(?:Deal ID|رقم الصفقة)\s*[:：]?\s*(\d+)');
  //        // RegExp regex = RegExp(r'Deal ID:\s*(\d+)');
  //         Match? match = regex.firstMatch(message);

  //         if (match != null) {
  //           String dealId = match.group(1)!;
  //           print("Deal ID: $dealId");

  //          await Future.delayed(const Duration(seconds: 2));
  //           createEsouqOrder(
  //             productId: product.id.toString(),
  //             goldQuantity: goldQuantity.toString(),
  //             goldPrice: goldpriceUpdated.toString(),//(double.parse(goldPrice) * goldQuantity*).toString(),//(goldPrice).toString(),
  //             paymentMethod: paymentMethod.toString(),

  //             deliveryAddress: deliveryAddress,
  //             isNominate: isNominate,
  //             nomineeName: nomineeName,
  //             nomineeDocument: nomineeDocument,
  //             branchId: branchId,
  //             deliveryMethod: deliveryMethod,
  //             makingCharges: makingCharges,
  //             valueAtTax: valueAtTax,
  //             deliveryCharges: deliveryCharges,
  //             premiumDiscount: premiumDiscount,
  //             totalCharges: totalCharges,
  //             dealId: dealId,
  //             payableGrandTotal: payableGrandTotal,
  //             selectedDealsData: selectedDealsData,
  //             totalMetal: totalMetal,
  //             context: context,
  //           );
  //         } else {
  //           print("No Deal ID found");
  //         }
  //         // SoundPlayer().playSound(AppSounds.buySellSound);
  //         // await genericPopUpWidget(
  //         //   context: context,
  //         //   heading: buyAtPriceStatus ? "${AppLocalizations.of(context)!.invest_order_placed}":"${AppLocalizations.of(context)!.invest_filled_oreder}",//"Buy Order Placed" : "Buy Order Filled",
  //         //   subtitle:
  //         //       successResponse.payload!.message ??
  //         //       AppLocalizations.of(context)!.invest_successfully_submitted,//"Your buy order has been successfully submitted for processing.",
  //         //   yesButtonTitle: AppLocalizations.of(context)!.close,//"Close",
  //         //   isLoadingState: false,
  //         //   onYesPress: () async {
  //         //     Navigator.pop(context);
  //         //   },
  //         //   onNoPress: () async {},
  //         // );

  //         break;

  //       case ServerResponseType.error:
  //         ErrorResponse errorResponse = ErrorResponse.fromJson(
  //           serverResponse.resultData,
  //         );
  //         state = state.copyWith(errorResponse: errorResponse);
  //         getLocator<Logger>().e("Error: ${errorResponse.payload?.message}");
  //         Toasts.getErrorToast(
  //           duration: Duration(seconds: 10),
  //           gravity: ToastGravity.TOP,
  //           text: "${errorResponse.payload?.message}",
  //         );
  //         break;

  //       case ServerResponseType.exception:
  //         getLocator<Logger>().e("Exception: ${serverResponse.resultData}");
  //         break;
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     getLocator<Logger>().e("Create Trade Error: $e");
  //   } finally {
  //     // Reset button loading state
  //     state = state.copyWith(isButtonState: false);
  //   }
  // }

  /// create esouq order
  Future<void> createEsouqOrder({
    required String productId,
    required String goldQuantity,
    required String goldPrice,
    required String paymentMethod,
    required String deliveryAddress,
    required bool isNominate,
    required String nomineeName,
    required String nomineeDocument,
    required String? branchId,

    required double currentGoldPrice,
    required AllProducts product,
    String? dealId,
    double? totalMetal,
    required String deliveryMethod,
    required String makingCharges,
    required String valueAtTax,
    required String deliveryCharges,
    required String premiumDiscount,
    required String totalCharges,
    required String payableGrandTotal,
    List<Map<String, dynamic>>? selectedDealsData,
    required BuildContext context,
  }) async {
    try {
      double goldpriceUpdated = double.parse(
  ((double.parse(product.weightFactor!) * double.parse(goldQuantity) * currentGoldPrice)
          .toStringAsFixed(2)),
);

double totalMetal = double.parse(
  ((double.parse(product.weightFactor!) * double.parse(goldQuantity))
          .toStringAsFixed(2)),
);
      setButtonState(true);
      // setLoadingState(LoadingState.loading);

      final token = await LocalDatabase.instance.getLoginToken();
      getLocator<Logger>().i("token: $token");

      final userId = await LocalDatabase.instance.getUserId();
      getLocator<Logger>().i("userId: $userId");

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
      // if (paymentMethod == "Money") {
      //   selectedDealsData!.add({
      //     "tradeId": null,
      //     "dealId": dealId,
      //     "amount": totalMetal,
      //   });
      // }
      final body = {
        "productId": productId,
        "quantity": goldQuantity,
        "goldPrice": goldpriceUpdated,
        "makingCharges": makingCharges,
        "vat": valueAtTax,
        "deliveryCharges": deliveryCharges,
        "premiumDiscount": premiumDiscount,
        "paymentMethod": paymentMethod, // Metal or Money
        "address": deliveryAddress,
        "isNominate": "$isNominate",
        "actualPaymnetMethod": "Metal",
        "nomineeName": nomineeName,
        "nomineeDocument": nomineeDocument,
        "branchId": branchId,
        "deliveryMethod": deliveryMethod, // Delivery or Pickup
        "totalCharges": totalCharges,
        "grandTotal": payableGrandTotal,
        "goldQuantityInGrams" : totalMetal,
        "dealsData": selectedDealsData,
      };

      getLocator<Logger>().i("OrderBody: $body");

      ServerResponse serverResponse = await DioNetworkManager().callAPI(
        url: ApiEndpoints.createOrderApiUrl,
        httpMethod: HttpMethod.post,
        headers: headers,
        body: body,
      );

      switch (serverResponse.responseType) {
        case ServerResponseType.success:
          SuccessResponse successResponse = SuccessResponse.fromJson(
            serverResponse.resultData,
          );

          if (!context.mounted) return;
          SoundPlayer().playSound(AppSounds.buySellSound);
          state = state.copyWith(
            successResponse: successResponse,
          );
          getLocator<Logger>().i(
            "successResponse: ${successResponse.payload?.toJson()}",
          );

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainHomeScreen(),
            ),
            ((route) => false),
          );

          setButtonState(false);
          break;

        case ServerResponseType.error:
          ErrorResponse errorResponse = ErrorResponse.fromJson(
            serverResponse.resultData,
          );
          state = state.copyWith(
            errorResponse: errorResponse,
          );
          getLocator<Logger>().e(
            "error: ${errorResponse.payload?.message.toString()}",
          );
          Toasts.getErrorToast(
            text: "${errorResponse.payload?.message.toString()}",
          );

          setButtonState(false);
          break;
        case ServerResponseType.exception:
          getLocator<Logger>().e(
            "ExceptionError: ${serverResponse.resultData}",
          );
          setButtonState(false);
          break;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      getLocator<Logger>().e("onError: $e");
      setButtonState(false);
    }
  }
}
