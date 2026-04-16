import 'dart:async' show unawaited;
import 'package:audioplayers/audioplayers.dart';

class _SoundPool {
  final List<AudioPlayer> _players;
  int _index = 0;

  _SoundPool(int size) : _players = List.generate(size, (_) => AudioPlayer());

  Future<void> init(String asset) async {
    for (final p in _players) {
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(0.6);
      // Ses dosyasını önceden yükle
      await p.setSource(AssetSource('audio/$asset'));
    }
  }

  void play() {
    final player = _players[_index];
    _index = (_index + 1) % _players.length;
    // seek(0) sonra resume — stopped state'den de güvenli çalışır
    unawaited(player.seek(Duration.zero).then((_) => player.resume()));
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
  }
}

class AudioService {
  bool _enabled = true;

  late final _SoundPool _jumpPool;
  late final _SoundPool _scorePool;
  late final _SoundPool _hitPool;
  late final _SoundPool _buttonPool;

  bool get enabled => _enabled;

  void toggle() => _enabled = !_enabled;

  Future<void> init() async {
    _jumpPool   = _SoundPool(3);
    _scorePool  = _SoundPool(2);
    _hitPool    = _SoundPool(2);
    _buttonPool = _SoundPool(2);

    await Future.wait([
      _jumpPool.init('jump.wav'),
      _scorePool.init('score.wav'),
      _hitPool.init('hit.wav'),
      _buttonPool.init('button.wav'),
    ]);
  }

  void playJump()   { if (_enabled) _jumpPool.play(); }
  void playScore()  { if (_enabled) _scorePool.play(); }
  void playHit()    { if (_enabled) _hitPool.play(); }
  void playButton() { if (_enabled) _buttonPool.play(); }

  void dispose() {
    _jumpPool.dispose();
    _scorePool.dispose();
    _hitPool.dispose();
    _buttonPool.dispose();
  }
}
