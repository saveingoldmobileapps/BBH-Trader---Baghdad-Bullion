import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';

class EsouqItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String itemPrice;
  final VoidCallback onTap;
  final VoidCallback onTapAddToCart;

  const EsouqItemCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.itemPrice,
    required this.onTap,
    required this.onTapAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Dark card background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover, // Shows the gold bar clearly
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Text Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetGenericText(
                    text: title,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  GetGenericText(
                    text: "IQD $itemPrice",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold500,
                  ),
                  GetGenericText(
                    text: "IQD 181,250/g", // Example subtitle logic
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
