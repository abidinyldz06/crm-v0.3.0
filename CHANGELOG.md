
# Vize Danışmanlık CRM - Değişiklik Günlüğü

## [v0.2.4] - 2025-01-27

### 🔔 Bildirim Sistemi ve Modern Ayarlar Sayfası
- **Bildirim Sistemi:**
  - AppBar'a profesyonel bildirim çanı eklendi (profil butonunun yerine)
  - Okunmamış bildirim sayısı için kırmızı badge sistemi (3 bildirim gösterimi)
  - PopupMenu ile dropdown bildirim listesi (4 farklı bildirim türü)
  - Bildirim türleri: Yeni Başvuru, Randevu Hatırlatması, Başvuru Onayı, Sistem Güncellemesi
  - Tüm bildirimler dialog'u (6 bildirim örneği ile)
  - Akıllı yönlendirme: Bildirime tıklayınca ilgili sayfaya gitme
  - Okunmuş/okunmamış durum yönetimi (mavi vurgu sistemi)
  - "Tümünü Okundu İşaretle" toplu işlem özelliği
- **Modern Ayarlar Sayfası:**
  - Kapsamlı ayarlar sayfası oluşturuldu (settings_screen_simple.dart)
  - 5 ana bölüm: Profil, Görünüm & Dil, Bildirimler, Sistem & Destek, Güvenlik
  - Modern section header tasarımı (renkli ikonlar ve açıklamalar)
  - Gelişmiş switch tile'lar (modern container tasarımı)
  - Kullanıcı ayarlarını Firestore'a kaydetme servisi
  - Dil seçimi (Türkçe/English), tema ayarları, bildirim tercihleri
  - Sistem bilgileri, depolama kullanımı, yardım ve destek
  - Şifre değiştirme ve güvenli çıkış yapma özellikleri
- **UI/UX İyileştirmeleri:**
  - Renkli ikonlar ve kategori bazlı renk kodlaması
  - Responsive tasarım (web ve mobil uyumlu)
  - Modern card-based layout
  - Hover efektleri ve smooth animasyonlar
  - Kullanıcı dostu dialog'lar ve feedback sistemleri
- **Backend Geliştirmeleri:**
  - KullaniciServisi'ne updateUserSettings() metodu eklendi
  - getUserSettings() metodu ile ayar okuma
  - updateUserRole() admin fonksiyonu
  - getAllUsers() kullanıcı yönetimi metodu
- **Test Sonuçları:** 
  - Bildirim sistemi Chrome'da tam fonksiyonel
  - Ayarlar sayfası responsive ve kullanıcı dostu
  - Tüm yönlendirmeler ve popup'lar çalışıyor
  - Firebase entegrasyonu sorunsuz

---

## [v0.2.3] - 2025-01-26

### 🎯 Faz 8: Sistem Stabilizasyonu ve Tam Fonksiyonel CRM Tamamlandı
- **Kritik Sistem Düzeltmeleri:**
  - Tüm derleme hataları sistematik olarak çözüldü
  - Eksik dosyalar ve import'lar tamamlandı
  - Firebase bağlantı sorunları giderildi
  - NavigationRail overflow sorunu çözüldü
- **Modül Tamamlama:**
  - **Otomasyon Modülü:** E-posta ve SMS otomasyonları tamamlandı
  - **SMS Otomasyonları:** Kural yönetimi, şablon sistemi ve loglama
  - **Gelişmiş Otomasyonlar:** İş akışı, zamanlayıcı ve koşullu otomasyonlar
  - **Görev Yönetimi:** Görev oluşturma, takip ve durum yönetimi
  - **Gelişmiş Raporlama:** KPI'lar, trend analizleri ve özelleştirilebilir raporlar
- **UI/UX İyileştirmeleri:**
  - İkon sorunları düzeltildi (placeholder ikonlar kaldırıldı)
  - Türkçe karakter uyumluluğu sağlandı
  - Responsive tasarım optimizasyonu
  - Navigation menüsü stabilizasyonu
- **Kod Kalitesi:**
  - Null safety iyileştirmeleri
  - Model sınıfları arası tutarlılık
  - Servis katmanı optimizasyonu
  - Error handling geliştirmeleri
