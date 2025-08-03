# CRM Flutter Uygulaması

Bu depo; Flutter ile geliştirilen, Firebase servisleri (Auth, Firestore, Storage, Messaging) ve web/PWA desteği olan bir CRM uygulamasının kaynak kodlarını içerir.

Sürüm: 0.3.1+2

## İçindekiler
- [Ön Koşullar](#ön-koşullar)
- [Kurulum ve Çalıştırma](#kurulum-ve-çalıştırma)
- [Proje Yapısı](#proje-yapısı)
- [PWA Notları](#pwa-notları)
- [i18n (Yerelleştirme)](#i18n-yerelleştirme)
- [Sürümleme ve Notlar](#sürümleme-ve-notlar)
- [Geliştirme İpuçları](#geliştirme-ipuçları)
- [Lisans](#lisans)

---

## Ön Koşullar
- Flutter SDK (stable kanal tavsiye edilir)
- Dart SDK (Flutter ile gelir)
- Bir Firebase projesi ve aşağıdaki servislerin etkinleştirilmiş olması:
  - Authentication (Email/Password vb.)
  - Cloud Firestore
  - Storage (opsiyonel modüller için)
  - Firebase Cloud Messaging (opsiyonel PWA bildirimleri için)
- Web geliştirme için Chrome (Flutter Web debug hedefi)

Sürüm kontrolleri:
```
flutter --version
dart --version
```

---

## Kurulum ve Çalıştırma

1) Bağımlılıkları indir
```
flutter pub get
```

2) Firebase yapılandırması
- lib/firebase_options.dart dosyasında projenize ait Firebase konfigürasyonu bulunur.
- Gerekirse FlutterFire CLI ile yeniden oluşturabilirsiniz:
```
dart pub global activate flutterfire_cli
flutterfire configure
```
- Web için: web/firebase-messaging-sw.js servis çalışanı dosyası mevcuttur. Firebase Messaging kullanacaksanız, alan adınızın bu SW’ı servis edebildiğinden emin olun.

3) Uygulamayı çalıştırma (Web – Chrome)
```
flutter run -d chrome
```

4) Uygulamayı çalıştırma (Desktop/Diğer)
- Desktop hedefleri için platform gereksinimlerini sağlayın (Windows/Mac/Linux).
- Ardından:
```
flutter run
```

Not: Üretim dağıtımı için:
```
flutter build web
```
çıktısı web/build dizininde oluşur ve Netlify/GitHub Pages/Heroku gibi yerlere dağıtabilirsiniz.

---

## Proje Yapısı

Önemli klasörler:
- lib/main.dart: Uygulama girişi, tema/yerelleştirme/provider kurulumları ve AuthWrapper.
- lib/routes/: İsimli rotalar ve RouteGenerator.
- lib/screens/: Ekranlar (dashboard_v2, login_screen, müşteri, başvuru, ayarlar vb.).
- lib/services/: Servisler (auth_service, basvuru_servisi, fcm_service, ...).
- lib/models/: Veri modelleri.
- lib/widgets/: Paylaşılan widget’lar.
- lib/generated/l10n/: AppLocalizations kaynakları (ARB’den üretilen dosyalar).
- web/: PWA için manifest.json, firebase-messaging-sw.js ve statik dosyalar.

---

## PWA Notları

Dosyalar:
- web/manifest.json: Uygulama adı, kısa ad, ikonlar ve başlangıç URL’si.
- web/firebase-messaging-sw.js: Firebase Messaging için servis çalışanı (SW).

Dikkat edilmesi gerekenler:
- Manifest’te ikon yollarının doğru olduğundan emin olun (web/icons/*).
- Uygulamanın kısa adı (short_name) ve name alanları web başlatıcılarda görünür.
- PWA offline cache stratejisi:
  - Flutter web, üretim build’inde kendi asset manifest ve cache mekanizmasını oluşturur.
  - Ek rota/dosya cache’i isteniyorsa özel SW yazılabilir (ileri seviye).
- FCM için:
  - SW dosyası kök dizinde servis edilmelidir (web/firebase-messaging-sw.js).
  - Prod alan adınızda SW’ın düzgün yüklendiğini (navigator.serviceWorker) doğrulayın.

Dağıtım örnekleri:
- Netlify: netlify.toml yapılandırması ile /build/web klasörü servis edilebilir.
- GitHub Pages: build web çıktısını gh-pages dalına publish edebilirsiniz.
- Firebase Hosting: “firebase init hosting” ve “firebase deploy” komutlarıyla servis edebilirsiniz.

---

## i18n (Yerelleştirme)

Kaynak dosyalar:
- lib/l10n/app_tr.arb
- lib/l10n/app_en.arb
- lib/generated/l10n/ ve lib/generated/l10n/app_localizations.dart (otomatik üretilir)

Kullanım:
- MaterialApp içinde:
  - localizationsDelegates ve supportedLocales tanımlıdır.
- Metin kullanımı:
```
final loc = AppLocalizations.of(context)!;
Text(loc.appTitle);
```

Yeni anahtar ekleme akışı:
1) app_tr.arb ve app_en.arb dosyalarına aynı anahtarları uygun çevirilerle ekleyin.
2) Flutter gen ile veya “flutter pub get” sonrasında üretilen AppLocalizations sınıflarını kullanın.
3) Derlemede eksik çeviri/anahtar eşleşmelerini takip edin.

Dil ve tema kontrolü:
- LocalizationService, dil seçimlerini yönetir.
- ThemeService, light/dark temayı yönetir.

---

## Sürümleme ve Notlar

- Versiyon: pubspec.yaml’daki version alanı (ör. 0.3.1+2).
- Değişiklik günlükleri:
  - CHANGELOG.md (genel değişiklik listeleri)
  - RELEASE_NOTES_vX.Y.Z.md (özgül sürüm notları, varsa)
- Sürüm artırma adımları (öneri):
  1) pubspec.yaml versiyonu yükselt
  2) CHANGELOG.md ve/veya yeni RELEASE_NOTES dosyasını güncelle/ekle
  3) flutter analyze ve temel smoke testleri çalıştır
  4) build al ve dağıtım platformuna yükle

---

## Geliştirme İpuçları

- Analiz ve lint:
```
flutter analyze
```
- Hot restart/hot reload (flutter run içinde R/r).
- Yaygın uyarılar:
  - prefer_const_constructors, use_super_parameters: performans ve modern Dart önerileri.
  - unnecessary_non_null_assertion, invalid_null_aware_operator: null-safety temizlikleri.
  - avoid_print: üretimde logger kullanın (ör. lib/utils/logger.dart — AppLogger).
- Firebase hataları:
  - API anahtarları ve konfigürasyonların doğru olduğuna emin olun.
  - Yetki kuralları (Firestore Rules) geliştirme/üretim moduna uygun olmalı.

---

## Lisans

Bu proje için lisans bilgisi eklenmemiştir. Gerekli ise uygun bir lisans metni (MIT/Apache-2.0 vs.) bu bölüme eklenmelidir.
