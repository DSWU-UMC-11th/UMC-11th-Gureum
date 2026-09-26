import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_data.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key, this.initialGenres = const []});
  final List<String> initialGenres;
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Set<String> _selectedGenres = widget.initialGenres.toSet();
  final _genres = const ['드라마', 'SF', '스릴러', '애니메이션'];

  Future<void> _openFilters() async {
    final draft = {..._selectedGenres};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .5,
            minChildSize: .35,
            maxChildSize: .85,
            builder: (context, controller) => Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '장르 필터',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: _genres
                        .map(
                          (genre) => CheckboxListTile(
                            value: draft.contains(genre),
                            title: Text(genre),
                            onChanged: (checked) => setSheetState(
                              () => checked == true
                                  ? draft.add(genre)
                                  : draft.remove(genre),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, draft),
                        child: const Text('필터 적용'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (result == null) return;
    setState(() => _selectedGenres = result);
    final uri = Uri(
      path: '/movies',
      queryParameters: result.isEmpty ? null : {'genres': result.join(',')},
    );
    if (mounted) context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedGenres.isEmpty
        ? movies
        : movies
              .where((movie) => _selectedGenres.contains(movie.genre))
              .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('영화'),
        actions: [
          IconButton(
            onPressed: _openFilters,
            tooltip: '장르 필터',
            icon: Badge(
              isLabelVisible: _selectedGenres.isNotEmpty,
              label: Text('${_selectedGenres.length}'),
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: .62,
        ),
        itemBuilder: (_, index) => MovieCard(
          movie: filtered[index],
          onTap: () => context.push('/movies/${filtered[index].id}'),
        ),
      ),
    );
  }
}
