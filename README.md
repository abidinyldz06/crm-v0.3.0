# 🚀 Vize CRM v0.2.5 Real-time Edition

[![Netlify Status](https://api.netlify.com/api/v1/badges/YOUR_SITE_ID/deploy-status.svg)](https://app.netlify.com/sites/YOUR_SITE_NAME/deploys)

**Modern, Real-time Müşteri İlişkileri Yönetim Sistemi**

🌐 **Live Demo**: Netlify'de deploy ediliyor...

## ✨ Özellikler

### 🔔 Real-time Bildirimler
- Firebase Cloud Messaging entegrasyonu
- 7 farklı bildirim türü (Application, Appointment, Approval, System, Message, Customer, Test)
- Real-time badge updates
- Background/foreground mesaj işleme

### 🎨 Modern UI/UX
- **Responsive Design**: Mobil, tablet, desktop uyumlu
- **Dark/Light Theme**: Kullanıcı tercihi
- **Multi-language**: Türkçe/İngilizce desteği
- **PWA Support**: Ana ekrana eklenebilir

### 🔧 Teknik Özellikler
- **Flutter Web**: Cross-platform web uygulaması
- **Firebase**: Authentication, Firestore, Cloud Messaging
- **Provider Pattern**: State management
- **Responsive Layout**: Tüm cihazlarda mükemmel görünüm

## 🏃‍♂️ Hızlı Başlangıç

### Development
```bash
# Repository'yi clone et
git clone https://github.com/KULLANICI_ADI/crm-web.git
cd crm-web

# Dependencies yükle
flutter pub get

# Development server başlat
flutter run -d chrome --web-port 8080
```

### Production Build
```bash
# Web için build et
flutter build web --release

# GitHub Pages için build et
flutter build web --release --base-href "/crm-web/"
```

## 🌐 Deployment

### Netlify (Otomatik) - Önerilen
1. Repository'yi GitHub'a push et
2. Netlify'de "New site from Git" seç
3. Repository'yi bağla
4. Build settings otomatik algılanır (netlify.toml sayesinde)
5. Deploy et!

**Build Command**: `flutter build web --release --base-href / --no-tree-shake-icons`  
**Publish Directory**: `build/web`

### Manuel Deployment
```bash
# Local build için
flutter build web --release --base-href / --no-tree-shake-icons
# build/web klasörünü Netlify'e upload et
```

## 📱 Ekran Görüntüleri

### Dashboard
- Real-time bildirimler
- KPI kartları
- Müşteri özeti
- Başvuru durumları

### Responsive Design
- **Desktop**: Geniş layout, sidebar navigation
- **Tablet**: Hybrid yaklaşım
- **Mobile**: Full-screen, drawer navigation

## 🔧 Konfigürasyon

### Firebase Setup
1. Firebase Console'da proje oluştur
2. Web app ekle
3. `firebase_options.dart` dosyasını güncelle
4. Authorized domains listesine domain ekle

### Environment Variables
```bash
# .env dosyası (opsiyonel)
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

## 📊 Performance

### Metrics
- **First Load**: ~2-3 saniye
- **Bundle Size**: ~2-3 MB
- **Lighthouse Score**: 90+

### Optimizasyonlar
- Tree-shaking
- Font optimization
- Asset compression
- Code splitting

## 🐛 Troubleshooting

### Yaygın Sorunlar
1. **Firebase CORS**: Authorized domains kontrol et
2. **Build Hatası**: `flutter clean && flutter pub get`
3. **404 Hatası**: `.nojekyll` dosyası var mı kontrol et

### Debug
```bash
# Verbose build
flutter build web --release --verbose

# Development mode
flutter run -d chrome --web-port 8080 --verbose
```

## 🤝 Katkıda Bulunma

1. Repository'yi fork et
2. Feature branch oluştur (`git checkout -b feature/amazing-feature`)
3. Commit et (`git commit -m 'Add amazing feature'`)
4. Branch'e push et (`git push origin feature/amazing-feature`)
5. Pull Request oluştur

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Geliştirici**: [GitHub Profile](https://github.com/KULLANICI_ADI)
- **Demo**: [Live Demo](https://KULLANICI_ADI.github.io/crm-web/)
- **Issues**: [GitHub Issues](https://github.com/KULLANICI_ADI/crm-web/issues)

## 🎯 Roadmap

### v0.2.6 (Planlanan)
- [ ] Advanced analytics
- [ ] Export/Import özellikleri
- [ ] Bulk operations
- [ ] Advanced filtering

### v0.3.0 (Gelecek)
- [ ] Mobile app
- [ ] API integration
- [ ] Third-party integrations
- [ ] Advanced reporting

---

**🎉 CRM v0.2.5 Real-time Edition - Modern müşteri yönetimi artık web'de!**

Made with ❤️ using Flutter & Firebase