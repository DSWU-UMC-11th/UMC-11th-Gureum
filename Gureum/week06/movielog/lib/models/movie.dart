class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.synopsis,
    this.rating = 4.5,
  });
  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final String synopsis;
  final double rating;
}
