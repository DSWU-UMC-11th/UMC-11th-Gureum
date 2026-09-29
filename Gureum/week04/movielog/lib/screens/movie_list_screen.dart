import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../models/movie_list_initial_data.dart';
import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';
import '../widgets/movie_list_states.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.initialGenres = const [],
    this.movieService = const FakeMovieService(),
    this.genreStore,
  });

  final List<String> initialGenres;
  final FakeMovieService movieService;
  final GenreStore? genreStore;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '스릴러', '애니메이션'];
  static const _requestTimeout = Duration(seconds: 2);

  late final GenreStore _genrePreference;
  late Future<MovieListInitialData> _moviesFuture;
  MovieLoadMode _loadMode = MovieLoadMode.success;
  String _selectedGenre = '전체';

  @override
  void initState() {
    super.initState();
    _genrePreference = widget.genreStore ?? GenrePreference();
    _moviesFuture = _loadInitialData();
  }

  Future<MovieListInitialData> _loadInitialData() async {
    try {
      final results = await Future.wait<Object>([
        widget.movieService
            .fetchMovies(mode: _loadMode)
            .timeout(_requestTimeout),
        _genrePreference.read(),
      ]);
      final savedGenre = results[1] as String;
      final selectedGenre = widget.initialGenres.isNotEmpty
          ? widget.initialGenres.first
          : (_genres.contains(savedGenre) ? savedGenre : '전체');
      _selectedGenre = selectedGenre;
      return MovieListInitialData(
        movies: results[0] as List<Movie>,
        selectedGenre: selectedGenre,
      );
    } on TimeoutException {
      throw const MovieLoadException('요청 시간이 초과되었습니다.');
    } finally {
      debugPrint('영화 목록 로드 시도 종료');
    }
  }

  Future<void> _selectGenre(String genre) async {
    setState(() => _selectedGenre = genre);
    await _genrePreference.save(genre);
    if (!mounted) return;
    final uri = Uri(
      path: '/movies',
      queryParameters: genre == '전체' ? null : {'genres': genre},
    );
    context.go(uri.toString());
  }

  void _reload({MovieLoadMode? mode}) {
    setState(() {
      _loadMode = mode ?? MovieLoadMode.success;
      _moviesFuture = _loadInitialData();
    });
  }

  Future<void> _refresh() async {
    _reload();
    await _moviesFuture;
  }

  List<Movie> _filteredMovies(List<Movie> loadedMovies) {
    if (_selectedGenre == '전체') return loadedMovies;
    return loadedMovies
        .where((movie) => movie.genre == _selectedGenre)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영화'),
        actions: [
          PopupMenuButton<MovieLoadMode>(
            tooltip: '상태 테스트',
            icon: const Icon(Icons.science_outlined),
            onSelected: (mode) => _reload(mode: mode),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: MovieLoadMode.success,
                child: Text('Success 상태'),
              ),
              PopupMenuItem(
                value: MovieLoadMode.empty,
                child: Text('Empty 상태'),
              ),
              PopupMenuItem(
                value: MovieLoadMode.failure,
                child: Text('Error 상태'),
              ),
              PopupMenuItem(
                value: MovieLoadMode.timeout,
                child: Text('Timeout 상태'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final genre = _genres[index];
                return ChoiceChip(
                  label: Text(genre),
                  selected: _selectedGenre == genre,
                  onSelected: (_) => _selectGenre(genre),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<MovieListInitialData>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _reload);
                }
                final loadedMovies = snapshot.data?.movies ?? const <Movie>[];
                final filtered = _filteredMovies(loadedMovies);
                if (filtered.isEmpty) {
                  return MovieListEmpty(onShowAll: () => _selectGenre('전체'));
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: MovieGrid(
                    movies: filtered,
                    onMovieTap: (movie) => context.push('/movies/${movie.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
