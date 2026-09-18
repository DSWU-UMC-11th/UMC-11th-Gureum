# MovieLog

UMC Flutter 0주차 개발 환경 및 Dart 기초 실습 프로젝트입니다.

## 구현 내용

- Flutter 앱을 생성하고 Android Emulator에서 실행했습니다.
- 앱 첫 화면 중앙에 `Hello MovieLog!` 문구를 표시했습니다.
- Hot Reload로 코드 변경이 실행 중인 앱에 반영되는 것을 확인했습니다.
- `Movie` 모델을 만들고 생성자, getter, `copyWith`를 연습했습니다.
- 영화 목록을 필터링하고 평균 평점을 계산하며 Dart 컬렉션 API를 연습했습니다.

## 프로젝트 구조

```text
lib/
├─ main.dart
├─ models/
│  └─ movie.dart
└─ practice/
   └─ movie_practice.dart
```

## 실행 방법

프로젝트 루트에서 다음 명령을 실행합니다.

```powershell
flutter pub get
flutter analyze
flutter run
```

앱 실행 중 `lib/main.dart`를 수정한 뒤 터미널에서 `r`을 입력하면 Hot Reload가 실행됩니다.
