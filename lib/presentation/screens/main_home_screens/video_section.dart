// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// const Color appPrimaryColor = Color(0xFFBBA473);

// class IntroductionVideoSection extends StatefulWidget {
//   const IntroductionVideoSection({super.key});

//   @override
//   State<IntroductionVideoSection> createState() =>
//       _IntroductionVideoSectionState();
// }

// class _IntroductionVideoSectionState extends State<IntroductionVideoSection> {
//   bool showAll = false;

//   final List<String> videos = [
//     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
//     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
//     "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         /// Header Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "Introduction Video",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.white,
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   showAll = !showAll;
//                 });
//               },
//               child: Text(
//                 showAll ? "Hide" : "See all",
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: appPrimaryColor,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         /// Expand video list
//         if (showAll)
//           Column(
//             children: videos.asMap().entries.map((entry) {
//               final index = entry.key;
//               final url = entry.value;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: VideoPlayerWidget(
//                   videoUrl: url,
//                   videoNumber: index + 1,
//                 ),
//               );
//             }).toList(),
//           ),
//       ],
//     );
//   }
// }

// /// Video Player widget with fullscreen option
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//   final int videoNumber;
//   const VideoPlayerWidget({
//     super.key,
//     required this.videoUrl,
//     required this.videoNumber,
//   });

//   @override
//   State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _hasError = false;
//         _errorMessage = '';
//       });

//       _videoPlayerController = VideoPlayerController.network(widget.videoUrl);

//       await _videoPlayerController.initialize().timeout(
//         const Duration(minutes: 5),
//         onTimeout: () {
//           throw TimeoutException('Video initialization timed out');
//         },
//       );

//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: false,
//         looping: false,
//         allowFullScreen: true,
//         allowMuting: true,
//         showControls: true,
//         materialProgressColors: ChewieProgressColors(
//           playedColor: appPrimaryColor,
//           handleColor: appPrimaryColor,
//           backgroundColor: Colors.grey,
//           bufferedColor: Colors.grey.shade400,
//         ),
//         placeholder: Container(
//           color: appPrimaryColor,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.videocam, color: Colors.white, size: 50),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Video ${widget.videoNumber}',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         errorBuilder: (context, errorMessage) {
//           return Container(
//             color: appPrimaryColor,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline,
//                       color: Colors.white, size: 50),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Playback Error',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       errorMessage ?? 'Unknown error occurred',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _retryVideoLoad,
//                     icon: const Icon(Icons.refresh, color: Colors.white),
//                     label: const Text('Retry'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: appPrimaryColor,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } on TimeoutException catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = 'Timeout: ${e.message}';
//         });
//       }
//     } catch (error) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = error.toString();
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: Text(
//             'Video ${widget.videoNumber}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: _buildVideoContent(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildVideoContent() {
//     if (_isLoading) {
//       return Container(
//         height: 200,
//         decoration: BoxDecoration(
//             border: Border.all(
//           width: 1,
//           color: appPrimaryColor,
//         )),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Loading video...',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_hasError) {
//       return Container(
//         height: 200,
//         color: appPrimaryColor,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.white, size: 50),
//               const SizedBox(height: 16),
//               const Text(
//                 'Failed to load video',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               if (_errorMessage.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     _errorMessage.length > 100
//                         ? '${_errorMessage.substring(0, 100)}...'
//                         : _errorMessage,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _retryVideoLoad,
//                 icon: const Icon(Icons.refresh, color: Colors.white),
//                 label: const Text('Retry'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: appPrimaryColor,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//       child: Chewie(controller: _chewieController!),
//     );
//   }

//   void _retryVideoLoad() {
//     _initializeVideoPlayer();
//   }
// }

// class TimeoutException implements Exception {
//   final String message;
//   TimeoutException(this.message);

//   @override
//   String toString() => message;
// }
