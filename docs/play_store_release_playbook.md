# Play Store Release Playbook

Taboo Rush'ı yayınlarken uyguladığımız adımların sırası. Yeni bir Flutter uygulamasını (örn. Flappy Bird) baştan sona Play Store'a almak için bu listeyi takip et.

---

## 0. Ön hazırlık (kod tarafı)
- [ ] `pubspec.yaml` içinde `name`, `description`, `version: 1.0.0+1` net olsun
- [ ] `applicationId` (package name) `android/app/build.gradle.kts` içinde doğru — örn. `com.tumray.flappy_bird`
- [ ] Uygulama ikonları hazır: `flutter_launcher_icons` çalıştırılmış
- [ ] Splash screen: `flutter_native_splash` çalıştırılmış
- [ ] `flutter analyze` temiz, release build'de crash yok (debug'ta değil, **release APK** ile test et)
- [ ] Firebase Crashlytics (istersek) kurulu ve `flutter run --release` ile crash raporu düştüğü görüldü

---

## 1. Keystore & signing
- [ ] Keystore oluştur (Android Studio JDK'sıyla):
  ```bash
  "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v \
    -keystore C:\Projects\<proje>\android\upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [ ] `android/key.properties` oluştur:
  ```properties
  storePassword=...
  keyPassword=...
  keyAlias=upload
  storeFile=../upload-keystore.jks
  ```
- [ ] `.gitignore`'a ekle: `android/key.properties`, `android/upload-keystore.jks`
- [ ] `android/app/build.gradle.kts` içinde `signingConfigs.release` + `buildTypes.release.signingConfig` bağlandı
- [ ] **Keystore + şifreyi yedekle** (USB + şifreli cloud). Kaybedersen uygulamayı bir daha güncelleyemezsin
- [ ] SHA-1 / SHA-256 fingerprint'i not et (Firebase, Play Console ownership için lazım olabilir):
  ```bash
  keytool -list -v -keystore upload-keystore.jks -alias upload
  ```

---

## 2. Play Console — uygulama oluştur
- [ ] Play Console → "Uygulama oluştur"
- [ ] Ad, varsayılan dil (Türkçe), oyun/uygulama, ücretsiz/ücretli seç
- [ ] Beyannameleri onayla (politikalar, ABD ihracat kanunu)

## 3. Paket adı sahiplik doğrulaması (gerekirse)
Play Console paket adını bir başkası daha önce denediyse ek doğrulama ister:
- [ ] "Paket adı sahipliğini doğrula" adımında küçük bir token snippet verir
- [ ] `android/app/src/main/assets/adi-registration.properties` dosyası oluştur, snippet'i **dosyanın içeriği** olarak yapıştır (dosya adı değil!)
- [ ] Debug APK build et: `flutter build apk --debug --split-per-abi` (arm64-v8a APK'sı < 160 MB)
- [ ] APK'yı Play Console'a yükle → "doğrulandı" görünce tamam
- [ ] Post-release TODO listesine ekle: "`adi-registration.properties` dosyasını ilk güncellemede kaldır"

---

## 4. Mağaza listesi (store listing)
Hepsini tek bir `docs/store_listing.md` dosyasında topla. Gerekli alanlar:
- [ ] **Uygulama adı** (≤30 karakter)
- [ ] **Kısa açıklama** (≤80 karakter)
- [ ] **Uzun açıklama** (≤4000 karakter) — emoji + başlıklarla bölümle
- [ ] **Uygulama ikonu** 512×512 PNG
- [ ] **Feature graphic** 1024×500 (Microsoft Designer / Canva ile üret)
- [ ] **Telefon ekran görüntüleri** en az 2 adet (ideal: 4-8)
- [ ] **Tablet görselleri** 7" ve 10" — telefon ekranlarını yükleyebiliriz, zorunlu değil ama boşluk kalmasın
- [ ] Kategori seç (Oyun → alt kategori)
- [ ] Etiketler: 5 taneye kadar (Bulmaca, Kelime, Parti, vb.)
- [ ] İletişim e-postası

---

## 5. Politika & form cevapları
Play Console "Uygulamanızı kurun" panelinde sıralı olarak:

### Uygulama erişimi
- [ ] Giriş gerekiyor mu? → Hayır ise "tüm işlevler özel kimlik bilgisi olmadan kullanılabilir"

### Reklamlar
- [ ] AdMob kullanıyorsan → "Evet, reklam içerir"

### İçerik derecelendirmesi (IARC anketi)
- [ ] Şiddet, cinsel içerik, küfür, korku, kumar, iletişim, konum sorularını cevapla
- [ ] Kumar sorusu: bahis modu bile olsa **gerçek para yoksa Hayır**

### Hedef kitle ve içerik
- [ ] Yaş grubu (13+ genelde uygun)
- [ ] Çocuklara yönelik mi? → Hayır (aksi halde COPPA yükümlülüğü)

### Veri güvenliği (Data Safety)
- [ ] Toplanan veriler: reklam ID (AdMob), crash logs (Crashlytics), performance diagnostics (Crashlytics)
- [ ] Kişisel bilgi, konum, kişiler, kamera, mikrofon → Hayır
- [ ] "Aktarım sırasında şifreleniyor mu?" → Evet (HTTPS)
- [ ] "Kullanıcı veri silme talep edebilir mi?" → Google üzerinden (AdMob/Crashlytics)
- [ ] Reklam ID beyanı: "Reklam veya pazarlama" seç (Crashlytics AAID kullanmaz)

### Diğer
- [ ] Haberler uygulaması → Hayır
- [ ] COVID-19 izleme → Hayır
- [ ] Devlet destekli → Hayır
- [ ] Finansal özellikler → Hayır

---

## 6. Gizlilik politikası
- [ ] Privacy policy yazılmış ve herkese açık bir URL'de (GitHub Pages, Netlify, kendi site)
- [ ] AdMob + Crashlytics + varsa in-app purchase'tan bahset
- [ ] URL'yi Play Console'a gir

---

## 7. Release build (AAB)
- [ ] Sürüm kodunu artır: `pubspec.yaml` → `version: 1.0.0+X` (her yüklemede +1)
- [ ] Obfuscate + symbols ile build:
  ```bash
  flutter build appbundle --obfuscate --split-debug-info=build/symbols
  ```
- [ ] Çıktı: `build/app/outputs/bundle/release/app-release.aab`
- [ ] (Opsiyonel) Crashlytics symbol upload kur: `build/symbols/` klasörünü Firebase'e yükle

---

## 8. Test track'leri
**Strateji:** Dahili test → Kapalı test (14 gün) → Production

### Dahili test
- [ ] Sürüm oluştur → AAB yükle
- [ ] Testçi listesi oluştur (kendi e-postan + yakınlar)
- [ ] Release notes yaz (Türkçe + İngilizce)
- [ ] Yayınla → opt-in linkiyle test et

### Kapalı test (zorunlu — kişisel dev hesabı için)
- [ ] **En az 12 opt-in testçi** (Kasım 2023 sonrası kural, 2024 Aralık'ta 20→12'ye düştü)
- [ ] 12 kişinin opt-in link'e tıklayıp uygulamayı en az 1 kez açması gerekli
- [ ] **14 gün kesintisiz** test süresi — süre testçi dolunca başlar
- [ ] Play Console → Test → Kapalı test sayacı "X / 12 testçi, Y / 14 gün" gösterir
- [ ] Sayaç ilerlemezse: testçiler uygulamayı gerçekten açmadı demektir

---

## 9. Production
- [ ] Kapalı test 14 gün + 12 testçi tamamlanınca production başvurusu açılır
- [ ] Aynı AAB'yi (veya yeni sürümü) production track'e yükle
- [ ] Google inceleme: 1-7 gün (ilk yayında bazen 2-3 haftaya çıkabilir)
- [ ] Onaydan sonra yayınla → mağazada görünmesi 2-4 saat

---

## 10. Yayın sonrası
- [ ] `adi-registration.properties` dosyasını kaldır (varsa)
- [ ] Crashlytics'e ilk crash raporları düşüyor mu kontrol et
- [ ] AdMob doldurma oranı ve gelir raporları
- [ ] Post-release TODO listesi: iyileştirmeler, kullanıcı geri bildirimleri

---

## Tekrar eden notlar (her uygulamada)
- Keystore ayrı tut (her uygulama kendi `upload-keystore.jks`'si)
- Package name benzersiz olmalı, sonradan değişmez
- Her AAB yüklemesinde version code (`+X`) artmalı, düşürülemez
- İlk yayından sonra güncellemeler **kapalı test/14 gün süreci gerektirmez**, direkt production'a yükleyebilirsin
- Farklı uygulamaların 14-gün sayaçları paralel işler — ikinci uygulamayı birinciyi beklemeden başlatabilirsin
