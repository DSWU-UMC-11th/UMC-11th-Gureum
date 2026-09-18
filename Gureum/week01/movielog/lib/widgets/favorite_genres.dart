import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  static const genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('선호하는 장르', style: AppTextStyles.title),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(genre),
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: AppColors.violetContainer,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
