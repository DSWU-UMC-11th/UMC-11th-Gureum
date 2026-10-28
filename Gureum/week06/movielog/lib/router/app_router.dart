import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/member_check_service.dart';
import '../data/services/rating_api_service.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/start_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/sign_up_view_model.dart';

abstract final class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (_, _) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, _) => ChangeNotifierProvider(
          create: (context) =>
              SignUpViewModel(context.read<MemberCheckService>()),
          child: const SignUpScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, _) => ChangeNotifierProvider(
                  create: (context) =>
                      MovieHomeViewModel(context.read<TmdbMovieService>())
                        ..loadPopular(),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, _) => ChangeNotifierProvider(
                  create: (context) =>
                      MovieListViewModel(context.read<TmdbMovieService>())
                        ..loadInitial(),
                  child: const MovieListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/my', builder: (_, _) => const MyPageScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/movies/:movieId',
        builder: (_, state) {
          final movie = state.extra as TmdbMovieDto?;
          return movie == null
              ? const Scaffold(body: Center(child: Text('영화 정보를 찾을 수 없습니다.')))
              : MovieDetailScreen(movie: movie);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/my/ratings',
        builder: (context, _) => ChangeNotifierProvider(
          create: (context) => MyRatingsViewModel(
            context.read<RatingApiService>(),
            context.read<TmdbMovieService>(),
            1,
          )..load(),
          child: const MyRatingsScreen(),
        ),
      ),
    ],
  );
}
