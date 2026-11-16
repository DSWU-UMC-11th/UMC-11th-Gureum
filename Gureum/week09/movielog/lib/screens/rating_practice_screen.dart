import 'package:flutter/material.dart';

import '../widgets/rating_input.dart';

class RatingPracticeScreen extends StatefulWidget {
  const RatingPracticeScreen({super.key});

  @override
  State<RatingPracticeScreen> createState() => _RatingPracticeScreenState();
}

class _RatingPracticeScreenState extends State<RatingPracticeScreen> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영화 평점 기록')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie_outlined, size: 72),
                    const SizedBox(height: 20),
                    Text(
                      '오늘 본 영화는 어땠나요?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rating == 0 ? '별을 눌러 평점을 선택해주세요.' : '선택한 평점: $_rating점',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    RatingInput(
                      rating: _rating,
                      onRatingUpdate: (rating) =>
                          setState(() => _rating = rating),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _rating > 0
                            ? () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$_rating점으로 저장했어요.')),
                              )
                            : null,
                        child: const Text('평점 저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
