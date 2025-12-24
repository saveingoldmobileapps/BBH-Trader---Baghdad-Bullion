import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/network_sources/network_export.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_index.dart';
import 'package:saveingold_fzco/presentation/screens/fund_screens/add_fund_screen.dart';
import 'package:saveingold_fzco/presentation/screens/main_home_screens/slider_offers.dart';
import 'package:saveingold_fzco/presentation/screens/news_screen/news_screen.dart';
import 'package:saveingold_fzco/presentation/screens/notification_screens/notification_screen.dart';
import 'package:saveingold_fzco/presentation/screens/setting_screens/setting_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/home_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/account_warning.dart';
import 'package:saveingold_fzco/presentation/widgets/demo_banner.dart';
import 'package:saveingold_fzco/presentation/widgets/get_drawer_bar.dart';
import 'package:saveingold_fzco/presentation/widgets/home_feed_wallet.dart';
import 'package:saveingold_fzco/presentation/widgets/home_news_card.dart';
import 'package:saveingold_fzco/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/socket_services.dart';
import '../../../data/data_sources/local_database/local_database.dart';
import '../../../data/models/LoginResponse.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/pop_up_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isHiddenBalance = false;
  Timer? timer;
  final int _currentIndex = 0;
  final PageController _pageController = PageController();
  LoginResponse? loginResponse;
  bool _isDisposed = false;
  final SocketService _socketService = SocketService();
  late Timer _autoScrollTimer; // Add this for auto-scrolling
  int _currentOfferIndex = 0; // Track current offer index

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppUpdate();

      if (_isDisposed) return;
      setLoginState();
      ref.read(homeProvider.notifier).getUserProfile();
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(context: context, showLoading: true);
      // connectSocket();
      _startAutoScroll();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _socketService.disconnect();
    }

    if (state == AppLifecycleState.resumed) {
      CommonService.connectSocket();
    }
  }

  Future<void> checkAppUpdate() async {
    // Call API
    await ref.read(homeProvider.notifier).checkAppUpdate();

    final response = ref.watch(homeProvider).appUpdateResponse;

    if (response.payload != null) {
      final apiAndroidVersion = response.payload?.androidVersion;
      final apiIosVersion = response.payload?.iosVersion;
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersionCode = int.tryParse(packageInfo.buildNumber);
      int? apiVersionCode;

      if (Platform.isAndroid) {
        apiVersionCode = int.tryParse(apiAndroidVersion ?? "") ?? 0;
      } else if (Platform.isIOS) {
        apiVersionCode = int.tryParse(apiIosVersion ?? "") ?? 0;
      }
      bool isForceUpdate = response.payload?.updateType == "Normal"
          ? false
          : true;
      if (apiVersionCode != null && currentVersionCode != null) {
        if (apiVersionCode > currentVersionCode) {
          print(
            " Update available! Current: $currentVersionCode, New: $apiVersionCode",
          );
          if (!mounted) return;
          updateAppPopupWidget(
            context: context,
            heading: AppLocalizations.of(context)!.update_required,
            subtitle: AppLocalizations.of(context)!.update_message,
            isForceUpdate: isForceUpdate,
            onUpdatePress: () async {
              final url = Platform.isIOS
                  ? Uri.parse(ApiEndpoints.appStoreUrl)
                  : Uri.parse(
                      ApiEndpoints.playStoreUrl,
                    );

              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                throw "Could not launch $url";
              }
            },
            onClosePress: () {
              Navigator.pop(context);
            },
          );
        } else {
          debugPrint(
            "App is up to date. Current: $currentVersionCode, API: $apiVersionCode",
          );
        }
      }
    }
  }

  // Add auto-scroll methods
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      final offerCount =
          ref.read(homeProvider).getHomeFeedResponse.payload?.offers?.length ??
          0;

      if (offerCount <= 1) return;

      if (_currentOfferIndex < offerCount - 1) {
        // Scroll to next offer
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Jump back to first offer without animation
        _pageController.jumpToPage(0);
        setState(() {
          _currentOfferIndex = 0;
        });
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer.cancel();
  }

  Future<void> getName() async {
    loginResponse = await LocalDatabase.instance.getLoginUserFromStorage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizes!.initializeSize(context);
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  Future<void> setLoginState() async {
    await LocalDatabase.instance.storeAutoLogin(autoLogin: true);
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final mainStateWatchProvider = ref.watch(homeProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      onDrawerChanged: (isOpened) {},
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        surfaceTintColor: AppColors.greyScale1000,
        leading: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Container(
            color: Colors.transparent,
            height: sizes!.responsiveHeight(
              phoneVal: 24,
              tabletVal: 32,
            ),
            width: sizes!.responsiveWidth(
              phoneVal: 24,
              tabletVal: 32,
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/svg/menu_icon.svg",
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: GetGenericText(
          text: mainStateWatchProvider.getUserProfileResponse.payload != null
              ? CommonService.getGreeting(
                  mainStateWatchProvider
                          .getUserProfileResponse
                          .payload!
                          .userProfile!
                          .firstName!
                          .en ??
                      "",
                  context,
                )
              : "",
          fontSize: sizes!.responsiveFont(
            phoneVal: 18,
            tabletVal: 22,
          ),
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        // GetGenericText(
        //   text: mainStateWatchProvider.getUserProfileResponse.payload != null
        //       ?
        //       mainStateWatchProvider.getUserProfileResponse.payload!
        //               .userProfile!.firstName!.en ??
        //           "" ??
        //           ""
        //       : "",
        //   fontSize: sizes!.responsiveFont(
        //     phoneVal: 18,
        //     tabletVal: 22,
        //   ),
        //   fontWeight: FontWeight.w400,
        //   color: Colors.white,
        // ),
        actions: [
          Directionality.of(context) == TextDirection.rtl
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/svg/notify_icon.svg",
                        height: sizes!.responsiveHeight(
                          phoneVal: 24,
                          tabletVal: 32,
                        ),
                        width: sizes!.responsiveWidth(
                          phoneVal: 24,
                          tabletVal: 32,
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/svg/notify_icon.svg",
                        height: sizes!.responsiveHeight(
                          phoneVal: 24,
                          tabletVal: 32,
                        ),
                        width: sizes!.responsiveWidth(
                          phoneVal: 24,
                          tabletVal: 32,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      body: Container(
        height: sizes!.height,
        width: sizes!.width,
        decoration: const BoxDecoration(
          color: AppColors.greyScale1000,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: AppColors.primaryGold500,
            color: AppColors.whiteColor,
            onRefresh: () async {
              await ref.read(homeProvider.notifier).getUserProfile();
              if (!context.mounted) return;
              await ref
                  .read(homeProvider.notifier)
                  .getHomeFeed(context: context, showLoading: true);
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible:
                        !mainStateWatchProvider.isEmailVerified &&
                        // mainStateWatchProvider.isDemo == false &&
                        mainStateWatchProvider.getHomeFeedResponse.payload !=
                            null &&
                        mainStateWatchProvider.loadingState ==
                            LoadingState.data,
                    child: AccountWarning(
                      kycStatus: "email",
                      onTap: () {
                        if (!mainStateWatchProvider.isEmailVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailVerifyCodeScreen(
                                email: mainStateWatchProvider.userEmail,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Visibility(
                  //   visible:mainStateWatchProvider
                  //           .getUserProfileResponse.payload?.userProfile?.userCustomKYCData
                  //           ?.adminVerificationStatus ==
                  //       "Pending",
                  //   child: CustomKycAccountWarning(
                  //     kycStatus: "Admin",
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => UserProfileScreen(),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  Visibility(
                    visible:
                        mainStateWatchProvider.getHomeFeedResponse.payload !=
                            null &&
                        mainStateWatchProvider.isDemo == true,
                    child: AccountModeBanner(
                      isDemo: true,
                      onGoLive: () {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible:
                        mainStateWatchProvider.getHomeFeedResponse.payload != null &&
                        (!mainStateWatchProvider.isBasicUserVerified ||
                            !mainStateWatchProvider.isUserKYCVerified) &&
                        mainStateWatchProvider.isDemo == false &&
                        mainStateWatchProvider.loadingState ==
                            LoadingState.data,
                    child: AccountWarning(
                      kycStatus: "documents",
                      onTap: () {
                        if (!mainStateWatchProvider.isBasicUserVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KycFirstStepScreen(),
                            ),
                          );
                        }

                        /// isBasicUserVerified = true than isUserKYCVerified = false
                        if (mainStateWatchProvider.isBasicUserVerified &&
                            !mainStateWatchProvider.isUserKYCVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KycSecondStepScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  ConstPadding.sizeBoxWithHeight(height: 6),

                  // Visibility(
                  //   visible:
                  //       (mainStateWatchProvider
                  //               .getUserProfileResponse
                  //               ?.payload
                  //               ?.userProfile
                  //               ?.adminCustomKYCStatus ==
                  //           null) &&
                  //       (mainStateWatchProvider.isDemo == false) &&
                  //       (mainStateWatchProvider.loadingState ==
                  //           LoadingState.data),
                  //   child: AccountWarning(
                  //     kycStatus: "custom Kyc",
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => UserProfileScreen(),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  //ConstPadding.sizeBoxWithHeight(height: 6),

                  /// Home Feed Wallet
                  mainStateWatchProvider.loadingState == LoadingState.data &&
                          mainStateWatchProvider.getHomeFeedResponse.payload !=
                              null
                      ? HomeFeedWallet(
                          isHiddenBalance: isHiddenBalance,
                          walletExists: mainStateWatchProvider
                              .getHomeFeedResponse
                              .payload!
                              .walletExists!,
                          onBalancePress: () {
                            setState(() {
                              isHiddenBalance = !isHiddenBalance;
                            });
                          },
                          onDepositPress: () async {
                            if (Scaffold.of(context).isDrawerOpen) {
                              Navigator.of(context).pop(); // Close the drawer
                            }
                            //If email not verified.
                            if (!mainStateWatchProvider.isEmailVerified) {
                              await genericPopUpWidget(
                                isLoadingState: false,
                                context: context,
                                heading: AppLocalizations.of(
                                  context,
                                )!.email_verification_required,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.email_verification_msg,
                                noButtonTitle: AppLocalizations.of(
                                  context,
                                )!.cancel,
                                yesButtonTitle: AppLocalizations.of(
                                  context,
                                )!.verify,
                                onNoPress: () async {
                                  Navigator.pop(context);
                                },
                                onYesPress: () async {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EmailVerifyCodeScreen(
                                            email: mainStateWatchProvider
                                                .userEmail,
                                          ),
                                    ),
                                  );
                                },
                              );
                              return;
                            }
                            //if email verified and Residency documents not verified.
                            if (mainStateWatchProvider.isEmailVerified &&
                                !mainStateWatchProvider.isBasicUserVerified) {
                              await genericPopUpWidget(
                                isLoadingState: false,
                                context: context,
                                heading: AppLocalizations.of(
                                  context,
                                )!.residency_document_required,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.residency_verification_message,
                                noButtonTitle: AppLocalizations.of(
                                  context,
                                )!.later,
                                yesButtonTitle: AppLocalizations.of(
                                  context,
                                )!.proceed,
                                onNoPress: () async {
                                  Navigator.pop(context);
                                },
                                onYesPress: () async {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          KycFirstStepScreen(),
                                    ),
                                  );
                                },
                              );
                              return;
                            }
                            //if email and residency document verified and kyc not verified
                            if (mainStateWatchProvider.isEmailVerified &&
                                mainStateWatchProvider.isBasicUserVerified &&
                                !mainStateWatchProvider.isUserKYCVerified) {
                              await genericPopUpWidget(
                                isLoadingState: false,
                                context: context,
                                heading: AppLocalizations.of(
                                  context,
                                )!.kyc_verification_required,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.kyc_verification_message,
                                noButtonTitle: AppLocalizations.of(
                                  context,
                                )!.later,
                                yesButtonTitle: AppLocalizations.of(
                                  context,
                                )!.proceed,
                                onNoPress: () async {
                                  Navigator.pop(context);
                                },
                                onYesPress: () async {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          KycSecondStepScreen(),
                                    ),
                                  );
                                },
                              );
                              return;
                            }
                            //if all verified, then navigate to add fund screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddFundScreen(),
                              ),
                            ).then((onValue) {});
                          },
                        )
                      : ShimmerLoader(
                          loop: sizes!.isPhone ? 1 : 4,
                        ),
                  ConstPadding.sizeBoxWithHeight(height: 8),

                  /// Offers
                  OfferCarousel(
                    mainStateWatchProvider: mainStateWatchProvider,
                    sizes: sizes!,
                  ),
                  //ConstPadding.sizeBoxWithHeight(height: 16),
                  //IntroductionVideoSection(),
                  ConstPadding.sizeBoxWithHeight(height: 8),
                  Visibility(
                    visible:
                        mainStateWatchProvider.loadingState ==
                        LoadingState.data,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetGenericText(
                          text: AppLocalizations.of(context)!.latest_news,
                          fontSize: sizes!.responsiveFont(
                            phoneVal: 20,
                            tabletVal: 22,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsScreen(),
                              ),
                            );
                          },
                          child: GetGenericText(
                            text:
                                (mainStateWatchProvider
                                            .getHomeFeedResponse
                                            .payload
                                            ?.newsUpdates ==
                                        null ||
                                    mainStateWatchProvider
                                        .getHomeFeedResponse
                                        .payload!
                                        .newsUpdates!
                                        .isEmpty
                                ? ""
                                : AppLocalizations.of(context)!.see_all),
                            fontSize: sizes!.responsiveFont(
                              phoneVal: 14,
                              tabletVal: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFBBA473),
                            isUnderline: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  mainStateWatchProvider.loadingState == LoadingState.data
                      ? (mainStateWatchProvider
                                        .getHomeFeedResponse
                                        .payload
                                        ?.newsUpdates ==
                                    null ||
                                mainStateWatchProvider
                                    .getHomeFeedResponse
                                    .payload!
                                    .newsUpdates!
                                    .isEmpty)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 10,
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
                                    GetGenericText(
                                      text: AppLocalizations.of(
                                        context,
                                      )!.oops_no_news,
                                      fontSize: sizes!.responsiveFont(
                                        phoneVal: 14,
                                        tabletVal: 16,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey6Color,
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                child: ListView.builder(
                                  itemCount:
                                      mainStateWatchProvider
                                          .getHomeFeedResponse
                                          .payload
                                          ?.newsUpdates
                                          ?.length ??
                                      0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final data = mainStateWatchProvider
                                        .getHomeFeedResponse
                                        .payload!
                                        .newsUpdates![index];
                                    return HomeNewsCard(
                                      newsUpdates: data,
                                    ).get6VerticalPadding();
                                  },
                                ),
                              )
                      : mainStateWatchProvider.loadingState ==
                            LoadingState.error
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GetGenericText(
                                text:
                                    "${mainStateWatchProvider.errorResponse.payload?.message.toString()}",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        )
                      : const ShimmerLoader(
                          loop: 2,
                        ),
                ],
              ).get16HorizontalPadding(),
            ),
          ),
        ),
      ),
    );
  }
}
