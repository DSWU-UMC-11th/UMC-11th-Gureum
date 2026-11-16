import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'movielog_button.dart';

class MovieRatingDialog extends StatefulWidget {
  const MovieRatingDialog({
    super.key,
    required this.title,
    required this.onSubmit,
    this.initialScore = 0,
    this.initialComment,
  });
  final String title;
  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<MovieRatingDialog> createState() => _MovieRatingDialogState();
}

class _MovieRatingDialogState extends State<MovieRatingDialog> {
  late int _score = widget.initialScore;
  late final _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_score == 0 || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      await widget.onSubmit(
        _score,
        _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText = '저장하지 못했어요. 입력값을 유지했으니 다시 시도해 주세요.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isSubmitting,
    child: AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_score == 0 ? '별점을 선택해주세요.' : '선택한 평점: $_score점'),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _score.toDouble(),
              minRating: 1,
              allowHalfRating: false,
              ignoreGestures: _isSubmitting,
              itemCount: 5,
              itemSize: 36,
              itemBuilder: (_, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => setState(() => _score = value.toInt()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              enabled: !_isSubmitting,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '코멘트 (선택)',
                hintText: '영화에 대한 감상을 남겨주세요.',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        MovieLogButton(
          label: widget.initialScore == 0 ? '등록' : '수정',
          isLoading: _isSubmitting,
          onPressed: _score == 0 ? null : _submit,
        ),
      ],
    ),
  );
}
