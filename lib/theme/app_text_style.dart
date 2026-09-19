import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    color: AppColors.navy,
    fontSize: 25,
    fontWeight: FontWeight.w900,
  );
  static const title = TextStyle(
    color: AppColors.navy,
    fontSize: 20,
    fontWeight: FontWeight.w900,
  );
  static const sectionTitle = TextStyle(
    color: AppColors.navy,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );
  static const body = TextStyle(
    color: AppColors.muted,
    fontSize: 15,
    height: 1.5,
  );
  static const label = TextStyle(
    color: AppColors.navy,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const button = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const hint = TextStyle(
    color: AppColors.hint,
    fontSize: 13,
  );
}
