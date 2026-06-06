import 'dart:async';
import 'dart:io';

import 'package:baghdad_bullion_house/presentation/screens/withdraw_fund_screens/withdraw_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:baghdad_bullion_house/data/data_sources/network_sources/network_export.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/auth_index.dart';
import 'package:baghdad_bullion_house/presentation/screens/main_home_screens/slider_offers.dart';
import 'package:baghdad_bullion_house/presentation/screens/news_screen/news_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/notification_screens/notification_screen.dart';
import 'package:baghdad_bullion_house/presentation/screens/setting_screens/setting_screen.dart';
import 'package:baghdad_bullion_house/presentation/sharedProviders/providers/home_provider.dart';
import 'package:baghdad_bullion_house/presentation/widgets/account_warning.dart';
import 'package:baghdad_bullion_house/presentation/widgets/demo_banner.dart';
import 'package:baghdad_bullion_house/presentation/widgets/get_drawer_bar.dart';
import 'package:baghdad_bullion_house/presentation/widgets/home_feed_wallet.dart';
import 'package:baghdad_bullion_house/presentation/widgets/home_news_card.dart';
import 'package:baghdad_bullion_house/presentation/widgets/shimmers/shimmer_loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/socket_services.dart';
import '../../../data/data_sources/local_database/local_database.dart';
import '../../../data/models/LoginResponse.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/demo_account_popup.dart';
import '../../widgets/home_quick_actions.dart';
import '../../widgets/pop_up_widget.dart';
import '../fund_screens/add_fund_screen.dart';
import '../setting_screens/support_screen.dart';
import '../withdraw_fund_screens/withdrawal_fund_screen.dart';

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
  late Timer _autoScrollTimer; // For auto-scrolling
  int _currentOfferIndex = 0; // Track current offer index

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppUpdate();

      if (_isDisposed) return;
      ref.read(homeProvider.notifier).getUserProfile();
      ref
          .read(homeProvider.notifier)
          .getHomeFeed(context: context, showLoading: true);
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

      bool isForceUpdate =
          // response.payload?.updateType == "Normal"
          //     ?
          false;
      // : true;

      if (apiVersionCode != null && currentVersionCode != null) {
        if (apiVersionCode > currentVersionCode) {
          if (!mounted) return;
          updateAppPopupWidget(
            context: context,
            heading: AppLocalizations.of(context)!.update_required,
            subtitle: AppLocalizations.of(context)!.update_message,
            isForceUpdate: isForceUpdate,
            onUpdatePress: () async {
              final url = Platform.isIOS
                  ? Uri.parse(ApiEndpoints.appStoreUrl)
                  : Uri.parse(ApiEndpoints.playStoreUrl);

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
        }
      }
    }
  }

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
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentOfferIndex += 1;
        });
      } else {
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

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final mainStateWatchProvider = ref.watch(homeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.greyScale1000,
      extendBodyBehindAppBar: true,
      drawer: GetDrawerBar(
        onTap: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      onDrawerChanged: (isOpened) {},
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.transparent,
        surfaceTintColor: AppColors.greyScale1000,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            /// Profile Avatar
            FutureBuilder<String?>(
              future: LocalDatabase.instance.getUserProfileImage(),
              builder: (context, snapshot) {
                final cachedImage = snapshot.data ?? '';

                final networkImage =
                    mainStateWatchProvider
                        .getUserProfileResponse
                        .payload
                        ?.userProfile
                        ?.imageUrl ??
                    '';

                final imageToShow = networkImage.isNotEmpty
                    ? networkImage
                    : cachedImage;

                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldLightColor,
                        width: 1.2,
                      ),
                      image: imageToShow.isNotEmpty
                          ? DecorationImage(
                              image: imageToShow.startsWith('http')
                                  ? NetworkImage(imageToShow)
                                  : FileImage(File(imageToShow))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                "assets/images/user_avatar.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            /// Search Bar
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.goldLightColor.withOpacity(0.4),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF1E1E1E),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.gift_search_here,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// Notification Icon
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: SvgPicture.asset(
                "assets/svg/notify_icon.svg",
                height: 24,
                width: 24,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff453e26),
                    Color(0xff1e2424),
                    Color(0xff1e2424),
                  ],
                  stops: const [
                    0.25,
                    0.7,
                    1.0,
                  ], // Adjust 0.4 to control how far the top gradient goes
                ),
              ),
            ),
          ),
          SafeArea(
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
                    /// Account Warnings
                    Visibility(
                      visible:
                          !mainStateWatchProvider.isEmailVerified &&
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

                    // Demo / KYC / Account Warnings...
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
                          mainStateWatchProvider.getHomeFeedResponse.payload !=
                              null &&
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

                    ConstPadding.sizeBoxWithHeight(height: 10),

                    /// Home Feed Wallet
                    mainStateWatchProvider.loadingState == LoadingState.data &&
                            mainStateWatchProvider
                                    .getHomeFeedResponse
                                    .payload !=
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
                              // Your deposit logic (email/KYC checks)
                            },
                          )
                        : ShimmerLoader(
                            loop: sizes!.isPhone ? 1 : 4,
                          ),

                    ConstPadding.sizeBoxWithHeight(height: 8),

                    Visibility(
                      visible:
                          mainStateWatchProvider.loadingState ==
                              LoadingState.data &&
                          mainStateWatchProvider
                                  .getHomeFeedResponse
                                  .payload !=
                              null,
                      child: HomeQuickActions(
                      onAddFunds: () async {
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;

                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;

                        if (isDemo) {
                          if (!context.mounted) return;
                          await UpgradeAccountPopup.show(
                            context: context,
                            ref: ref,
                          );
                          return;
                        }

                        if (!isEmailVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.email_verification_required, //"Email Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.email_verification_msg,
                            //"To continue, please verify your email address. Do you want to verify now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_cancel_btn, //"Cancel",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_verify_btn, //"Verify",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerifyCodeScreen(
                                    email: mainStateWatchProvider.userEmail,
                                  ),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        //if email verified and Residency documents not verified.
                        if (isEmailVerified && !isUserBasicKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.residency_document_required, //"Residency Document Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"To continue, please complete your residency document verification. Would you like to proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycFirstStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        //if email and residency document verified and kyc not verified
                        if (isEmailVerified &&
                            isUserBasicKycVerified &&
                            !isUserKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.kyc_verification_required, //"KYC Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"To continue, please complete your KYC verification. Would you like to proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycSecondStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // If all verifications are complete
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddFundScreen(),
                          ),
                        );
                      },
                      onWithdraw: () async {
                        final isEmailVerified =
                            await LocalDatabase.instance.getIsEmailVerified() ??
                            false;
                        final isUserBasicKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;
                        final isUserKycVerified =
                            await LocalDatabase.instance
                                .getIsUserBasicKycVerified() ??
                            false;

                        final isDemo =
                            await LocalDatabase.instance.getIsDemo() ?? false;
                        if (isDemo) {
                          if (!context.mounted) return;
                          await UpgradeAccountPopup.show(
                            context: context,
                            ref: ref,
                          );
                          return;
                        }
                        final temporaryCreditStatus =
                            await LocalDatabase.instance
                                .getIsUsertemporaryCreditStatus() ??
                            false;

                        //temporary credit
                        if (temporaryCreditStatus) {
                          if (!context.mounted) return;

                          await temporaryCreditPopUpWidget(
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.temporary_credit_title,
                            subtitle: AppLocalizations.of(
                              context,
                            )!.temperory_credit_detect,
                            buttonTitle: AppLocalizations.of(
                              context,
                            )!.temporary_credit_contact_support,
                            icon: Icons
                                .account_balance_wallet_outlined, //Icons.card_giftcard,
                            onButtonPress: () {
                              Navigator.pop(context);

                              ///  Navigate to Support Screen (customizable)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SupportScreen(),
                                ),
                              );
                            },
                            oncloseButtonPress: () {
                              Navigator.pop(context);
                            },
                          );
                          return;
                        }
                        // Email not verified
                        if (!isEmailVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.email_verification_required, //"Email Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.email_verification_msg,
                            //"To continue, please verify your email address. Do you want to verify now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_cancel_btn, //"Cancel",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.email_verification_verify_btn, //"Verify",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailVerifyCodeScreen(
                                    email: mainStateWatchProvider.userEmail,
                                  ),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        // Email verified but Residency Document not verified
                        if (isEmailVerified && !isUserBasicKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.residency_document_required, //"Residency Document Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.residency_verification_message, //"You must complete Residency Document verification first. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycFirstStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }

                        // Email and Residency verified but KYC not verified
                        if (isEmailVerified &&
                            isUserBasicKycVerified &&
                            !isUserKycVerified) {
                          if (!context.mounted) return;
                          await genericPopUpWidget(
                            isLoadingState: false,
                            context: context,
                            heading: AppLocalizations.of(
                              context,
                            )!.kyc_verification_required, //"KYC Verification Required",
                            subtitle: AppLocalizations.of(
                              context,
                            )!.kyc_verification_message, //"You must complete KYC verification to continue. Proceed now?",
                            noButtonTitle: AppLocalizations.of(
                              context,
                            )!.later, //"Later",
                            yesButtonTitle: AppLocalizations.of(
                              context,
                            )!.proceed, //"Proceed",
                            onNoPress: () async {
                              Navigator.pop(context);
                            },
                            onYesPress: () async {
                              Navigator.pop(context);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KycSecondStepScreen(),
                                ),
                              );
                            },
                          );
                          return;
                        }
                        if (!context.mounted) return;
                        // All verifications passed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const withdrawViewScreen()//WithdrawalFundScreen//WithdrawalFundScreen(),
                          ),
                        );
                      },
                      onMore: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                    ),
                    ),

                    /// Offers Carousel
                    OfferCarousel(
                      mainStateWatchProvider: mainStateWatchProvider,
                      sizes: sizes!,
                    ),

                    ConstPadding.sizeBoxWithHeight(height: 8),

                    /// News Section
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
    children: [
      Container(
        height: sizes!.heightRatio * 50, // larger icon container
        width: sizes!.heightRatio * 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryGold500.withOpacity(0.1), // subtle background
        ),
        child: Icon(
          Icons.cancel_outlined,
          color: AppColors.primaryGold500,
          size: 36, // bigger icon
        ),
      ),
      SizedBox(height: sizes!.heightRatio * 16), // proper spacing
      Padding(
        padding: EdgeInsets.symmetric(horizontal: sizes!.widthRatio * 20),
        child: Text(
          AppLocalizations.of(context)!.oops_no_news,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sizes!.responsiveFont(phoneVal: 16, tabletVal: 18),
            fontWeight: FontWeight.bold,
            color: AppColors.grey6Color,
          ),
        ),
      ),
      SizedBox(height: sizes!.heightRatio * 8),
      
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                        : const ShimmerLoader(loop: 2),
                  ],
                ).get16HorizontalPadding(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
