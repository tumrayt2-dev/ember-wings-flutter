import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class ScoreDisplay extends TextComponent {
  int _score = 0;

  ScoreDisplay() : super(
    text: '0',
    anchor: Anchor.topCenter,
    priority: 10,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFFFF),
        shadows: [
          Shadow(color: Color(0xFF000000), blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
    ),
  );

  int get score => _score;

  void increment() {
    _score++;
    text = '$_score';
  }

  void reset() {
    _score = 0;
    text = '0';
  }
}
