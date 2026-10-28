import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    key: const Key('movie-list-loading'),
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 16,
      childAspectRatio: .62,
    ),
    itemBuilder: (_, _) => const _MovieCardSkeleton(),
  );
}

class _MovieCardSkeleton extends StatelessWidget {
  const _MovieCardSkeleton();
  @override
  Widget build(BuildContext context) => Semantics(
    label: '영화 정보를 불러오는 중',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    ),
  );
}

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key, required this.onShowAll});
  final VoidCallback onShowAll;
  @override
  Widget build(BuildContext context) => Center(
    key: const Key('movie-list-empty'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.movie_filter_outlined, size: 56),
        const SizedBox(height: 12),
        const Text('조건에 맞는 영화가 없습니다.'),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onShowAll, child: const Text('전체 보기')),
      ],
    ),
  );
}

class MovieListError extends StatelessWidget {
  const MovieListError({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    key: const Key('movie-list-error'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 56),
        const SizedBox(height: 12),
        const Text('영화를 불러오지 못했습니다.'),
        const SizedBox(height: 4),
        Text('잠시 후 다시 시도해 주세요.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    ),
  );
}

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies, required this.onMovieTap});
  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;
  @override
  Widget build(BuildContext context) => GridView.builder(
    key: const Key('movie-list-success'),
    padding: const EdgeInsets.all(16),
    itemCount: movies.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 16,
      childAspectRatio: .62,
    ),
    itemBuilder: (_, index) =>
        MovieCard(movie: movies[index], onTap: () => onMovieTap(movies[index])),
  );
}
