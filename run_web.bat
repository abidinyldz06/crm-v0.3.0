@echo off
echo ========================================
echo   CRM v0.2.5 Real-time Edition
echo   Development Server
echo ========================================

echo.
echo Dependencies kontrol ediliyor...
flutter pub get

echo.
echo ========================================
echo   Web sunucusu başlatılıyor...
echo   URL: http://localhost:8080
echo ========================================
echo.
echo Özellikler:
echo - Real-time bildirimler
echo - Firebase Cloud Messaging
echo - Responsive tasarım
echo - PWA desteği
echo.
echo Çıkmak için Ctrl+C tuşlarına basın
echo.

flutter run -d chrome --web-port 8080