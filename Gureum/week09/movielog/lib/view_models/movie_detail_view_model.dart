import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';

enum RatingSubmitStatus { idle, submitting, success, error }

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._service, this.memberId, this.movie);
  final RatingApiService _service;
  final int? memberId;
  final TmdbMovieDto movie;
  RatingSubmitStatus submitStatus = RatingSubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    final id = memberId;
    if (id == null) {
      submitStatus = RatingSubmitStatus.error;
      submitMessage = '먼저 학습용 회원가입을 완료해 주세요.';
      notifyListeners();
      throw StateError(submitMessage!);
    }
    if (submitStatus == RatingSubmitStatus.submitting) return;
    submitStatus = RatingSubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();
    try {
      await _service.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      if (_disposed) return;
      submitStatus = RatingSubmitStatus.success;
      submitMessage = '평점을 등록했어요. 마이페이지에서 확인해 주세요.';
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = RatingSubmitStatus.error;
      submitMessage = writeRatingErrorMessage(error);
      rethrow;
    } finally {
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
