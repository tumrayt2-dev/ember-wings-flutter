# Ember Wings

Yanan bir ormandan kaçmaya çalışan küçük bir kuşun hikâyesi. Flutter + Flame ile yazılmış, tek parmakla oynanan bir arcade oyunu.

4 farklı biyom, 4 farklı karakter, ödüllü video ile ekstra can sistemi ve liderlik tablosu içerir.

## Linkler

- **Gizlilik politikası:** [privacy_policy.html](https://tumrayt2-dev.github.io/ember-wings-flutter/privacy_policy.html)
- **İletişim:** tumrayt2@gmail.com

## Teknik

- Flutter 3 / Dart
- [Flame](https://flame-engine.org/) 1.36 oyun motoru
- Firebase Crashlytics + Analytics
- Google AdMob (ödüllü reklamlar)
- Google Play Games Services (liderlik tablosu)
- Google Play Billing (uygulama içi satın alma)

## Biyomlar

- 🔥 **Alev** — yanan orman, ateş kuşu
- 💧 **Bataklık** — sazlıklar arası, su kuşu
- ❄️ **Buzul** — kış ormanı, buz kuşu
- 🌙 **Gece** — gölgeler arası, gölge kuşu

## Build

```bash
flutter pub get
flutter run                         # debug
flutter build appbundle --obfuscate --split-debug-info=build/symbols
```

Release imzalama için `android/key.properties` ve `android/upload-keystore.jks` dosyaları gereklidir (repo'ya dahil değildir).
