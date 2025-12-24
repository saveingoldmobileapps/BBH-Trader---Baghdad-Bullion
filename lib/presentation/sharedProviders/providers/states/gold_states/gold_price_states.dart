import '../../../../../core/enums/loading_state.dart';
import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/SuccessResponse.dart';
import '../../../../../data/models/gold_price_model/CurrentGoldPriceModel.dart';

class GoldPriceState {
  final CurrentGoldPriceModel currentGoldPriceModel;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final LoadingState loadingState;

  final double oneOunceDollarSellingPrice;
  final double oneOunceDollarBuyingPrice;

  final double oneGramBuyingPriceInAED;
  final double oneGramSellingPriceInAED;

  final bool isLoading;
  final bool isButtonState;

  /// Constructor with default values
  GoldPriceState({
    CurrentGoldPriceModel? currentGoldPriceModel,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.oneGramBuyingPriceInAED = 0.0,
    this.oneGramSellingPriceInAED = 0.0,
    this.oneOunceDollarSellingPrice = 0.0,
    this.oneOunceDollarBuyingPrice = 0.0,
    this.isButtonState = false,
    this.loadingState = LoadingState.loading,
    this.isLoading = false,
  }) : currentGoldPriceModel = currentGoldPriceModel ?? CurrentGoldPriceModel(),
       errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  /// Copy method for updating state
  GoldPriceState copyWith({
    CurrentGoldPriceModel? currentGoldPriceModel,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    double? oneGramBuyingPriceInAED,
    double? oneGramSellingPriceInAED,
    double? oneOunceDollarSellingPrice,
    double? oneOunceDollarBuyingPrice,
    LoadingState? loadingState,
    bool? isButtonState,
    bool? isLoading,
  }) {
    return GoldPriceState(
      currentGoldPriceModel:
          currentGoldPriceModel ?? this.currentGoldPriceModel,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      oneGramBuyingPriceInAED:
          oneGramBuyingPriceInAED ?? this.oneGramBuyingPriceInAED,
      oneGramSellingPriceInAED:
          oneGramSellingPriceInAED ?? this.oneGramSellingPriceInAED,
      oneOunceDollarSellingPrice:
          oneOunceDollarSellingPrice ?? this.oneOunceDollarSellingPrice,
      oneOunceDollarBuyingPrice:
          oneOunceDollarBuyingPrice ?? this.oneOunceDollarBuyingPrice,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
