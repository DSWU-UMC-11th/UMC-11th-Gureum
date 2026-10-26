import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_data.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/start_screen.dart';

abstract final class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (_, _) => const StartScreen()),
      GoRoute(path: '/register', builder: (_, _) => const SignUpScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (_, state) {
                  final raw = state.uri.queryParameters['genres'];
                  return MovieListScreen(
                    key: ValueKey(raw),
                    initialGenres: raw == null || raw.isEmpty
                        ? const []
                        : raw.split(','),
                  );
                },
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
          final movie = findMovieById(
            int.tryParse(state.pathParameters['movieId'] ?? ''),
          );
          return movie == null
              ? const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')))
              : MovieDetailScreen(movie: movie);
        },
      ),
    ],
  );
}
