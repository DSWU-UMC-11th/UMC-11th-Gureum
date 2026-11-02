import '../models/movie.dart';

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    synopsis: '별빛이 쏟아지는 작은 마을에서 다시 만난 두 사람의 따뜻한 이야기.',
  ),
  Movie(
    id: 2,
    title: '심연을 걷는 자',
    genre: '스릴러',
    year: 2025,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    synopsis: '사라진 기억을 따라 심연으로 향하는 긴장감 넘치는 여정.',
  ),
  Movie(
    id: 3,
    title: '공허의 메아리',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    synopsis: '우주 끝에서 들려온 신호가 인류의 운명을 바꾼다.',
  ),
  Movie(
    id: 4,
    title: '네 번째 오후',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    synopsis: '반복되는 오후 속에서 찾아낸 소중한 선택의 순간.',
  ),
  Movie(
    id: 5,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2025,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    synopsis: '도시의 밤을 뒤덮은 비밀을 쫓는 추적극.',
  ),
  Movie(
    id: 6,
    title: '속삭이는 숲',
    genre: '애니메이션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    synopsis: '숲의 목소리를 듣는 아이와 신비한 친구들의 모험.',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
