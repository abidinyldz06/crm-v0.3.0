# Vize Danışmanlık CRM

Bu proje, vize danışmanlık süreçlerini yönetmek için geliştirilmiş bir CRM (Müşteri İlişkileri Yönetimi) uygulamasıdır. Flutter ve Firebase kullanılarak oluşturulmuştur.

## ✨ Temel Özellikler

*   **Kullanıcı Yönetimi:** Rol bazlı (admin/danışman) kimlik doğrulama.
*   **Müşteri Yönetimi:** Müşteri ekleme, listeleme, arama ve güvenli silme (soft delete).
*   **Başvuru Yönetimi:** Müşterilere özel başvurular oluşturma, danışman atama ve dosya yükleme.
*   **Dinamik Dashboard:** Ana ekranda son başvuruların anlık olarak listelenmesi.
*   **Güvenli ve Modern Altyapı:** Firebase (Auth, Firestore, Storage) ve Flutter web (Canvaskit) kullanılarak geliştirilmiştir.

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