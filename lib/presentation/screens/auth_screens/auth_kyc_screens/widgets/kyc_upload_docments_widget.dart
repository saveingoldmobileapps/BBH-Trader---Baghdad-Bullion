import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/widgets/documets_camera.dart';

import '../../../../../core/theme/const_colors.dart';
import '../../../../sharedProviders/providers/kyc_provider.dart/kyc_provider.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  Future<void> _handleFilePicked(
    File file, {
    bool isFront = false,
    bool isSelfie = false,
  }) async {
    final notifier = ref.read(kYCProvider.notifier);

    if (isSelfie) {
      notifier.setSelfieImage(file);
    } else if (isFront) {
      notifier.setFrontImage(file);
    } else {
      notifier.setBackImage(file);
    }

    await notifier.uploadResidencyDocument(
      image: file,
      fileName: file.path.split("/").last,
      isFront: isFront,
      isSelfie: isSelfie,
      context: context,
    );
  }

  Future<void> _pickPdf(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      await _handleFilePicked(
        File(result.files.single.path!),
        isFront: isFront,
      );
    }
  }

  Future<void> _pickImage(bool isFront, {bool fromCamera = false}) async {
    if (fromCamera) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentCameraScreen(
            onImageCaptured: (file) async {
              await _handleFilePicked(file, isFront: isFront);
            },
          ),
        ),
      );
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await _handleFilePicked(File(pickedFile.path), isFront: isFront);
      }
    }
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (pickedFile != null) {
      await _handleFilePicked(File(pickedFile.path), isSelfie: true);
    }
  }

  void _showPickerDialog({bool isFront = false, bool isSelfie = false}) {
    if (isSelfie) {
      _pickSelfie(); // always from front camera
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Upload PDF"),
              onTap: () {
                Navigator.pop(context);
                _pickPdf(isFront);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Capture Image"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront, fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isFront);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    File? file,
    String title, {
    bool isFront = false,
    bool isSelfie = false,
  }) {
    final kycState = ref.watch(kYCProvider);

    final isLoading = isSelfie
        ? kycState.isSelfieUploading
        : isFront
        ? kycState.isFrontUploading
        : kycState.isBackUploading;

    return GestureDetector(
      onTap: () => _showPickerDialog(isFront: isFront, isSelfie: isSelfie),
      child: Container(
        height: 120,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.5,
            color: file != null ? Colors.green : AppColors.primaryGold500,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : file != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSelfie ? "Selfie.jpg" : file.path.split("/").last,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Uploaded successfully!",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSelfie
                          ? "Take and upload selfie"
                          : "Upload image or PDF",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kYCProvider);

    final isSubmitEnabled =
        kycState.selfieImage != null &&
        kycState.frontImage != null &&
        (kycState.selectedDocumentType == KYCDocumentType.passport ||
            kycState.backImage != null);

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlaceholder(
              kycState.selfieImage,
              "Upload selfie",
              isSelfie: true,
            ),
            _buildPlaceholder(
              kycState.frontImage,
              "Upload Front Document",
              isFront: true,
            ),
            if (kycState.selectedDocumentType != KYCDocumentType.passport)
              _buildPlaceholder(kycState.backImage, "Upload Back Document"),
            ElevatedButton(
              onPressed: isSubmitEnabled
                  ? () {
                      ref
                          .read(kYCProvider.notifier)
                          .submitKycData(
                            userImage: kycState.selfieImagePath ?? "",
                            context: context,
                          );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primaryGold500,
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
