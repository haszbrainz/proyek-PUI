import 'package:flutter/material.dart';
import 'type.dart'; // Sesuaikan path jika perlu
import 'package:pui/themes/custom_colors.dart'; // Ganti 'pui' dengan nama paket Anda
import 'package:pui/themes/custom_text_styles.dart'; // Ganti 'pui' dengan nama paket Anda

class FishInfoCard extends StatelessWidget {
  final FishData fishData;

  const FishInfoCard({super.key, required this.fishData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: CustomColors.secondary300.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: CustomColors.primary50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.asset( // <<--- PERBAIKAN DI SINI: Image.asset
                  fishData.imagePath, // Menggunakan imagePath dari FishData
                  width: 86,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading asset: ${fishData.imagePath}, Error: $error');
                    return Container(
                      width: 86,
                      height: 68,
                      color: CustomColors.secondary100,
                      child: Center(
                        child: Icon(Icons.broken_image, color: CustomColors.secondary300, size: 40),
                      ),
                    );
                  },
                  // loadingBuilder tidak terlalu relevan untuk Image.asset karena biasanya cepat,
                  // tapi tidak masalah jika tetap ada.
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  fishData.name,
                  style: CustomTextStyles.boldBase.copyWith(color: CustomColors.secondary500),
                ),
                const SizedBox(height: 4),
                Text(
                  fishData.scientificName,
                  style: CustomTextStyles.regularXs.copyWith(
                    color: CustomColors.primary500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fishData.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.regularXs.copyWith(color: CustomColors.secondary400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
