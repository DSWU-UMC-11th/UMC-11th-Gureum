import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsStatus { idle, loading, success, empty, error }

class MyRatingItem {
  const MyRatingItem({required this.rating, required this.movie});
  final RatingDto rating;
  final TmdbMovieDto? movie;
}

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingService, this._movieService, this.memberId);
  final RatingApiService _ratingService;
  final TmdbMovieService _movieService;
  final int memberId;

  MyRatingsStatus status = MyRatingsStatus.idle;
  List<MyRatingItem> items = const [];
  String? message;
  bool _disposed = false;

  Future<void> load() async {
    status = MyRatingsStatus.loading;
    message = null;
    notifyListeners();
    try {
      final ratings = await _ratingService.fetchMyRatings(memberId);
      if (_disposed) return;
      if (ratings.isEmpty) {
        items = const [];
        status = MyRatingsStatus.empty;
      } else {
        final resolved = await Future.wait(
          ratings.map((rating) async {
            try {
              final movie = await _movieService.fetchMovieDetails(
                rating.movieId,
              );
              return MyRatingItem(rating: rating, movie: movie);
            } on DioException {
              return MyRatingItem(rating: rating, movie: null);
            }
          }),
        );
        if (_disposed) return;
        items = resolved;
        status = MyRatingsStatus.success;
      }
    } on DioException {
      if (_disposed) return;
      status = MyRatingsStatus.error;
      message = '평점 목록을 불러오지 못했어요. 다시 시도해 주세요.';
    }
    if (!_disposed) notifyListeners();
  }

  void showVerificationState(MyRatingsStatus value) {
    status = value;
    message = value == MyRatingsStatus.error
        ? '평점 목록을 불러오지 못했어요. 다시 시도해 주세요.'
        : null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
