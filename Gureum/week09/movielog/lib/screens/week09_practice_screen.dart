import 'package:flutter/material.dart';

class Week09PracticeScreen extends StatefulWidget {
  const Week09PracticeScreen({super.key});
  @override
  State<Week09PracticeScreen> createState() => _Week09PracticeScreenState();
}

class _Week09PracticeScreenState extends State<Week09PracticeScreen> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    const tabs = ['상세 즐겨찾기', '내 즐겨찾기', '더 보기', '검색', '동시성'];
    const data = [
      (
        'movieId 550 · isFavorite: true',
        [
          'POST /v8/favorites → 201',
          'DELETE /v8/favorites/550 → 200',
          '409/404는 GET 여부 재조회로 정합성 회복',
        ],
      ),
      (
        '내 즐겨찾기 · 최신순 2개',
        [
          'favorite movieId → TMDB 상세 결합',
          '영화 1건 실패는 placeholder + 카드 재시도',
          '상세에서 해제 후 복귀하면 목록 갱신',
        ],
      ),
      (
        '페이지네이션 · page 1 → 2',
        ['초기 로딩과 추가 로딩 분리', '다음 page 실패 시 같은 page 재시도', '마지막 page에서는 더 보기 숨김'],
      ),
      (
        '검색 · 듄',
        [
          '/search/movie?query=듄&page=1',
          '검색어 변경 시 generation 증가',
          '결과 없음·오류·재시도 상태 분리',
        ],
      ),
      (
        '세션·요청 generation',
        [
          '검색/장르 변경의 늦은 응답 무시',
          '로그아웃/계정 전환은 SessionGuard invalidate',
          'TMDB 보충 조회 동시 요청 최대 5개',
        ],
      ),
    ];
    final item = data[selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('9주차 · 즐겨찾기·검색·페이지네이션'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0f766e), Color(0xff2563eb)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK 09',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '목록을 서비스답게 확장하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '즐겨찾기와 TMDB 영화를 movieId로 결합하고, 검색·더 보기·늦은 응답 보호를 완성합니다.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              tabs.length,
              (i) => ChoiceChip(
                label: Text(tabs[i]),
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: .07),
              border: Border.all(color: Colors.blue.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 14),
                ...item.$2.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.teal,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
