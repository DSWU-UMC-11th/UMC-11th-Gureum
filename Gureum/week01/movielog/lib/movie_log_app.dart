import 'package:flutter/material.dart';

import 'screens/profile_screen.dart';
import 'screens/start_screen.dart';
import 'theme/app_theme.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({
    super.key,
    this.showStartScreen = const bool.fromEnvironment('SHOW_START_SCREEN'),
  });

  final bool showStartScreen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      home: showStartScreen ? const StartScreen() : const ProfileScreen(),
    );
  }
}
