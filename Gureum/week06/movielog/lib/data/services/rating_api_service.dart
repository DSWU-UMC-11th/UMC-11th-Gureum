import 'package:dio/dio.dart';

import '../models/rating_dto.dart';

class RatingApiService {
  const RatingApiService(this._dio);
  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get<List<dynamic>>(
      '/v5/members/$memberId/ratings',
    );
    return (response.data ?? const [])
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
