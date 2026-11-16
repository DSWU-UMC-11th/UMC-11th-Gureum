import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/favorite_models.dart';
import '../data/services/favorite_api_service.dart';

class Week08PracticeScreen extends StatefulWidget {
  const Week08PracticeScreen({super.key});

  @override
  State<Week08PracticeScreen> createState() => _Week08PracticeScreenState();
}

class _Week08PracticeScreenState extends State<Week08PracticeScreen> {
  static const _token = String.fromEnvironment('WEEK8_ACCESS_TOKEN');
  static const _demo = bool.fromEnvironment('WEEK8_DEMO');
  int _selected = 0;
  bool _busy = false;
  String? _message;
  List<FavoriteDto> _favorites = _demo
      ? [
          FavoriteDto(
            favoriteId: 3,
            movieId: 550,
            createdAt: DateTime.utc(2026, 11, 13, 7, 22),
          ),
        ]
      : const [];
  bool _status = _demo;
  MovieRecordDto? _record = _demo
      ? const MovieRecordDto(
          ratingId: 7,
          favoriteId: 4,
          movieId: 238,
          score: 5,
          comment: '다시 보고 싶은 영화입니다.',
        )
      : null;

  Future<void> _run(
    Future<void> Function(FavoriteApiService, String) action,
  ) async {
    if (_token.isEmpty) {
      setState(() => _message = 'WEEK8_ACCESS_TOKEN을 dart-define으로 전달해 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action(context.read<FavoriteApiService>(), _token);
    } on DioException catch (error) {
      setState(
        () => _message =
            '${error.response?.statusCode} · ${favoriteErrorMessage(error)}',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['등록·중복', '목록·여부·해제', '영화 기록', '트랜잭션'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('8주차 · 즐겨찾기 & 영화 기록'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _HeroCard(),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                titles.length,
                (i) => ChoiceChip(
                  label: Text(titles[i]),
                  selected: _selected == i,
                  onSelected: (_) => setState(() => _selected = i),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_selected == 0) _registrationPanel(),
            if (_selected == 1) _listPanel(),
            if (_selected == 2) _recordPanel(),
            if (_selected == 3) const _TransactionPanel(),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_message != null)
              _ResponseCard(code: _message!, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _registrationPanel() => Column(
    children: [
      _ActionCard(
        title: 'POST /v8/favorites',
        subtitle: 'Body  { movieId: 550 } · memberId 없음',
        button: '즐겨찾기 등록',
        onPressed: () => _run((api, token) async {
          final item = await api.create(token, 550);
          setState(() {
            _favorites = [item, ..._favorites];
            _status = true;
            _message = '201 · COMMON201 · 즐겨찾기를 등록했습니다.';
          });
        }),
      ),
      const SizedBox(height: 12),
      const _ResponseCard(
        code: '409 · FAVORITE409_1',
        detail: '이미 이 영화를 즐겨찾기하셨습니다.',
        color: Colors.deepOrange,
      ),
    ],
  );

  Widget _listPanel() => Column(
    children: [
      _ActionCard(
        title: 'GET /v8/favorites',
        subtitle: 'Authorization 토큰의 내 목록 · 최신순',
        button: '목록 새로고침',
        onPressed: () => _run((api, token) async {
          final list = await api.fetchMine(token);
          setState(() {
            _favorites = list;
            _message = '200 · COMMON200 · ${list.length}개';
          });
        }),
      ),
      const SizedBox(height: 12),
      _ResponseCard(
        code: '200 · isFavorite: $_status',
        detail: _favorites.isEmpty
            ? '[]'
            : _favorites
                  .map(
                    (e) => 'favoriteId ${e.favoriteId} · movieId ${e.movieId}',
                  )
                  .join('\n'),
        color: Colors.teal,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _run((api, token) async {
                final value = await api.isFavorite(token, 550);
                setState(() => _status = value);
              }),
              child: const Text('여부 조회'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _run((api, token) async {
                await api.delete(token, 550);
                setState(() {
                  _status = false;
                  _favorites = _favorites
                      .where((e) => e.movieId != 550)
                      .toList();
                  _message = '200 · COMMON200 · result: null';
                });
              }),
              child: const Text('해제'),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _recordPanel() => Column(
    children: [
      _ActionCard(
        title: 'POST /v8/movie-records',
        subtitle: '평점 + 즐겨찾기를 한 요청으로 저장',
        button: '영화 기록 저장',
        onPressed: () => _run((api, token) async {
          final record = await api.createMovieRecord(
            token,
            movieId: 238,
            score: 5,
            comment: '다시 보고 싶은 영화입니다.',
            addToFavorites: true,
          );
          setState(() {
            _record = record;
            _message = '201 · COMMON201 · 영화 기록을 저장했습니다.';
          });
        }),
      ),
      const SizedBox(height: 12),
      _ResponseCard(
        code: _record == null ? '아직 저장 전' : '201 · rating + favorite',
        detail: _record == null
            ? '두 결과가 함께 반환됩니다.'
            : 'ratingId ${_record!.ratingId} · score ${_record!.score}\nfavoriteId ${_record!.favoriteId} · movieId ${_record!.movieId}',
        color: Colors.indigo,
      ),
    ],
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff6c5ce7), Color(0xff00b894)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEK 08',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text(
          '서비스의 핵심 기능 만들기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '토큰으로 내 데이터만 다루고, 트랜잭션으로 두 저장의 원자성을 보장합니다.',
          style: TextStyle(color: Colors.white, height: 1.5),
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onPressed,
  });
  final String title, subtitle, button;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 16),
          FilledButton(onPressed: onPressed, child: Text(button)),
        ],
      ),
    ),
  );
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.code, this.detail, required this.color});
  final String code;
  final String? detail;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      border: Border.all(color: color.withValues(alpha: .35)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 8),
          Text(detail!, style: const TextStyle(height: 1.5)),
        ],
      ],
    ),
  );
}

class _TransactionPanel extends StatelessWidget {
  const _TransactionPanel();
  @override
  Widget build(BuildContext context) => const _ResponseCard(
    code: '@Transactional / DataSource.transaction()',
    detail: 'rating 저장 → favorite 저장 → 모두 성공하면 commit\n하나라도 실패하면 앞선 저장까지 rollback\n\n두 저장을 묶은 이유: 사용자의 한 번의 영화 기록 의도가 부분 저장된 불일치 상태로 남지 않게 하기 위해서입니다.',
    color: Colors.purple,
  );
}
