class Movie {
  const Movie({
    required this.title,
    required this.releaseYear,
    required this.rating,
    this.watched = false,
  });

  final String title;
  final int releaseYear;
  final double rating;
  final bool watched;

  String get summary => '$title ($releaseYear) · $rating';

  Movie copyWith({
    String? title,
    int? releaseYear,
    double? rating,
    bool? watched,
  }) {
    return Movie(
      title: title ?? this.title,
      releaseYear: releaseYear ?? this.releaseYear,
      rating: rating ?? this.rating,
      watched: watched ?? this.watched,
    );
  }
}
