import 'package:dio/dio.dart';

String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  return data is Map<String, dynamic> && data['code'] is String
      ? data['code'] as String
      : null;
}

String apiErrorMessage(DioException error) {
  final data = error.response?.data;
  return data is Map<String, dynamic> && data['message'] is String
      ? data['message'] as String
      : '요청을 처리하지 못했습니다.';
}

bool isExpiredSession(DioException error) =>
    const {'AUTH401_2', 'AUTH401_3', 'AUTH401_4'}.contains(apiErrorCode(error));
