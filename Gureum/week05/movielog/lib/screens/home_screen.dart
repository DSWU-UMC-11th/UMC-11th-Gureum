import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_home_view_model.dart';
import '../widgets/tmdb_movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('MovieLog')),
        body: Consumer<MovieHomeViewModel>(
          builder: (context, viewModel, _) => switch (viewModel.status) {
            MovieHomeLoadStatus.idle || MovieHomeLoadStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            MovieHomeLoadStatus.error => _HomeMessage(
                icon: Icons.error_outline,
                message: viewModel.message ?? '영화를 불러오지 못했어요.',
                onRetry: viewModel.loadPopular,
              ),
            MovieHomeLoadStatus.empty => const _HomeMessage(
                icon: Icons.movie_outlined,
                message: '표시할 인기 영화가 없습니다.',
              ),
            MovieHomeLoadStatus.success => _HomeSuccess(viewModel: viewModel),
          },
        ),
      );
}

class _HomeSuccess extends StatelessWidget {
  const _HomeSuccess({required this.viewModel});
  final MovieHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final movies = viewModel.popularMovies;
    final featured = movies.first;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '오늘은 어떤 영화를\n기록해볼까요?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.push('/movies/${featured.id}', extra: featured),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TmdbPoster(movie: featured),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        featured.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('지금 인기 있는 영화', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go('/movies'),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => SizedBox(
              width: 160,
              child: TmdbMovieCard(
                movie: movies[index],
                onTap: () => context.push(
                  '/movies/${movies[index].id}',
                  extra: movies[index],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.icon, required this.message, this.onRetry});
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      );
}
