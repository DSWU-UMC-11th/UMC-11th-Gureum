import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/movie_data.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('MovieLog')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '오늘은 어떤 영화를\n기록해볼까요?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.push('/movies/${movies.first.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(
                  movies.first.posterAsset,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    movies.first.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('지금 인기 있는 영화', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go('/movies'),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => SizedBox(
              width: 160,
              child: MovieCard(
                movie: movies[index],
                onTap: () => context.push('/movies/${movies[index].id}'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
