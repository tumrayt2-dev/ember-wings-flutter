import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

class Background extends PositionComponent with HasGameReference<EmberWingsGame> {
  final Random _random = Random();
  late List<_Particle> _particles;
  late List<_SmokeCloud> _smokeClouds;

  Background() : super(
    size: Vector2(GameConfig.gameWidth, GameConfig.gameHeight),
    priority: -10,
  );

  @override
  Future<void> onLoad() async {
    _particles = List.generate(20, (_) => _Particle(
      x: _random.nextDouble() * GameConfig.gameWidth,
      y: _random.nextDouble() * GameConfig.gameHeight,
      size: 1 + _random.nextDouble() * 3,
      speed: 20 + _random.nextDouble() * 40,
      drift: -10 + _random.nextDouble() * 20,
      alpha: 0.3 + _random.nextDouble() * 0.7,
    ));

    _smokeClouds = List.generate(5, (_) => _SmokeCloud(
      x: _random.nextDouble() * GameConfig.gameWidth,
      y: _random.nextDouble() * (GameConfig.gameHeight * 0.4),
      radius: 30 + _random.nextDouble() * 50,
      speed: 10 + _random.nextDouble() * 20,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final p in _particles) {
      p.y -= p.speed * dt;
      p.x += p.drift * dt;
      p.alpha -= dt * 0.3;

      if (p.y < -10 || p.alpha <= 0) {
        p.x = _random.nextDouble() * GameConfig.gameWidth;
        p.y = GameConfig.gameHeight + _random.nextDouble() * 20;
        p.alpha = 0.3 + _random.nextDouble() * 0.7;
      }
    }

    for (final cloud in _smokeClouds) {
      cloud.x -= cloud.speed * dt;
      if (cloud.x < -cloud.radius * 2) {
        cloud.x = GameConfig.gameWidth + cloud.radius;
        cloud.y = _random.nextDouble() * (GameConfig.gameHeight * 0.3);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;

    // Biyoma göre gradyan gökyüzü
    final skyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [biome.skyTop, biome.skyBottom, biome.skyAccent],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyGradient);

    // Sis/bulut (biyoma göre ton)
    for (final cloud in _smokeClouds) {
      final smokePaint = Paint()
        ..color = biome.skyAccent.withValues(alpha: 0.25);
      canvas.drawCircle(
        Offset(cloud.x, cloud.y),
        cloud.radius,
        smokePaint,
      );
    }

    // Parçacıklar (biyoma göre: kıvılcım, su damlası, kar, yıldız)
    for (final p in _particles) {
      final particlePaint = Paint()
        ..color = biome.particleColor.withValues(alpha: p.alpha);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        particlePaint,
      );
    }

    // Biyom geçiş flash'ı — beyaz overlay fade out
    if (game.biomeFlashTime > 0) {
      final t = game.biomeFlashTime / EmberWingsGame.biomeFlashDuration;
      final flashPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: t * 0.7);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), flashPaint);
    }
  }
}

class _Particle {
  double x, y, size, speed, drift, alpha;
  _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.drift, required this.alpha,
  });
}

class _SmokeCloud {
  double x, y, radius, speed;
  _SmokeCloud({
    required this.x, required this.y,
    required this.radius, required this.speed,
  });
}
