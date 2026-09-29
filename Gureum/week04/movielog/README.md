# MovieLog 4주차

Mock Future를 이용해 영화 목록의 비동기 상태를 처리하고 마지막 선택 장르를 로컬에 저장하는 프로젝트입니다.

## 구현 내용

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