- **Test Sonuçları:** 
  - Uygulama Chrome'da tam fonksiyonel çalışıyor
  - Tüm modüller erişilebilir ve çalışır durumda
  - Firebase entegrasyonu sorunsuz
  - Real-time veri akışı aktif

---

## [v0.2.2] - 2025-01-21

### 🎯 Faz 7: Sistem Stabilizasyonu ve Hata Düzeltmeleri Tamamlandı
- **Kritik Hata Düzeltmeleri:**
  - Tüm derleme hataları sistematik olarak çözüldü
  - Eksik import'lar ve referanslar düzeltildi
  - Model sınıfları arasındaki tutarsızlıklar giderildi
  - Constructor sorunları çözüldü
- **Finans Modülü Temizliği:**
  - Gereksiz finans modülü tamamen kaldırıldı
  - TeklifModel, OdemeModel ve ilgili servisler silindi
  - Finans referansları tüm dosyalardan temizlendi
  - Dashboard'dan finans sekmesi kaldırıldı
- **Menü Optimizasyonu:**
  - NavigationRail'den gereksiz "Raporlar" sekmesi kaldırıldı
  - "Gelişmiş Raporlar" → "Raporlar" olarak yeniden adlandırıldı
  - Sekme indeksleri yeniden düzenlendi
  - Mobil ve web menüleri senkronize edildi
- **Uygulama Stabilizasyonu:**
  - AutomationManagementScreen basit placeholder haline getirildi
  - AdvancedReportingScreen basitleştirildi ve çalışır hale getirildi
  - MusteriDetay constructor'ı musteriId parametresi kullanacak şekilde düzeltildi
  - Tüm navigation referansları güncellendi
- **Kod Temizliği:**
  - KPIService referansları geçici olarak devre dışı bırakıldı
  - Kullanılmayan import'lar temizlendi
  - Dead code kaldırıldı
  - Flutter cache sorunları çözüldü
- **Test Sonuçları:** 
  - Uygulama Chrome'da başarıyla çalışıyor
  - Firebase bağlantısı aktif
  - Tüm temel özellikler çalışır durumda
  - Responsive tasarım sorunsuz çalışıyor

---

## [v0.2.1] - 2025-01-21

### 🎯 Faz 6: Eksik Temel Fonksiyonlar Tamamlandı
- **Müşteri Ekleme Sistemi:**
  - Eksik olan `musteri_ekle.dart` ekranı oluşturuldu
  - Kapsamlı müşteri ekleme formu (kişisel, iletişim, başvuru bilgileri)
  - Form validasyonu ve hata yönetimi
  - Tarih seçici entegrasyonu
  - Responsive tasarım ile mobil/web uyumluluğu
- **MusteriModel Geliştirmeleri:**
  - TC Kimlik No, Pasaport No, Doğum Tarihi alanları eklendi
  - Güncelleme tarihi ve aktiflik durumu alanları eklendi
  - toMap ve fromFirestore metodları güncellendi
  - Null safety iyileştirmeleri
- **MusteriServisi Güncellemeleri:**
  - MusteriModel ile uyumlu `musteriEkle` metodu eklendi
  - Backward compatibility için eski Map versiyonu korundu
  - Gelişmiş veri validasyonu ve hata yönetimi
- **Dashboard Entegrasyonu:**
  - Müşteri ekleme ekranı import edildi
  - Bireysel müşteri ekleme butonu aktif hale getirildi
  - Müşteri türü seçim dialog'u düzgün çalışıyor
- **Test Sonuçları:** Müşteri ekleme sistemi test edildi ve sorunsuz çalışıyor

---

## [v0.2.0] - 2025-01-21

### 🎯 Faz 5: Enterprise Otomasyon ve Gelişmiş Raporlama Sistemi Tamamlandı
- **Otomasyon Yönetim Sistemi:**
  - Tam özellikli otomasyon kuralları oluşturma ve yönetim sistemi
  - Tetikleyici (trigger) ve eylem (action) tabanlı kural motoru
  - E-posta, SMS, WhatsApp ve sistem bildirimi gönderme özellikleri
  - Başvuru durumu değişikliği, tarih bazlı ve manuel tetikleyiciler
  - Aktif/pasif kural durumu yönetimi ve gerçek zamanlı izleme
