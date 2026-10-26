import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieRatingDialog extends StatefulWidget {
  const MovieRatingDialog({super.key, required this.title});
  final String title;
  @override
  State<MovieRatingDialog> createState() => _MovieRatingDialogState();
}

class _MovieRatingDialogState extends State<MovieRatingDialog> {
  double _rating = 0;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_rating == 0 ? '별점을 선택해주세요.' : '선택한 평점: $_rating'),
        const SizedBox(height: 20),
        RatingBar.builder(
          initialRating: _rating,
          minRating: .5,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 36,
          itemBuilder: (_, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (value) => setState(() => _rating = value),
        ),
        TextButton(
          onPressed: _rating == 0 ? null : () => setState(() => _rating = 0),
          child: const Text('평점 초기화'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: _rating == 0 ? null : () => Navigator.pop(context, _rating),
        child: const Text('저장'),
      ),
    ],
  );
}
