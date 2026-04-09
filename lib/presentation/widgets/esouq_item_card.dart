import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/l10n/app_localizations.dart';

class EsouqItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String itemPrice;
  final VoidCallback onTap;
  final VoidCallback onTapAddToCart;
  final String oneGramPrice;
  const EsouqItemCard({
    super.key,
    required this.title,
    required this.oneGramPrice,
    required this.imageUrl,
    required this.itemPrice,
    required this.onTap,
    required this.onTapAddToCart,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: GetGenericText(
                        text: "${l10n.idq_currency} $itemPrice",
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: GetGenericText(
                        text:
                            "${l10n.idq_currency} ${CommonService.formatIqdCurrency(double.tryParse(oneGramPrice) ?? 0)}${l10n.g_}",
                        fontSize: 8,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
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