- **Gelişmiş Raporlama Sistemi:**
  - Kapsamlı istatistik ve analiz dashboard'u
  - Danışman performans raporları ve karşılaştırmalı analizler
  - Zaman serisi grafikleri ve trend analizleri
  - Filtrelenebilir raporlar (tarih, danışman, kategori, durum)
  - CSV export özelliği ile veri dışa aktırma
- **Dashboard Entegrasyonu:**
  - Hem web hem mobil arayüzde yeni modüller entegre edildi
  - NavigationRail'e "Otomasyon" ve "Gelişmiş Raporlar" sekmeleri eklendi
  - Mobil popup menüsünde yeni seçenekler eklendi
  - Responsive tasarım ile tüm cihazlarda uyumlu çalışma
- **Kod Kalitesi ve Performans:**
  - Singleton pattern ile servis katmanı optimize edildi
  - Real-time veri akışı için StreamBuilder kullanımı
  - Null safety ve tip güvenliği iyileştirmeleri
  - Modüler kod yapısı ile bakım kolaylığı
- **Test Sonuçları:** Tüm yeni özellikler Chrome'da test edildi ve sorunsuz çalışıyor

---

## [v0.1.3] - 2025-01-13

### 🎯 Faz 4: Gelişmiş Raporlama ve Analiz Sistemi Tamamlandı
- **Gelişmiş Raporlama Servisi:** Singleton pattern ile real-time istatistik ve analiz servisi oluşturuldu
- **Chart Widget'ları:** Pie chart, line chart, bar chart ve istatistik kartları için yeniden kullanılabilir widget'lar geliştirildi
- **Gelişmiş Raporlama Ekranı:** 
  - Genel Bakış, Trendler, Performans ve Filtreler sekmeleri eklendi
  - Danışman, kategori, durum ve tarih aralığına göre filtreleme sistemi
  - Filtrelenmiş başvuru sonuçları ve durum renk kodlaması
- **Model Sınıfları Güncellendi:** 
  - `TeklifModel`, `BasvuruModel`, `KullaniciModel` sınıflarına `fromMap` factory constructor'ları eklendi
  - Firestore veri parsing'i için eksik alanlar tamamlandı
- **Tip Güvenliği:** 
  - `doc.data()` metodları `Map<String, dynamic>` tipine cast edildi
  - Firestore query field isimleri düzeltildi
  - Enum karşılaştırmaları string literal yerine enum constant kullanacak şekilde güncellendi
- **Kod Kalitesi:** 
  - Syntax hataları düzeltildi
  - Import hataları çözüldü
  - Null safety uyarıları giderildi
- **Test Sonuçları:** Uygulama Chrome'da sorunsuz çalışıyor, tüm raporlama özellikleri aktif

---

## [v0.1.2] - 2025-01-13

### 🎯 Faz 3: Gelişmiş Bildirim ve Arama Sistemi Tamamlandı
- **Gelişmiş Bildirim Sistemi:** Real-time push notification altyapısı, badge'ler ve mesajlaşma sistemi entegre edildi
- **Global Arama Sistemi:** Çoklu kriter arama, filtreleme ve sonuç listeleme özellikleri eklendi
- **E-posta Sistemi:** SMTP konfigürasyonu ve otomatik bildirim e-postaları sistemi kuruldu
- **UI/UX İyileştirmeleri:** 
  - Mesaj ve global arama ikonları sol navigasyondan kaldırılıp sağ üst header'a taşındı
  - "Raporlar" menüsü kaldırıldı, sadece "Gelişmiş Raporlama" bırakıldı
  - NavigationRail layout overflow hataları düzeltildi
  - Menü sıralaması optimize edildi
- **Kod Kalitesi:** 
  - Singleton pattern düzeltmeleri
  - Null safety uyarıları giderildi
  - Import hataları çözüldü
  - PowerShell komut syntax açıklamaları eklendi
- **Test Sonuçları:** Uygulama Chrome'da sorunsuz çalışıyor, tüm özellikler aktif

---

## [v0.1.1] - 2025-01-13

