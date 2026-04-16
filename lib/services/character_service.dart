import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_character.dart';

class CharacterService {
  static const _selectedKey = 'selected_character';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  CharacterId getSelectedCharacter() {
    final name = _prefs.getString(_selectedKey);
    if (name == null) return CharacterId.phoenix;
    return CharacterId.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CharacterId.phoenix,
    );
  }

  Future<void> setSelectedCharacter(CharacterId id) async {
    await _prefs.setString(_selectedKey, id.name);
  }
}
