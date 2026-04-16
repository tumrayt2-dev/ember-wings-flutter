import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

class Background extends PositionComponent with HasGameReference<EmberWingsGame> {
  final Random _random = Random();
  late List<_Particle> _particles;
  late List<_SmokeCloud> _smokeClouds;

  // Cached Paint nesneleri
  final Paint _skyPaint = Paint();
  final Paint _smokePaint = Paint();
  final Paint _particlePaint = Paint();
  final Paint _flashPaint = Paint();

  // Gradient cache — sadece biyom değişince yeniden oluşturulur
  Color? _cachedSkyTop;
  late Rect _fullRect;

  // Smoke renk cache
  Color? _cachedSmokeColor;

  Background() : super(
    size: Vector2(GameConfig.gameWidth, GameConfig.gameHeight),
    priority: -10,
  );

  @override
  Future<void> onLoad() async {
    _fullRect = Rect.fromLTWH(0, 0, size.x, size.y);

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

    // Gradient shader — sadece biyom değişince yeniden oluştur
    if (_cachedSkyTop != biome.skyTop) {
      _cachedSkyTop = biome.skyTop;
      _skyPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [biome.skyTop, biome.skyBottom, biome.skyAccent],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(_fullRect);

      // Smoke renk de biyomla değişir
      final sa = biome.skyAccent;
      _cachedSmokeColor = Color.fromARGB(64, sa.r.toInt(), sa.g.toInt(), sa.b.toInt());
      _smokePaint.color = _cachedSmokeColor!;
    }

    canvas.drawRect(_fullRect, _skyPaint);

    // Sis/bulut
    for (final cloud in _smokeClouds) {
      canvas.drawCircle(
        Offset(cloud.x, cloud.y),
        cloud.radius,
        _smokePaint,
      );
    }

    // Parçacıklar
    final pc = biome.particleColor;
    final pr = pc.r.toInt();
    final pg = pc.g.toInt();
    final pb = pc.b.toInt();
    for (final p in _particles) {
      _particlePaint.color = Color.fromARGB((p.alpha * 255).toInt(), pr, pg, pb);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        _particlePaint,
      );
    }

    // Biyom geçiş flash'ı
    if (game.biomeFlashTime > 0) {
      final t = game.biomeFlashTime / EmberWingsGame.biomeFlashDuration;
      _flashPaint.color = Color.fromARGB((t * 179).toInt(), 255, 255, 255);
      canvas.drawRect(_fullRect, _flashPaint);
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
