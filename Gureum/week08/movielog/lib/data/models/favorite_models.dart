class FavoriteDto {
  const FavoriteDto({
    required this.favoriteId,
    required this.movieId,
    required this.createdAt,
  });

  final int favoriteId;
  final int movieId;
  final DateTime createdAt;

  factory FavoriteDto.fromJson(Map<String, dynamic> json) => FavoriteDto(
    favoriteId: json['favoriteId'] as int,
    movieId: json['movieId'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class MovieRecordDto {
  const MovieRecordDto({
    required this.ratingId,
    required this.favoriteId,
    required this.movieId,
    required this.score,
    required this.comment,
  });

  final int ratingId;
  final int favoriteId;
  final int movieId;
  final int score;
  final String? comment;

  factory MovieRecordDto.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>;
    final favorite = json['favorite'] as Map<String, dynamic>;
    return MovieRecordDto(
      ratingId: rating['ratingId'] as int,
      favoriteId: favorite['favoriteId'] as int,
      movieId: rating['movieId'] as int,
      score: rating['score'] as int,
      comment: rating['comment'] as String?,
    );
  }
}