### 🎯 Faz 1: Acil Eksiklikler Tamamlandı
- **Route Sistemi Düzeltildi:** `/musteri_detay` ve `/basvuru_detay` route'ları eklendi, `onGenerateRoute` ile tip güvenli navigation sağlandı
- **MusteriDetay Widget'ı Geliştirildi:** Hem String ID hem MusteriModel kabul ediyor, StreamBuilder ile gerçek zamanlı veri çekiyor
- **MusteriServisi Geliştirildi:** `getMusteriByIdStream()` metodu eklendi, gerçek zamanlı müşteri verisi sağlıyor
- **Navigation Tutarlılığı:** Tüm müşteri listelerinde aynı navigation yöntemi, String ID ile route navigation
- **Kod Temizliği:** Kullanılmayan import'lar temizlendi, null safety uyarıları giderildi
- **Test Sonuçları:** Uygulama Chrome'da başarıyla çalışıyor, Firebase bağlantıları aktif, müşteri detay sayfası sorunsuz açılıyor

---

## [v0.0.8] - 2025-01-13

### 🐛 Hata Düzeltmeleri ve İyileştirmeler
- **Platform Uyumluluğu:**
  - `raporlar_ekrani.dart` dosyasındaki `dart:html` importu `universal_html` paketi ile değiştirilerek Windows ve diğer masaüstü platformlarında derleme hataları giderildi.
  - CSV dışa aktarma işlevi platforma özgü hale getirildi: Web'de indirme, masaüstü/mobilde dosya kaydetme.
  - `path_provider` paketi eklenerek masaüstü ve mobil platformlarda dosya kaydetme işlevselliği sağlandı.
  
- **Derleme Hataları:**
  - `dashboard_v2.dart` dosyasındaki "Not a constant expression" hataları, `NavigationRailDestination` ve `PopupMenuItem` widget'larından `const` anahtar kelimesi kaldırılarak çözüldü.
  - StreamBuilder içeren dinamik widget'ların const olmayan yapıya dönüştürülmesiyle derleme hataları giderildi.

### 📦 Paket Güncellemeleri
- `universal_html: ^2.2.4` paketi eklendi (platformlar arası HTML API uyumluluğu için).
- `path_provider` paketi güncellendi (masaüstü dosya işlemleri için).

---

## [v0.0.7] - 2024-07-12

### Yeni Özellikler
- **Finans Modülü (Sürüm 1.0):**
  - Teklif ve Ödeme veri modelleri (`TeklifModel`, `OdemeModel`) ve ilgili servis katmanı (`FinansServisi`) oluşturuldu.
  - Ana menüye "Finans" sekmesi eklendi.
  - Oluşturulan tüm tekliflerin listelendiği bir ana finans ekranı tasarlandı.
  - Müşteri (bireysel/kurumsal) detay sayfalarından, o müşteriye özel yeni teklif oluşturma özelliği eklendi. Teklif formu, dinamik hizmet kalemi ekleme/çıkarma ve toplam tutarı anlık hesaplama yeteneğine sahiptir.
  - Teklif detay ekranı oluşturuldu. Bu ekranda teklifin durumu (taslak, onaylandı vb.) güncellenebilir.
  - Teklif detay ekranından, o teklife ait yeni ödemeler ekleme ve mevcut ödemeleri listeleme özelliği tamamlandı.

### Hata Düzeltmeleri ve İyileştirmeler
- **Derleme ve Bağımlılık Hataları:**
  - Proje genelinde `flutter upgrade` ve `flutter pub outdated` komutları ile paketler güncellendi, SDK ve paketler arası sürüm uyumsuzlukları giderildi.
  - `theme.dart` dosyasındaki inatçı önbellek ve derleme hatası, dosyanın `theme_v2.dart` olarak yeniden oluşturulmasıyla kalıcı olarak çözüldü.
  - Eksik `import` ifadelerinden kaynaklanan derleme hataları düzeltildi.
- **Dashboard Sorunları:**
  - "Finans" sekmesinin görünmemesine neden olan ve `dashboard.dart` dosyasında tekrarlayan sorun, dosyanın `dashboard_v2.dart` olarak yeniden oluşturulmasıyla çözüldü.

---

## [v0.0.6] - 2024-07-12

### Yeni Özellikler
- **Kurumsal Müşteri Modülü (Sürüm 2.0 başlangıcı):**
  - Bireysel müşterilerin yanı sıra kurumsal müşterileri (şirketleri) yönetmek için altyapı oluşturuldu.
  - Müşteriler sayfası, Bireysel ve Kurumsal müşterileri gösterecek şekilde sekmeli bir yapıya kavuşturuldu.
  - Yeni kurumsal müşteri ekleme ve listeleme özellikleri eklendi.
  - Bireysel müşterileri, oluşturulurken veya güncellenirken bir kuruma bağlama özelliği eklendi.
  - Kurumsal müşteri detay sayfasında, o kuruma bağlı irtibat kişileri listelenmektedir.
