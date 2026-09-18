import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 54,
            backgroundColor: AppColors.violetContainer,
            backgroundImage: AssetImage(
              'assets/images/profile/profile_movielog.jpg',
            ),
          ),
          const SizedBox(height: 18),
          const Text('무비러버', style: AppTextStyles.headline),
          const SizedBox(height: 8),
          const Text(
            '매주 주말에 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.violet,
              side: const BorderSide(color: AppColors.violet),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('프로필 수정'),
          ),
        ],
      ),
    );
  }
}
