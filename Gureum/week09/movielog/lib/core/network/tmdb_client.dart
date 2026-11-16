import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/tmdb_config.dart';
import 'tmdb_logging_interceptor.dart';

Dio createTmdbClient() {
  final token = TmdbConfig.accessToken;
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    ),
  );
  if (kDebugMode) dio.interceptors.add(TmdbLoggingInterceptor());
  return dio;
}
