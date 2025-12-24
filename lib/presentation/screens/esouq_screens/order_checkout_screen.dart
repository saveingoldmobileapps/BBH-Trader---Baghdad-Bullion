import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/models/esouq_model/GetAllProductResponse.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/screens/esouq_screens/one_min_timer.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/eouq_provider/e_souq_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/widget_export.dart';

import '../../sharedProviders/providers/sseGoldPriceProvider/sse_gold_price_provider.dart';

class OrderCheckoutScreen extends ConsumerStatefulWidget {
  final AllProducts product;
  final String paymentMethod;
  final String productId;
  final double goldPrice;
  final double goldQuantity;
  final double deliveryCharges;
  final double makingCharges;
  final double currentGoldPrice;

  final double valueAtTax;
  final double premiumDiscount;
  final double totalCharges;
  final double grandPayableTotalGramOrMoney;
  final String selectedPaymentMethod;
  final List<Map<String, dynamic>> selectedDealsData;

  const OrderCheckoutScreen({
    super.key,
    required this.product,
    required this.paymentMethod,
    required this.productId,
    required this.goldPrice,
    required this.goldQuantity,
    required this.deliveryCharges,
    required this.makingCharges,
    required this.currentGoldPrice,
    required this.valueAtTax,
    required this.premiumDiscount,
    required this.totalCharges,
    required this.grandPayableTotalGramOrMoney,
    required this.selectedPaymentMethod,
    required this.selectedDealsData,
  });

  @override
  ConsumerState createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends ConsumerState<OrderCheckoutScreen> {
  // Initial selected value
  String _selectedItem = 'Delivery';
  int selectedBranchIndex = -1;
  bool isSelected = true;
  String? selectedBranchId;
  final GlobalKey<OneMinuteTimerState> timerKey =
      GlobalKey<OneMinuteTimerState>();

  // List of items in the dropdown
  final _dropdownItems = [
    'Delivery',
    'Collection',
  ];

  final houseNumberController = TextEditingController();
  final streetAddressController = TextEditingController();
  final areaController = TextEditingController();
  final emirateController = TextEditingController();
  final nomineeController = TextEditingController();
  // LocationData? locationData;
  // supporting variables,
  bool isNominate = false;

  final _formKey = GlobalKey<FormState>();

  num collectionTotal = 0.0;
  num withDeliveryCharges = 0.0;
  num totalChargersMinusDeliveryFee = 0.0;
  num collectionCharges = 0.0;
  // final MapController _mapController = MapController();
  final bool _isLocationLoading = true;
  bool isLocationRequired = false;
  @override
  @override
  void initState() {
    super.initState();
    debugPrint("the selected selectedDealsData ${widget.selectedDealsData}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllBranches();
      updateCheckOutMethod();
      collectionCharges = widget.totalCharges - widget.deliveryCharges;
    });
  }
  //Esouq location
  // Future<void> _getCurrentLocation() async {
  //   Location location = Location();
  //   bool serviceEnabled;
  //   PermissionStatus permissionGranted;

  //   try {
  //     serviceEnabled = await location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await location.requestService();
  //       if (!serviceEnabled) {
  //         setState(() {
  //           _isLocationLoading = false;
  //         });
  //         return;
  //       }
  //     }

  //     permissionGranted = await location.hasPermission();
  //     if (permissionGranted == PermissionStatus.denied) {
  //       permissionGranted = await location.requestPermission();
  //       if (permissionGranted != PermissionStatus.granted) {
  //         setState(() {
  //           _isLocationLoading = false;
  //         });
  //         return;
  //       }
  //     }

  //     locationData = await location.getLocation();

  //     setState(() {
  //       _isLocationLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint('Error getting location: $e');
  //     setState(() {
  //       _isLocationLoading = false;
  //     });
  //   }
  // }

