import '../data/movie_data.dart' as data;
import '../models/movie.dart';

const movies = data.movies;

List<Movie> moviesByGenre(Iterable<Movie> items, String genre) =>
    items.where((movie) => movie.genre == genre).toList();

double averageRating(Iterable<Movie> items) {
  if (items.isEmpty) {
    return 0;
  }

  final total = items.fold<double>(0, (sum, movie) => sum + movie.rating);
  return total / items.length;
}
