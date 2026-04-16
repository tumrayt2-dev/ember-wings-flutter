import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale { tr, en }

class LocaleService extends ChangeNotifier {
  static const _key = 'app_locale';
  late SharedPreferences _prefs;
  AppLocale _locale = AppLocale.tr;

  AppLocale get locale => _locale;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getString(_key);
    if (saved == 'en') _locale = AppLocale.en;
  }

  Future<void> setLocale(AppLocale locale) async {
    _locale = locale;
    await _prefs.setString(_key, locale.name);
    notifyListeners();
  }

  String get(String key) => _strings[_locale]?[key] ?? _strings[AppLocale.tr]?[key] ?? key;

  static const Map<AppLocale, Map<String, String>> _strings = {
    AppLocale.tr: {
      // Ana menü
      'appTitle': 'EMBER WINGS',
      'bestScore': 'En İyi',
      'start': 'BAŞLA',
      'tryPlay': 'DENE',
      'unlock': 'KİLİDİ AÇ',
      'leaderboard': 'SIRALAMA',
      'settings': 'AYARLAR',

      // Durum chip'leri
      'gamesRemaining': '{n} oyun hakkın var',
      'watchVideoEarn': 'Video izle, 3 oyun hakkı kazan',

      // Popup
      'tryRemaining': 'Dene — {n} hak kaldı',
      'watchVideo3Games': 'Video İzle — 3 Oyun Hakkı',
      'watchVideoRemaining': 'Video İzle — 3 Oyun Hakkı ({n} kaldı)',
      'hourlyLimitReached': 'Saatlik video limitine ulaştın',
      'buyCharacter': 'Satın Al — {price}',
      'buyAll': 'Tümünü Al — {price}',

      // Game Over
      'gameOver': 'YANDIN!',
      'score': 'Skor',
      'newRecord': 'YENİ REKOR!',
      'revive': 'Canlan',
      'reviveVideo': 'Canlan — Video İzle ({n})',
      'reviveRemaining': 'Canlan ({n})',
      'adFree': 'Reklamsız Oyna — {price}',
      'retry': 'TEKRAR DENE',
      'tryN': 'DENE ({n})',
      'mainMenu': 'ANA MENÜ',

      // Pause
      'paused': 'DURAKLATILDI',
      'resume': 'DEVAM ET',

      // Continue overlay
      'getReady': 'HAZIR OL!',
      'continueGame': 'DEVAM ET',

      // Karakter açıklamaları
      'desc_phoenix':    'Ateş kuşu — yanan ormandan kaçar',
      'desc_kingfisher': 'Su kuşu — bataklıktan geçer',
      'desc_frostBird':  'Buz kuşu — kış ormanından kaçar',
      'desc_shadow':     'Gölge kuşu — gece ormanında süzülür',

      // Biyomlar
      'biomeFire': 'ALEV',
      'biomeWater': 'BATAKLIK',
      'biomeIce': 'BUZUL',
      'biomeNight': 'GECE',

      // Ayarlar
      'sound': 'Ses',
      'language': 'Dil',
      'soundOn': 'Açık',
      'soundOff': 'Kapalı',
      'turkish': 'Türkçe',
      'english': 'English',
    },
    AppLocale.en: {
      // Main menu
      'appTitle': 'EMBER WINGS',
      'bestScore': 'Best',
      'start': 'START',
      'tryPlay': 'TRY',
      'unlock': 'UNLOCK',
      'leaderboard': 'LEADERBOARD',
      'settings': 'SETTINGS',

      // Status chips
      'gamesRemaining': '{n} games left',
      'watchVideoEarn': 'Watch video, earn 3 games',

      // Popup
      'tryRemaining': 'Try — {n} left',
      'watchVideo3Games': 'Watch Video — 3 Games',
      'watchVideoRemaining': 'Watch Video — 3 Games ({n} left)',
      'hourlyLimitReached': 'Hourly video limit reached',
      'buyCharacter': 'Buy — {price}',
      'buyAll': 'Buy All — {price}',

      // Game Over
      'gameOver': 'GAME OVER!',
      'score': 'Score',
      'newRecord': 'NEW RECORD!',
      'revive': 'Revive',
      'reviveVideo': 'Revive — Watch Video ({n})',
      'reviveRemaining': 'Revive ({n})',
      'adFree': 'Ad-Free — {price}',
      'retry': 'RETRY',
      'tryN': 'TRY ({n})',
      'mainMenu': 'MAIN MENU',

      // Pause
      'paused': 'PAUSED',
      'resume': 'RESUME',

      // Continue overlay
      'getReady': 'GET READY!',
      'continueGame': 'CONTINUE',

      // Character descriptions
      'desc_phoenix':    'Fire bird — escapes the burning forest',
      'desc_kingfisher': 'Water bird — glides through the swamp',
      'desc_frostBird':  'Frost bird — escapes the frozen forest',
      'desc_shadow':     'Shadow bird — soars through the night forest',

      // Biomes
      'biomeFire': 'FIRE',
      'biomeWater': 'SWAMP',
      'biomeIce': 'GLACIER',
      'biomeNight': 'NIGHT',

      // Settings
      'sound': 'Sound',
      'language': 'Language',
      'soundOn': 'On',
      'soundOff': 'Off',
      'turkish': 'Türkçe',
      'english': 'English',
    },
  };
}
