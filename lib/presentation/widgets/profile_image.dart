import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveingold_fzco/core/res_sizes/res.dart';
import 'package:saveingold_fzco/core/theme/const_colors.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class DisplayImage extends StatefulWidget {
  final String imagePath;
  final ValueChanged<File?> onImageSelected;
  final bool isEditable;

  const DisplayImage({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
    this.isEditable = true,
  });

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImageSelected(_selectedImage);
    }
    Navigator.pop(context); // close sheet after picking
  }

  void _showPickOptions() {
    if (!widget.isEditable) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding:  EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
               Text(
                AppLocalizations.of(context)!.select_image,
                //"Select Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _optionButton(
                    icon: Icons.camera_alt,
                    text: "Camera",
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _optionButton(
                    icon: Icons.photo_library,
                    text: "Gallery",
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 28, color: AppColors.primaryGold500),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryGold500;

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.isEditable
                ? _showPickOptions
                : null, // only tap if editable
            child: buildImage(color),
          ),
          if (widget.isEditable) // show icon only if editable
            Positioned(
              right: 2,
              top: 8,
              child: GestureDetector(
                onTap: _showPickOptions,
                child: buildEditIcon(color),
              ),
            ),
        ],
      ),
    );
  }

  // Profile Image
  Widget buildImage(Color color) {
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (widget.imagePath.isNotEmpty &&
        widget.imagePath.contains('https://')) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: CachedNetworkImageProvider(widget.imagePath),
      );
    } else if (widget.imagePath.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(File(widget.imagePath)),
      );
    } else {
      //  If no image, show default Icon
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade400,
        child: SvgPicture.asset(
          "assets/svg/user_icon.svg",
          height: sizes!.responsiveHeight(phoneVal: 24, tabletVal: 32),
          width: sizes!.responsiveWidth(phoneVal: 24, tabletVal: 32),
        ),
      );
    }
  }

  // Edit Icon
  Widget buildEditIcon(Color color) => buildCircle(
    all: 8,
    child: Icon(
      Icons.edit,
      color: color,
      size: 20,
    ),
  );

  // Circle wrapper
  Widget buildCircle({
    required Widget child,
    required double all,
  }) => ClipOval(
    child: Container(
      padding: EdgeInsets.all(all),
      color: Colors.white,
      child: child,
    ),
  );
}
