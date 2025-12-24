import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';

import '../../../../../core/res_sizes/res.dart';
import '../../../../../core/theme/get_generic_text_widget.dart'
    show GetGenericText;

class DocumentCameraScreen extends ConsumerStatefulWidget {
  final Function(File) onImageCaptured;

  const DocumentCameraScreen({super.key, required this.onImageCaptured});

  @override
  ConsumerState<DocumentCameraScreen> createState() =>
      _DocumentCameraScreenState();
}

class _DocumentCameraScreenState extends ConsumerState<DocumentCameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      widget.onImageCaptured(File(image.path));
      Navigator.pop(context); // Go back after capturing
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Overlay box
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Capture button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: getCaptureButton(
                  title: "Capture",
                  isLoadingState: false,
                  onTap: _captureImage),
            ),
          ),
        ],
      ),
    );
  }
}

Widget getCaptureButton({
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
        color: AppColors.primaryGold500,
        borderRadius: BorderRadius.circular(50), // rounded for capture feel
        border: Border.all(
          width: 2,
          color: const Color(0xFFBBA473),
        ),
      ),
      child: Center(
        child: isLoadingState
            ? SizedBox(
                width: sizes!.widthRatio * 26,
                height: sizes!.widthRatio * 26,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  GetGenericText(
                    text: title,
                    fontSize: sizes!.responsiveFont(
                      phoneVal: 16,
                      tabletVal: 18,
                    ),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    ),
  );
}
