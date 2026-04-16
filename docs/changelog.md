# Ember Wings — Sürüm Notları

Her sürümde yapılan değişikliklerin listesi. Play Console sürüm notlarını (TR + EN) yazarken buradan derle.

---

## v1.0.0+5 (2026-04-12) — Monetizasyon + Dil desteği

### 🌍 Dil desteği
- **Türkçe + İngilizce** tam UI çevirisi eklendi
- `LocaleService` ile kalıcı dil tercihi (SharedPreferences)
- Tüm overlay metinleri (menü, game over, pause, popup, biyom isimleri) localize edildi

### ⚙️ Ayarlar
- Ana menüye sağ üst köşede **Ayarlar butonu** eklendi (düşük opacity, ambiyansı bozmaz)
- Ayarlar popup: **Ses toggle** (açık/kapalı) + **Dil seçimi** (bayraklı kart UI: 🇹🇷 Türkçe / 🇬🇧 English)

### 💰 Monetizasyon dengeleme
- **Canlanma sınırı**: Herkes max 2/oyun (reklamsız paket dahil, artık sınırsız değil)
- **Saatlik video limiti**: Reklamsız paket 5/saat, normal kullanıcı sınırsız
- **Günlük bonus hak**: Reklamsız paket sahiplerine günlük +1 hak, max 3 birikir (tüm kilitli karakterler arasında ortak havuz)
- **UI**: Limit dolunca gri buton + bilgi mesajı, reklamsız pakette kalan video sayısı gösteriliyor

### 🎮 Oynanış
- **Canlanma akışı yenilendi**: Reklam sonrası direkt oyuna devam yerine "HAZIR OL! → DEVAM ET" overlay'i gösteriliyor. Oyuncu hazır olunca basıp devam ediyor. Kuş ekranın ortasına spawn, yakın engeller temizleniyor.
- **Karakter seçici sonsuz döngü**: Son karakterden sağa gidince başa, ilkten sola gidince sona dönüyor. Ok butonları her zaman aktif.

### 🐛 Bug fix
- Canlanma sonrası kuş görünmez olma + ölümsüzlük bug'ı giderildi (invincibility sistemi kaldırılıp overlay tabanlı yaklaşıma geçildi)
- "TEKRAR DENE (X hak)" satır taşması düzeltildi → "DENE (X)"
- IAP butonları fiyat yüklenmeden gizleniyor

---

## v1.0.0+4 (2026-04-11) — Test build

### 🎮 Oynanış
- **Oyun başlangıcı daha rahat**: İlk ağaç artık oyuncuya ~3.9 saniye hazırlık süresi tanıyor. Eskiden başlar başlamaz çarpışma oluyordu.
- **Ağaç çakışma bug'ı giderildi**: Başlangıçta manuel yerleştirilen iki ağaç ile timer-based spawn sistemi çakışıyordu, aynı yerde üst üste ağaç çıkabiliyordu. Artık tüm spawn'lar tek kaynaktan (timer) yönetiliyor.

### 🎨 Arayüz
- **Kilitli karakterler için yeni akış**: Gri "BAŞLA" butonu kaldırıldı.
  - **Hak varsa** → Buton `DENE (X)` olarak gösteriliyor, üstünde `▶ X hak kaldı` chip'i
  - **Hak yoksa** → Buton altın rengi `KİLİDİ AÇ`, üstünde `🎬 Video ile hak kazan` chip'i
  - Kullanıcı dokunmadan önce kaç hakkı olduğunu ve video ile hak kazanabileceğini görüyor
- **Sahipli karakter** → Sade `BAŞLA` butonu, chip yok

### 🛒 Uygulama içi satın alma
- **Kritik bug fix**: Satın alınan karakterin kullanıcıya sahiplendirilmesindeki product ID parsing hatası giderildi (`substring` düzeltmesi).
- **Fiyat yükleme göstergesi**: Play Store'dan fiyat henüz gelmediyse butonlar gri + "Fiyat yükleniyor..." metni, tıklama disable. Fiyat gelince otomatik aktif olur.

### 🏆 Play Games Services
- Leaderboard entegrasyonu tamamlandı (ID: `CgkInfXyq70WEAIQAQ` — "En Yüksek Skor")
- `AndroidManifest.xml` → `com.google.android.gms.games.APP_ID` meta-data eklendi
- Google Cloud Console OAuth client (Android) tanımlandı

### 🔥 Firebase
- 4 SHA fingerprint Firebase projesine eklendi (upload + app signing × SHA-1/SHA-256)

### 📄 Doküman
- Gizlilik politikası TR + EN çift dilli yeniden yazıldı, GitHub Pages'te yayında
- README default Flutter şablonundan Ember Wings tanıtımına güncellendi

---

## v1.0.0+3 (2026-04-11) — Yayın öncesi ilk AAB

### 🛒 IAP
- Uygulama içi satın alma akışı iyileştirildi
- Satın alma sonrası karakter sahiplendirme bug fix
- Fiyat yükleme fallback UI

### 🏆 Play Games
- Leaderboard gerçek ID entegre
- Manifest meta-data tamamlandı

---

## v1.0.0+2 (2026-04-11) — Öncül test build

### 🛒 Monetizasyon
- AdMob gerçek ID'leri entegre (debug'ta test ID'leri kullanılır, release'de prod)
- Kritik IAP product ID parsing bug'ı giderildi

---

## v1.0.0+1 (2026-04-10) — İlk release imzalı AAB

### ✨ Yeni özellikler
- 4 biyom: Alev, Bataklık, Buzul, Gece
- 4 karakter (Phoenix ücretsiz)
- AudioPool tabanlı ses sistemi (jump / score pool overflow bug'ı çözüldü)
- Firebase Crashlytics + Analytics entegrasyonu
- Keystore + release signing config
- R8 minify + ProGuard keep rules

---

## Play Console sürüm notu şablonu

Her yayın için bu formatta yaz (TR + EN, ≤500 karakter):

### TR
```
Sürüm 1.0.X:
- [En büyük özellik veya düzeltme]
- [İkincil geliştirme]
- [Performans/bug fix]
```

### EN
```
Version 1.0.X:
- [Biggest feature or fix]
- [Secondary improvement]
- [Performance/bug fix]
```

---

## v1.0.1 backlog (yayın sonrası ilk güncelleme)

### Oynanış — zorluk artışı
- **Gap daraltma**: Skor arttıkça gap 160 → 130 px'e iner (hassasiyet artar)
- **Dikey salınım**: Engeller `sin()` ile yukarı-aşağı sallanır (skor 10+ sonra aktif, amplitude ±40 px, ardışık ağaçlar arası `_maxGapShift` kontrolü korunur — imkansız duvar oluşmaz)
- **Karakter özel sıralama**: Her karakter/biyom için ayrı leaderboard (karakterlere mekanik fark eklenirse anlamlı olur)

### Karakter mekanikleri
- Hitbox farkı, yer çekimi farkı, özel yetenek gibi diferansiyasyon
- Biyom bazlı zorluk parametreleri (gece → daha dar gap, buz → kaygan fizik vb.)

### Altyapı / içerik
- ~~İngilizce dil desteği~~ ✅ v1.0.0+5'te tamamlandı
- Firebase Crashlytics symbol upload (obfuscated stack trace için Gradle task)
- Karakter kart animasyonları (seçim hissi için)
- İnce ayar: hazırlık süresi oyuncu geri bildirimine göre
