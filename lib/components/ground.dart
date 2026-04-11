import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

class Ground extends PositionComponent with CollisionCallbacks, HasGameReference<EmberWingsGame> {
  double _scrollOffset = 0;
  final Random _random = Random(42); // sabit seed = tutarlı desen

  Ground() : super(
    position: Vector2(0, GameConfig.gameHeight - GameConfig.groundHeight),
    size: Vector2(GameConfig.gameWidth, GameConfig.groundHeight),
    priority: 5,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;
    _scrollOffset += game.currentSpeed * dt;
    if (_scrollOffset > 40) _scrollOffset -= 40;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;

    // Ana zemin
    final groundPaint = Paint()..color = biome.groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), groundPaint);

    // Üst kenar - biyoma göre vurgu çizgisi
    final ashPaint = Paint()
      ..color = biome.treeEmber.withValues(alpha: 0.8)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, 2), Offset(size.x, 2), ashPaint);

    // Koyu toprak deseni
    final darkPaint = Paint()..color = biome.groundDark;
    _random.nextInt(1); // seed reset workaround
    final rng = Random(42);
    for (double x = -_scrollOffset; x < size.x + 40; x += 40) {
      for (double y = 10; y < size.y; y += 15) {
        final offset = rng.nextDouble() * 10;
        canvas.drawRect(
          Rect.fromLTWH(x + offset, y, 12 + rng.nextDouble() * 8, 3),
          darkPaint,
        );
      }
    }

    // Kor parçaları (üst kısımda)
    final emberPaint = Paint()..color = biome.treeEmber.withValues(alpha: 0.4);
    final rng2 = Random(123);
    for (double x = -_scrollOffset; x < size.x + 40; x += 60) {
      canvas.drawCircle(
        Offset(x + rng2.nextDouble() * 30, 6 + rng2.nextDouble() * 8),
        1.5 + rng2.nextDouble() * 2,
        emberPaint,
      );
    }
  }
}
