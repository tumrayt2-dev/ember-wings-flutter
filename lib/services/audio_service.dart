import 'package:flutter_soloud/flutter_soloud.dart';

class AudioService {
  bool _enabled = true;

  AudioSource? _jumpSource;
  AudioSource? _scoreSource;
  AudioSource? _hitSource;
  AudioSource? _buttonSource;

  bool get enabled => _enabled;
  void toggle() => _enabled = !_enabled;

  Future<void> init() async {
    await SoLoud.instance.init();

    // Ses dosyalarını belleğe yükle — bir kez yüklenir, play() sıfır overhead
    _jumpSource   = await SoLoud.instance.loadAsset('assets/audio/jump.wav');
    _scoreSource  = await SoLoud.instance.loadAsset('assets/audio/score.wav');
    _hitSource    = await SoLoud.instance.loadAsset('assets/audio/hit.wav');
    _buttonSource = await SoLoud.instance.loadAsset('assets/audio/button.wav');
  }

  // play() dart:ffi üzerinden çalışır — platform channel yok, UI thread bloklanmaz
  void playJump()   { if (_enabled && _jumpSource   != null) SoLoud.instance.play(_jumpSource!,   volume: 0.6); }
  void playScore()  { if (_enabled && _scoreSource  != null) SoLoud.instance.play(_scoreSource!,  volume: 0.6); }
  void playHit()    { if (_enabled && _hitSource    != null) SoLoud.instance.play(_hitSource!,    volume: 0.6); }
  void playButton() { if (_enabled && _buttonSource != null) SoLoud.instance.play(_buttonSource!, volume: 0.6); }

  void dispose() {
    SoLoud.instance.deinit();
  }
}
