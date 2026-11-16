import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../widgets/movie_rating_dialog.dart';
import '../widgets/tmdb_movie_card.dart';
import '../view_models/movie_detail_view_model.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});
  final TmdbMovieDto movie;
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _favorite = false;
  Future<void> _rate() async {
    final viewModel = context.read<MovieDetailViewModel>();
    if (viewModel.memberId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('먼저 학습용 회원가입을 완료해 주세요.')));
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MovieRatingDialog(
        title: '${widget.movie.title} 평점',
        onSubmit: (score, comment) =>
            viewModel.createRating(score: score, comment: comment),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('평점을 등록했어요. 마이페이지에서 확인해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _favorite = !_favorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_favorite ? '즐겨찾기에 추가했어요.' : '즐겨찾기에서 삭제했어요.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(_favorite ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(height: 390, child: TmdbPoster(movie: movie)),
          ),
          const SizedBox(height: 20),
          Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('${movie.year} · TMDB #${movie.id}'),
          const SizedBox(height: 12),
          Row(
            children: [
              RatingBarIndicator(
                rating: movie.voteAverage / 2,
                itemCount: 5,
                itemSize: 24,
                itemBuilder: (_, _) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
              const SizedBox(width: 8),
              Text(movie.voteAverage.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            movie.overview.isEmpty ? '등록된 줄거리가 없습니다.' : movie.overview,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _rate,
            icon: const Icon(Icons.star_outline),
            label: const Text('평점 남기기'),
          ),
        ],
      ),
    );
  }
}
