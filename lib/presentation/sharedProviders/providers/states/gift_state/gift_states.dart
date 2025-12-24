import '../../../../../core/enums/loading_state.dart';
import '../../../../../data/models/ErrorResponse.dart';
import '../../../../../data/models/SuccessResponse.dart';
import '../../../../../data/models/gift_model/AllFriendsApiResponseModel.dart';
import '../../../../../data/models/gift_model/AllUserResponse.dart';

class GiftState {
  final List<AllUsers> friends;
  final List<AllAppUsers> allUser;
  final ErrorResponse errorResponse;
  final SuccessResponse successResponse;
  // final bool isLoading;
  final LoadingState loadingState;
  final LoadingState? allUserLoadingState;
  final bool isAddingFriend;
  bool? isButtonState;

  GiftState({
    this.friends = const [],
    this.allUser = const [],
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    this.loadingState = LoadingState.loading,
    this.allUserLoadingState = LoadingState.loading,
    this.isAddingFriend = false,
    this.isButtonState = false,
  }) : errorResponse = errorResponse ?? ErrorResponse(),
       successResponse = successResponse ?? SuccessResponse();

  GiftState copyWith({
    List<AllUsers>? friends,
    List<AllAppUsers>? allUser,
    ErrorResponse? errorResponse,
    SuccessResponse? successResponse,
    LoadingState? loadingState,
    LoadingState? allUserLoadingState,
    bool? isButtonState,
    bool? isAddingFriend,
  }) {
    return GiftState(
      friends: friends ?? this.friends,
      allUser: allUser ?? this.allUser,
      isButtonState: isButtonState ?? this.isButtonState,
      errorResponse: errorResponse ?? this.errorResponse,
      successResponse: successResponse ?? this.successResponse,
      loadingState: loadingState ?? this.loadingState,
      allUserLoadingState: allUserLoadingState ?? this.allUserLoadingState,
      isAddingFriend: isAddingFriend ?? this.isAddingFriend,
    );
  }
}