  Future<void> getAllBranches() async {
    final notifier = ref.read(esouqProvider.notifier);
    await notifier.fetchBankBranches(
      productId: widget.productId,
      //  "688385ab0c8f01625a8d3f29"
    );

    final state = ref.read(esouqProvider);
    if (state.loadingState == LoadingState.error) {
      getAllBranches();
      return;
    }
    final branches = state.getAllBranchesResponse.payload;

    if (branches != null && branches.isNotEmpty) {
      final firstBranch = branches.first;
      final branchNameWithLocation =
          '${firstBranch.branchName} - ${firstBranch.branchLocation}';

      notifier.setSelectedBranch(
        branchName: branchNameWithLocation,
        branchId: firstBranch.id ?? '',
      );
    }
  }

  bool isPDFSelected = false;
  bool isPDFError = false;
  String? selectedPDFFileName;
  String? pdfPath;
  Future<void> _pickPdf() async {
    try {
      // Show bottom sheet with options
      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 180,
            child: Column(
              children: [
                const Text(
                  "Select Document",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _optionButton(
                      icon: Icons.camera_alt,
                      text: "Camera",
                      onTap: () {
                        Navigator.pop(context);
                        _takePhotoFromCamera();
                      },
                    ),
                    _optionButton(
                      icon: Icons.insert_drive_file,
                      text: "File",
                      onTap: () {
                        Navigator.pop(context);
                        _pickFileFromStorage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Error showing bottom sheet: $e');
      // await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // Add this helper widget for the option buttons
  Widget _optionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 30, color: AppColors.primaryGold500),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Keep the rest of the methods as they were
  Future<void> _takePhotoFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // Generate a short custom name instead of long default one
        final String shortName =
            "photo_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await _processSelectedFile(pickedFile.path, shortName);
      }
    } catch (e, stackTrace) {
      debugPrint('Error taking photo: $e');
      // await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // Future<void> _takePhotoFromCamera() async {
  //   try {
  //     final pickedFile = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //       imageQuality: 80,
  //       maxWidth: 800,
  //       maxHeight: 800,
  //     );

  //     if (pickedFile != null) {
  //       await _processSelectedFile(pickedFile.path, pickedFile.name);
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Error taking photo: $e');
  //     // await Sentry.captureException(e, stackTrace: stackTrace);
  //   }
  // }
  Future<void> _pickFileFromStorage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        await _processSelectedFile(
          result.files.single.path!,
          result.files.single.name,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking file: $e');
      // await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> _processSelectedFile(String filePath, String fileName) async {
    try {
      debugPrint('Selected file: $filePath');

      if (!mounted) return;

      await ref
          .read(authProvider.notifier)
          .uploadNomineeDocument(
            pdfPath: filePath,
            fileName: fileName,
            context: context,
          );

      setState(() {
        pdfPath = filePath;
        isPDFSelected = true;
        isPDFError = false;
        selectedPDFFileName = fileName;
      });
    } catch (e, stackTrace) {
      debugPrint('Error processing file: $e');
      setState(() {
        isPDFSelected = false;
        selectedPDFFileName = null;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// Update checkout method based on payment type
  Future<void> updateCheckOutMethod() async {
    setState(() {
      // payable money amount
      num payableAmount =
          num.tryParse(widget.grandPayableTotalGramOrMoney.toString()) ?? 0.0;
      // delivery fee
      num deliveryFee = num.tryParse(widget.deliveryCharges.toString()) ?? 0.0;
      // total charges including delivery charges
      num totalCharges = num.tryParse(widget.totalCharges.toString()) ?? 0.0;

      // Money or Metal
      bool isMoneyPayment = widget.paymentMethod == "Money";
      // Collection | Delivery
      final bool isDelivery = _selectedItem == "Delivery";
      debugPrint("isMoneyPayment: $isMoneyPayment | isDelivery: $isDelivery");

      if (isDelivery) {
        // delivery
        withDeliveryCharges = num.parse(payableAmount.toStringAsFixed(2));
        debugPrint("withDeliveryCharges: $withDeliveryCharges");
      } else if (!isDelivery && isMoneyPayment) {
        // collect and money
        collectionTotal = num.parse(
          (payableAmount - deliveryFee).toStringAsFixed(2),
        );
        debugPrint("collectionTotal: $collectionTotal");
      } else {
        // collect and metal
        collectionTotal = num.parse(
          (payableAmount).toStringAsFixed(2),
        );
        totalChargersMinusDeliveryFee = num.parse(
          (totalCharges - deliveryFee).toStringAsFixed(2),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Map English -> Arabic for display only
    final Map<String, String> displayMap = {
      'Delivery': Directionality.of(context) == TextDirection.rtl
          ? 'توصيل'
          : 'Delivery',
      'Collection': Directionality.of(context) == TextDirection.rtl
          ? 'استلام'
          : 'Collection',
    };
    final goldPriceState = ref.watch(goldPriceProvider);

    /// Refresh sizes on orientation change
    sizes!.refreshSize(context);
    //final bankBranchNotifier = ref.watch(bankBranchProvider.notifier);
    final bankBranchState = ref.watch(esouqProvider);
    final authState = ref.watch(authProvider);
    //final authNotifier = ref.read(authProvider.notifier);
    /// update checkout method
    updateCheckOutMethod();

    // /// bank branch state
    // final bankBranchState = ref.watch(bankBranchProvider);

    ///provider
    final esouqStateWatchProvider = ref.watch(esouqProvider);
    final esouqStateReadProvider = ref.read(esouqProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.checkout,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OneMinuteTimer(
              key: timerKey,
              onFinish: () {
                print("Timer finished");
              },
            ),
          ),
        ],
      ),

      // appBar: AppBar(
      //   backgroundColor: AppColors.greyScale1000,
      //   elevation: 0,
      //   surfaceTintColor: AppColors.greyScale1000,
      //   foregroundColor: Colors.white,
      //   centerTitle: true,
      //   title: GetGenericText(
      //     text: AppLocalizations.of(context)!.checkout, //"Checkout",
      //     fontSize: 20,
      //     fontWeight: FontWeight.w400,
      //     color: AppColors.grey6Color,
      //   ),
      // ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: sizes!.isPhone
                      ? sizes!.widthRatio * 360
                      : sizes!.width,
                  height: sizes!.heightRatio * 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      dropdownColor: AppColors.primaryGold500,
                      value: _selectedItem,
                      icon: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SvgPicture.asset(
                          "assets/svg/arrow_down.svg",
                          height: sizes!.heightRatio * 24,
                          width: sizes!.widthRatio * 24,
                        ),
                      ),
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedItem = newValue!; // Keep English for logic
                        });
                      },
                      items: _dropdownItems.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value, // English value
                          child: Padding(
                            padding:
                                Directionality.of(context) == TextDirection.rtl
                                ? EdgeInsets.only(right: 16)
                                : EdgeInsets.only(left: 16),
                            child: GetGenericText(
                              text:
                                  displayMap[value] ??
                                  value, // Show Arabic if RTL
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey6Color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // DropdownButton<String>(
                    //   dropdownColor: AppColors.primaryGold500,
                    //   value: _selectedItem,
                    //   icon: Padding(
                    //     padding: EdgeInsets.only(right: 16),
                    //     child: SvgPicture.asset(
                    //       "assets/svg/arrow_down.svg",
                    //       height: sizes!.heightRatio * 24,
                    //       width: sizes!.widthRatio * 24,
                    //     ),
                    //   ),
                    //   iconSize: 24,
                    //   elevation: 16,
                    //   // isDense: true,
                    //   isExpanded: true,
                    //   // style: TextStyle(color: Colors.deepPurple),
                    //   underline: Container(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _selectedItem = newValue!;
                    //     });
                    //   },
                    //   items: _dropdownItems.map<DropdownMenuItem<String>>((
                    //     String value,
                    //   ) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Padding(
                    //         padding: const EdgeInsets.only(left: 16),
                    //         child: GetGenericText(
                    //           text: value,
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           color: AppColors.grey6Color,
                    //         ),
                    //       ), //Text(value),
                    //     );
                    //   }).toList(),
                    // ),
                  ),
                ),
                ConstPadding.sizeBoxWithHeight(height: 16),
                _selectedItem == "Delivery"
                    ? buildDeliveryCard()
                    : bankBranchState.loadingState == LoadingState.loading ||
                          bankBranchState.loadingState != LoadingState.data
                    ? Center(
                        child: ShimmerLoader(loop: 6),
                      ).get6HorizontalPadding()
                    : buildCollectionCard(),
                ConstPadding.sizeBoxWithHeight(height: 16),
                //Delivery charge field
                _selectedItem == "Delivery"
                    ? Container(
                        width: sizes!.isPhone
                            ? sizes!.widthRatio * 360
                            : sizes!.width,
                        // height: sizes!.heightRatio * 56,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.deliveryCharges, //"Delivery Charges",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey2Color,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GetGenericText(
                                  text: _selectedItem == "Delivery"
                                      ? "${(widget.deliveryCharges).toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}"
                                      : "${collectionTotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey6Color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(),
                ConstPadding.sizeBoxWithHeight(height: 16),

                /// to pay card
                /// to pay card
                Container(
                  width: sizes!.isPhone
                      ? sizes!.widthRatio * 360
                      : sizes!.width,
                  // height: sizes!.heightRatio * 56,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GetGenericText(
                        text: AppLocalizations.of(context)!.toPay, //"To Pay",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey2Color,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GetGenericText(
                            text: _selectedItem == "Delivery"
                                ? widget.paymentMethod == "Money"
                                      ? "${(withDeliveryCharges).toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}"
                                      : "${(withDeliveryCharges).toStringAsFixed(2)} ${AppLocalizations.of(context)!.grams}"
                                : widget.paymentMethod == "Money"
                                ? "${collectionTotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}"
                                : "${collectionTotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.grams}",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey6Color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ConstPadding.sizeBoxWithHeight(height: 16),

                widget.selectedPaymentMethod == "Metal"
                    ? Container(
                        width: sizes!.isPhone
                            ? sizes!.widthRatio * 360
                            : sizes!.width,
                        // height: sizes!.heightRatio * 56,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GetGenericText(
                              text: AppLocalizations.of(
                                context,
                              )!.totalCharges, //"Total Charges",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey2Color,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GetGenericText(
                                  text: _selectedItem == "Delivery"
                                      ? "${widget.totalCharges.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}"
                                      : "${collectionCharges.toStringAsFixed(2)} ${AppLocalizations.of(context)!.aed_currency}",
                                  //collectionTotal.toStringAsFixed(2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey6Color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(),
                ConstPadding.sizeBoxWithHeight(height: 5),
                OneMinuteTimer(
                  key: timerKey,
                  onFinish: () {
                    print("Timer finished");
                  },
                ),

                ConstPadding.sizeBoxWithHeight(height: 16),
                widget.selectedPaymentMethod == "Metal"
                    ? ConstPadding.sizeBoxWithHeight(height: 16)
                    : Container(),

                /// confirm button
                LoaderButton(
                  title: AppLocalizations.of(
                    context,
                  )!.confirmPaymentBtn, //"Confirm Payment",
                  isLoadingState: esouqStateWatchProvider.isButtonState,
                  onTap: () async {
                    if (_selectedItem == "Delivery") {
                      if (_formKey.currentState?.validate() ?? false) {
                        var deliveryAddress =
                            "${houseNumberController.text.toString().trim()}, ${streetAddressController.text.toString().trim()}, ${areaController.text.toString().trim()}, ${emirateController.text.toString().trim()}";

                        final nomineeName = nomineeController.text
                            .toString()
                            .trim();
                        if (authState.residencyPDFUrl == "" && isNominate) {
                          Toasts.getErrorToast(
                            text:
                                '${AppLocalizations.of(context)!.upload_req_doc} ${authState.residencyPDFUrl}',
                            // 'Please upload required document ${authState.residencyPDFUrl}',
                          );
                          return;
                        }
                        if (nomineeName == "" && isNominate) {
                          Toasts.getErrorToast(
                            text: AppLocalizations.of(context)!.enter_nom_name,
                            // 'Please enter Nominee Name',
                          );
                          return;
                        }
                        // if (widget.paymentMethod == "Metal") {
                        //   print("object:  ${widget.goldPrice.toString()}");
                        // create esouq order ...
                        timerKey.currentState?.stopTimer();
                        await esouqStateReadProvider.createEsouqOrder(
                          productId: widget.product.id.toString(),
                          goldQuantity: widget.goldQuantity.toString(),
                          goldPrice: widget.goldPrice.toString(),
                          paymentMethod: widget.paymentMethod.toString(),
                          deliveryAddress: deliveryAddress,
                          currentGoldPrice: widget.currentGoldPrice,
                          product: widget.product,
                          isNominate: isNominate,
                          nomineeName: nomineeName,
                          nomineeDocument: authState.residencyPDFUrl.isNotEmpty
                              ? authState.residencyPDFUrl
                              : "",
                          branchId: null,
                          deliveryMethod: "Delivery",
                          makingCharges: widget.makingCharges.toString(),
                          valueAtTax: widget.valueAtTax.toString(),
                          deliveryCharges: widget.deliveryCharges.toString(),
                          premiumDiscount: widget.premiumDiscount.toString(),
                          totalCharges: widget.totalCharges.toString(),
                          payableGrandTotal: withDeliveryCharges.toString(),
                          selectedDealsData: widget.selectedDealsData,
                          context: context,
                        );
                        // }

                        // else {
                        //   print("object22222222222:  ${widget.goldPrice.toString()}");
                        //   // create esouq order
                        // await esouqStateReadProvider.userCanBuyGold(
                        //   productId: widget.product.id.toString(),
                        //   goldQuantity: widget.goldQuantity.toString(),
                        //     product: widget.product,
                        //     goldPrice: widget.goldPrice.toString(),
                        //     currentGoldPrice:
                        //         goldPriceState.value?.oneGramBuyingPriceInAED ??
                        //         0.0,
                        //     paymentMethod: widget.paymentMethod.toString(),
                        //     deliveryAddress: deliveryAddress,
                        //     isNominate: isNominate,
                        //     nomineeName: nomineeName,
                        //     nomineeDocument:
                        //         authState.residencyPDFUrl.isNotEmpty
                        //         ? authState.residencyPDFUrl
                        //         : "",
                        //     branchId: null,
                        //     deliveryMethod: "Delivery",
                        //     makingCharges: widget.makingCharges.toString(),
                        //     valueAtTax: widget.valueAtTax.toString(),
                        //     deliveryCharges: widget.deliveryCharges.toString(),
                        //     premiumDiscount: widget.premiumDiscount.toString(),
                        //     totalCharges: widget.totalCharges.toString(),
                        //     payableGrandTotal: withDeliveryCharges.toString(),
                        //   selectedDealsData: widget.selectedDealsData,
                        //     context: context,
                        //   );
                        // }
                      }
                    } else {
                      if (selectedBranchId == null) {
                        Toasts.getWarningToast(
                          text: AppLocalizations.of(
                            context,
                          )!.select_collection_branch, //"Please select collection branch first",
                        );
                        return;
                      }
                      // if (widget.paymentMethod == "Metal") {
                      //   print("object2112121212121:  ${widget.goldPrice.toString()}");
                      /// create esouq order
                      timerKey.currentState?.stopTimer();
                      await esouqStateReadProvider.createEsouqOrder(
                        productId: widget.product.id.toString(),
                        goldQuantity: widget.goldQuantity.toString(),
                        goldPrice: widget.goldPrice.toString(),
                        paymentMethod: widget.paymentMethod.toString(),
                        deliveryAddress: "",
                        currentGoldPrice: widget.currentGoldPrice,
                        product: widget.product,
                        isNominate: isNominate,
                        nomineeName: "",
                        nomineeDocument: "",
                        branchId: "$selectedBranchId",
                        deliveryMethod: "Pickup",
                        makingCharges: widget.makingCharges.toString(),
                        valueAtTax: widget.valueAtTax.toString(),
                        deliveryCharges: widget.deliveryCharges.toString(),
                        premiumDiscount: widget.premiumDiscount.toString(),
                        totalCharges:
                            (widget.totalCharges - widget.deliveryCharges)
                                .toString(),
                        payableGrandTotal: collectionTotal.toString(),
                        selectedDealsData: widget.selectedDealsData,
                        context: context,
                      );

                      // }
                      // else {
                      //   print("object33333333333333333333333333:  ${widget.goldPrice.toString()}");
                      //   /// create esouq order
                      //   await esouqStateReadProvider.userCanBuyGold(
                      //     productId: widget.product.id.toString(),
                      //     product: widget.product,
                      //     goldQuantity: widget.goldQuantity.toString(),
                      //     currentGoldPrice:
                      //         goldPriceState.value?.oneGramBuyingPriceInAED ??
                      //         0.0,
                      //     goldPrice: widget.goldPrice.toString(),
                      //     paymentMethod: widget.paymentMethod.toString(),
                      //     deliveryAddress: "",
                      //     isNominate: isNominate,
                      //     nomineeName: "",
                      //     nomineeDocument: "",
                      //     branchId: "$selectedBranchId",
                      //     deliveryMethod: "Pickup",
                      //     makingCharges: widget.makingCharges.toString(),
                      //     valueAtTax: widget.valueAtTax.toString(),
                      //     deliveryCharges: widget.deliveryCharges.toString(),
                      //     premiumDiscount: widget.premiumDiscount.toString(),
                      //     totalCharges:
                      //         (widget.totalCharges - widget.deliveryCharges)
                      //             .toString(),
                      //     payableGrandTotal: collectionTotal.toString(),
                      //     selectedDealsData: widget.selectedDealsData,
                      //     context: context,
                      //   );

                      // }
                    }
                  },
                ),

                ConstPadding.sizeBoxWithHeight(height: 16),
              ],
            ).get16HorizontalPadding(),
          ),
        ),
      ),
    );
  }

  // build delivery card
  Widget buildDeliveryCard() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //_buildLocationToggleAndMap(),
          CommonTextFormField(
            title: "",
            hintText: "10",
            labelText: AppLocalizations.of(
              context,
            )!.houseNumber, //"House Number",
            textInputType: TextInputType.number,
            controller: houseNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(
                  context,
                )!.enterHouseNo; //'Please enter a house number';
              }
              return null;
            },
          ),
          ConstPadding.sizeBoxWithHeight(height: 16),
          CommonTextFormField(
            title: "",
            hintText: AppLocalizations.of(
              context,
            )!.roadingStreet, //"Roding Street",
            labelText: AppLocalizations.of(
              context,
            )!.streetAddress, //"Street Address",
            textInputType: TextInputType.text,
            controller: streetAddressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(
                  context,
                )!.enter_street_address; //'Please enter a street address';
              }
              return null;
            },
          ),
          ConstPadding.sizeBoxWithHeight(height: 16),
          CommonTextFormField(
            title: "",
            hintText: AppLocalizations.of(
              context,
            )!.emiratesHill, //"Emirates Hill First",
            labelText: AppLocalizations.of(context)!.area, //"Area",
            textInputType: TextInputType.text,
            controller: areaController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(
                  context,
                )!.please_enter_area; //'Please enter an area';
              }
              return null;
            },
          ),
          ConstPadding.sizeBoxWithHeight(height: 16),
          CommonTextFormField(
            title: "",
            hintText: AppLocalizations.of(context)!.dubai_title, //"Dubai",
            labelText: AppLocalizations.of(context)!.emirate, //"Emirate",
            textInputType: TextInputType.text,
            controller: emirateController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(
                  context,
                )!.list_of_emirates; //'Please enter an emirate';
              }
              return null;
            },
          ),
          ConstPadding.sizeBoxWithHeight(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetGenericText(
                text: AppLocalizations.of(
                  context,
                )!.nominate_recipient, //"Nominate a Recipient",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              Switch.adaptive(
                activeColor: AppColors.primaryGold500,
                thumbColor: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.orange.withValues(alpha: .48);
                  }
                  return Colors.white;
                }),
                value: isNominate,
                onChanged: (value) {
                  setState(() {
                    isNominate = value;
                  });
                },
              ),
            ],
          ),
          Visibility(
            visible: isNominate,
            child: Column(
              children: [
                ConstPadding.sizeBoxWithHeight(height: 10),
                CommonTextFormField(
                  title: "",
                  hintText: AppLocalizations.of(
                    context,
                  )!.user_firstName, //"James",
                  labelText: AppLocalizations.of(
                    context,
                  )!.nominee_name, //"Nominee Name",
                  controller: nomineeController,
                ),
                ConstPadding.sizeBoxWithHeight(height: 4),
                // GetGenericText(
                //   text:
                //       "Your nominated recipient will be asked to show their ID.",
                //   fontSize: 12,
                //   fontWeight: FontWeight.w400,
                //   color: AppColors.grey6Color,
                // ),
              ],
            ),
          ),
          Visibility(
            visible: isNominate,
            child: GestureDetector(
              onTap: _pickPdf,
              child: Container(
                height: sizes!.heightRatio * 120,
                width: sizes!.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1.50,
                    color: isPDFError
                        ? Color(0xFFFF0000)
                        : isPDFSelected
                        ? Color(0xFFBBA473)
                        : AppColors.secondaryColor,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (selectedPDFFileName != null) ...[
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGold500,
                            size: 30,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 8),
                          GetGenericText(
                            text: selectedPDFFileName!,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor,
                          ),
                          ConstPadding.sizeBoxWithHeight(height: 4),
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.kyc_doc_success, //"Document added successfully!",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteColor,
                          ),
                        ] else ...[
                          GetGenericText(
                            text: AppLocalizations.of(
                              context,
                            )!.upload_residency_esoq, //"Upload residency Proof ",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteColor,
                          ),
                          ConstPadding.sizeBoxWithHeight(
                            height: 4,
                          ),
                          GetGenericText(
                            text: AppLocalizations.of(context)!.nominee_id,
                            //"Please upload the Emirates Id of Your Nominee",
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteColor,
                          ),
                          ConstPadding.sizeBoxWithHeight(
                            height: 4,
                          ),
                          // GetGenericText(
                          //   text: "Passport",
                          //   fontSize: 8,
                          //   fontWeight: FontWeight.w400,
                          //   color: AppColors.whiteColor,
                          // ),
                        ],
                      ],
                    ),
                    // Visibility(
                    //   visible: authState.isImageState,
                    //   child: Positioned(
                    //     child: CircularProgressIndicator(
                    //       color: AppColors.primaryGold500,
                    //       strokeWidth: 2,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCollectionCard() {
    final bankBranchState = ref.watch(esouqProvider);
    final branches = bankBranchState.getAllBranchesResponse.payload!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (branches.isNotEmpty)
          ListView.builder(
            itemCount: branches.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final data = branches[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedBranchIndex = index;
                    selectedBranchId = data.id;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedBranchIndex == index
                        ? AppColors.primaryGold500.withValues(alpha: 0.2)
                        : AppColors.greyScale900,
                    border: Border.all(
                      color: selectedBranchIndex == index
                          ? AppColors.primaryGold500
                          : AppColors.greyScale700,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GetGenericText(
                        text:
                            data.branchName ??
                            AppLocalizations.of(
                              context,
                            )!.branch_name, //"Branch Name",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey6Color,
                      ),
                      ConstPadding.sizeBoxWithHeight(height: 4),
                      GetGenericText(
                        text:
                            data.branchLocation ??
                            AppLocalizations.of(
                              context,
                            )!.branch_address, //"Branch Address",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey4Color,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          GetGenericText(
            text: AppLocalizations.of(
              context,
            )!.no_branch_available, //"No branches available.",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.grey6Color,
          ),
        ConstPadding.sizeBoxWithHeight(height: 16),
        GetGenericText(
          text: AppLocalizations.of(context)!.dateTime, //"Date & Time:",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.grey3Color,
        ),
        ConstPadding.sizeBoxWithHeight(height: 4),
        GetGenericText(
          text: AppLocalizations.of(context)!.will_notify_via_email,
          //"You will be notified via email once your order is ready for collection",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey4Color,
        ),
      ],
    );
  }

  // Widget _buildLocationToggleAndMap() {
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           GetGenericText(
  //             text: "Deliver To My Location",
  //             fontSize: 16,
  //             fontWeight: FontWeight.w400,
  //             color: Colors.white,
  //           ),
  //           Switch.adaptive(
  //             activeColor: AppColors.primaryGold500,
  //             thumbColor: WidgetStateProperty.resolveWith<Color>((
  //               Set<WidgetState> states,
  //             ) {
  //               if (states.contains(WidgetState.disabled)) {
  //                 return Colors.orange.withOpacity(0.48);
  //               }
  //               return Colors.white;
  //             }),
  //             value: isLocationRequired,
  //             onChanged: (value) {
  //               setState(() {
  //                 isLocationRequired = value;
  //               });
  //               if (value) {
  //                 _getCurrentLocation();
  //               }
  //             },
  //           ),
  //         ],
  //       ),

  //       if (isLocationRequired) ...[
  //         ConstPadding.sizeBoxWithHeight(height: 16),
  //         SizedBox(
  //           height: sizes!.heightRatio * 200,
  //           width: double.infinity,
  //           // decoration: BoxDecoration(
  //           //   borderRadius: BorderRadius.circular(10),
  //           //   border: Border.all(color: AppColors.secondaryColor),
  //           // ),
  //           child: _isLocationLoading
  //               ? Center(
  //                   child: CircularProgressIndicator(
  //                     color: AppColors.primaryGold500,
  //                   ),
  //                 )
  //               : locationData == null
  //               ? Center(
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(
  //                         Icons.location_off,
  //                         color: AppColors.grey4Color,
  //                         size: 40,
  //                       ),
  //                       ConstPadding.sizeBoxWithHeight(height: 8),
  //                       GetGenericText(
  //                         text: "Unable to get location",
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w400,
  //                         color: AppColors.grey4Color,
  //                       ),
  //                       ConstPadding.sizeBoxWithHeight(height: 8),
  //                       ElevatedButton(
  //                         onPressed: _getCurrentLocation,
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.primaryGold500,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         child: GetGenericText(
  //                           text: "Retry",
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                           color: AppColors.whiteColor,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               : Container(
  //                   height: sizes!.heightRatio * 200,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(
  //                       12,
  //                     ), // Circular border radius
  //                     border: Border.all(
  //                       color: AppColors.secondaryColor, // Border color
  //                       width: 1.5,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.1),
  //                         blurRadius: 4,
  //                         offset: Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: ClipRRect(
  //                     // This clips the map to the border radius
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: FlutterMap(
  //                       mapController: _mapController,
  //                       options: MapOptions(
  //                         initialCenter: LatLng(
  //                           locationData!.latitude!,
  //                           locationData!.longitude!,
  //                         ),
  //                         initialZoom: 15.0,
  //                       ),
  //                       children: [
  //                         TileLayer(
  //                           urlTemplate:
  //                               'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  //                           userAgentPackageName:
  //                               'ae.saveingold.saveingold.fzco',
  //                         ),
  //                         MarkerLayer(
  //                           markers: [
  //                             Marker(
  //                               point: LatLng(
  //                                 locationData!.latitude ?? 0.0,
  //                                 locationData!.longitude ?? 0.0,
  //                               ),
  //                               width: 40,
  //                               height: 40,
  //                               child: Icon(
  //                                 Icons.location_pin,
  //                                 color: AppColors.primaryGold500,
  //                                 size: 40,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //         ),
  //         ConstPadding.sizeBoxWithHeight(height: 8),
  //         GetGenericText(
  //           text: "Your current location is being shared for delivery purposes",
  //           fontSize: 12,
  //           fontWeight: FontWeight.w400,
  //           color: AppColors.grey6Color,
  //         ),
  //         ConstPadding.sizeBoxWithHeight(height: 8),
  //       ],
  //     ],
  //   );
  // }
}
