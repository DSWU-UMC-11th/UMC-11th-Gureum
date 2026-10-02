import '../data/movie_data.dart';
import '../models/movie.dart';

enum MovieLoadMode { success, empty, failure, timeout }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FakeMovieService {
  const FakeMovieService({this.delay = const Duration(milliseconds: 900)});
  final Duration delay;

  // TODO(5주차 유저별 평점 조회 API): Mock 호출을 실제 API Service로 교체한다.
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    await Future<void>.delayed(
      mode == MovieLoadMode.timeout ? const Duration(seconds: 4) : delay,
    );
    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
      MovieLoadMode.timeout => movies,
    };
  }
}
