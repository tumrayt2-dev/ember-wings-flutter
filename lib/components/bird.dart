import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import 'tree_obstacle.dart';
import 'ground.dart';

class Bird extends PositionComponent with CollisionCallbacks {
  double velocity = 0;
  double _wingAngle = 0;
  bool isDead = false;
  void Function()? onHit;
  Color _bodyColor = GameConfig.birdBody;
  Color _wingColor = GameConfig.birdWing;
  Color _beakColor = const Color(0xFFFF6600);

  void updateColors(Color body, Color wing, Color beak) {
    _bodyColor = body;
    _wingColor = wing;
    _beakColor = beak;
  }

  Bird() : super(
    position: Vector2(GameConfig.birdX, GameConfig.gameHeight / 2),
    size: Vector2(GameConfig.birdSize, GameConfig.birdSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (isDead || !isActive) return;
    if (other is TreeObstacle || other is Ground) {
      onHit?.call();
    }
  }

  void jump() {
    if (isDead) return;
    velocity = GameConfig.jumpForce;
    _wingAngle = -0.5;
  }

  void reset() {
    position = Vector2(GameConfig.birdX, GameConfig.gameHeight / 2);
    velocity = 0;
    angle = 0;
    isDead = false;
    isActive = true;
  }

  bool isActive = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || !isActive) return;

    // Yerçekimi
    velocity += GameConfig.gravity * dt;
    velocity = velocity.clamp(-GameConfig.maxVelocity, GameConfig.maxVelocity);
    position.y += velocity * dt;

    // Kuşun açısı (hıza göre eğilme)
    angle = (velocity / GameConfig.maxVelocity) * 0.8;

    // Kanat animasyonu
    _wingAngle += dt * 12;
    if (_wingAngle > pi * 2) _wingAngle -= pi * 2;

    // Tavan kontrolü
    if (position.y < GameConfig.birdSize / 2) {
      position.y = GameConfig.birdSize / 2;
      velocity = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // Gövde
    final bodyPaint = Paint()..color = _bodyColor;
    canvas.drawCircle(center, radius, bodyPaint);

    // Kanat
    final wingPaint = Paint()..color = _wingColor;
    final wingOffset = sin(_wingAngle) * 4;
    final wingPath = Path()
      ..moveTo(center.dx - 2, center.dy)
      ..lineTo(center.dx - radius - 6, center.dy + wingOffset)
      ..lineTo(center.dx - radius + 2, center.dy + 8)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Göz
    final eyePaint = Paint()..color = GameConfig.birdEye;
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.2),
      3,
      eyePaint,
    );

    // Göz beyazı
    final eyeWhitePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.25),
      1.2,
      eyeWhitePaint,
    );

    // Gaga
    final beakPaint = Paint()..color = _beakColor;
    final beakPath = Path()
      ..moveTo(center.dx + radius, center.dy - 2)
      ..lineTo(center.dx + radius + 10, center.dy + 2)
      ..lineTo(center.dx + radius, center.dy + 4)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }
}
