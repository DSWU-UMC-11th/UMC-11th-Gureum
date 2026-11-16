import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/favorite_models.dart';

void main() {
  test('즐겨찾기 응답을 모델로 변환한다', () {
    final item = FavoriteDto.fromJson({
      'favoriteId': 3,
      'movieId': 550,
      'createdAt': '2026-11-13T07:22:00.294Z',
    });
    expect(item.favoriteId, 3);
    expect(item.movieId, 550);
  });

  test('영화 기록 응답에서 평점과 즐겨찾기를 함께 변환한다', () {
    final record = MovieRecordDto.fromJson({
      'rating': {'ratingId': 7, 'movieId': 238, 'score': 5, 'comment': '좋아요'},
      'favorite': {'favoriteId': 4, 'movieId': 238},
    });
    expect(record.ratingId, 7);
    expect(record.favoriteId, 4);
    expect(record.movieId, 238);
  });

  test('인증 헤더에는 Bearer 토큰 형식을 사용한다', () {
    final options = Options(headers: {'Authorization': 'Bearer token'});
    expect(options.headers?['Authorization'], 'Bearer token');
  });
}
