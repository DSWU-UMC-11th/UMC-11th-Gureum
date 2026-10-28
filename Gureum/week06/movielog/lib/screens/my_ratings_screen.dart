import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/my_ratings_view_model.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('내가 등록한 평점'),
      centerTitle: true,
      actions: [
        PopupMenuButton<MyRatingsStatus>(
          tooltip: '상태 확인',
          icon: const Icon(Icons.science_outlined),
          onSelected: (status) {
            final vm = context.read<MyRatingsViewModel>();
            if (status == MyRatingsStatus.success) {
              vm.load();
            } else {
              vm.showVerificationState(status);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: MyRatingsStatus.loading,
              child: Text('Loading 확인'),
            ),
            PopupMenuItem(
              value: MyRatingsStatus.empty,
              child: Text('Empty 확인'),
            ),
            PopupMenuItem(
              value: MyRatingsStatus.error,
              child: Text('Error 확인'),
            ),
            PopupMenuItem(
              value: MyRatingsStatus.success,
              child: Text('Success 복원'),
            ),
          ],
        ),
      ],
    ),
    body: Consumer<MyRatingsViewModel>(
      builder: (context, vm, child) => switch (vm.status) {
        MyRatingsStatus.idle || MyRatingsStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        MyRatingsStatus.empty => const _CenteredState(
          icon: Icons.rate_review_outlined,
          text: '등록한 평점이 없습니다.',
        ),
        MyRatingsStatus.error => _CenteredState(
          icon: Icons.error_outline,
          text: vm.message ?? '평점 목록을 불러오지 못했어요.',
          action: FilledButton(onPressed: vm.load, child: const Text('다시 시도')),
        ),
        MyRatingsStatus.success => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: vm.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = vm.items[index];
            final movie = item.movie;
            final date = item.rating.createdAt.toLocal();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: movie?.posterUrl == null
                          ? const _PosterPlaceholder()
                          : Image.network(
                              movie!.posterUrl!,
                              width: 88,
                              height: 126,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const _PosterPlaceholder(),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie?.title ?? '영화 #${item.rating.movieId}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text('★ ${item.rating.score.toStringAsFixed(1)}'),
                          const SizedBox(height: 8),
                          Text(
                            item.rating.comment?.trim().isNotEmpty == true
                                ? item.rating.comment!
                                : '작성한 후기가 없습니다.',
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      },
    ),
  );
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 12),
        Text(text),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 126,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: const Icon(Icons.movie_outlined),
  );
}
