import 'package:flutter/material.dart';

class AppColors {
  static const Color blueYonder = Color(0xFF2E96F5);
  static const Color neonBlue = Color(0xFF0960E1);
  static const Color electricBlue = Color(0xFF0042A6);
  static const Color deepBlue = Color(0xFF07173F);

  static const Color rocketRed = Color(0xFFE43700);
  static const Color martianRed = Color(0xFFBE1100);
  static const Color neonYellow = Color(0xFFEAFE07);

  static const Color grayFade = Color(0xFF646464);

  // New theme colors , removing the old ones after completing the migration
  static const Color vividOrange = Color(0xFFFF5D00);
  static const Color maastrichtBlue = Color(0xFF0C1A39);
  static const Color spiroDiscoBall = Color(0xFF2DC3FF);
  static const Color brightYellow = Color(0xFFFFA220);
  static const Color pineTree = Color(0xFF2B2828);
}

class AppTheme {
  static final darkThemeMode = ThemeData.dark();

  // ThemeData(
  //   brightness: Brightness.dark,
  //   primaryColor: AppColors.electricBlue,
  //   scaffoldBackgroundColor: AppColors.deepBlue,
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: AppColors.deepBlue,
  //     elevation: 0,
  //     iconTheme: IconThemeData(color: Colors.white),
  //     titleTextStyle: TextStyle(
  //       color: Colors.white,
  //       fontSize: 20,
  //       fontWeight: FontWeight.w600,
  //     ),
  //   ),
  //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //     backgroundColor: AppColors.maastrichtBlue,
  //     selectedItemColor: AppColors.vividOrange,
  //     unselectedItemColor: Colors.white70,
  //   ),
  // );
}
