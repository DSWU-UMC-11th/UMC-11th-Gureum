import '../../core/config/tmdb_config.dart';

class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.genreIds,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) => TmdbMovieDto(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String? ?? '제목 없음',
        overview: json['overview'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
            .map((value) => (value as num).toInt())
            .toList(),
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
        releaseDate: json['release_date'] as String? ?? '',
      );

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final List<int> genreIds;
  final double voteAverage;
  final String releaseDate;

  String? get posterUrl => posterPath == null
      ? null
      : '${TmdbConfig.imageBaseUrl}$posterPath';
  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '-';
}

class TmdbMoviePageDto {
  const TmdbMoviePageDto({
    required this.page,
    required this.results,
    required this.totalPages,
  });

  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) =>
      TmdbMoviePageDto(
        page: (json['page'] as num?)?.toInt() ?? 1,
        results: (json['results'] as List<dynamic>? ?? const [])
            .map((item) => TmdbMovieDto.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      );

  final int page;
  final List<TmdbMovieDto> results;
  final int totalPages;
}
