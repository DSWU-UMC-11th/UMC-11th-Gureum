import 'package:shared_preferences/shared_preferences.dart';

abstract interface class GenreStore {
  Future<String> read();
  Future<void> save(String genre);
}

class GenrePreference implements GenreStore {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const selectedGenreKey = 'selected_genre';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String> read() async =>
      await _preferences.getString(selectedGenreKey) ?? '전체';

  @override
  Future<void> save(String genre) async {
    await _preferences.setString(selectedGenreKey, genre);
  }
}
