import 'package:flutter/material.dart';

import 'screens/sign_up_screen.dart';
import 'theme/app_theme.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key, this.theme});

  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: theme ?? AppTheme.light,
      home: const SignUpScreen(),
    );
  }
}
