import '../models/movie.dart';

const movies = <Movie>[
  Movie(title: 'Inception', releaseYear: 2010, rating: 8.8, watched: true),
  Movie(title: 'Parasite', releaseYear: 2019, rating: 8.5, watched: true),
  Movie(title: 'La La Land', releaseYear: 2016, rating: 8.0),
];

List<Movie> watchedMovies(Iterable<Movie> items) {
  return items.where((movie) => movie.watched).toList();
}

double averageRating(Iterable<Movie> items) {
  if (items.isEmpty) {
    return 0;
  }

  final total = items.fold<double>(0, (sum, movie) => sum + movie.rating);
  return total / items.length;
}
