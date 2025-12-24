import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/enums/loading_state.dart';
import '../../../core/res_sizes/sizes.dart';
import '../../../core/theme/const_colors.dart';
import '../../sharedProviders/providers/states/home_state.dart';
import '../../widgets/shimmers/shimmer_loader.dart';

class OfferCarousel extends StatefulWidget {
  final HomeState mainStateWatchProvider;
  final AppSizes sizes;

  const OfferCarousel({
    super.key,
    required this.mainStateWatchProvider,
    required this.sizes,
  });

  @override
  State<OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  late PageController _pageController;
  int _currentOfferIndex = 0;
  bool _isHolding = false;
  bool _isDisposed = false;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isHolding &&
          mounted &&
          widget.mainStateWatchProvider.getHomeFeedResponse.payload?.offers !=
              null &&
          widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
              .isNotEmpty) {
        int nextPage = (_currentOfferIndex + 1) %
            widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
                .length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.mainStateWatchProvider;
    final sizes = widget.sizes;

    if (provider.loadingState == LoadingState.data &&
        provider.getHomeFeedResponse.payload != null) {
      final offers = provider.getHomeFeedResponse.payload!.offers ?? [];

      if (offers.isEmpty) {
        return Container();
      }

      return Container(
        width: sizes.isPhone ? sizes.widthRatio * 361 : sizes.width,
        height:
            sizes.isPhone ? sizes.heightRatio * 140 : sizes.heightRatio * 240,
        decoration: BoxDecoration(
          color: AppColors.greyScale900,
          border: Border.all(
            color: AppColors.primaryGold500,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Stack(
            children: [
              Listener(
                onPointerDown: (_) {
                  // Pause auto-scroll when user touches screen
                  _isHolding = true;
                },
                onPointerUp: (_) {
                  // Resume after small delay when user releases
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _isHolding = false;
                  });
                },
                onPointerCancel: (_) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _isHolding = false;
                  });
                },
                child: GestureDetector(
                  onLongPressStart: (_) {
                    _isHolding = true;
                  },
                  onLongPressEnd: (_) {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) _isHolding = false;
                    });
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    physics:
                        const PageScrollPhysics(), // ✅ manual scroll always allowed
                    onPageChanged: (index) {
                      if (mounted && !_isDisposed) {
                        setState(() => _currentOfferIndex = index);
                      }
                    },
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return GestureDetector(
                        onTap: () async {
                          final url = offer.offerLinkUrl ?? '';
                          if (url.isNotEmpty) {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open the link"),
                                ),
                              );
                            }
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: offer.offerImgUrl ?? '',
                          fit: BoxFit.fill,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              color: AppColors.primaryGold500,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: sizes.heightRatio * 2,
                right: sizes.widthRatio * 10,
                left: sizes.widthRatio * 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    offers.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentOfferIndex == index ? 20 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentOfferIndex == index
                            ? AppColors.primaryGold500
                            : AppColors.grey4Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ShimmerLoader(loop: sizes.isPhone ? 1 : 4);
    }
  }
}

// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../../core/enums/loading_state.dart';
// import '../../../core/res_sizes/sizes.dart';
// import '../../../core/theme/const_colors.dart';
// import '../../sharedProviders/providers/states/home_state.dart';
// import '../../widgets/shimmers/shimmer_loader.dart';

// class OfferCarousel extends StatefulWidget {
//   final HomeState mainStateWatchProvider;
//   final AppSizes sizes;

//   const OfferCarousel({
//     super.key,
//     required this.mainStateWatchProvider,
//     required this.sizes,
//   });

//   @override
//   State<OfferCarousel> createState() => _OfferCarouselState();
// }

// class _OfferCarouselState extends State<OfferCarousel> {
//   late PageController _pageController;
//   int _currentOfferIndex = 0;
//   bool _isHolding = false;
//   bool _isDisposed = false;
//   Timer? _autoScrollTimer;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _startAutoScroll();
//   }

