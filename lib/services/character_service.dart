import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_character.dart';
import '../config/monetization_config.dart';

class CharacterService {
  static const _selectedKey = 'selected_character';
  static const _ownedPrefix = 'owned_';
  static const _trialPrefix = 'trial_remaining_';
  static const _sessionPrefix = 'session_remaining_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Seçili karakter
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

  // Sahiplik kontrolü
  bool isOwned(CharacterId id) {
    final character = GameCharacter.getById(id);
    if (character.isFree) return true;
    return _prefs.getBool('$_ownedPrefix${id.name}') ?? false;
  }

  Future<void> setOwned(CharacterId id) async {
    await _prefs.setBool('$_ownedPrefix${id.name}', true);
  }

  Future<void> setAllOwned() async {
    for (final c in GameCharacter.all) {
      if (!c.isFree) {
        await setOwned(c.id);
      }
    }
  }

  // Ücretsiz deneme hakkı
  int getTrialRemaining(CharacterId id) {
    return _prefs.getInt('$_trialPrefix${id.name}') ??
        MonetizationConfig.freeTrialGamesPerCharacter;
  }

  Future<void> useTrialGame(CharacterId id) async {
    final remaining = getTrialRemaining(id);
    if (remaining > 0) {
      await _prefs.setInt('$_trialPrefix${id.name}', remaining - 1);
    }
  }

  // Video ile kazanılan seans hakkı
  int getSessionRemaining(CharacterId id) {
    return _prefs.getInt('$_sessionPrefix${id.name}') ?? 0;
  }

  Future<void> addSessionGames(CharacterId id) async {
    final current = getSessionRemaining(id);
    await _prefs.setInt(
      '$_sessionPrefix${id.name}',
      current + MonetizationConfig.gamesPerVideoReward,
    );
  }

  Future<void> useSessionGame(CharacterId id) async {
    final remaining = getSessionRemaining(id);
    if (remaining > 0) {
      await _prefs.setInt('$_sessionPrefix${id.name}', remaining - 1);
    }
  }

  // Karakter oynayabilir mi?
  bool canPlay(CharacterId id) {
    if (isOwned(id)) return true;
    if (getTrialRemaining(id) > 0) return true;
    if (getSessionRemaining(id) > 0) return true;
    return false;
  }

  // Bir oyun hakkı kullan (otomatik olarak doğru kaynaktan düşer)
  Future<void> consumeOneGame(CharacterId id) async {
    if (isOwned(id)) return; // sahipse düşme
    if (getTrialRemaining(id) > 0) {
      await useTrialGame(id);
    } else if (getSessionRemaining(id) > 0) {
      await useSessionGame(id);
    }
  }

  // Kalan toplam hak
  int getTotalRemainingGames(CharacterId id) {
    if (isOwned(id)) return -1; // sınırsız
    return getTrialRemaining(id) + getSessionRemaining(id);
  }
}
