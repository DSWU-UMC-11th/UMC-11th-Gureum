import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const headline = TextStyle(
    color: AppColors.black,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const title = TextStyle(
    color: AppColors.black,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    color: AppColors.black,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const caption = TextStyle(
    color: AppColors.gray,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
