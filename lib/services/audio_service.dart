import 'package:flame_audio/flame_audio.dart';

class AudioService {
  bool _enabled = true;
  AudioPool? _jumpPool;
  AudioPool? _scorePool;
  AudioPool? _hitPool;
  AudioPool? _buttonPool;

  bool get enabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
  }

  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      'jump.wav',
      'hit.wav',
      'score.wav',
      'button.wav',
    ]);
    // Havuzlanmış oynatıcılar — hızlı tetiklenen sesler için player birikmesini önler
    _jumpPool = await FlameAudio.createPool('jump.wav', minPlayers: 2, maxPlayers: 4);
    _scorePool = await FlameAudio.createPool('score.wav', minPlayers: 1, maxPlayers: 3);
    _hitPool = await FlameAudio.createPool('hit.wav', minPlayers: 1, maxPlayers: 2);
    _buttonPool = await FlameAudio.createPool('button.wav', minPlayers: 1, maxPlayers: 2);
  }

  void playJump() {
    if (!_enabled) return;
    _jumpPool?.start();
  }

  void playHit() {
    if (!_enabled) return;
    _hitPool?.start();
  }

  void playScore() {
    if (!_enabled) return;
    _scorePool?.start();
  }

  void playButton() {
    if (!_enabled) return;
    _buttonPool?.start();
  }
}
