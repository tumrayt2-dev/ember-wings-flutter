import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../game/ember_wings_game.dart';
import 'bird.dart';

class _TrailParticle {
  double x, y, life, size;
  _TrailParticle({required this.x, required this.y, required this.life, required this.size});
}

class BirdTrail extends PositionComponent with HasGameReference<EmberWingsGame> {
  final Bird bird;
  final List<_TrailParticle> _particles = [];
  double _emitTimer = 0;

  BirdTrail({required this.bird}) : super(priority: -1);

  @override
  void update(double dt) {
    super.update(dt);

    if (bird.isActive && !bird.isDead) {
      _emitTimer += dt;
      if (_emitTimer >= 0.03) {
        _emitTimer = 0;
        _particles.add(_TrailParticle(
          x: bird.position.x - 8,
          y: bird.position.y + 2,
          life: 1.0,
          size: 3 + (bird.velocity.abs() / 400) * 2,
        ));
      }
    }

    for (final p in _particles) {
      p.life -= dt * 2.0;
      p.x -= 60 * dt;
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;
    final baseColor = biome.particleColor;

    for (final p in _particles) {
      final paint = Paint()..color = baseColor.withValues(alpha: p.life * 0.6);
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }
}
