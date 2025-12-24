import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/core/decimal_text_input_formatter.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/data/models/home_models/GetHomeFeedResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gift_provider/gift_fund_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../../core/validators.dart';
import '../../../data/models/gift_model/AllUserResponse.dart';
import '../../sharedProviders/providers/gram_provider/gram_provider.dart';
import '../../sharedProviders/providers/home_provider.dart';
import '../../widgets/search_check_dropdown.dart';

enum GiftType {
  metal, // Commented out metal option
  money,
}

class GiftFundScreen extends ConsumerStatefulWidget {
  WalletExists? walletExists;

  GiftFundScreen({required this.walletExists, super.key});

  @override
  ConsumerState createState() => _GiftFundScreenState();
}

class _GiftFundScreenState extends ConsumerState<GiftFundScreen> {
  var giftType = GiftType.metal; // Set to money by default

  final _formKey = GlobalKey<FormState>();

  final receiverAccountNumberController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverAccountEmailController = TextEditingController();
  final amountController = TextEditingController();
  final commentController = TextEditingController();
  final userIdController = TextEditingController();
  String? selectedAccountId;

  // ADD THIS: State variable for reactive quantity
  double _currentQuantity = 0;

  late StreamSubscription<void> _amountSubscription;
  // double gramBalanceEqual = 0.0;

  late String? selectedDealId = '';
  List? selectedIds;
  List<Map<String, dynamic>> selectedDealsData = [];
  Future<String?> getUserEmail() async {
    return await LocalDatabase.instance.read(key: Strings.userEmail);
  }

  Future<String?> getUserPhoneNumber() async {
    return await LocalDatabase.instance.read(key: Strings.userPhoneNumber);
  }

