import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../game/ember_wings_game.dart';
import 'bird.dart';

class _TrailParticle {
  double x = 0, y = 0, life = 0, size = 0;
  bool active = false;
}

class BirdTrail extends PositionComponent with HasGameReference<EmberWingsGame> {
  final Bird bird;
  double _emitTimer = 0;
  final Paint _trailPaint = Paint();

  // Object pool — sabit boyutlu, allocation yok
  static const int _maxParticles = 40;
  final List<_TrailParticle> _pool = List.generate(_maxParticles, (_) => _TrailParticle());

  BirdTrail({required this.bird}) : super(priority: -1);

  @override
  void update(double dt) {
    super.update(dt);

    if (bird.isActive && !bird.isDead) {
      _emitTimer += dt;
      if (_emitTimer >= 0.03) {
        _emitTimer = 0;
        _emit();
      }
    }

    for (final p in _pool) {
      if (!p.active) continue;
      p.life -= dt * 2.0;
      p.x -= 60 * dt;
      if (p.life <= 0) p.active = false;
    }
  }

  void _emit() {
    // Havuzda boş slot bul
    for (final p in _pool) {
      if (!p.active) {
        p.x = bird.position.x - 8;
        p.y = bird.position.y + 2;
        p.life = 1.0;
        p.size = 3 + (bird.velocity.abs() / 400) * 2;
        p.active = true;
        return;
      }
    }
    // Havuz doluysa en eski (en düşük life) olanı geri dönüştür
    var oldest = _pool[0];
    for (final p in _pool) {
      if (p.life < oldest.life) oldest = p;
    }
    oldest.x = bird.position.x - 8;
    oldest.y = bird.position.y + 2;
    oldest.life = 1.0;
    oldest.size = 3 + (bird.velocity.abs() / 400) * 2;
    oldest.active = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final baseColor = game.activeBiome.particleColor;
    final r = baseColor.r.toInt();
    final g = baseColor.g.toInt();
    final b = baseColor.b.toInt();

    for (final p in _pool) {
      if (!p.active) continue;
      _trailPaint.color = Color.fromARGB((p.life * 153).toInt(), r, g, b);
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, _trailPaint);
    }
  }
}
