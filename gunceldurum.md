# Ember Wings - Proje Guncel Durum Raporu

**Tarih:** 2026-04-10
**Platform:** Android (arm64)
**Framework:** Flutter 3.41.6 + Flame 1.36.0
**Tema:** Yanan ormandan kacan kus (Flappy Bird varyanti)

---

## Proje Yapisi

```
lib/
├── main.dart                          # Uygulama giris noktasi
├── config/
│   ├── game_config.dart               # Oyun fizik sabitleri, renkler, boyutlar
│   └── monetization_config.dart       # Urun ID'leri, AdMob ID, seans ayarlari
├── models/
│   └── game_character.dart            # Karakter tanimlari, biom renkleri
├── components/
│   ├── bird.dart                      # Kus fizigi, animasyon, cizim
│   ├── background.dart                # Arka plan, kivilcim parcaciklari, duman
│   ├── ground.dart                    # Kayan zemin, komur deseni
│   ├── tree_obstacle.dart             # Agac engelleri (ust+alt cift)
│   └── score_display.dart             # Skor gosterimi
├── game/
│   ├── ember_wings_game.dart          # Ana oyun sinifi, state yonetimi
│   └── overlays.dart                  # Menu, GameOver, Pause, HUD arayuzleri
└── services/
    ├── character_service.dart         # Karakter sahiplik, deneme hakki, seans
    └── purchase_service.dart          # Google Play IAP entegrasyonu
```

**Toplam:** 13 Dart dosyasi

---

## Karakterler

| Karakter   | Durum   | Biom   | Govde Rengi | Kanat Rengi  |
|------------|---------|--------|-------------|--------------|
| Phoenix    | UCRETSIZ| Ates   | Altin       | Turuncu      |
| Kingfisher | KILITLI | Su     | Cyan        | Koyu Cyan    |
| Frost Bird | KILITLI | Buz    | Acik Cyan   | Cyan         |
| Shadow     | KILITLI | Gece   | Koyu Gri    | Koyu         |

Her karakterin kendine ozel 8 renk seti var (gokyuzu, agac, zemin, parcacik).

---

## Tamamlanan Ozellikler

### Oyun Mekanikleri
- [x] Dokunarak zipla fizigi (yercekimi: 900, ziplama: -350, maks hiz: 500)
- [x] Prosedural agac engel olusturma (aralik: 160px, spawn: 1.6s, hiz: 150px/s)
- [x] Carpisma algilama (kus vs zemin, kus vs agac)
- [x] Skor takibi (kus agaci gecince +1)
- [x] Oyun durumlari: menu → oynuyor → duraklatma/olum → menu
- [x] Devam etme sistemi (oyun basina 2 hak, reklamsiz pakette sinirsiz)
- [x] Devam ederken yakin engelleri temizleme

### Gorsel/Grafik (Tamami Prosedural - Asset Yok)
- [x] Ozel kus cizimi (govde, kanat, goz, gaga)
- [x] Kanat cirpma animasyonu
- [x] Kivilcim parcaciklari (arka plan)
- [x] Duman bulutlari (kayan)
- [x] Kayan zemin deseni (komur, kul)
- [x] Agac govdeleri (kabuk cizgileri, kivilcim noktalari, parlama efekti)
- [x] Biom bazli degrade gokyuzu renkleri
- [x] Karakter bazli renk degisimi

### Arayuz (UI)
- [x] Ana menu — karakter karuseli (kaydirma + ok butonlari)
- [x] Biom bazli arka plan degradesi (menu)
- [x] Kilitli karakter karanlik efekti + kilit ikonu
- [x] Kilitli karakter popup (dene, video izle, satin al, tumunu al)
- [x] Oyun bitti ekrani (skor, devam et, tekrar dene, ana menu)
- [x] Duraklatma ekrani (devam et, ana menu)
- [x] HUD (ses acma/kapama + duraklatma butonlari)
- [x] GameOver overlay — LayoutBuilder ile responsive
- [x] Turkce arayuz metinleri

