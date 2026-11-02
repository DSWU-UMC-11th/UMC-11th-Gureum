import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;
  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({int? genreId}) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;
    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );
      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == 30) break;
      }
      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }
    return byId.values.take(30).toList();
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      genres = await _service.fetchGenres();
      final result = await fetchUpToThirtyMovies();
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      _setError(version, '영화를 불러오지 못했어요. 다시 시도해 주세요.');
    } catch (_) {
      _setError(version, 'TMDB 설정을 확인해 주세요.');
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading) return;
    selectedGenreId = genreId;
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      final result = await fetchUpToThirtyMovies(genreId: genreId);
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      _setError(version, '해당 장르 영화를 불러오지 못했어요.');
    } catch (_) {
      _setError(version, 'TMDB 설정을 확인해 주세요.');
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  void _setError(int version, String value) {
    if (_disposed || version != _requestVersion) return;
    status = MovieListLoadStatus.error;
    message = value;
  }

  void showVerificationState(MovieListLoadStatus value) {
    _requestVersion++;
    status = value;
    message = value == MovieListLoadStatus.error
        ? '네트워크 오류 상태를 확인하는 테스트 화면입니다.'
        : null;
    if (value == MovieListLoadStatus.empty) movies = const [];
    notifyListeners();
  }

  void showPosterPlaceholder() {
    _requestVersion++;
    movies = const [
      TmdbMovieDto(
        id: -1,
        title: '포스터 준비 중',
        overview: 'poster_path가 null일 때 표시되는 대체 UI입니다.',
        posterPath: null,
        genreIds: [],
        voteAverage: 0,
        releaseDate: '',
      ),
    ];
    status = MovieListLoadStatus.success;
    message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
