import 'dart:math';
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
import '../services/purchase_service.dart';
import '../services/ad_service.dart';
import '../services/score_service.dart';
import '../services/leaderboard_service.dart';
import '../services/audio_service.dart';
import '../services/analytics_service.dart';

enum GameState { menu, playing, paused, gameOver }

class EmberWingsGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Bird bird;
  late Ground ground;
  late ScoreDisplay scoreDisplay;
  final Random _random = Random();
  final CharacterService characterService = CharacterService();
  late final PurchaseService purchaseService;
  late final AdService adService;
  final ScoreService scoreService = ScoreService();
  final LeaderboardService leaderboardService = LeaderboardService();
  final AudioService audioService = AudioService();
  final AnalyticsService analyticsService = AnalyticsService();

  GameState state = GameState.menu;
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

  @override
  Future<void> onLoad() async {
    await characterService.init();
    purchaseService = PurchaseService(characterService);
    await purchaseService.init();
    adService = AdService();
    await adService.init();
    await scoreService.init();
    await leaderboardService.init();
    await audioService.init();
    analyticsService.init();
    purchaseService.onPurchased = (productId) =>
        analyticsService.logPurchase(productId);

    camera.viewfinder.visibleGameSize = Vector2(GameConfig.gameWidth, GameConfig.gameHeight);
    camera.viewfinder.position = Vector2(GameConfig.gameWidth / 2, GameConfig.gameHeight / 2);
    camera.viewfinder.anchor = Anchor.center;

    // Arka plan
    world.add(Background());

    // Zemin
    ground = Ground();
    world.add(ground);

    // Kuş
    bird = Bird();
    bird.onHit = _gameOver;
    world.add(bird);
    world.add(BirdTrail(bird: bird));

    // Skor
    scoreDisplay = ScoreDisplay();
    scoreDisplay.position = Vector2(GameConfig.gameWidth / 2, 50);
    world.add(scoreDisplay);

    // Menü overlay
    overlays.add('menu');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (biomeFlashTime > 0) {
      biomeFlashTime -= dt;
      if (biomeFlashTime < 0) biomeFlashTime = 0;
    }

    if (state != GameState.playing) return;

    // Ağaç spawn
    _treeSpawnTimer += dt;
    if (_treeSpawnTimer >= currentSpawnInterval) {
      _treeSpawnTimer = 0;
      _spawnTree();
    }

    // Skor kontrolü
    _checkScore();
  }

  /// Skora göre dinamik hız — her 5 skorda %5 artar, maks %50 artış
  double get currentSpeed {
    final multiplier = 1.0 + (scoreDisplay.score ~/ 5) * 0.05;
    return GameConfig.treeSpeed * multiplier.clamp(1.0, 1.5);
  }

  /// Skora göre dinamik spawn aralığı — hız arttıkça kısalır
  double get currentSpawnInterval {
    final multiplier = 1.0 - (scoreDisplay.score ~/ 5) * 0.04;
    return GameConfig.treeSpawnInterval * multiplier.clamp(0.65, 1.0);
  }

  void _spawnTree() {
    _spawnTreeAt(GameConfig.gameWidth + 20);
  }

  void _spawnTreeAt(double x) {
    final minCenter = GameConfig.minTreeHeight + GameConfig.treeGap / 2;
    final maxCenter = GameConfig.gameHeight - GameConfig.groundHeight - GameConfig.minTreeHeight - GameConfig.treeGap / 2;
    final gapCenter = minCenter + _random.nextDouble() * (maxCenter - minCenter);

    world.add(TreePair(
      gapCenter: gapCenter,
      x: x,
    ));
  }

  void _checkScore() {
    final trees = world.children.whereType<TreePair>();
    for (final tree in trees) {
      if (!tree.scored && tree.obstacles.isNotEmpty) {
        final firstObstacle = tree.obstacles.first;
        if (firstObstacle.position.x + GameConfig.treeWidth < bird.position.x) {
          tree.scored = true;
          scoreDisplay.increment();
          audioService.playScore();
        }
      }
    }
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
    state = GameState.menu;
    bird.isActive = false;
    bird.reset();
    overlays.remove('pause');
    overlays.remove('gameOver');
    overlays.remove('hud');
    // Ağaçları temizle
    world.children.whereType<TreePair>().toList().forEach((t) => t.removeFromParent());
    overlays.add('menu');
  }

  bool get canContinue => purchaseService.isAdFree || _continueCount < maxContinuesPerGame;
  int get continuesRemaining => maxContinuesPerGame - _continueCount;

  void continueGame() {
    if (!canContinue) return;
    if (!purchaseService.isAdFree) {
      _continueCount++;
    }
    analyticsService.logContinue(scoreDisplay.score);

    // Kuşu güvenli pozisyona taşı
    bird.isDead = false;
    bird.isActive = true;
    bird.velocity = 0;
    bird.position.y = GameConfig.gameHeight / 2;

    // Yakın engelleri temizle (kuşun etrafındakiler)
    final nearTrees = world.children.whereType<TreePair>().where((t) {
      if (t.obstacles.isEmpty) return false;
      final x = t.obstacles.first.position.x;
      return x > bird.position.x - 80 && x < bird.position.x + 120;
    }).toList();
    for (final t in nearTrees) {
      t.removeFromParent();
    }

    state = GameState.playing;
    overlays.remove('gameOver');
    if (!overlays.isActive('hud')) {
      overlays.add('hud');
    }
  }

  void _gameOver() async {
    if (state != GameState.playing) return;
    state = GameState.gameOver;
    bird.isDead = true;
    bird.isActive = false;
    audioService.playHit();
    isNewHighScore = await scoreService.submitScore(scoreDisplay.score);
    leaderboardService.submitScore(scoreDisplay.score);
    analyticsService.logGameOver(scoreDisplay.score, isNewHighScore, _activeCharacterId.name);
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  void startGame() {
    // Seçili karakteri al ve uygula
    _activeCharacterId = characterService.getSelectedCharacter();
    final character = GameCharacter.getById(_activeCharacterId);

    // Oynayabilir mi kontrol et
    if (!characterService.canPlay(_activeCharacterId)) {
      return;
    }

    // Hak düş
    characterService.consumeOneGame(_activeCharacterId);

    // Kuş renklerini güncelle
    bird.updateColors(character.bodyColor, character.wingColor, character.beakColor);

    // Aktif biyomu güncelle + geçiş flash'ı tetikle
    activeBiome = character.biomeColors;
    activeBiomeName = character.biome;
    biomeFlashTime = biomeFlashDuration;

    analyticsService.logGameStart(_activeCharacterId.name, character.biome);

    state = GameState.playing;
    overlays.remove('menu');
    overlays.remove('gameOver');
    overlays.remove('pause');
    if (!overlays.isActive('hud')) {
      overlays.add('hud');
    }
    bird.reset();
    scoreDisplay.reset();
    _continueCount = 0;
    isNewHighScore = false;

    // Mevcut ağaçları temizle
    world.children.whereType<TreePair>().toList().forEach((t) => t.removeFromParent());

    // İlk ağaçları eşit aralıkla yerleştir
    _treeSpawnTimer = 0;
    _spawnTreeAt(GameConfig.gameWidth * 0.65);
    _spawnTreeAt(GameConfig.gameWidth * 1.2);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == GameState.playing) {
      bird.jump();
      audioService.playJump();
    }
  }
}
