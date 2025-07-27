# Vize Danışmanlık CRM v0.2.5

Bu proje, vize danışmanlık süreçlerini yönetmek için geliştirilmiş bir **Enterprise CRM (Müşteri İlişkileri Yönetimi)** uygulamasıdır. Flutter ve Firebase kullanılarak oluşturulmuştur.

## 🎉 v0.2.5 - Real-time Bildirimler Sürümü

### 🔔 Yeni Özellikler
- **Firebase Cloud Messaging (FCM)** ile real-time bildirimler
- **7 farklı bildirim türü** (Application, Appointment, Approval, System, Message, Customer, Test)
- **Modern bildirim dropdown** menüsü ve badge sayısı
- **Test bildirimi** gönderme sistemi
- **Kalıcı bildirim saklama** ve okundu/okunmadı durumu

## ✨ Temel Özellikler

### 🔐 Kullanıcı Yönetimi
*   **Rol bazlı kimlik doğrulama** (admin/danışman)
*   **Güvenli oturum yönetimi**

### 👥 Müşteri Yönetimi
*   **Müşteri ekleme, listeleme, arama**
*   **Güvenli silme (soft delete)**
*   **Detaylı müşteri profilleri**

### 📋 Başvuru Yönetimi
*   **Müşterilere özel başvurular**
*   **Danışman atama sistemi**
*   **Dosya yükleme ve yönetimi**

### 📊 Dashboard v2
*   **Modern ve responsive tasarım**
*   **Real-time bildirimler**
*   **Anlık istatistikler**
*   **Son başvuruların listelenmesi**

### 🎨 Tema ve Dil Desteği
*   **Karanlık/Açık tema** desteği
*   **Türkçe/İngilizce** çoklu dil desteği
*   **Kullanıcı tercihlerinin kaydedilmesi**

### 🔔 Real-time Bildirimler
*   **Firebase Cloud Messaging** entegrasyonu
*   **Anlık bildirim alma**
*   **Badge sayısı göstergesi**
*   **Test bildirimi sistemi**

### 🛡️ Güvenli ve Modern Altyapı
*   **Firebase** (Auth, Firestore, Storage, FCM)
*   **Flutter web** (Canvaskit)
*   **Provider pattern** ile state management
*   **SharedPreferences** ile kalıcı veri saklama

## 🚀 Kurulum ve Çalıştırma

Bu projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin.

### Gereksinimler

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (versiyon 3.x veya üstü)
*   [Firebase CLI](https://firebase.google.com/docs/cli)
*   Bir Firebase projesi ve bu projeye ait `firebase_options.dart` dosyası.

### Adımlar

1.  **Projeyi Klonlayın:**
    ```bash
    git clone <proje_repository_adresi>
    cd crm
    ```

2.  **Firebase Yapılandırması:**
    *   Kendi Firebase projenizi oluşturun.
    *   `flutterfire configure` komutunu kullanarak projenizi Firebase'e bağlayın ve `lib/firebase_options.dart` dosyasının oluştuğundan emin olun.
    *   Firebase konsolundan **Authentication** (E-posta/Şifre ile), **Firestore Database** ve **Storage** servislerini aktif edin.
    *   Firestore veritabanı kurallarını (`Rules`) aşağıdaki gibi düzenleyin:
      ```
      rules_version = '2';
      service cloud.firestore {
        match /databases/{database}/documents {
          match /{document=**} {
            allow read, write: if request.auth != null;
          }
        }
      }
      ```

3.  **Bağımlılıkları Yükleyin:**
    ```bash
    flutter pub get
    ```

4.  **Uygulamayı Çalıştırın:**
    ```bash
    flutter run -d chrome --web-renderer canvaskit
    ```

Uygulama, Chrome tarayıcısında başlayacaktır. 