import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movie_rating_dialog.dart';
import '../widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  Future<void> _edit(BuildContext context, MyRatingItem item) async {
    final vm = context.read<MyRatingsViewModel>();
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MovieRatingDialog(
        title: '${item.movie?.title ?? '영화'} 평점 수정',
        initialScore: item.rating.score.toInt(),
        initialComment: item.rating.comment,
        onSubmit: (score, comment) => vm.updateRating(
          rating: item.rating,
          score: score,
          comment: comment,
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.message ?? '평점을 수정했어요.')));
    }
  }

  Future<void> _delete(BuildContext context, RatingDto rating) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final vm = context.read<MyRatingsViewModel>();
    await vm.deleteRating(rating.ratingId);
    if (context.mounted && vm.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.message!)));
    }
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final vm = context.read<MyRatingsViewModel>();
    final count = vm.selectedRatingIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('선택한 $count개 평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await vm.deleteSelectedRatings();
      if (context.mounted && vm.message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(vm.message!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<MyRatingsViewModel>(
    builder: (context, vm, _) => PopScope(
      canPop: !vm.isDeletingSelected,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: vm.isEditing
              ? Text('${vm.selectedRatingIds.length}개 선택')
              : const Text('내가 등록한 평점'),
          centerTitle: true,
          actions: [
            if (vm.status == MyRatingsStatus.success)
              TextButton(
                onPressed: () => vm.setEditing(!vm.isEditing),
                child: Text(vm.isEditing ? '취소' : '편집'),
              ),
            PopupMenuButton<String>(
              tooltip: '상태 확인',
              icon: const Icon(Icons.science_outlined),
              onSelected: (value) {
                if (value == 'refreshFailure') {
                  vm.showRefreshFailureVerification();
                } else if (value == 'success') {
                  vm.load();
                } else {
                  vm.showVerificationState(
                    MyRatingsStatus.values.byName(value),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'loading', child: Text('Loading 확인')),
                PopupMenuItem(value: 'empty', child: Text('Empty 확인')),
                PopupMenuItem(value: 'error', child: Text('Error 확인')),
                PopupMenuItem(
                  value: 'refreshFailure',
                  child: Text('저장 성공 / GET 실패 확인'),
                ),
                PopupMenuItem(value: 'success', child: Text('Success 복원')),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            _body(context, vm),
            if (vm.isDeletingSelected) ...[
              const ModalBarrier(dismissible: false, color: Colors.black45),
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ],
        ),
        bottomNavigationBar: vm.isEditing
            ? SafeArea(
                minimum: const EdgeInsets.all(16),
                child: MovieLogButton(
                  label: '선택한 ${vm.selectedRatingIds.length}개 삭제',
                  width: double.infinity,
                  onPressed: vm.selectedRatingIds.isEmpty
                      ? null
                      : () => _deleteSelected(context),
                ),
              )
            : null,
      ),
    ),
  );

  Widget _body(BuildContext context, MyRatingsViewModel vm) {
    if (vm.writeSucceededButRefreshFailed) {
      return _CenteredState(
        icon: Icons.sync_problem,
        text: vm.message!,
        action: FilledButton(
          onPressed: vm.load,
          child: const Text('GET만 다시 시도'),
        ),
      );
    }
    return switch (vm.status) {
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
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = vm.items[index];
          return _RatingCard(
            item: item,
            editing: vm.isEditing,
            selected: vm.selectedRatingIds.contains(item.rating.ratingId),
            onSelected: () => vm.toggleSelection(item.rating.ratingId),
            onEdit: () => _edit(context, item),
            onDelete: () => _delete(context, item.rating),
          );
        },
      ),
    };
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.item,
    required this.editing,
    required this.selected,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete,
  });
  final MyRatingItem item;
  final bool editing;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: editing ? onSelected : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.movie?.posterUrl == null
                  ? const _PosterPlaceholder()
                  : Image.network(
                      item.movie!.posterUrl!,
                      width: 72,
                      height: 104,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _PosterPlaceholder(),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.movie?.title ?? '영화 #${item.rating.movieId}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text('TMDB movieId ${item.rating.movieId}'),
                  const SizedBox(height: 6),
                  Text('★ ${item.rating.score.toInt()}'),
                  const SizedBox(height: 6),
                  Text(
                    item.rating.comment?.trim().isNotEmpty == true
                        ? item.rating.comment!
                        : '작성한 후기가 없습니다.',
                  ),
                ],
              ),
            ),
            if (editing)
              Checkbox(value: selected, onChanged: (_) => onSelected())
            else
              Column(
                children: [
                  IconButton(
                    tooltip: '수정',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: '삭제',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
          ],
        ),
      ),
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
        Text(text, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 104,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: const Icon(Icons.movie_outlined),
  );
}
