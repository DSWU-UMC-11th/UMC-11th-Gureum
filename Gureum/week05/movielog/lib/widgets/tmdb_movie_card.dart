import 'package:flutter/material.dart';

import '../data/models/tmdb_movie_dto.dart';

class TmdbMovieCard extends StatelessWidget {
  const TmdbMovieCard({super.key, required this.movie, required this.onTap});
  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Poster(movie: movie)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                child: Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  '${movie.year} · ★ ${movie.voteAverage.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
}

class TmdbPoster extends StatelessWidget {
  const TmdbPoster({super.key, required this.movie, this.fit = BoxFit.cover});
  final TmdbMovieDto movie;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => _Poster(movie: movie, fit: fit);
}

class _Poster extends StatelessWidget {
  const _Poster({required this.movie, this.fit = BoxFit.cover});
  final TmdbMovieDto movie;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = movie.posterUrl;
    if (url == null) return const _PosterPlaceholder();
    return SizedBox.expand(
      child: Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => const _PosterPlaceholder(),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const ColoredBox(
                color: Color(0xFFE9E7E2),
                child: Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFE9E7E2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_outlined, size: 42, color: Colors.black38),
              SizedBox(height: 8),
              Text('포스터 없음', style: TextStyle(color: Colors.black45)),
            ],
          ),
        ),
      );
}
