# Changelog

Tüm anlamlı değişiklikler bu dosyada takip edilir. Sürümleme SemVer prensiplerine yaklaşık olarak uyar.

## v0.3.0 — 2025-08-04

Bu sürüm, Flutter Web için üretim derlemesi, i18n güçlendirmeleri ve güvenli bağımlılık güncellemeleri içerir. Ayrıca dağıtım ve belgeleme iyileştirmeleri yapılmıştır.

### Öne Çıkanlar
- Flutter Web prod derlemesi alındı ve Netlify dağıtımına hazır hale getirildi (build/web).
- DashboardV2’de mobil menü ve bazı sabit metinler i18n’e taşındı.
- PWA manifest gözden geçirildi (ad, renkler, ikonlar doğrulandı).
- Güvenli (major olmayan) bağımlılık güncellemeleri uygulandı.

### Detaylı Değişiklikler
- i18n
  - DashboardV2:
    - Mobil menü etiketleri i18n: trash, reports, automation, taskManagement, advancedReporting, messages
    - BottomNavigationBar etiketleri i18n: mobileHome, mobileCustomers, mobileApplications, mobileCalendar
    - “Müşteri Türü Seçin” diyalog başlığı ve seçenekleri i18n: addCustomer, filterIndividual, filterCorporate
  - TR/EN ARB dosyaları senkron kontrol edildi.

- Bildirim Modeli ve Widget
  - NotificationPriority enum ASCII’ye çevrildi: dusuk, yuksek (illegal character 252/351 hataları giderildi).
  - Geriye dönük uyumluluk: fromFirestore içinde eski “düşük/yüksek” değerleri yeni enumlara map edildi.
  - notification_tile.dart enum referansları düzeltildi.

- Bağımlılıklar
  - Güvenli yükseltme: flutter pub upgrade
    - google_fonts 6.2.1 → 6.3.0
    - mailer 6.4.1 → 6.5.0
  - cached_network_image projeye eklendi ve resolve edildi.
  - Not: Major yükseltmeler (Firebase 4.x/6.x, fl_chart 1.0.0, rxdart 0.28.0 vb.) kod uyarlaması gerektirdiği için bu sürümde uygulanmadı.

- PWA
  - Manifest güncellendi ve tema ile uyumlu renkler doğrulandı.
  - --pwa-strategy=none ile Flutter SW devre dışı; web/firebase-messaging-sw.js ayrı servis edilmeye devam ediyor.
  - Not: Prod FCM için web/firebase-messaging-sw.js içindeki firebaseConfig değerlerinin prod’a uygun şekilde güncellenmesi gerekir.

- Kod Kalitesi / Analiz
  - flutter analyze çalıştırıldı; kırmızı hata yok, çoğu uyarı performans/temizlik (prefer_const_constructors, unnecessary_non_null_assertion, avoid_print vb.).
  - İlerleyen sürümlerde kademeli lint temizliği ve Logger geçişi planlandı.

- Derleme
  - flutter build web --release başarıyla tamamlandı. build/web dağıtıma hazır.

### Dağıtım Notları
- Netlify için:
  - Build command: flutter build web --release
  - Publish directory: build/web
  - SPA yönlendirme gerekiyorsa _redirects: `/*  /index.html  200`
- Firebase Messaging üretim kullanımı için: firebaseConfig değerleri Netlify alan adına uygun şekilde güncellenmelidir.

### Gelecek Plan (Özet)
- Kademeli major dependency yükseltmeleri (Firebase paketleri, fl_chart 1.0.0, rxdart 0.28.0, flutter_lints 6.0.0)
- Lint temizliği ve AppLogger’a geçiş (avoid_print yerine)
- Diğer ekranlarda i18n güçlendirmelerinin sürdürülmesi (Login/Settings vb.)