  @override
  void initState() {
    super.initState();

    // ADD THIS: Listen to amount controller changes

    amountController.addListener(_onAmountChanged);
    // _amountSubscription = amountController.addListener(_onAmountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch user and friend lists
      ref.read(giftProvider.notifier).fetchAllUsers(context: context);
      ref.read(giftProvider.notifier).fetchAllFriends(context: context);

      if (widget.walletExists == null) {
        final payload = ref.read(homeProvider).getHomeFeedResponse.payload;
        if (payload == null) {
          ref
              .read(homeProvider.notifier)
              .getHomeFeed(
                context: context,
                showLoading: true,
              );
        }

        final updatedPayload = ref
            .read(homeProvider)
            .getHomeFeedResponse
            .payload;
        if (updatedPayload != null) {
          widget.walletExists = updatedPayload.walletExists;
        }
      }
    });
    fetchData();
  }

  // ADD THIS: Cancel the subscription
  // ADD THIS: Method to handle amount changes
  void _onAmountChanged() {
    setState(() {
      _currentQuantity = double.tryParse(amountController.text.trim()) ?? 0;
    });
  }

  void fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gramProvider.notifier).getUserGramBalance();
    });
  }

  @override
  void dispose() {
    // CORRECT: Remove the listener without using the subscription
    amountController.removeListener(_onAmountChanged);
    super.dispose();
    receiverAccountEmailController.dispose();
    receiverAccountNumberController.dispose();
    receiverNameController.dispose();
    amountController.dispose();
    commentController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    final gramState = ref.watch(gramProvider);

    /// states
    final giftState = ref.watch(giftProvider);
    final giftStateReadProvider = ref.read(giftProvider.notifier);

    ///provider
    var authStateReadProvider = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.gift, //"Gift",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          //sizes!.isPhone ? 20 : 24,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// tabs - Commented out the metal/money toggle since we only have money now
                  Container(
                    height: sizes!.responsiveLandscapeHeight(
                      phoneVal: 44,
                      tabletVal: 44,
                      tabletLandscapeVal: 64,
                      isLandscape: sizes!.isLandscape(),
                    ),
                    width: sizes!.isPhone
                        ? sizes!.widthRatio * 360
                        : sizes!.width,
                    decoration: BoxDecoration(
                      color: Color(0xFF333333),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizes!.widthRatio * 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  giftType = GiftType.metal;
                                });
                              },
                              child: Container(
                                width: sizes!.responsiveWidth(
                                  phoneVal: 150,
                                  tabletVal: 380,
                                ),
                                height: sizes!.responsiveLandscapeHeight(
                                  phoneVal: 34,
                                  tabletVal: 44,
                                  tabletLandscapeVal: 54,
                                  isLandscape: sizes!.isLandscape(),
                                ),
                                decoration: giftType == GiftType.metal
                                    ? BoxDecoration(
                                        color: AppColors.primaryGold500,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : null,
                                child: Center(
                                  child: GetGenericText(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.metal, //"Metal",
                                    fontSize: sizes!.responsiveFont(
                                      phoneVal: 18,
                                      tabletVal: 22,
                                    ),
                                    fontWeight: giftType == GiftType.metal
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: giftType == GiftType.metal
                                        ? AppColors.greyScale1000
                                        : AppColors.grey3Color,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Expanded(
                          //   child: GestureDetector(
                          //     behavior: HitTestBehavior.opaque,
                          //     onTap: () {
                          //       setState(() {
                          //         giftType = GiftType.money;
                          //       });
                          //     },
                          //     child: Container(
                          //       width: sizes!.responsiveWidth(
                          //         phoneVal: 150,
                          //         tabletVal: 380,
                          //       ),
                          //       height: sizes!.responsiveLandscapeHeight(
                          //         phoneVal: 34,
                          //         tabletVal: 44,
                          //         tabletLandscapeVal: 54,
                          //         isLandscape: sizes!.isLandscape(),
                          //       ),
                          //       decoration: giftType == GiftType.money
                          //           ? BoxDecoration(
                          //               color: AppColors.primaryGold500,
                          //               borderRadius: BorderRadius.circular(4),
                          //             )
                          //           : null,
                          //       child: Center(
                          //         child: GetGenericText(
                          //           text: AppLocalizations.of(context)!.money,//"Money",
                          //           fontSize: sizes!.responsiveFont(
                          //             phoneVal: 18,
                          //             tabletVal: 22,
                          //           ),
                          //           fontWeight: giftType == GiftType.money
                          //               ? FontWeight.w700
                          //               : FontWeight.w400,
                          //           color: giftType == GiftType.money
                          //               ? AppColors.greyScale1000
                          //               : AppColors.grey3Color,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  ConstPadding.sizeBoxWithHeight(height: 16),
                  Directionality.of(context) == TextDirection.rtl
                      ? GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.friends, //"Friends",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 20,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey5Color,
                        ).getAlignRight()
                      : GetGenericText(
                          text: AppLocalizations.of(
                            context,
                          )!.friends, //"Friends",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 20,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey5Color,
                        ).getAlign(),
                  ConstPadding.sizeBoxWithHeight(height: 8),
                  if (giftState.loadingState == LoadingState.loading)
                    SizedBox(
                      height: sizes!.heightRatio * 20,
                      width: sizes!.widthRatio * 20,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold500,
                      ),
                    )
                  else if (giftState.loadingState == LoadingState.data &&
                      giftState.friends.isNotEmpty)
                    Directionality.of(context) == TextDirection.rtl
                        ? SizedBox(
                            height:
                                sizes!.heightRatio * (sizes!.isPhone ? 42 : 62),
                            child: ListView.builder(
                              itemCount: giftState.friends.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final friend = giftState.friends[index];

                                /// friend card
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: friendCard(
                                    placeholderName:
                                        (friend.firstName != null &&
                                            friend.firstName!.length >= 2)
                                        ? friend.firstName!.substring(0, 1)
                                        : "Friend",
                                    onLongPress: () {
                                      userIdController.text = friend.id!;
                                      genericPopUpWidget(
                                        isLoadingState: false,
                                        context: context,
                                        heading: AppLocalizations.of(
                                          context,
                                        )!.warning, //"Warning",
                                        subtitle: AppLocalizations.of(context)!.gift_friend_del_warning,//"Are you sure want to delete",
                                        noButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.logout_no, //"No",
                                        yesButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.logout_yes, //"Yes",
                                        onNoPress: () async {
                                          Navigator.pop(context);
                                        },
                                        onYesPress: () async {
                                          await giftStateReadProvider
                                              .deleteFriend(
                                                friendId: userIdController.text
                                                    .trim()
                                                    .toString(),
                                                context: context,
                                              )
                                              .then((onValue) {
                                                if (!context.mounted) return;

                                                Navigator.pop(context);
                                                ref
                                                    .read(giftProvider.notifier)
                                                    .fetchAllFriends(
                                                      context: context,
                                                    );
                                              });
                                        },
                                      );
                                    },
                                    onPress: () {
                                      setState(() {
                                        selectedAccountId = friend.accountId;
                                      });
                                      amountController.clear();
                                      commentController.clear();
                                      receiverNameController.text =
                                          "${friend.firstName ?? ""} ${friend.surname ?? ""}";
                                      receiverAccountEmailController.text =
                                          friend.email ?? "";
                                      userIdController.text = friend.id!;
                                      receiverAccountNumberController.text =
                                          friend.accountId!;
                                    },
                                  ),
                                );
                              },
                            ),
                          ).getAlignRight()
                        : SizedBox(
                            height:
                                sizes!.heightRatio * (sizes!.isPhone ? 42 : 62),
                            child: ListView.builder(
                              itemCount: giftState.friends.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final friend = giftState.friends[index];

                                /// friend card
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: friendCard(
                                    placeholderName:
                                        (friend.firstName != null &&
                                            friend.firstName!.length >= 2)
                                        ? friend.firstName!.substring(0, 1)
                                        : "Friend",
                                    onLongPress: () {
                                      userIdController.text = friend.id!;
                                      genericPopUpWidget(
                                        isLoadingState: false,
                                        context: context,
                                        heading: AppLocalizations.of(
                                          context,
                                        )!.warning, //"Warning",
                                        subtitle: AppLocalizations.of(context)!.gift_friend_del_warning,//"Are you sure want to delete",
                                        noButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.logout_no, //"No",
                                        yesButtonTitle: AppLocalizations.of(
                                          context,
                                        )!.logout_yes, //"Yes",
                                        onNoPress: () async {
                                          Navigator.pop(context);
                                        },
                                        onYesPress: () async {
                                          await giftStateReadProvider
                                              .deleteFriend(
                                                friendId: userIdController.text
                                                    .trim()
                                                    .toString(),
                                                context: context,
                                              )
                                              .then((onValue) {
                                                if (!context.mounted) return;

                                                Navigator.pop(context);
                                                ref
                                                    .read(giftProvider.notifier)
                                                    .fetchAllFriends(
                                                      context: context,
                                                    );
                                              });
                                        },
                                      );
                                    },
                                    onPress: () {
                                      setState(() {
                                        selectedAccountId = friend.accountId;
                                      });
                                      amountController.clear();
                                      commentController.clear();
                                      receiverNameController.text =
                                          "${friend.firstName ?? ""} ${friend.surname ?? ""}";
                                      receiverAccountEmailController.text =
                                          friend.email ?? "";
                                      userIdController.text = friend.id!;
                                      receiverAccountNumberController.text =
                                          friend.accountId!;
                                    },
                                  ),
                                );
                              },
                            ),
                          ).getAlign()
                  else
                    GetGenericText(
                      text: AppLocalizations.of(
                        context,
                      )!.noFriendsFound, //"No friends found.",
                      fontSize: sizes!.responsiveFont(
                        phoneVal: 14,
                        tabletVal: 16,
                      ),
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey5Color,
                    ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "12345678",
                    labelText: AppLocalizations.of(
                      context,
                    )!.receiverAccNum, //"Receiver Account Number",
                    controller: receiverAccountNumberController,
                    textInputType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.valReceiverAccNum; //"Please enter receiver account number";
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: AppLocalizations.of(context)!.user_firstName,//"Amro Al Jaber",
                    labelText: AppLocalizations.of(
                      context,
                    )!.receiverName, //"Receiver Name",
                    controller: receiverNameController,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.valReceiverName; //"Please enter receiver name";
                      }
                      return null;
                    },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: "name@mail.com | 00971XXXXXXXXX",
                    labelText: AppLocalizations.of(
                      context,
                    )!.receiverAccEmail, //"Receiver Email/Phone",
                    controller: receiverAccountEmailController,
                    textInputType: TextInputType.emailAddress,
                    isCapitalizationEnabled: false,
                    validator: ValidatorUtils.validateEmailOrPhone,
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: giftType == GiftType.metal
                        ? AppLocalizations.of(context)!
                              .enter_gram //"Enter Amount (grams) here"
                        : AppLocalizations.of(
                            context,
                          )!.enter_amount, //"Enter Amount (AED) here",
                    labelText: AppLocalizations.of(context)!.amount, //"Amount",
                    controller: amountController,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                    ],
                    textInputType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentQuantity = double.tryParse(value) ?? 0;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return giftType == GiftType.metal
                            ? AppLocalizations.of(context)!.enter_metal_plz
                            : AppLocalizations.of(
                                context,
                              )!.phAmount; //"Please enter amount";
                      }
                      final amount = num.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.enter_correct_amount; //'Please add correct amount';
                      }
                      return null;
                    },
                  ),

                  // CommonTextFormField(
                  //   title: "title",
                  //   hintText: "Enter amount here",
                  //   labelText: "Amount",
                  //   controller: amountController,
                  //   inputFormatters: [
                  //     DecimalTextInputFormatter(decimalRange: 2),
                  //     //LengthLimitingTextInputFormatter(15),
                  //   ],
                  //   textInputType: TextInputType.numberWithOptions(
                  //     decimal: true,
                  //   ),

                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return "Please enter amount";
                  //     }
                  //     final amount = num.tryParse(value);
                  //     if (amount == null || amount <= 0) {
                  //       return 'Please add correct amount';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  if (giftType == GiftType.metal)
                    ConstPadding.sizeBoxWithHeight(height: 16),
                  giftType == GiftType.metal
                      ? Consumer(
                          builder: (context, ref, child) {
                            final gramState = ref.watch(gramProvider);

                            // Use a state variable that updates when the text changes
                            final quantity = _currentQuantity;

                            if (gramState.loadingState ==
                                LoadingState.loading) {
                              return const CircularProgressIndicator();
                            }
                            if (gramState
                                    .gramApiResponseModel
                                    .payload
                                    ?.isEmpty ??
                                true) {
                              return Text(
                                AppLocalizations.of(
                                  context,
                                )!.no_deals_available, //"No gram deals available",
                                style: const TextStyle(color: Colors.white),
                              );
                            }

                            final filteredDeals = gramState
                                .gramApiResponseModel
                                .payload!
                                .where(
                                  (deal) =>
                                      deal.tradeType == 'Buy' &&
                                      deal.tradeStatus == 'Opened',
                                )
                                .toList();

                            // Calculate total available grams for better UX
                            final totalAvailableGrams = filteredDeals.fold(
                              0.0,
                              (sum, deal) => sum + (deal.tradeMetal ?? 0),
                            );

                            return GestureDetector(
                              onTap: () {
                                print("Current quantity: $quantity");
                                if (quantity <= 0) {
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(
                                      context,
                                    )!.valid_quantitty, //"Please enter a valid quantity.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                }

                                // Additional validation
                                if (quantity > totalAvailableGrams) {
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(
                                      context,
                                    )!.requested_quntity, //"Requested quantity exceeds available grams",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                              child: AbsorbPointer(
                                absorbing: quantity <= 0,
                                child: Opacity(
                                  opacity: quantity <= 0 ? 0.5 : 1.0,
                                  child: SearchableWithCheckBox(
                                    iconString: "assets/svg/arrow_down.svg",
                                    title: AppLocalizations.of(
                                      context,
                                    )!.gift_select_gram, //"Select Gram Deal",
                                    items: filteredDeals
                                        .map<String>(
                                          (deal) =>
                                              "${deal.dealId} - ${deal.tradeType == "Buy" ? 
                                              AppLocalizations.of(context)!.buy 
                                              : AppLocalizations.of(context)!.sell} ${deal.tradeMetal!.toStringAsFixed(2)}g ${AppLocalizations.of(context)!.g_Gold}",
                                        )
                                        .toList(),
                                    //items: filteredDeals
                                    //     .map<String>(
                                    //       (deal) =>
                                    //           "${deal.dealId} - ${deal.tradeType} "
                                    //           "${deal.tradeMetal?.toStringAsFixed(2) ?? '0.00'}g Gold",
                                    //     )
                                    //     .toList(),
                                    label: AppLocalizations.of(
                                      context,
                                    )!.gramDeal, //"Gram Deal",
                                    hint: quantity <= 0
                                        ? AppLocalizations.of(context)!
                                              .gift_enter_qu //"Enter valid quantity first"
                                        : "${AppLocalizations.of(context)!.gift_please_choose} ${totalAvailableGrams.toStringAsFixed(2)}${AppLocalizations.of(context)!.metal_g})",
                                    gramBalanceEqual: quantity,
                                    selectedItems: selectedIds != null
                                        ? selectedIds!.map((id) {
                                            final deal = filteredDeals
                                                .firstWhere(
                                                  (d) =>
                                                      d.dealId.toString() == id,
                                                );
                                            return "${deal.dealId} - ${deal.tradeType} ${deal.tradeMetal!.toStringAsFixed(2)}${AppLocalizations.of(context)!.g_Gold}";
                                          }).toList()
                                        : [],
                                    onChanged: (List<String> selectedList) {
                                      if (selectedList.isEmpty) {
                                        setState(() {
                                          selectedIds = null;
                                          selectedDealsData = [];
                                          selectedDealId = null;
                                        });
                                        return;
                                      }

                                      List<Map<String, dynamic>>
                                      newSelectedDeals = [];
                                      double totalSelectedGrams = 0.0;

                                      for (var item in selectedList) {
                                        final dealId = item
                                            .split(" - ")
                                            .first
                                            .trim();
                                        final deal = filteredDeals.firstWhere(
                                          (d) => d.dealId.toString() == dealId,
                                        );
                                        final dealGrams = deal.tradeMetal ?? 0;

                                        if (totalSelectedGrams + dealGrams >
                                            quantity) {
                                          final remainingGrams =
                                              quantity - totalSelectedGrams;
                                          if (remainingGrams > 0) {
                                            newSelectedDeals.add({
                                              "tradeId": deal.id,
                                              "dealId": deal.dealId,
                                              "amount": remainingGrams,
                                            });
                                            totalSelectedGrams +=
                                                remainingGrams;
                                          }
                                          break;
                                        } else {
                                          newSelectedDeals.add({
                                            "tradeId": deal.id,
                                            "dealId": deal.dealId,
                                            "amount": dealGrams,
                                          });
                                          totalSelectedGrams += dealGrams;
                                        }
                                      }

                                      setState(() {
                                        selectedIds = newSelectedDeals
                                            .map(
                                              (deal) =>
                                                  deal["dealId"].toString(),
                                            )
                                            .toList();
                                        selectedDealsData = newSelectedDeals;
                                        selectedDealId = selectedIds!.isNotEmpty
                                            ? selectedIds!.first
                                            : null;

                                        // Debug print
                                        print(
                                          "Selected $totalSelectedGrams grams out of $quantity requested",
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                  // if (giftType == GiftType.metal)
                  //   ConstPadding.sizeBoxWithHeight(height: 16),
                  // giftType == GiftType.metal
                  //     ? Consumer(
                  //         builder: (context, ref, child) {
                  //           // final gramState = ref.watch(gramProvider);
                  //           final quantityText = amountController.text.trim();
                  //           final quantity = double.tryParse(quantityText) ?? 0;

                  //           if (gramState.loadingState ==
                  //               LoadingState.loading) {
                  //             return const CircularProgressIndicator();
                  //           }
                  //           if (gramState
                  //                   .gramApiResponseModel
                  //                   .payload
                  //                   ?.isEmpty ??
                  //               true) {
                  //             return const Text(
                  //               "No gram deals available",
                  //               style: TextStyle(color: Colors.white),
                  //             );
                  //           }
                  //           final filteredDeals = gramState
                  //               .gramApiResponseModel
                  //               .payload!
                  //               .where(
                  //                 (deal) =>
                  //                     deal.tradeType == 'Buy' &&
                  //                     deal.tradeStatus == 'Opened',
                  //               )
                  //               .toList();

                  //           return GestureDetector(
                  //             onTap: () {
                  //               print(" hellloooooo$quantity");
                  //               if (quantity <= 0) {
                  //                 Fluttertoast.showToast(
                  //                   msg: "Please enter a valid quantity.",
                  //                   toastLength: Toast.LENGTH_SHORT,
                  //                   gravity: ToastGravity.TOP,
                  //                   timeInSecForIosWeb: 1,
                  //                   backgroundColor: Colors.red,
                  //                   textColor: Colors.white,
                  //                   fontSize: 16.0,
                  //                 );
                  //                 return;
                  //               }
                  //             },
                  //             child: AbsorbPointer(
                  //               absorbing: quantity <= 0,
                  //               child: Opacity(
                  //                 opacity: quantity <= 0 ? 0.5 : 1.0,
                  //                 child: SearchableWithCheckBox(
                  //                   iconString: "assets/svg/arrow_down.svg",
                  //                   title: "Select Gram Deal",
                  //                   items: filteredDeals
                  //                       .map<String>(
                  //                         (deal) =>
                  //                             "${deal.dealId} - ${deal.tradeType} ${deal.tradeMetal!.toStringAsFixed(2)}g Gold",
                  //                       )
                  //                       .toList(),
                  //                   label: "Gram Deal",
                  //                   hint: quantity <= 0
                  //                       ? "Enter valid quantity first"
                  //                       : "Please choose a deal",
                  //                   gramBalanceEqual: quantity,
                  //                   selectedItems: selectedIds != null
                  //                       ? selectedIds!.map((id) {
                  //                           final deal = filteredDeals
                  //                               .firstWhere(
                  //                                 (d) =>
                  //                                     d.dealId.toString() == id,
                  //                               );
                  //                           return "${deal.dealId} - ${deal.tradeType} ${deal.tradeMetal!.toStringAsFixed(2)}g Gold";
                  //                         }).toList()
                  //                       : [],
                  //                   onChanged: (List<String> selectedList) {
                  //                     if (selectedList.isEmpty) {
                  //                       setState(() {
                  //                         selectedIds = null;
                  //                         selectedDealsData = [];
                  //                         selectedDealId = null;
                  //                       });
                  //                       return;
                  //                     }

                  //                     List<Map<String, dynamic>>
                  //                     newSelectedDeals = [];
                  //                     double totalSelectedGrams = 0.0;

                  //                     for (var item in selectedList) {
                  //                       final dealId = item
                  //                           .split(" - ")
                  //                           .first
                  //                           .trim();
                  //                       final deal = filteredDeals.firstWhere(
                  //                         (d) => d.dealId.toString() == dealId,
                  //                       );
                  //                       final dealGrams = deal.tradeMetal ?? 0;

                  //                       if (totalSelectedGrams + dealGrams >
                  //                           quantity) {
                  //                         final remainingGrams =
                  //                             quantity - totalSelectedGrams;
                  //                         if (remainingGrams > 0) {
                  //                           newSelectedDeals.add({
                  //                             "tradeId": deal.id,
                  //                             "dealId": deal.dealId,
                  //                             "amount": remainingGrams,
                  //                           });
                  //                           totalSelectedGrams +=
                  //                               remainingGrams;
                  //                         }
                  //                         break;
                  //                       } else {
                  //                         newSelectedDeals.add({
                  //                           "tradeId": deal.id,
                  //                           "dealId": deal.dealId,
                  //                           "amount": dealGrams,
                  //                         });
                  //                         totalSelectedGrams += dealGrams;
                  //                       }
                  //                     }

                  //                     setState(() {
                  //                       selectedIds = newSelectedDeals
                  //                           .map(
                  //                             (
                  //                               deal,
                  //                             ) => deal["dealId"].toString(),
                  //                           )
                  //                           .toList();
                  //                       selectedDealsData = newSelectedDeals;
                  //                       selectedDealId = selectedIds!.isNotEmpty
                  //                           ? selectedIds!.first
                  //                           : null;
                  //                     });
                  //                   },
                  //                 ),
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //       )
                  //     : const SizedBox.shrink(),
                  ConstPadding.sizeBoxWithHeight(height: 16),
                  CommonTextFormField(
                    title: "title",
                    hintText: AppLocalizations.of(
                      context,
                    )!.gift_leave_comment, //"Leave a Comment",
                    labelText: AppLocalizations.of(
                      context,
                    )!.gift_comment, //"Comment",
                    controller: commentController,
                    textInputType: TextInputType.text,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return "Please enter comment";
                    //   }
                    //   return null;
                    // },
                  ),
                  ConstPadding.sizeBoxWithHeight(height: 24),

                  /// continue button
                  LoaderArrowButton(
                    title: AppLocalizations.of(context)!.continu, //"Continue",
                    isLoadingState: giftState.isButtonState ?? false,
                    onTap: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      List<AllAppUsers> matchedUsers = giftState.allUser.where((
                        user,
                      ) {
                        final emailInput = receiverAccountEmailController.text
                            .toLowerCase()
                            .trim();
                        final nameInput = receiverNameController.text
                            .toLowerCase()
                            .trim();
                        final accountInput = receiverAccountNumberController
                            .text
                            .trim();

                        final userEmail =
                            user.email?.toLowerCase().trim() ?? '';
                        final userPhone = user.phoneNumber?.trim() ?? '';
                        final accountId = user.accountId?.trim() ?? '';

                        // normalize phone for comparison
                        String normalizeForComparison(String phone) {
                          if (phone.startsWith("00")) {
                            return "+${phone.substring(2)}"; // 00971 → +971
                          }
                          return phone; // keep as is if already + or local
                        }

                        final normalizedUserPhone = normalizeForComparison(
                          userPhone,
                        );
                        final normalizedInputPhone = normalizeForComparison(
                          emailInput,
                        );

                        // Build full name (first + last), safe against null
                        final fullName = [
                          user.firstName ?? '',
                          user.surname ?? '',
                        ].join(' ').toLowerCase().trim();

                        // Check matches (all lowercased already)
                        final emailMatches = userEmail == emailInput;
                        final phoneMatches =
                            normalizedUserPhone == normalizedInputPhone;
                        final accountIdMatches = accountId == accountInput;
                        final nameMatches = fullName == nameInput;

                        return (emailMatches || phoneMatches) &&
                            accountIdMatches &&
                            nameMatches;
                      }).toList();

                      bool alreadyFriend = giftState.friends.any(
                        (user) =>
                            user.accountId ==
                            receiverAccountNumberController.text,
                      );
                      if (giftType == GiftType.metal &&
                          selectedDealsData.isEmpty) {
                        genericPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(
                            context,
                          )!.no_deals_available, //"Gram deals no selected",
                          subtitle: AppLocalizations.of(
                            context,
                          )!.gift_no_deal_selected, // "Gram deals no selected.Please select deals",
                          noButtonTitle: "",
                          isLoadingState: false,
                          onNoPress: () => Navigator.pop(context),
                          yesButtonTitle: AppLocalizations.of(
                            context,
                          )!.gift_close, //'Close',
                          onYesPress: () async => Navigator.pop(context),
                        );
                        return;
                      }
                      if (matchedUsers.isEmpty) {
                        debugPrint(
                          "Error: Selected Account ID does not match.",
                        );
                        if (context.mounted) {
                          await transactionFailedPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.gift_account_not_found, //"Account Details Not Found!",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.gift_account_not_match,
                            //"The account details you entered do not match our records. Please check your information and try again.",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.gift_close, //"Close",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.gift_go_back, // "Go Back",
                            isLoadingState: false,
                            onNoPress: () => Navigator.pop(context),
                            onYesPress: () async => Navigator.pop(context),
                          );
                        }
                        return;
                      }
                      if (giftType == GiftType.money) {
                        double walletBalance =
                            double.tryParse(
                              widget.walletExists!.moneyBalance.toString(),
                            ) ??
                            0.0;
                        double enteredAmount =
                            double.tryParse(amountController.text.trim()) ??
                            0.0;

                        if (enteredAmount <= 0) {
                          await genericPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.gift_inavalid_amount, //"Invalid Amount",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.gitf_valid_amount, //"Please enter a valid amount.",
                            noButtonTitle: "",
                            isLoadingState: false,
                            onNoPress: () => Navigator.pop(context),
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.gift_close, //'Close',
                            onYesPress: () async => Navigator.pop(context),
                          );
                          return;
                        }

                        // Only check money balance since we're only doing money transactions now
                        if (walletBalance < enteredAmount) {
                          await genericPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.gift_insufficient, //"Insufficient Balance",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.gift_add_fund,
                            //"Please add funds into your account to send money.",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.gift_go_back, //"Back",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.dep_method_header, //"Add funds",
                            isLoadingState: false,
                            onNoPress: () => Navigator.pop(context),
                            onYesPress: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddFundScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        /// add friend
                        await genericTransactionPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(
                            context,
                          )!.gift_account_detail_found, //"Account Details Found!",
                          subtitle: AppLocalizations.of(
                            context,
                          )!.gift_click_btn,
                          //"Click on the button below to complete this transaction.",
                          alreadyFriend: alreadyFriend,
                          noButtonTitle: AppLocalizations.of(
                            context,
                          )!.close, //"Close",
                          yesButtonTitle: AppLocalizations.of(
                            context,
                          )!.completeTransaction, //"Complete Transaction",
                          isLoadingState: false,
                          isAddingFriendState: giftState.isAddingFriend,
                          onNoPress: () {
                            if (context.mounted) Navigator.pop(context);
                          },
                          // onAddFriendPress: () async {
                          //   /// add friend
                          //   await giftStateReadProvider.addFriend(
                          //     friendId: matchedUsers[0].id!,
                          //     context: context,
                          //   );
                          // },
                          onDeleteFriendPress: () async {
                            /// delete friend
                            await giftStateReadProvider.deleteFriend(
                              friendId: userIdController.text,
                              context: context,
                            );
                          },
                          onYesPress: () async {
                            String? phoneNumber = await getUserPhoneNumber();
                            debugPrint(phoneNumber.toString());

                            if (context.mounted) {
                              /// resend phone passcode

                              await authStateReadProvider
                                  .authenticateWithBiometricsForGift(
                                    context: context,
                                    phoneNumber: phoneNumber!,
                                    receiverId:
                                        receiverAccountNumberController.text,
                                    receiverName: receiverNameController.text,
                                    receiverEmail: matchedUsers[0].email ?? "",
                                    receiverPhoneNumber:
                                        matchedUsers[0].phoneNumber ?? "",
                                    giftAmount: amountController.text,
                                    paymentMethod:
                                        "Money", // Hardcoded to Money now
                                    comment: commentController.text,
                                  );
                            } else {
                              debugPrint("Context is not mounted.");
                            }
                          },
                        );
                      } else {
                        double enteredAmount =
                            double.tryParse(amountController.text.trim()) ??
                            0.0;
                        // double totalSelectedAmount = selectedDealsData.fold(
                        //   0.0,
                        //   (sum, deal) {
                        //     final amount = deal['amount'];
                        //     return sum +
                        //         (amount is int
                        //             ? amount.toDouble()
                        //             : (amount as double? ?? 0.0));
                        //   },
                        // );
                        double totalSelectedAmount = selectedDealsData.fold(
                          0.0,
                          (sum, deal) {
                            final amount = deal['amount'];
                            double dealAmount = (amount is int)
                                ? amount.toDouble()
                                : (amount as double? ?? 0.0);
                            // normalize this deal amount to 2 decimals
                            dealAmount = double.parse(
                              dealAmount.toStringAsFixed(2),
                            );
                            double newSum = sum + dealAmount;
                            // normalize running sum as well
                            return double.parse(newSum.toStringAsFixed(2));
                          },
                        );

                        //  totalSelectedAmount= totalSelectedAmount.toStringAsFixed(2) as double;

                        if (totalSelectedAmount < enteredAmount) {
                          await genericPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.insufficient_gram_title, //"Insufficient Gram Selection",
                            subtitle:
                                "${AppLocalizations.of(context)!.ins_firt}$totalSelectedAmount ${AppLocalizations.of(context)!.ins_sec}$enteredAmount ${AppLocalizations.of(context)!.ins_th}",
                            noButtonTitle: "",
                            isLoadingState: false,
                            onNoPress: () => Navigator.pop(context),
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.close, //'Close',
                            onYesPress: () async => Navigator.pop(context),
                          );
                          return;
                        }
                        await genericTransactionPopUpWidget(
                          context: context,
                          heading: AppLocalizations.of(
                            context,
                          )!.gift_account_detail_found, //"Account Details Found!",
                          subtitle: AppLocalizations.of(
                            context,
                          )!.gift_click_btn,
                          //"Click on the button below to complete this transaction.",
                          alreadyFriend: alreadyFriend,
                          noButtonTitle: AppLocalizations.of(
                            context,
                          )!.close, //"Close",
                          yesButtonTitle: AppLocalizations.of(
                            context,
                          )!.completeTransaction, //"Complete Transaction",
                          isLoadingState: false,
                          isAddingFriendState: giftState.isAddingFriend,
                          onNoPress: () {
                            if (context.mounted) Navigator.pop(context);
                          },
                          // onAddFriendPress: () async {
                          //   /// add friend
                          //   await giftStateReadProvider.addFriend(
                          //     friendId: matchedUsers[0].id!,
                          //     context: context,
                          //   );
                          // },
                          onDeleteFriendPress: () async {
                            /// delete friend
                            await giftStateReadProvider.deleteFriend(
                              friendId: userIdController.text,
                              context: context,
                            );
                          },
                          onYesPress: () async {
                            String? phoneNumber = await getUserPhoneNumber();
                            debugPrint(
                              "Original phone from backend: $phoneNumber",
                            );

                            // Normalize receiver phone before API
                            final normalizedReceiverPhone =
                                normalizePhoneForApi(
                                  matchedUsers[0].phoneNumber ?? "",
                                );

                            debugPrint(
                              "Normalized receiver phone: $normalizedReceiverPhone",
                            );

                            if (context.mounted) {
                              await authStateReadProvider
                                  .authenticateWithBiometricsForGift(
                                    context: context,
                                    phoneNumber: phoneNumber!,
                                    receiverId:
                                        receiverAccountNumberController.text,
                                    receiverName: receiverNameController.text,
                                    receiverEmail: matchedUsers[0].email ?? "",
                                    receiverPhoneNumber:
                                        normalizedReceiverPhone ??
                                        "", // Fixed here
                                    giftAmount: amountController.text,
                                    paymentMethod:
                                        "Metal", // Hardcoded to Money now
                                    selectedDealsData: selectedDealsData,
                                    comment: commentController.text,
                                  );
                            } else {
                              debugPrint("Context is not mounted.");
                            }
                          },
                        );
                      }

                      // Commented out metal balance check
                      // double metalBalance =
                      //     double.tryParse(
                      //       widget.walletExists!.metalBalance.toString(),
                      //     ) ??
                      //     0.0;
                    },
                  ),

                  ConstPadding.sizeBoxWithHeight(height: 24),
                ],
              ).get16HorizontalPadding(),
            ),
          ),
        ),
      ),
    );
  }

  /// friend card
  Widget friendCard({
    required String placeholderName,
    required VoidCallback onLongPress,
    required VoidCallback onPress,
  }) {
    return GestureDetector(
      onTap: onPress,
      onLongPress: onLongPress,
      child: Container(
        width: sizes!.responsiveWidth(
          phoneVal: 42,
          tabletVal: 52,
        ),
        height: sizes!.responsiveHeight(
          phoneVal: 42,
          tabletVal: 52,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF333333),
          shape: BoxShape.circle,
          border: Border.all(
            width: 1,
            color: Color(0xFFBBA473),
          ),
        ),
        child: Center(
          child: GetGenericText(
            text: placeholderName.toUpperCase(),
            textAlign: TextAlign.center,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFBBA473),
          ),
        ),
      ),
    );
  }

  String normalizePhoneForApi(String phone) {
    phone = phone.trim();

    // UAE local → international
    if (phone.startsWith("05") && phone.length == 10) {
      return "00971${phone.substring(1)}";
    }

    // Iraq local → international
    if (phone.startsWith("07") && phone.length == 11) {
      return "00964${phone.substring(1)}";
    }

    // Jordan local → international
    if (phone.startsWith("07") && phone.length == 10) {
      return "00962${phone.substring(1)}";
    }

    // Already in international format
    return phone;
  }
}
