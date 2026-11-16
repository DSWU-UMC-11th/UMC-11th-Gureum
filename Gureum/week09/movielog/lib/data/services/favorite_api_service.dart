import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/favorite_models.dart';

class FavoriteApiService {
  const FavoriteApiService(this._dio);
  final Dio _dio;

  Options _authorized(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<FavoriteDto> create(String token, int movieId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v8/favorites',
      data: {'movieId': movieId},
      options: _authorized(token),
    );
    return FavoriteDto.fromJson(
      response.data!['result'] as Map<String, dynamic>,
    );
  }

  Future<List<FavoriteDto>> fetchMine(String token) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v8/favorites',
      options: _authorized(token),
    );
    return (response.data!['result'] as List<dynamic>)
        .map((e) => FavoriteDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(String token, int movieId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v8/favorites/$movieId',
      options: _authorized(token),
    );
    return (response.data!['result'] as Map<String, dynamic>)['isFavorite']
        as bool;
  }

  Future<void> delete(String token, int movieId) async {
    await _dio.delete('/v8/favorites/$movieId', options: _authorized(token));
  }

  Future<MovieRecordDto> createMovieRecord(
    String token, {
    required int movieId,
    required int score,
    String? comment,
    required bool addToFavorites,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v8/movie-records',
      data: {
        'movieId': movieId,
        'score': score,
        'comment': comment,
        'addToFavorites': addToFavorites,
      },
      options: _authorized(token),
    );
    return MovieRecordDto.fromJson(
      response.data!['result'] as Map<String, dynamic>,
    );
  }
}

String favoriteErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    return CommonResponse<Object?>.fromJson(data, (value) => value).message;
  }
  return '요청을 처리하지 못했습니다.';
}
