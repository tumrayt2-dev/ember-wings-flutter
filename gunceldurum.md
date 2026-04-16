# Ember Wings — Güncel Durum Raporu

**Tarih:** 2026-04-12
**Sürüm:** 1.0.0+5 (Split APK test build hazır)
**Platform:** Android (arm64, armeabi-v7a, x86_64)
**Framework:** Flutter 3 + Flame 1.36.0
**Paket adı:** `com.tumray.emberwings`
**Repo:** https://github.com/tumrayt2-dev/ember-wings-flutter

---

## Tamamlanan

### Oyun / oynanış
- 4 biyom: Alev, Bataklık, Buzul, Gece — her biri kendi renk paleti + özel ağaç varyantları
- 4 karakter: Phoenix (ücretsiz), Kingfisher, Frost Bird, Shadow
- Tek parmak zıplama fiziği + kuş izi efekti
- Biyom geçiş flash efekti
- Ağaç gap spacing constraint (`_maxGapShift = 120`) — imkansız geçişler engellendi
- Gece biyomu kontrast iyileştirmesi
- Responsive UI (LayoutBuilder ile)
- Karakter seçici sonsuz döngü (son karakter → başa dön)
- Canlanma: max 2/oyun (herkes için), reklam sonrası "HAZIR OL! → DEVAM ET" overlay

### Dil desteği
- Türkçe + İngilizce tam UI çevirisi
- `LocaleService` — SharedPreferences ile kalıcı dil tercihi
- Tüm overlay metinleri localize (menü, game over, pause, popup, biyomlar)
- Ayarlar popup: ses toggle + dil seçimi (bayraklı kart UI)

### Ses
- `AudioPool` ile ses efektleri (jump, score) — pool overflow bug'ı çözüldü
- Ses aç/kapa (ayarlar popup + HUD)

### Monetizasyon
- IAP servis: karakter + bundle + reklamsız paket
- **Bug fix**: Satın alınan karakterin sahiplendirilmesi (`substring` düzeltmesi)
- **UI**: Fiyat yüklenmediğinde IAP butonları gizleniyor
- AdMob gerçek ID'leri entegre, debug'ta Google test ID'leri
- Rewarded video → ekstra can hakkı akışı
- Kilitli karakterler: BAŞLA/DENE(X)/KİLİDİ AÇ dinamik buton + chip
- Game Over: aynı 3-state mantık + popup açma
- **Reklamsız paket dengesi:**
  - Saatlik video limiti: 5/saat (normal kullanıcı sınırsız)
  - Günlük bonus: +1 hak/gün, max 3 birikir (kilitli karakterler arası ortak)
  - Canlanma: max 2/oyun (reklamsız dahil)
  - UI: limit dolunca gri buton + bilgi mesajı

### Firebase
- `firebase_core`, `firebase_crashlytics`, `firebase_analytics` entegre
- Crash handler: `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError`
- Analytics events: `game_start`, `game_over`, `continue_used`, `ad_shown`, `character_selected`, `iap_purchase`
- Web + init failure fallback

### Play Games Services
- Google Cloud Console OAuth client (Android)
- `AndroidManifest.xml` meta-data + `strings.xml`
- Leaderboard: "En Yüksek Skor" — ID `CgkInfXyq70WEAIQAQ`

### Release konfigürasyonu
- Upload keystore + `key.properties`
- `signingConfigs.release` + debug fallback
- R8 minify + resource shrink + ProGuard keep rules
- 4 SHA fingerprint Firebase'e eklendi

### Mağaza / doküman
- Privacy policy TR + EN (GitHub Pages)
- README — Ember Wings tanıtımı
- Launcher icon + native splash
- Play Console: uygulama oluşturuldu, Internal Testing track aktif

---

## Onay bekliyor / yayın sonrası yapılacak

### Play Console
- [ ] AAB yükle (version bump + build gerekli)
- [ ] Ekran görüntüleri + feature graphic + kısa/uzun açıklama
- [ ] Kategori: Arcade + Casual
- [ ] İçerik derecelendirmesi (IARC anketi)
- [ ] Veri güvenliği formu (AdMob AAID, Crashlytics, Analytics)
- [ ] Privacy policy URL'si gir

### IAP ürünleri (satıcı profili onayından sonra)
- [ ] `character_kingfisher` — ₺29,99
- [ ] `character_frostBird` — ₺29,99
- [ ] `character_shadow` — ₺29,99
- [ ] `character_bundle_all` — ₺69,99
- [ ] `ad_free_pack` — ₺39,99
- [ ] Reklamsız paket açıklamasını güncelle (saatlik video limiti, günlük bonus, canlanma bilgisi)

### Play Games Services
- [ ] Leaderboard yayınla (production submission'dan önce)

### Kapalı test
- [ ] En az 12 test kullanıcısı opt-in
- [ ] 14 gün kesintisiz test süresi
- [ ] Production submission

---

## Ertelenen / v1.0.1+ backlog

- **Zorluk artışı**: Gap daraltma (skor bazlı), dikey salınım (sin() engeller)
- **Karakter mekanikleri**: Hitbox/yerçekimi farkı, biyom bazlı zorluk
- **Firebase Crashlytics symbol upload** — obfuscated stack trace decode
- **Karakter kart animasyonları**

---

## Proje yapısı

```
lib/
├── main.dart
├── config/
│   ├── game_config.dart
│   └── monetization_config.dart
├── models/
│   └── game_character.dart
├── components/
│   ├── bird.dart
│   ├── bird_trail.dart
│   ├── background.dart
│   ├── ground.dart
│   ├── tree_obstacle.dart
│   └── score_display.dart
├── game/
│   ├── ember_wings_game.dart
│   └── overlays.dart
└── services/
    ├── character_service.dart
    ├── purchase_service.dart
    ├── ad_service.dart
    ├── audio_service.dart
    ├── score_service.dart
    ├── leaderboard_service.dart
    ├── analytics_service.dart
    └── locale_service.dart          # TR/EN dil desteği
```

---

## Kimlikler ve kritik değerler

| Alan | Değer |
|---|---|
| Package name | `com.tumray.emberwings` |
| AdMob App ID | `ca-app-pub-8438407620610676~6627756207` |
| AdMob Rewarded | `ca-app-pub-8438407620610676/6198788478` |
| Play Games Project ID | `772380867229` |
| Leaderboard ID | `CgkInfXyq70WEAIQAQ` |
| Firebase App ID | `1:772380867229:android:d4c1c442f13e5c32f37274` |
| Privacy policy | https://tumrayt2-dev.github.io/ember-wings-flutter/privacy_policy.html |
| İletişim | tumrayt2@gmail.com |

---

## Son oturum (2026-04-12) özeti

1. Monetizasyon dengeleme: saatlik video limiti, günlük bonus hak, canlanma max 2
2. Canlanma akışı yenilendi: invincibility → "Devam Et" overlay
3. TR + EN dil desteği + LocaleService
4. Ayarlar popup: ses toggle + dil seçimi (bayraklı kartlar)
5. Karakter seçici sonsuz döngü
6. UI düzeltmeleri: buton taşması, fiyat gizleme, chip metinleri

**Şu an**: Kapalı test onay sürecini bekliyoruz. IAP ürünleri satıcı profili onayından sonra oluşturulacak.
