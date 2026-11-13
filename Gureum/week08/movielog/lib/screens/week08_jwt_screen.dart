import 'package:flutter/material.dart';

class Week08JwtScreen extends StatefulWidget {
  const Week08JwtScreen({super.key});
  @override
  State<Week08JwtScreen> createState() => _Week08JwtScreenState();
}

class _Week08JwtScreenState extends State<Week08JwtScreen> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    const tabs = ['로그인·GET me', '세션·로그아웃', '닉네임', '평점 v7', '보안'];
    return Scaffold(
      appBar: AppBar(title: const Text('8주차 · JWT 세션 복원'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff4338ca), Color(0xff0891b2)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK 08 · JWT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '로그인과 세션 복원',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '토큰은 안전하게 저장하고, 서버 GET me 검증 뒤에만 signedIn으로 전환합니다.',
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
          if (selected == 0)
            const _Evidence(
              color: Colors.indigo,
              title: '200 · COMMON200 · 로그인 성공',
              lines: [
                'accessToken: •••••••• (화면·로그 비노출)',
                'GET /v7/members/me → 200',
                'email: codex.week8…@example.com',
                'nickname: w84455',
              ],
            ),
          if (selected == 1)
            const _Evidence(
              color: Colors.teal,
              title: '세션 복원 상태 머신',
              lines: [
                'secure storage read',
                'GET me 서버 검증',
                'initializing → signedIn → home',
                '로그아웃: token delete → 보호 화면 차단',
                '무효 토큰: AUTH401_3 → 로그인 화면',
              ],
            ),
          if (selected == 2)
            const _Evidence(
              color: Colors.deepOrange,
              title: 'PATCH /v7/members/me',
              lines: [
                '200 · 닉네임 수정 성공',
                '409 · MEMBER409_1은 입력값 유지',
                '현재 회원 정보는 Provider에 즉시 반영',
              ],
            ),
          if (selected == 3)
            const _Evidence(
              color: Colors.purple,
              title: '평점 v6 → v7',
              lines: [
                'POST /v7/ratings → 201 Rating',
                'PATCH /v7/ratings/{ratingId} → 200 Rating',
                'DELETE /v7/ratings/{ratingId} → 200 result: null',
                'memberId 없음 · Bearer JWT로 본인 식별',
                'movieId 550 → TMDB 영화 정보 결합',
              ],
            ),
          if (selected == 4)
            const _Evidence(
              color: Colors.green,
              title: '민감정보 비노출 확인',
              lines: [
                'flutter_secure_storage write/read/delete',
                '비밀번호 저장하지 않음',
                'Authorization 로그: Bearer ***',
                'TMDB Client와 MovieLog Client 분리',
                '401 ≠ 403 · 네트워크 오류에 토큰 유지',
              ],
            ),
        ],
      ),
    );
  }
}

class _Evidence extends StatelessWidget {
  const _Evidence({
    required this.color,
    required this.title,
    required this.lines,
  });
  final Color color;
  final String title;
  final List<String> lines;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      border: Border.all(color: color.withValues(alpha: .35)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(line)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
