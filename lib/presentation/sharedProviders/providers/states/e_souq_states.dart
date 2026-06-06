import 'package:baghdad_bullion_house/core/enums/loading_state.dart';
import 'package:baghdad_bullion_house/data/models/ErrorResponse.dart';
import 'package:baghdad_bullion_house/data/models/SuccessResponse.dart';
import 'package:baghdad_bullion_house/data/models/bank_models/BankBranchResponse.dart'
    show BankBranchesApiResponseModel;
import 'package:baghdad_bullion_house/data/models/esouq_model/EsouqFilterModel.dart'
    as filter;
import 'package:baghdad_bullion_house/data/models/esouq_model/GetAllOrdersResponse.dart';
import 'package:baghdad_bullion_house/data/models/esouq_model/GetAllProductResponse.dart';

import '../../../../data/models/esouq_model/GetOrderDetailResponse.dart';

class EsouqState {
  final List<AllProducts> products;
  final List<filter.AllProducts> filterOptions;
  final List<KAllOrders> kAllOrders;
  final GetAllOrdersResponse getAllOrdersResponse;
  final BankBranchesApiResponseModel getAllBranchesResponse;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  final GetAllProductResponse getAllProductResponse;
  final GetOrderDetailResponse selectedOrder;
  final bool isLoading;
  final bool isFilterLoading;
  final LoadingState loadingState;
  final bool isButtonState;
  final num page;
  final num totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  String? selectedBranch;
  String? selectedBranchId;

  EsouqState({
    this.products = const [],
    this.filterOptions = const [],
    this.kAllOrders = const [],
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetAllProductResponse? getAllProductResponse,
    GetAllOrdersResponse? getAllOrdersResponse,
    BankBranchesApiResponseModel? getAllBranchesResponse,
    GetOrderDetailResponse? selectedOrder,
    this.selectedBranch,
    this.selectedBranchId,
    this.loadingState = LoadingState.loading,
    this.isLoading = false,
    this.isFilterLoading = false,
    this.isButtonState = false,
    this.page = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  }) : getAllBranchesResponse =
           getAllBranchesResponse ?? BankBranchesApiResponseModel(),
       errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse(),
       getAllProductResponse = getAllProductResponse ?? GetAllProductResponse(),
       selectedOrder = selectedOrder ?? GetOrderDetailResponse(),
       getAllOrdersResponse = getAllOrdersResponse ?? GetAllOrdersResponse();

  EsouqState copyWith({
    List<AllProducts>? products,
    List<filter.AllProducts>? filterOptions,
    List<KAllOrders>? kAllOrders,
    BankBranchesApiResponseModel? getAllBranchesResponse,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    GetAllProductResponse? getAllProductResponse,
    GetAllOrdersResponse? getAllOrdersResponse,
    GetOrderDetailResponse? selectedOrder,
    bool? isLoading,
    bool? isFilterLoading,
    LoadingState? loadingState,
    bool? isButtonState,
    num? page,
    num? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    String? selectedBranch,
    String? selectedBranchId,
  }) {
    return EsouqState(
      products: products ?? this.products,
      filterOptions: filterOptions ?? this.filterOptions,
      kAllOrders: kAllOrders ?? this.kAllOrders,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      getAllProductResponse:
          getAllProductResponse ?? this.getAllProductResponse,
      getAllBranchesResponse:
          getAllBranchesResponse ?? this.getAllBranchesResponse,
      getAllOrdersResponse: getAllOrdersResponse ?? this.getAllOrdersResponse,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      isFilterLoading: isFilterLoading ?? this.isFilterLoading,
      loadingState: loadingState ?? this.loadingState,
      isButtonState: isButtonState ?? this.isButtonState,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
    );
  }
}