- **Raporlama Modülü (İlk Versiyon):**
  - Projeye `fl_chart` ve `csv` paketleri entegre edildi.
  - 'Raporlar' adında yeni bir sayfa eklendi.
  - Başvuru durumlarının dağılımını gösteren bir pasta grafiği (pie chart) eklendi.
  - Tüm başvuru verilerini CSV formatında dışa aktırma özelliği eklendi.
- **Finans Modülü (Temel Altyapı):**
  - Teklif ve ödemeler için `TeklifModel` ve `OdemeModel` veri yapıları oluşturuldu.
  - Finansal işlemleri yönetecek `FinansServisi` eklendi.
  - 'Finans' adında yeni bir sayfa eklendi ve bu sayfada oluşturulan teklifler listelenmektedir.
  - Müşteri (bireysel/kurumsal) detay sayfalarından o müşteriye özel yeni teklif oluşturma ekranı ve işlevselliği eklendi.

### Hata Düzeltmeleri ve İyileştirmeler
- **Paket ve SDK Güncellemeleri:**
  - Proje bağımlılıkları ve Flutter SDK uyumluluğu ile ilgili çok sayıda inatçı hata, proje temizliği, paket yükseltmeleri ve Flutter'ın yeniden yapılandırılmasıyla çözüldü.
  - `CardThemeData` gibi güncel Flutter sürümleriyle uyumlu olmayan tema tanımları düzeltildi.
- **Veritabanı Yapılandırması:**
  - Firestore'da sorgular için eksik olan `index` (dizin) oluşturuldu.
  - Geliştirme ortamında daha esnek veri yazımına olanak tanıyan güvenlik kuralları güncellendi.

---

## [v0.0.5] - 2024-07-11

### 🎨 UI/UX Yenilemesi (Sprint 5 - Material 3)

*   **Global Tema:** Uygulama geneli için Material 3 standartlarına uygun, modern ve tutarlı bir tema (`ThemeData`) oluşturuldu. Kurumsal mavi renk paleti ve `Google Fonts` ile profesyonel bir görünüm kazandırıldı.
*   **Modernize Edilmiş Arayüz:** Dashboard, liste, detay ve form ekranları dahil olmak üzere tüm uygulama, yeni temayla uyumlu hale getirilerek baştan sona yeniden tasarlandı.
*   **Bileşen Stilleri:** Kartlar (`Card`), butonlar (`ElevatedButton`, `FilledButton`), metin giriş alanları (`TextFormField`) ve listeler (`ListView`) gibi tüm temel bileşenler, Material 3 prensiplerine göre modernize edildi.

### 🐛 Hata Düzeltmeleri

*   Flutter web'de karşılaşılan ve kullanıcı arayüzü güncellemelerinden kaynaklanan `Assertion failed: targetElement == domElement` çalışma zamanı hatası, sayfa yapıları `FutureBuilder` ve `ListView` kullanılarak yeniden düzenlenerek kalıcı olarak çözüldü.
*   `google_fonts` paketinin projeye dahil edilememesinden kaynaklanan derleme hatası giderildi.

---

## [v0.0.4] - 2025-07-11

### ✨ Yeni Özellikler

*   **Dashboard Geliştirmesi:** Ana ekrana (`Dashboard`) tıklandığında, oluşturulma tarihine göre en son 10 başvuruyu gösteren dinamik bir liste eklendi.
*   **Müşteri Arama Fonksiyonu:** "Müşteriler" ekranına, müşteri adına göre anlık arama ve filtreleme yapabilen bir arama çubuğu entegre edildi.
*   **Navigasyon Menüsü:** Hata ayıklama sürecinde kaybolan ana navigasyon menüsü (`NavigationRail`) yeniden yapılandırılarak uygulamaya eklendi.

### 🐛 Hata Düzeltmeleri