### Monetizasyon Altyapisi
- [x] Karakter kilit acma sistemi (ucretsiz Phoenix, 3 kilitli)
- [x] Deneme hakki sistemi (karakter basina 2 ucretsiz oyun)
- [x] Video odul seans sistemi (video basina 3 oyun hakki)
- [x] SharedPreferences ile veri kaliciligi
- [x] Google Play IAP framework kurulumu
- [x] Dinamik fiyat cekme (Play Store'dan)
- [x] Satin alma isleyicisi (karakter, paket, reklamsiz)
- [x] Paket satin alma (tum karakterler, %20 indirim)
- [x] Reklamsiz paket (sinirsiz devam etme)
- [x] Secili karakter hafizasi
- [x] Web uyumluluk guardi (kIsWeb — IAP atlanir)

### Servisler
- [x] CharacterService — sahiplik, deneme, seans yonetimi
- [x] PurchaseService — IAP baglantisi, satin alma, geri yukleme

---

## Eksik / Tamamlanmamis Ozellikler

### 1. AdMob Reklam Entegrasyonu (KRITIK)
**Durum:** Butonlar hazir, backend altyapisi hazir, AdMob entegrasyonu YOK

**Eksik noktalar:**
- `overlays.dart:434` — Video izle butonu (kilitli karakter popup): Simdilik video gostermeden direkt 3 oyun hakki veriyor
- `overlays.dart:573` — Devam et butonu (game over): Simdilik video gostermeden direkt devam ettiriyor
- `google_mobile_ads` paketi pubspec.yaml'a eklenmemis
- AdMob baslatma (initialize) kodu yok
- Rewarded video yukleme/gosterme/callback mantigi yok
- `monetization_config.dart:17` — Test ID var, gercek ID ile degistirilecek

**Yapilmasi gerekenler:**
```
1. google_mobile_ads paketini ekle
2. AdMob SDK baslatma kodunu main.dart'a ekle
3. RewardedAd yukleme servisi olustur
4. Video izle butonlarini reklam gosterimi ile bagla
5. Reklam basarili izlendiginde odulu ver
6. Test ID'lerini gercek ID'ler ile degistir (yayin oncesi)
```

### 2. Ses Efektleri (ORTA)
**Durum:** Ses acma/kapama butonu MEVCUT ama hicbir ses efekti yok

**Eksik noktalar:**
- Ziplama sesi yok
- Carpisma/yanma sesi yok
- Skor artis sesi yok
- Arka plan muzigi yok
- Buton tiklama sesi yok
- Flame audio sistemi (`FlameAudio`) entegre edilmemis
- Ses dosyalari (assets/audio/) yok

### 3. Farkli Biom Gorselleri (DUSUK)
**Durum:** Biom RENKLERI tanimli ama sadece menu arka planinda kullaniliyor

**Eksik noktalar:**
- Oyun icinde arka plan her zaman ates biomu (sabit renkler)
- Agac engelleri her zaman ayni gorunum
- Zemin her zaman ayni gorunum
- Secilen karakterin biom renklerinin oyuna yansimasi yok
- `game_config.dart` sabitleri biom bazli degil

**Yapilmasi gerekenler:**
```
1. Background component'i aktif karakterin biom renklerini kullanacak sekilde guncelle
2. TreeObstacle'da biom bazli renkler kullan
3. Ground'da biom bazli renkler kullan
4. Parcacik efektlerini bioma gore degistir (ates→kivilcim, su→damla, buz→kristal, gece→yildiz)
```

### 4. Google Play Games Servisleri (DUSUK)
**Durum:** Hic baslanmadi

**Eksik noktalar:**
- Liderlik tablosu (leaderboard) yok
- Basarimlar (achievements) yok
- Google Play Games oturum acma yok
- games_services paketi yok

### 5. Karakter Ozel Mekanikleri (DUSUK)
**Durum:** Hic baslanmadi

**Planlanan mekanikler:**
- Phoenix: Ates direnci (engelle temas geciktirmesi?)
- Kingfisher: Daha kucuk hitbox
- Frost Bird: Yavas dusme
- Shadow: Gorunmezlik (kisa sureli)

---

## Bagimlilklar (pubspec.yaml)

| Paket              | Versiyon | Amac                      | Durum    |
|--------------------|----------|---------------------------|----------|
| flame              | ^1.36.0  | 2D oyun motoru            | AKTIF    |
| shared_preferences | ^2.5.5   | Yerel veri saklama        | AKTIF    |
| in_app_purchase    | ^3.2.3   | Google Play satin alma    | AKTIF    |
| cupertino_icons    | ^1.0.8   | iOS ikon seti             | AKTIF    |
| google_mobile_ads  | —        | AdMob reklam              | EKSIK    |
| games_services     | —        | Play Games liderlik/basarim| EKSIK   |
| flame_audio        | —        | Ses efektleri             | EKSIK    |

---

## Bilinen Sorunlar

1. **Emulator crash:** Dusuk RAM'li emulatorlerde lowmemorykiller uygulamayi olduruyor. Fiziksel cihazda sorun yok.
2. **BillingClient uyarisi:** Emulatorde "API version 3 not supported" — normal, gercek cihazda calisiyor.
3. **Chrome'da IAP:** Web'de IAP desteklenmiyor, kIsWeb guardi ile handle ediliyor.

---

## Yayin Oncesi Yapilacaklar (Checklist)

### Zorunlu
- [ ] AdMob rewarded video entegrasyonu (2 konum)
- [ ] AdMob gercek unit ID'leri (test ID'leri degistirilecek)
- [ ] Google Play Console'da urun tanimlari (character_*, character_bundle_all, ad_free_pack)
- [ ] Uygulama ikonu tasarimi
- [ ] Splash screen
- [ ] ProGuard/R8 ayarlari (release build)
- [ ] Uygulama adi ve paket adi son kontrolu (com.tumray.flappy_bird → ?)
- [ ] Privacy Policy sayfasi
- [ ] Minimum Android SDK kontrolu

### Onerilen
- [ ] Ses efektleri eklenmesi
- [ ] Biom gorsellerinin oyun icine yansitmasi
- [ ] Google Play Games liderlik tablosu
- [ ] Firebase Crashlytics (crash raporlama)
- [ ] Firebase Analytics (kullanici metrikleri)

### Opsiyonel
- [ ] Karakter ozel mekanikleri
- [ ] Basarim sistemi
- [ ] Gunluk gorev/odul sistemi
- [ ] Sosyal paylasim (skor paylasma)

---

## Teknik Notlar

- **Oyun boyutu:** Sabit 400x800 piksel, AspectRatio ile sarmalanmis
- **Render:** Tamamen prosedural (Canvas) — hicbir gorsel asset yok
- **Dart SDK:** ^3.11.4
- **APK boyutu:** ~15.5 MB (arm64 release)
- **Mimari:** Flame game + Flutter overlay sistemi (menu/HUD oyun ustunde)
