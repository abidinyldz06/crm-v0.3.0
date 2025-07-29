@echo off
echo ========================================
echo   CRM v0.2.5 Real-time Edition
echo   Web Build Script
echo ========================================

echo.
echo 1. Dependencies güncelleniyor...
flutter pub get

echo.
echo 2. Web build başlatılıyor...
flutter build web --release

echo.
echo 3. Build tamamlandı!
echo Web dosyaları: build/web/ klasöründe

echo.
echo ========================================
echo   Deployment Seçenekleri:
echo ========================================
echo 1. Firebase Hosting: firebase deploy
echo 2. Netlify: build/web klasörünü upload et
echo 3. Vercel: vercel --prod
echo 4. GitHub Pages: gh-pages branch'ine push et
echo.

echo Yerel test için:
echo flutter run -d chrome --web-port 8080

pause