*   Proje genelinde model, servis ve ekranlar arasındaki tutarsızlıklardan kaynaklanan çok sayıda derleme hatası (`compilation error`) kökten çözüldü.
*   Paketler, `flutter pub upgrade` komutu ile en güncel ve uyumlu versiyonlarına yükseltildi.

---

## [v0.0.3] - 2024-07-26

### ✨ Yeni Özellikler

*   **Başvuru Ülkesi Eklendi:** Müşteri kayıt formuna, müşterinin hangi ülkeye vize başvurusu yapacağını belirten "Başvuru Yapılacak Ülke" alanı eklendi.
    *   `MusteriModel` güncellenerek `basvuruUlkesi` alanı eklendi.
    *   `MusteriEkle` ekranına yeni giriş alanı entegre edildi.
    *   `MusteriDetay` ekranında başvuru ülkesinin gösterilmesi sağlandı.

---

## [v0.0.2] - 2024-07-26

### ✨ Yeni Özellikler

*   **Müşteri ve Başvuru Yönetimi (Sprint 2):**
    *   **Müşteri Ekleme:** Yeni müşteri oluşturma formu ve servisi eklendi.
    *   **Başvuru Sistemi:** Müşterilere bağlı başvuru oluşturma altyapısı kuruldu.
    *   **Danışman Atama:** Yöneticilerin başvurulara danışman ataması için arayüz ve altyapı geliştirildi.
    *   **Dosya Yönetimi:** Başvurulara dosya ekleme (`file_picker`), bulutta saklama (`firebase_storage`) ve görüntüleme (`url_launcher`) özellikleri eklendi.
*   **Kullanıcı Arayüzü Geliştirmeleri:**
    *   Müşteri, başvuru ve detay ekranları oluşturuldu.
    *   Veri listelemek için `BasvuruListTile` gibi yeniden kullanılabilir widget'lar geliştirildi.

### 🐛 Hata Düzeltmeleri

*   Firebase Firestore kural ve indeks hataları giderilerek veri okuma/yazma sorunları çözüldü.
*   "Müşteri Ekle" butonu tüm kullanıcı rollerinin görebilmesi için güncellendi.

---

## [v0.0.5] - 2024-07-11

### Yeni Özellikler
- **Takvim Modülü:**
  - Projeye `table_calendar` paketi entegre edilerek dinamik bir takvim modülü eklendi.
  - Takvim arayüzü, daha okunaklı ve belirgin olması için özel olarak stillendirildi ve Türkçeleştirildi.
  - Müşteri detay sayfasından, seçili müşteri için takvime yeni randevu ekleme özelliği geliştirildi.
  - Takvim ekranında, seçilen güne ait randevular liste halinde görüntülenmektedir.
  - Firestore veritabanına `appointments` koleksiyonu ve ilgili servis/model katmanları eklendi.

### Hata Düzeltmeleri
- **Kimlik Doğrulama ve Veri Gösterimi:**
  - Uygulama başlangıcında kullanıcı rolünün alınamaması ve bu sebeple "Başvurular" gibi listelerin boş görünmesi sorunu, Firestore'a eksik olan `users` koleksiyonunun ve kullanıcı belgesinin eklenmesiyle çözüldü.
  - Bu kritik hata, hem başvuruların hem de randevuların artık doğru bir şekilde gösterilmesini sağladı.

---

## [v0.0.1] - 2024-07-25

### ✨ Yeni Özellikler

*   **Proje Kurulumu ve Temel Altyapı (Sprint 1):**
    *   **Firebase Entegrasyonu:** Firebase Auth (kimlik doğrulama), Firestore (veritabanı) ve Storage (dosya depolama) projeye entegre edildi.
    *   **GIT Versiyon Kontrolü:** Proje GIT ile versiyon kontrolü altına alındı.
    *   **Kullanıcı Sistemi:** Rol bazlı (admin/consultant) kullanıcı modeli ve giriş/çıkış altyapısı oluşturuldu.
    *   **Giriş Ekranı:** Material Design standartlarına uygun bir giriş ekranı tasarlandı.

### 🐛 Hata Düzeltmeleri

*   `flutterfire` yapılandırma sorunları giderildi.
*   Flutter web render motoru `canvaskit` olarak ayarlanarak performans ve uyumluluk artırıldı.
*   Eksik olan `firebase_options.dart` dosyası manuel olarak oluşturularak proje çalışır hale getirildi. 