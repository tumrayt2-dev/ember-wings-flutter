import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';
import 'tree_obstacle.dart';
import 'ground.dart';

class Bird extends PositionComponent with CollisionCallbacks, HasGameReference<EmberWingsGame> {
  double velocity = 0;
  double _wingAngle = 0;
  bool isDead = false;
  void Function()? onHit;

  // Cached Paint nesneleri
  final Paint _bodyPaint     = Paint();
  final Paint _wingPaint     = Paint();
  final Paint _eyePaint      = Paint()..color = GameConfig.birdEye;
  final Paint _eyeWhitePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _beakPaint     = Paint();
  final Path  _wingPath      = Path();
  final Path  _beakPath      = Path();

  // Pre-computed render değerleri — onLoad'da hesaplanır
  late final Offset _center;
  late final double _radius;
  late final Offset _eyeOffset;
  late final Offset _eyeWhiteOffset;
  late final double _wingMoveX, _wingMoveY;
  late final double _wingMidX;
  late final double _wingEndX, _wingEndY;

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

    final cx = size.x / 2;
    final cy = size.y / 2;
    final r  = size.x / 2;

    _center         = Offset(cx, cy);
    _radius         = r;
    _eyeOffset      = Offset(cx + r * 0.3,  cy - r * 0.2);
    _eyeWhiteOffset = Offset(cx + r * 0.3,  cy - r * 0.25);

    // Wing path sabit noktaları
    _wingMoveX = cx - 2;
    _wingMoveY = cy;
    _wingMidX  = cx - r - 6;
    _wingEndX  = cx - r + 2;
    _wingEndY  = cy + 8;

    // Gaga path tamamen sabit — bir kez çizilir
    _beakPath
      ..moveTo(cx + r,      cy - 2)
      ..lineTo(cx + r + 10, cy + 2)
      ..lineTo(cx + r,      cy + 4)
      ..close();
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
    // Ters yer çekiminde tap aşağı iter (pozitif velocity)
    velocity = game.isGravityReversed ? -GameConfig.jumpForce : GameConfig.jumpForce;
    _wingAngle = -0.5;
  }

  void reset() {
    position = Vector2(GameConfig.birdX, GameConfig.gameHeight / 2);
    velocity = 0;
    angle    = 0;
    isDead   = false;
    isActive = true;
  }

  bool isActive = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || !isActive) return;

    // Ters yer çekiminde gravity yukarı çeker (negatif velocity)
    final gravityValue = game.isGravityReversed ? -GameConfig.gravity : GameConfig.gravity;
    velocity += gravityValue * dt;
    velocity  = velocity.clamp(-GameConfig.maxVelocity, GameConfig.maxVelocity);
    position.y += velocity * dt;

    angle = (velocity / GameConfig.maxVelocity) * 0.8;

    _wingAngle += dt * 12;
    if (_wingAngle > pi * 2) _wingAngle -= pi * 2;

    // Tavana çarpınca öl (zemin ile simetrik)
    if (position.y < GameConfig.birdSize / 2) {
      position.y = GameConfig.birdSize / 2;
      onHit?.call();
      return;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Gövde
    canvas.drawCircle(_center, _radius, _bodyPaint);

    // Kanat — sadece y offset her frame değişir
    final wingOffset = sin(_wingAngle) * 4;
    _wingPath.reset();
    _wingPath.moveTo(_wingMoveX, _wingMoveY);
    _wingPath.lineTo(_wingMidX,  _wingMoveY + wingOffset);
    _wingPath.lineTo(_wingEndX,  _wingEndY);
    _wingPath.close();
    canvas.drawPath(_wingPath, _wingPaint);

    // Göz
    canvas.drawCircle(_eyeOffset,      3,   _eyePaint);
    canvas.drawCircle(_eyeWhiteOffset, 1.2, _eyeWhitePaint);

    // Gaga (pre-computed path)
    canvas.drawPath(_beakPath, _beakPaint);
  }
}
