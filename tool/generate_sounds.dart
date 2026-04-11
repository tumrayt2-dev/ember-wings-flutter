import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// Minimal WAV ses dosyaları üretici
// Oyun için 4 ses: jump, hit, score, button

void main() {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // Zıplama sesi — kısa yukarı sweep (100ms)
  generateWav('assets/audio/jump.wav', 0.1, (t) {
    final freq = 400 + t * 4000; // 400Hz → 800Hz sweep
    return sin(2 * pi * freq * t) * (1 - t) * 0.6;
  });

  // Çarpışma sesi — gürültülü düşük patlama (200ms)
  generateWav('assets/audio/hit.wav', 0.2, (t) {
    final noise = Random(((t * 44100).toInt())).nextDouble() * 2 - 1;
    final boom = sin(2 * pi * 80 * t) * (1 - t * 3).clamp(0.0, 1.0);
    return (noise * 0.3 + boom * 0.7) * (1 - t) * 0.8;
  });

  // Skor sesi — iki tonlu bip (150ms)
  generateWav('assets/audio/score.wav', 0.15, (t) {
    final f = t < 0.07 ? 880.0 : 1100.0;
    return sin(2 * pi * f * t) * (1 - t * 4).clamp(0.0, 1.0) * 0.5;
  });

  // Buton sesi — hafif tık (50ms)
  generateWav('assets/audio/button.wav', 0.05, (t) {
    return sin(2 * pi * 600 * t) * (1 - t * 20).clamp(0.0, 1.0) * 0.4;
  });

  print('Ses dosyaları oluşturuldu: assets/audio/');
}

void generateWav(String path, double durationSec, double Function(double t) generator) {
  const sampleRate = 44100;
  const bitsPerSample = 16;
  const numChannels = 1;

  final numSamples = (sampleRate * durationSec).toInt();
  final dataSize = numSamples * numChannels * (bitsPerSample ~/ 8);

  final buffer = ByteData(44 + dataSize);
  var offset = 0;

  // RIFF header
  void writeStr(String s) {
    for (var i = 0; i < s.length; i++) {
      buffer.setUint8(offset++, s.codeUnitAt(i));
    }
  }

  void writeU32(int v) {
    buffer.setUint32(offset, v, Endian.little);
    offset += 4;
  }

  void writeU16(int v) {
    buffer.setUint16(offset, v, Endian.little);
    offset += 2;
  }

  writeStr('RIFF');
  writeU32(36 + dataSize);
  writeStr('WAVE');
  writeStr('fmt ');
  writeU32(16); // fmt chunk size
  writeU16(1); // PCM
  writeU16(numChannels);
  writeU32(sampleRate);
  writeU32(sampleRate * numChannels * (bitsPerSample ~/ 8)); // byte rate
  writeU16(numChannels * (bitsPerSample ~/ 8)); // block align
  writeU16(bitsPerSample);
  writeStr('data');
  writeU32(dataSize);

  // Sample data
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final sample = (generator(t).clamp(-1.0, 1.0) * 32767).toInt();
    buffer.setInt16(offset, sample, Endian.little);
    offset += 2;
  }

  File(path).writeAsBytesSync(buffer.buffer.asUint8List());
}
