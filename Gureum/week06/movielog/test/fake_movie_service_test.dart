import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/services/fake_movie_service.dart';

void main() {
  const service = FakeMovieService(delay: Duration.zero);

  test('success 모드는 영화 목록을 반환한다', () async {
    final result = await service.fetchMovies();
    expect(result, isNotEmpty);
  });

  test('empty 모드는 빈 목록을 반환한다', () async {
    final result = await service.fetchMovies(mode: MovieLoadMode.empty);
    expect(result, isEmpty);
  });

  test('failure 모드는 MovieLoadException을 전달한다', () {
    expect(
      service.fetchMovies(mode: MovieLoadMode.failure),
      throwsA(isA<MovieLoadException>()),
    );
  });
}
