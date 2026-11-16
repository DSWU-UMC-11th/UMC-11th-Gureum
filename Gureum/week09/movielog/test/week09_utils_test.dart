import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/utils/map_bounded.dart';

void main() {
  test('mapBounded는 입력 순서를 보존한다', () async {
    expect(await mapBounded([3, 1, 2], 2, (v) async => v * 2), [6, 2, 4]);
  });
  test('SessionGuard는 계정 전환 전 응답을 무효화한다', () {
    final g = SessionGuard();
    final old = g.startSession('a');
    g.startSession('b');
    expect(g.isCurrent(old, 'a'), isFalse);
  });
}
