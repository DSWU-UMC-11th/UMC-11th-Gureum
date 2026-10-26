import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_list_view_model.dart';
import '../widgets/tmdb_movie_card.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('영화'),
          actions: [
            PopupMenuButton<MovieListLoadStatus>(
              tooltip: '비동기 상태 확인',
              icon: const Icon(Icons.science_outlined),
              onSelected: (state) {
                final viewModel = context.read<MovieListViewModel>();
                if (state == MovieListLoadStatus.idle) {
                  viewModel.showPosterPlaceholder();
                } else if (state == MovieListLoadStatus.success) {
                  viewModel.loadInitial();
                } else {
                  viewModel.showVerificationState(state);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: MovieListLoadStatus.loading,
                  child: Text('Loading 확인'),
                ),
                PopupMenuItem(
                  value: MovieListLoadStatus.empty,
                  child: Text('Empty 확인'),
                ),
                PopupMenuItem(
                  value: MovieListLoadStatus.error,
                  child: Text('Error 확인'),
                ),
                PopupMenuItem(
                  value: MovieListLoadStatus.idle,
                  child: Text('포스터 대체 UI 확인'),
                ),
                PopupMenuItem(
                  value: MovieListLoadStatus.success,
                  child: Text('Success 복원'),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<MovieListViewModel>(
          builder: (context, viewModel, _) => Column(
            children: [
              SizedBox(
                height: 54,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('전체'),
                      selected: viewModel.selectedGenreId == null,
                      onSelected: viewModel.isLoading
                          ? null
                          : (_) => viewModel.selectGenre(null),
                    ),
                    const SizedBox(width: 8),
                    for (final genre in viewModel.genres) ...[
                      ChoiceChip(
                        label: Text(genre.name),
                        selected: viewModel.selectedGenreId == genre.id,
                        onSelected: viewModel.isLoading
                            ? null
                            : (_) => viewModel.selectGenre(genre.id),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              if (viewModel.status == MovieListLoadStatus.success)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('TMDB Discover · ${viewModel.movies.length}편'),
                  ),
                ),
              Expanded(child: _MovieListBody(viewModel: viewModel)),
            ],
          ),
        ),
      );
}

class _MovieListBody extends StatelessWidget {
  const _MovieListBody({required this.viewModel});
  final MovieListViewModel viewModel;

  @override
  Widget build(BuildContext context) => switch (viewModel.status) {
        MovieListLoadStatus.idle || MovieListLoadStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        MovieListLoadStatus.empty => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.movie_filter_outlined, size: 48),
                SizedBox(height: 12),
                Text('조건에 맞는 영화가 없습니다.'),
              ],
            ),
          ),
        MovieListLoadStatus.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(viewModel.message ?? '영화를 불러오지 못했어요.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: viewModel.loadInitial,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        MovieListLoadStatus.success => GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemCount: viewModel.movies.length,
            itemBuilder: (_, index) {
              final movie = viewModel.movies[index];
              return TmdbMovieCard(
                movie: movie,
                onTap: () => context.push('/movies/${movie.id}', extra: movie),
              );
            },
          ),
      };
}
