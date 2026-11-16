# MovieLog 8주차

토큰으로 로그인한 회원의 즐겨찾기를 관리하고, 평점과 즐겨찾기를 하나의 영화 기록으로 저장하는 Flutter 실습입니다.

## 구현 내용

- `POST /v8/favorites`: 즐겨찾기 등록
- `GET /v8/favorites`: 내 즐겨찾기 최신순 조회
- `GET /v8/favorites/{movieId}`: 특정 영화 즐겨찾기 여부 조회
- `DELETE /v8/favorites/{movieId}`: 즐겨찾기 해제
- `POST /v8/movie-records`: 평점과 즐겨찾기 동시 저장
- `Authorization: Bearer ...` 헤더로 회원 식별, 요청에는 `memberId` 미포함
- `/week8` 실습 화면에서 API별 요청과 응답 확인

## 8주차 실제 API 검증

- 등록 `201 COMMON201`, 중복 등록 `409 FAVORITE409_1`
- 목록/여부 `200 COMMON200`, 등록 전 `false` → 등록 후 `true`
- 해제 `200 COMMON200` + `result: null`, 없는 항목 해제 `404 FAVORITE404_1`
- 영화 기록 `201 COMMON201`, `rating`과 `favorite` 동시 반환
- 동일 영화 기록 재요청 `409 RATING409_1`

영화 기록 서버 서비스는 두 저장을 한 트랜잭션으로 묶습니다. 둘 중 하나가 실패하면 앞선 저장도 rollback되어 사용자의 한 번의 의도가 부분 저장으로 남지 않습니다. 서버 사전 검사는 친절한 오류를, 복합 UNIQUE 제약은 동시 요청에서도 데이터 무결성을 보장합니다.

## 실행

```bash
flutter run -d chrome --dart-define=WEEK8_ACCESS_TOKEN={학습 API 로그인 토큰}
```

토큰은 코드나 Git에 저장하지 않습니다. 인증 캡처용 화면은 실제 검증 결과를 `--dart-define=WEEK8_DEMO=true`로 표시합니다.

## 이전 주차에서 이어지는 구현

- `FakeMovieService`의 Success·Empty·Failure·Timeout 모드
- `FutureBuilder` 기반 Loading·Empty·Error·Success 화면
- `initState`에서 Future 생성, 재시도 시에만 새 Future 할당
- Error 화면의 `다시 시도` 동작
- `SharedPreferencesAsync`를 이용한 `selected_genre` 저장과 복원
- `Future.wait`로 영화 목록과 저장 장르 동시 로드
- `RefreshIndicator` 당겨서 새로고침
- 2초 timeout 처리와 Skeleton Loading UI
- 상태별 Widget 분리 및 Service 단위 테스트
- 실제 API 교체 위치에 5주차 TODO 표시

## 상태 확인 방법

1. 앱에서 하단 **영화** 탭을 선택합니다.
2. 상단 실험 아이콘을 눌러 Success·Empty·Error·Timeout 상태를 선택합니다.
3. Error 화면에서 **다시 시도**를 누르면 Loading 후 Success 화면으로 복구됩니다.
4. 장르 Chip을 고른 뒤 앱을 재실행하면 선택한 장르가 복원됩니다.
5. Success 목록을 아래로 당기면 새로고침됩니다.

## 비동기 흐름

```text
initState
  └─ _loadInitialData()
      ├─ FakeMovieService.fetchMovies()
      └─ GenrePreference.read()
          ↓ Future.wait
FutureBuilder
  ├─ waiting → MovieListLoading
  ├─ error   → MovieListError
  ├─ empty   → MovieListEmpty
  └─ data    → MovieGrid
```

## 트러블슈팅

- 재현 상태: Error
- 사용한 MovieLoadMode: `MovieLoadMode.failure`
- 기대 결과: 오류 안내와 재시도 버튼 표시
- 실제 결과: 초기 구현에서 Future를 다시 만들지 않으면 같은 오류 상태가 유지됨
- 발생한 Exception: `MovieLoadException`
- Future 생성 위치: `initState`의 `_loadInitialData`, 재시도 callback의 `_reload`
- setState 호출 위치: `_reload`, `_selectGenre`
- mounted 확인 여부: 장르 저장을 await한 뒤 `if (!mounted) return` 확인
- SharedPreferences Key: `selected_genre`
- 수정 내용: 재시도 시 mode를 Success로 바꾸고 `_moviesFuture`에 새 Future 할당
- 재현 및 확인: Error 상태 선택 → 다시 시도 → Skeleton Loading → 영화 Grid 확인

## 검증

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

- `flutter analyze`: No issues found
- `flutter test`: 8 tests passed

실제 API, Dio, Retrofit, Provider는 사용하지 않았습니다.
