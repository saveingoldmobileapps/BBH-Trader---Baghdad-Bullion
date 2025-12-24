import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';
import 'package:saveingold_fzco/presentation/feature_injection.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/main_home_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/loader_button.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:saveingold_fzco/presentation/widgets/text_form_field_with_icon.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../widgets/search_drop_down.dart';

class KycFirstStepScreen extends ConsumerStatefulWidget {
  final bool? isFirstTime;

  const KycFirstStepScreen({
    super.key,
    this.isFirstTime,
  });

  @override
  ConsumerState createState() => _KycFirstStepScreenState();
}

class _KycFirstStepScreenState extends ConsumerState<KycFirstStepScreen> {
  final _formKey = GlobalKey<FormState>();
  final dateOfBirthController = TextEditingController();

  // Initial selected value
  String? _selectResidency;
  String? _selectNationality;

  bool isPDFSelected = false;
  bool isPDFError = false;
  String? selectedPDFFileName; // New state variable to store the file name

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).fetchAllCountries();
    });
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  /// select birthday
  Future<void> _selectBirthday() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime eighteenYearsAgo = DateTime(
        now.year - 18,
        now.month,
        now.day,
      );

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: eighteenYearsAgo,
        firstDate: DateTime(1950),
        lastDate: eighteenYearsAgo,
        helpText: "Select Date",
      );

      if (picked != null) {
        setState(() {
          dateOfBirthController.text = DateFormat("yyyy-MM-dd").format(picked);
        });
      }
    } catch (e) {
      getLocator<Logger>().e("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final List<String> countries =
        authState.countries
            .map((country) => "${country.name} - ${country.countryCode}")
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        centerTitle: false,

        // titleSpacing: 0,
        title: GetGenericText(
          text: AppLocalizations.of(context)!.kyc_tell_us_about_ur,//"Tell us about Yourself",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ), //20,
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
        ),
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.isLandscape() && !sizes!.isPhone
            ? sizes!.height
            : sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: authState.loadingState == LoadingState.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Note: 'spacing' is not a valid property for Column. Assuming you meant to add SizedBox for spacing.
                    children: [
                      Container(
                        height: sizes!.heightRatio * 30,
                        width: sizes!.widthRatio * 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.primaryGold500,
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: AppColors.whiteColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 10), // Added SizedBox for spacing
                      GetGenericText(
                        text:
                            "${authState.errorResponse.payload?.message.toString()}",
                        fontSize: sizes!.responsiveFont(
                          phoneVal: 14,
                          tabletVal: 16,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey6Color,
                      ),
                      ConstPadding.sizeBoxWithWidth(width: 6),
                      LoaderButton(
                        title: AppLocalizations.of(context)!.kyc_refresh,//"Refresh",
                        onTap: () async {
                          await ref
                              .read(authProvider.notifier)
                              .fetchAllCountries();
                        },
                      ).get16HorizontalPadding(),
                    ],
                  ),
                )
              : authState.loadingState == LoadingState.data
              ? SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ConstPadding.sizeBoxWithHeight(height: 8),
                        GetGenericText(
                          text:
                              AppLocalizations.of(context)!.kyc_information,//"Following information should match the information on the document you provide.",
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 16,
                            tabletVal: 18,
                          ),
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral80,
                        ).getAlign(),
                        ConstPadding.sizeBoxWithHeight(height: 24),
                        TextFormFieldWithIcon(
                          title: "title",
                          hintText: "DD/MM/YYYY",
                          labelText: AppLocalizations.of(context)!.kyc_dob,//"Date of Birth",
                          iconString: "assets/svg/date_icon.svg",
                          controller: dateOfBirthController,
                          readOnly: true,
                          textInputType: TextInputType.number,
                          onTap: _selectBirthday,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.kyc_enter_dob;//'Please enter date of birth';
                            }
                            return null;
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                        SearchableDropdown(
                          iconString: "assets/svg/arrow_down.svg",
                          title: "title",
                          items: countries,
                          label: AppLocalizations.of(context)!.kyc_res_cont,//"Country of Residence",
                          hint: "Select",
                          selectedItem: _selectResidency,
                          validator: (value) =>
                              value == null ? AppLocalizations.of(context)!.kyc_plz_select_resd:null,//'Please select residency' : null,
                          onChanged: (String value) {
                            setState(() {
                              _selectResidency = value;
                            });
                          },
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                        SearchableDropdown(
                          iconString: "assets/svg/arrow_down.svg",
                          title: "title",
                          items: countries,
                          label: AppLocalizations.of(context)!.kyc_nationality,//"Nationality",
                          hint: AppLocalizations.of(context)!.kyc_select,//"Select",
                          selectedItem: _selectNationality,
                          validator: (value) => value == null
                              ? AppLocalizations.of(context)!.kyc_plz_select_cont//'Please select nationality'
                              : null,
                          onChanged: (String value) {
                            setState(() {
                              _selectNationality = value;
                            });
                          },
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 16),

                        /// Upload Residency proof
                        GestureDetector(
                          onTap: _pickPdf,
                          child: Container(
                            height: sizes!.heightRatio * 120,
                            width: sizes!.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1.50,
                                color:
                                    // isPDFError
                                    //     ? Color(0xFFFF0000)
                                    //     : isPDFSelected
                                    // ? Color(0xFFBBA473)
                                    // :
                                    Color(0xFFBBA473).withAlpha(80),
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
                                        text: AppLocalizations.of(context)!.kyc_doc_success,//"Document added successfully!",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.whiteColor,
                                      ),
                                    ] else ...[
                                      GetGenericText(
                                        text:
                                        AppLocalizations.of(context)!.kyc_upload_proof,
                                            //"Upload residency proof (Optional)",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.whiteColor,
                                      ),
                                      ConstPadding.sizeBoxWithHeight(
                                        height: 4,
                                      ),
                                      GetGenericText(
                                        text: AppLocalizations.of(context)!.kyc_utility_bill,//"Utility Bill or Bank Statement",
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.whiteColor,
                                      ),
                                      ConstPadding.sizeBoxWithHeight(
                                        height: 4,
                                      ),
                                      GetGenericText(
                                        text: AppLocalizations.of(context)!.kyc_allowed_format,//"Allowed Format PDF",
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.whiteColor,
                                      ),
                                    ],
                                  ],
                                ),
                                Visibility(
                                  visible: authState.isImageState,
                                  child: Positioned(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold500,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //if (isPDFError) ...[
                        ConstPadding.sizeBoxWithHeight(height: 4),
                        // GetGenericText(
                        //   text: "Residency proof is required",
                        //   fontSize: 12,
                        //   fontWeight: FontWeight.w400,
                        //   color: AppColors.redColor,
                        // ).getAlign(),

                        //],
                        ConstPadding.sizeBoxWithHeight(height: 20),

                        /// get start button
                        getStartButton(
                          title: AppLocalizations.of(context)!.getStarted,//"Get Started",
                          isLoadingState: authState.isButtonState,
                          onTap: () async {
                            var residencyPdfUrl = ref
                                .watch(authProvider)
                                .residencyPDFUrl
                                .toString();

                            /// validate form
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                /// Call KYC first step
                                await authNotifier.kycFirstStep(
                                  dateOfBirthday: dateOfBirthController.text
                                      .trim(),
                                  countryOfResidence: _selectResidency ?? '',
                                  nationality: _selectNationality ?? '',
                                  // residencyProofUrl: residencyPdfUrl,
                                  residencyProofUrl: residencyPdfUrl.isNotEmpty
                                      ? residencyPdfUrl
                                      : "",
                                  context: context,
                                  isFirstTime: widget.isFirstTime,
                                );
                              } catch (e) {
                                // Show error toast for API failure
                                Toasts.getErrorToast(
                                  text: 'Failed to submit KYC: $e',
                                );
                              }
                            }
                          },
                        ),

                        ConstPadding.sizeBoxWithHeight(height: 16),
                        GestureDetector(
                          onTap: () async {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainHomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: GetGenericText(
                            text: AppLocalizations.of(context)!.kyc_skip,//"Skip for Now",
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGold500,
                          ).getChildCenter(),
                        ),
                        ConstPadding.sizeBoxWithHeight(height: 16),
                      ],
                    ).get16HorizontalPadding(),
                  ),
                )
              : Center(
                  child: ShimmerLoader(
                    loop: 5,
                  ),
                ).get20HorizontalPadding(),
        ),
      ),
    );
  }

  // Function to pick a PDF file
  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Restrict to PDF files
      );

      if (result != null && result.files.single.path != null) {
        String pdfPath = result.files.single.path!;
        String fileName = result.files.single.name;
        debugPrint('Selected PDF: $pdfPath');

        /// upload residency document
        if (!mounted) return;
        await ref
            .read(authProvider.notifier)
            .uploadResidencyDocument(
              pdfPath: pdfPath,
              fileName: fileName,
              context: context,
            );

        setState(() {
          isPDFSelected = true;
          isPDFError = false; // Reset error state on successful selection
          selectedPDFFileName = fileName; // Store the file name
        });
        // You can use pdfPath to display or process the PDF
      } else {
        debugPrint('No file selected');
        setState(() {
          isPDFSelected = false;
          selectedPDFFileName = null; // Clear file name if no file is selected
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking PDF: $e');
      setState(() {
        isPDFSelected = false;
        selectedPDFFileName = null; // Clear file name on error
      });
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // get start button
  Widget getStartButton({
    required String title,
    required bool isLoadingState,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sizes!.isPhone ? sizes!.widthRatio * 360 : sizes!.width,
        height: sizes!.responsiveLandscapeHeight(
          phoneVal: 56,
          tabletVal: 56,
          tabletLandscapeVal: 84,
          isLandscape: sizes!.isLandscape(),
        ),
        decoration: BoxDecoration(
          color: Color(0x33BBA473),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.50,
            color: Color(0xFFBBA473),
          ),
        ),
        child: Center(
          child: isLoadingState
              ? Container(
                  width: sizes!.widthRatio * 26,
                  height: sizes!.widthRatio * 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : GetGenericText(
                  text: title,
                  fontSize: sizes!.responsiveFont(
                    phoneVal: 16,
                    tabletVal: 18,
                  ),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
