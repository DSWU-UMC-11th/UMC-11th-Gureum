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
  bool writeSucceededButRefreshFailed = false;
  bool isEditing = false;
  bool isDeletingSelected = false;
  final Set<int> selectedRatingIds = {};
  bool _disposed = false;
  int _requestVersion = 0;

  Future<void> load({bool preserveItems = false}) async {
    final version = ++_requestVersion;
    if (!preserveItems) status = MyRatingsStatus.loading;
    message = null;
    writeSucceededButRefreshFailed = false;
    _notify();
    try {
      final ratings = await _ratingService.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion) return;
      if (ratings.isEmpty) {
        items = const [];
        status = MyRatingsStatus.empty;
      } else {
        final resolved = await Future.wait(
          ratings.map((rating) async {
            try {
              return MyRatingItem(
                rating: rating,
                movie: await _movieService.fetchMovieDetails(rating.movieId),
              );
            } on DioException {
              return MyRatingItem(rating: rating, movie: null);
            }
          }),
        );
        if (_disposed || version != _requestVersion) return;
        items = resolved;
        status = MyRatingsStatus.success;
      }
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsStatus.error;
      message = '평점 목록을 불러오지 못했어요. 다시 시도해 주세요.';
    }
    _notify();
  }

  Future<bool> updateRating({
    required RatingDto rating,
    required int score,
    String? comment,
  }) async {
    message = null;
    _notify();
    try {
      await _ratingService.updateRating(
        memberId: memberId,
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      );
      return await _refreshAfterWrite('평점을 수정했어요.');
    } on DioException catch (error) {
      message = writeRatingErrorMessage(error);
      if (shouldRefreshAfterRatingError(error)) await load(preserveItems: true);
      _notify();
      rethrow;
    }
  }

  Future<bool> deleteRating(int ratingId) async {
    try {
      await _ratingService.deleteRating(memberId: memberId, ratingId: ratingId);
      return await _refreshAfterWrite('평점을 삭제했어요.');
    } on DioException catch (error) {
      message = writeRatingErrorMessage(error);
      if (shouldRefreshAfterRatingError(error)) await load(preserveItems: true);
      _notify();
      return false;
    }
  }

  Future<bool> _refreshAfterWrite(String successMessage) async {
    try {
      final ratings = await _ratingService.fetchMyRatings(memberId);
      if (_disposed) return false;
      if (ratings.isEmpty) {
        items = const [];
        status = MyRatingsStatus.empty;
      } else {
        final oldMovies = {
          for (final item in items) item.rating.movieId: item.movie,
        };
        items = ratings
            .map(
              (rating) => MyRatingItem(
                rating: rating,
                movie: oldMovies[rating.movieId],
              ),
            )
            .toList();
        status = MyRatingsStatus.success;
      }
      message = successMessage;
      writeSucceededButRefreshFailed = false;
      _notify();
      return true;
    } on DioException {
      writeSucceededButRefreshFailed = true;
      message = '저장은 완료됐지만 목록을 새로 불러오지 못했어요. GET만 다시 시도해 주세요.';
      _notify();
      return false;
    }
  }

  void setEditing(bool value) {
    isEditing = value;
    if (!value) selectedRatingIds.clear();
    _notify();
  }

  void toggleSelection(int ratingId) {
    selectedRatingIds.contains(ratingId)
        ? selectedRatingIds.remove(ratingId)
        : selectedRatingIds.add(ratingId);
    _notify();
  }

  Future<void> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return;
    isDeletingSelected = true;
    _notify();
    var failed = 0;
    for (final ratingId in selectedRatingIds.toList()) {
      try {
        await _ratingService.deleteRating(
          memberId: memberId,
          ratingId: ratingId,
        );
        selectedRatingIds.remove(ratingId);
      } on DioException {
        failed++;
      }
    }
    isDeletingSelected = false;
    await _refreshAfterWrite('선택한 평점을 삭제했어요.');
    if (failed > 0) {
      message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
    } else {
      isEditing = false;
      selectedRatingIds.clear();
    }
    _notify();
  }

  void showVerificationState(MyRatingsStatus value) {
    status = value;
    message = value == MyRatingsStatus.error
        ? '평점 목록을 불러오지 못했어요. 다시 시도해 주세요.'
        : null;
    _notify();
  }

  void showRefreshFailureVerification() {
    writeSucceededButRefreshFailed = true;
    message = '저장은 완료됐지만 목록을 새로 불러오지 못했어요. GET만 다시 시도해 주세요.';
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
