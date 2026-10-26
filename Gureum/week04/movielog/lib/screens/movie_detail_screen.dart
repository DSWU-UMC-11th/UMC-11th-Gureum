import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../widgets/movie_rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});
  final Movie movie;
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _favorite = false;
  Future<void> _rate() async {
    final rating = await showDialog<double>(
      context: context,
      builder: (_) => MovieRatingDialog(title: widget.movie.title),
    );
    if (rating != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$rating점으로 저장했어요.'),
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
            child: Image.asset(
              movie.posterAsset,
              height: 390,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('${movie.genre} · ${movie.year}'),
          const SizedBox(height: 12),
          Row(
            children: [
              RatingBarIndicator(
                rating: movie.rating,
                itemCount: 5,
                itemSize: 24,
                itemBuilder: (_, _) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
              const SizedBox(width: 8),
              Text('${movie.rating}'),
            ],
          ),
          const SizedBox(height: 24),
          Text(movie.synopsis, style: Theme.of(context).textTheme.bodyLarge),
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
