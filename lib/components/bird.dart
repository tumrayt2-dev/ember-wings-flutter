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

  // Cached Paint nesneleri — her frame yeniden oluşturulmaz
  final Paint _bodyPaint = Paint();
  final Paint _wingPaint = Paint();
  final Paint _eyePaint = Paint()..color = GameConfig.birdEye;
  final Paint _eyeWhitePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _beakPaint = Paint();
  final Path _wingPath = Path();
  final Path _beakPath = Path();

  void updateColors(Color body, Color wing, Color beak) {
    _bodyPaint.color = body;
    _wingPaint.color = wing;
    _beakPaint.color = beak;
  }

  Bird() : super(
    position: Vector2(GameConfig.birdX, GameConfig.gameHeight / 2),
    size: Vector2(GameConfig.birdSize, GameConfig.birdSize),
    anchor: Anchor.center,
  ) {
    _bodyPaint.color = GameConfig.birdBody;
    _wingPaint.color = GameConfig.birdWing;
    _beakPaint.color = const Color(0xFFFF6600);
  }

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
    canvas.drawCircle(center, radius, _bodyPaint);

    // Kanat
    final wingOffset = sin(_wingAngle) * 4;
    _wingPath.reset();
    _wingPath.moveTo(center.dx - 2, center.dy);
    _wingPath.lineTo(center.dx - radius - 6, center.dy + wingOffset);
    _wingPath.lineTo(center.dx - radius + 2, center.dy + 8);
    _wingPath.close();
    canvas.drawPath(_wingPath, _wingPaint);

    // Göz
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.2),
      3,
      _eyePaint,
    );

    // Göz beyazı
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.25),
      1.2,
      _eyeWhitePaint,
    );

    // Gaga
    _beakPath.reset();
    _beakPath.moveTo(center.dx + radius, center.dy - 2);
    _beakPath.lineTo(center.dx + radius + 10, center.dy + 2);
    _beakPath.lineTo(center.dx + radius, center.dy + 4);
    _beakPath.close();
    canvas.drawPath(_beakPath, _beakPaint);
  }
}
