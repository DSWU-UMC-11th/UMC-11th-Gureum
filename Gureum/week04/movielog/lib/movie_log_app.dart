import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key, this.theme});

  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: theme ?? AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
