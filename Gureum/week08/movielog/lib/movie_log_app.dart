import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';
import 'core/auth/token_storage.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/favorite_api_service.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/learning_member_session.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key, this.theme});

  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient();
    const tokenStorage = SecureTokenStorage();
    final authenticatedClient = createAuthenticatedMovieLogClient(tokenStorage);
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(authenticatedClient),
        ),
        Provider<FavoriteApiService>(
          create: (_) => FavoriteApiService(movieLogClient),
        ),
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<AuthApiService>(
          create: (_) => AuthApiService(authenticatedClient, tokenStorage),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: theme ?? AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
