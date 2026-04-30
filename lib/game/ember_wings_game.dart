import 'dart:math';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../components/bird.dart';
import '../components/bird_trail.dart';
import '../components/tree_obstacle.dart';
import '../components/background.dart';
import '../components/ground.dart';
import '../components/score_display.dart';
import '../config/game_config.dart';
import '../models/game_character.dart';
import '../services/character_service.dart';
import '../services/ad_service.dart';
import '../services/score_service.dart';
import '../services/leaderboard_service.dart';
import '../services/audio_service.dart';
import '../services/analytics_service.dart';
import '../services/locale_service.dart';

enum GameState { menu, playing, paused, gameOver, waitingContinue }

enum GameMode { klasik, challenge }

class EmberWingsGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Bird bird;
  late Ground ground;
  late ScoreDisplay scoreDisplay;
  final Random _random = Random();
  final CharacterService characterService = CharacterService();
  final AdService adService = AdService();
  final ScoreService scoreService = ScoreService();
  final LeaderboardService leaderboardService = LeaderboardService();
  final AudioService audioService = AudioService();
  final AnalyticsService analyticsService = AnalyticsService();
  final LocaleService localeService = LocaleService();

  final ValueNotifier<bool> showBanner = ValueNotifier(true);

  GameState _state = GameState.menu;
  GameState get state => _state;
  set state(GameState value) {
    _state = value;
    showBanner.value = value == GameState.menu ||
                       value == GameState.gameOver ||
                       value == GameState.paused;
  }
  double _treeSpawnTimer = 0;
  bool soundEnabled = true;
  CharacterId _activeCharacterId = CharacterId.phoenix;
  BiomeColors activeBiome = GameCharacter.all.first.biomeColors;
  String activeBiomeName = GameCharacter.all.first.biome;
  double biomeFlashTime = 0;
  static const double biomeFlashDuration = 0.5;
  int _continueCount = 0;
  bool isNewHighScore = false;
  static const int maxContinuesPerGame = 2;
  final List<TreePair> _activeTreePairs = [];
  double _scoreSoundCooldown = 0;

  // Ters yer çekimi sistemi
  bool reverseGravityEnabled = false;  // kullanıcı tercihi (kalıcı)
  bool isGravityReversed = false;       // şu anki oyun durumu
  double _gravityFlipTimer = 0;         // bir sonraki flip için geri sayım
  double _postFlipNoSpawnTimer = 0;     // flip sonrası ağaç spawn yasağı
  static const double _warningDuration = 3.0;
  // Normal modda kalma süresi (uzun rahat)
  static const double _minNormalInterval = 30.0;
  static const double _maxNormalInterval = 45.0;
  // Ters modda kalma süresi (kısa zorlu)
  static const double _minReverseInterval = 15.0;
  static const double _maxReverseInterval = 20.0;
  static const double _postFlipNoSpawnDuration = 1.0;
  // Uyarı bildirici — UI bunu dinler
  final ValueNotifier<int> flipWarningSession = ValueNotifier(0);
  bool _wasFlipWarning = false;

  // Mod sistemi
  GameMode currentMode = GameMode.klasik;

  // Karma harita sistemi
  bool karmaMapEnabled = false;          // klasik modda kullanıcı tercihi
  static const int _biomeChangeInterval = 12; // her 12 ağaçta bir biyom değişir
  int _scoresSinceBiomeChange = 0;

  @override
  Future<void> onLoad() async {
    await characterService.init();
    await adService.init();
    await scoreService.init();
    await leaderboardService.init();
    await audioService.init();
    await localeService.init();
    analyticsService.init();

    camera.viewfinder.visibleGameSize = Vector2(GameConfig.gameWidth, GameConfig.gameHeight);
    camera.viewfinder.position = Vector2(GameConfig.gameWidth / 2, GameConfig.gameHeight / 2);
    camera.viewfinder.anchor = Anchor.center;

    world.add(Background());

    ground = Ground();
    world.add(ground);

    bird = Bird();
    bird.onHit = _gameOver;
    world.add(bird);
    world.add(BirdTrail(bird: bird));

    scoreDisplay = ScoreDisplay();
    scoreDisplay.position = Vector2(GameConfig.gameWidth / 2, 50);
    world.add(scoreDisplay);

    overlays.add('menu');
  }

  @override
  void update(double dt) {
    // dt spike'larını önle
    final clampedDt = dt.clamp(0.0, 0.05);
    super.update(clampedDt);

    if (biomeFlashTime > 0) {
      biomeFlashTime -= clampedDt;
      if (biomeFlashTime < 0) biomeFlashTime = 0;
    }

    if (state != GameState.playing) return;

    if (_scoreSoundCooldown > 0) _scoreSoundCooldown -= clampedDt;

    _updateGravityFlip(clampedDt);

    _treeSpawnTimer += clampedDt;
    if (_treeSpawnTimer >= currentSpawnInterval && _postFlipNoSpawnTimer <= 0) {
      _treeSpawnTimer = 0;
      _spawnTree();
    }

    _checkScore();
  }

  void _updateGravityFlip(double dt) {
    if (_postFlipNoSpawnTimer > 0) _postFlipNoSpawnTimer -= dt;
    if (!reverseGravityEnabled) return;

    _gravityFlipTimer -= dt;

    final isWarning = _gravityFlipTimer <= _warningDuration && _gravityFlipTimer > 0;

    // Yeni uyarı tetiklendi
    if (isWarning && !_wasFlipWarning) {
      audioService.playButton();
      HapticFeedback.lightImpact(); // uyarı başlangıcı
      flipWarningSession.value = flipWarningSession.value + 1;
    }
    _wasFlipWarning = isWarning;

    // Flip
    if (_gravityFlipTimer <= 0) {
      isGravityReversed = !isGravityReversed;
      _gravityFlipTimer = _nextFlipInterval();
      audioService.playScore();
      HapticFeedback.mediumImpact(); // flip anı
      _onGravityFlipped();
    }
  }

  double _nextFlipInterval() {
    // Şu an ters moddaysak → kısa kal, sonra normale dön
    // Şu an normal moddaysak → uzun kal, sonra terse dön
    if (isGravityReversed) {
      return _minReverseInterval + _random.nextDouble() * (_maxReverseInterval - _minReverseInterval);
    } else {
      return _minNormalInterval + _random.nextDouble() * (_maxNormalInterval - _minNormalInterval);
    }
  }

  void _onGravityFlipped() {
    // Bird velocity sıfırla — temiz başlangıç
    bird.velocity = 0;

    // Bird'ün önündeki TÜM ağaçları temizle (ekran boş olur)
    final bx = bird.position.x;
    _activeTreePairs.removeWhere((tree) {
      if (tree.obstacles.isEmpty) return true;
      final tx = tree.obstacles.first.position.x;
      if (tx > bx - 50) {
        tree.removeFromParent();
        return true;
      }
      return false;
    });

    // 1.5 saniye boyunca yeni ağaç spawn etme
    _postFlipNoSpawnTimer = _postFlipNoSpawnDuration;
    _treeSpawnTimer = 0;
  }

  double get currentSpeed {
    final multiplier = 1.0 + (scoreDisplay.score ~/ 5) * 0.05;
    return GameConfig.treeSpeed * multiplier.clamp(1.0, 1.5);
  }

  double get currentSpawnInterval {
    final multiplier = 1.0 - (scoreDisplay.score ~/ 5) * 0.04;
    return GameConfig.treeSpawnInterval * multiplier.clamp(0.65, 1.0);
  }

  void _spawnTree() => _spawnTreeAt(GameConfig.gameWidth + 20);

  double? _lastGapCenter;
  static const double _maxGapShift = 120;

  void _spawnTreeAt(double x) {
    final minCenter = GameConfig.minTreeHeight + GameConfig.treeGap / 2;
    final maxCenter = GameConfig.gameHeight - GameConfig.groundHeight - GameConfig.minTreeHeight - GameConfig.treeGap / 2;

    double lo = minCenter;
    double hi = maxCenter;
    if (_lastGapCenter != null) {
      lo = (_lastGapCenter! - _maxGapShift).clamp(minCenter, maxCenter);
      hi = (_lastGapCenter! + _maxGapShift).clamp(minCenter, maxCenter);
    }
    final gapCenter = lo + _random.nextDouble() * (hi - lo);
    _lastGapCenter = gapCenter;

    // Her ağaç şu anki biyom bilgisiyle spawn edilir — karma modda biyom değişse bile
    // mevcut ağaçlar görüntüsünü korur, yeni ağaçlar yeni biyomda gelir.
    final pair = TreePair(
      gapCenter: gapCenter,
      x: x,
      biomeName: activeBiomeName,
      biomeColors: activeBiome,
    );
    _activeTreePairs.add(pair);
    world.add(pair);
  }

  void _checkScore() {
    _activeTreePairs.removeWhere((tree) {
      if (tree.obstacles.isEmpty) return true;
      final firstObstacle = tree.obstacles.first;
      if (firstObstacle.position.x + GameConfig.treeWidth < bird.position.x) {
        tree.scored = true;
        scoreDisplay.increment();
        if (_scoreSoundCooldown <= 0) {
          audioService.playScore();
          _scoreSoundCooldown = 0.12;
        }
        // Karma harita: belirli sayıda ağaç sonra biyom değişir
        if (karmaMapEnabled) {
          _scoresSinceBiomeChange++;
          if (_scoresSinceBiomeChange >= _biomeChangeInterval) {
            _scoresSinceBiomeChange = 0;
            _changeToRandomBiome();
          }
        }
        return true;
      }
      return false;
    });
  }

  void _changeToRandomBiome() {
    // Mevcut biyomdan farklı bir biyom seç
    final candidates = GameCharacter.all
        .where((c) => c.biome != activeBiomeName)
        .toList();
    if (candidates.isEmpty) return;
    final picked = candidates[_random.nextInt(candidates.length)];
    activeBiome = picked.biomeColors;
    activeBiomeName = picked.biome;
    biomeFlashTime = biomeFlashDuration;
  }

  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    pauseEngine();
    overlays.add('pause');
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    resumeEngine();
    overlays.remove('pause');
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
    audioService.toggle();
  }

  void goToMenu() {
    if (paused) resumeEngine();
    state = GameState.menu;
    bird.isActive = false;
    bird.reset();
    overlays.remove('pause');
    overlays.remove('gameOver');
    overlays.remove('continue');
    overlays.remove('hud');
    _activeTreePairs.clear();
    world.children.whereType<TreePair>().toList().forEach((t) => t.removeFromParent());
    overlays.add('menu');
  }

  bool get canContinue => _continueCount < maxContinuesPerGame;
  int get continuesRemaining => maxContinuesPerGame - _continueCount;

  void prepareContinue() {
    if (!canContinue) return;
    _continueCount++;
    analyticsService.logContinue(scoreDisplay.score);

    state = GameState.waitingContinue;
    pauseEngine();

    bird.isDead = false;
    bird.velocity = 0;
    bird.position.y = GameConfig.gameHeight / 2;

    final nearTrees = world.children.whereType<TreePair>().where((t) {
      if (t.obstacles.isEmpty) return false;
      final x = t.obstacles.first.position.x;
      return x > bird.position.x - 80 && x < bird.position.x + 120;
    }).toList();
    for (final t in nearTrees) {
      _activeTreePairs.remove(t);
      t.removeFromParent();
    }

    overlays.remove('gameOver');
    overlays.add('continue');
  }

  void executeContinue() {
    if (state != GameState.waitingContinue) return;
    bird.isActive = true;
    state = GameState.playing;
    resumeEngine();
    overlays.remove('continue');
    if (!overlays.isActive('hud')) overlays.add('hud');
  }

  ScoreMode get _scoreMode =>
      currentMode == GameMode.challenge ? ScoreMode.challenge : ScoreMode.klasik;

  void _gameOver() async {
    if (state != GameState.playing) return;
    state = GameState.gameOver;
    bird.isDead = true;
    bird.isActive = false;
    audioService.playHit();
    HapticFeedback.heavyImpact(); // ölüm anı
    isNewHighScore = await scoreService.submitScore(scoreDisplay.score, mode: _scoreMode);
    leaderboardService.submitScore(scoreDisplay.score, mode: _scoreMode);
    analyticsService.logGameOver(scoreDisplay.score, isNewHighScore, _activeCharacterId.name);
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  void startGame({GameMode mode = GameMode.klasik}) {
    currentMode = mode;
    _activeCharacterId = characterService.getSelectedCharacter();
    final character = GameCharacter.getById(_activeCharacterId);

    bird.updateColors(character.bodyColor, character.wingColor, character.beakColor);
    activeBiome = character.biomeColors;
    activeBiomeName = character.biome;
    biomeFlashTime = biomeFlashDuration;

    analyticsService.logGameStart(_activeCharacterId.name, character.biome);

    state = GameState.playing;
    overlays.remove('menu');
    overlays.remove('gameOver');
    overlays.remove('pause');
    if (!overlays.isActive('hud')) overlays.add('hud');

    bird.reset();
    scoreDisplay.reset();
    _continueCount = 0;
    isNewHighScore = false;

    _activeTreePairs.clear();
    world.children.whereType<TreePair>().toList().forEach((t) => t.removeFromParent());

    _lastGapCenter = null;
    _treeSpawnTimer = currentSpawnInterval - 0.3;
    _scoreSoundCooldown = 0;

    // Mod ayarları — Challenge'da hepsi zorla aktif, Klasik'te kullanıcı tercihleri
    if (mode == GameMode.challenge) {
      reverseGravityEnabled = true;
      karmaMapEnabled = true;
    } else {
      reverseGravityEnabled = characterService.getReverseGravityEnabled();
      karmaMapEnabled = characterService.getKarmaMapEnabled();
    }

    // Ters yer çekimi state reset
    isGravityReversed = false;
    _wasFlipWarning = false;
    _postFlipNoSpawnTimer = 0;
    flipWarningSession.value = 0;
    _gravityFlipTimer = reverseGravityEnabled ? _nextFlipInterval() : 0;

    // Karma harita state reset
    _scoresSinceBiomeChange = 0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == GameState.playing) {
      bird.jump();
      audioService.playJump();
    }
  }
}