//   void _startAutoScroll() {
//     _autoScrollTimer?.cancel();
//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
//       if (!_isHolding &&
//           mounted &&
//           widget.mainStateWatchProvider.getHomeFeedResponse.payload?.offers !=
//               null &&
//           widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
//               .isNotEmpty) {
//         int nextPage = (_currentOfferIndex + 1) %
//             widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
//                 .length;
//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _autoScrollTimer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = widget.mainStateWatchProvider;
//     final sizes = widget.sizes;

//     if (provider.loadingState == LoadingState.data &&
//         provider.getHomeFeedResponse.payload != null) {
//       final offers = provider.getHomeFeedResponse.payload!.offers ?? [];

//       if (offers.isEmpty) {
//         return Container();
//       }

//       return Container(
//         width: sizes.isPhone ? sizes.widthRatio * 361 : sizes.width,
//         height:
//             sizes.isPhone ? sizes.heightRatio * 140 : sizes.heightRatio * 240,
//         decoration: BoxDecoration(
//           color: AppColors.greyScale900,
//           border: Border.all(
//             color: AppColors.primaryGold500,
//             width: 1.0,
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Center(
//           child: Stack(
//             children: [
//               Listener(
//                 onPointerDown: (_) {
//                   setState(() => _isHolding = true);
//                 },
//                 onPointerUp: (_) {
//                   setState(() => _isHolding = false);
//                 },
//                 onPointerCancel: (_) {
//                   setState(() => _isHolding = false);
//                 },
//                 child: GestureDetector(
//                   onLongPressStart: (_) {
//                     setState(() => _isHolding = true);
//                   },
//                   onLongPressEnd: (_) {
//                     setState(() => _isHolding = false);
//                   },
//                   child: PageView.builder(
//                     controller: _pageController,
//                     physics: _isHolding
//                         ? const NeverScrollableScrollPhysics()
//                         : const PageScrollPhysics(),
//                     onPageChanged: (index) {
//                       if (mounted && !_isDisposed) {
//                         setState(() => _currentOfferIndex = index);
//                       }
//                     },
//                     itemCount: offers.length,
//                     itemBuilder: (context, index) {
//                       final offer = offers[index];
//                       return GestureDetector(
//                         onTap: () async {
//                           final url = offer.offerLinkUrl ?? '';
//                           if (url.isNotEmpty) {
//                             final uri = Uri.parse(url);
//                             if (await canLaunchUrl(uri)) {
//                               await launchUrl(uri,
//                                   mode: LaunchMode.externalApplication);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Could not open the link"),
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                         child: CachedNetworkImage(
//                           imageUrl: offer.offerImgUrl ?? '',
//                           fit: BoxFit.fill,
//                           progressIndicatorBuilder: (context, url, progress) =>
//                               Center(
//                             child: CircularProgressIndicator(
//                               value: progress.progress,
//                               color: AppColors.primaryGold500,
//                             ),
//                           ),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.error),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: sizes.heightRatio * 2,
//                 right: sizes.widthRatio * 10,
//                 left: sizes.widthRatio * 10,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     offers.length,
//                     (index) => Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 5),
//                       width: _currentOfferIndex == index ? 20 : 10,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         color: _currentOfferIndex == index
//                             ? AppColors.primaryGold500
//                             : AppColors.grey4Color,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     } else {
//       return ShimmerLoader(loop: sizes.isPhone ? 1 : 4);
//     }
//   }
// }

// // class OfferCarousel extends StatefulWidget {
// //   final HomeState mainStateWatchProvider;
// //   final AppSizes sizes;

// //   const OfferCarousel({
// //     super.key,
// //     required this.mainStateWatchProvider,
// //     required this.sizes,
// //   });

// //   @override
// //   State<OfferCarousel> createState() => _OfferCarouselState();
// // }

// // class _OfferCarouselState extends State<OfferCarousel> {
// //   late PageController _pageController;
// //   int _currentOfferIndex = 0;
// //   bool _isHolding = false;
// //   bool _isDisposed = false;
// //   Timer? _autoScrollTimer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController();
// //     _startAutoScroll();
// //   }

// //   void _startAutoScroll() {
// //     _autoScrollTimer?.cancel();
// //     _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
// //       if (!_isHolding &&
// //           mounted &&
// //           widget.mainStateWatchProvider.getHomeFeedResponse.payload?.offers !=
// //               null &&
// //           widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
// //               .isNotEmpty) {
// //         int nextPage = (_currentOfferIndex + 1) %
// //             widget.mainStateWatchProvider.getHomeFeedResponse.payload!.offers!
// //                 .length;
// //         _pageController.animateToPage(
// //           nextPage,
// //           duration: const Duration(milliseconds: 500),
// //           curve: Curves.easeInOut,
// //         );
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _isDisposed = true;
// //     _autoScrollTimer?.cancel();
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final provider = widget.mainStateWatchProvider;
// //     final sizes = widget.sizes;

// //     if (provider.loadingState == LoadingState.data &&
// //         provider.getHomeFeedResponse.payload != null) {
// //       final offers = provider.getHomeFeedResponse.payload!.offers ?? [];

// //       if (offers.isEmpty) {
// //         return Container();
// //       }

// //       return Container(
// //         width: sizes.isPhone ? sizes.widthRatio * 361 : sizes.width,
// //         height:
// //             sizes.isPhone ? sizes.heightRatio * 140 : sizes.heightRatio * 240,
// //         decoration: BoxDecoration(
// //           color: AppColors.greyScale900,
// //           border: Border.all(
// //             color: AppColors.primaryGold500,
// //             width: 1.0,
// //           ),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Center(
// //           child: Stack(
// //             children: [
// //               GestureDetector(
// //                 onLongPressStart: (_) {
// //                   setState(() {
// //                     _isHolding = true;
// //                   });
// //                 },
// //                 onLongPressEnd: (_) {
// //                   setState(() {
// //                     _isHolding = false;
// //                   });
// //                 },
// //                 child: PageView.builder(
// //                   controller: _pageController,
// //                   physics: _isHolding
// //                       ? const NeverScrollableScrollPhysics()
// //                       : const PageScrollPhysics(),
// //                   onPageChanged: (index) {
// //                     if (mounted && !_isDisposed) {
// //                       setState(() {
// //                         _currentOfferIndex = index;
// //                       });
// //                     }
// //                   },
// //                   itemCount: offers.length,
// //                   itemBuilder: (context, index) {
// //                     final offer = offers[index];
// //                     return GestureDetector(
// //                       onTap: () async {
// //                         final url = offer.offerLinkUrl ?? '';
// //                         if (url.isNotEmpty) {
// //                           final uri = Uri.parse(url);
// //                           if (await canLaunchUrl(uri)) {
// //                             await launchUrl(uri,
// //                                 mode: LaunchMode.externalApplication);
// //                           } else {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               const SnackBar(
// //                                 content: Text("Could not open the link"),
// //                               ),
// //                             );
// //                           }
// //                         }
// //                       },
// //                       child: CachedNetworkImage(
// //                         imageUrl: offer.offerImgUrl ?? '',
// //                         fit: BoxFit.fill,
// //                         progressIndicatorBuilder: (context, url, progress) =>
// //                             Center(
// //                           child: CircularProgressIndicator(
// //                             value: progress.progress,
// //                             color: AppColors.primaryGold500,
// //                           ),
// //                         ),
// //                         errorWidget: (context, url, error) =>
// //                             const Icon(Icons.error),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //               Positioned(
// //                 bottom: sizes.heightRatio * 2,
// //                 right: sizes.widthRatio * 10,
// //                 left: sizes.widthRatio * 10,
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: List.generate(
// //                     offers.length,
// //                     (index) => Container(
// //                       margin: const EdgeInsets.symmetric(horizontal: 5),
// //                       width: _currentOfferIndex == index ? 20 : 10,
// //                       height: 10,
// //                       decoration: BoxDecoration(
// //                         color: _currentOfferIndex == index
// //                             ? AppColors.primaryGold500
// //                             : AppColors.grey4Color,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     } else {
// //       return ShimmerLoader(loop: sizes.isPhone ? 1 : 4);
// //     }
// //   }
// // }
