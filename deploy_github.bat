@echo off
echo ========================================
echo   CRM v0.2.5 GitHub Pages Deployment
echo ========================================

echo.
echo 1. Dependencies güncelleniyor...
flutter pub get

echo.
echo 2. Web build (GitHub Pages için)...
flutter build web --release --base-href "/crmwebdeneme/"

echo.
echo 3. GitHub Pages dosyaları hazırlanıyor...
echo. > build\web\.nojekyll

echo.
echo 4. Git repository durumu kontrol ediliyor...
git status

echo.
echo 5. Değişiklikleri commit ediliyor...
git add .
git commit -m "🚀 Deploy CRM v0.2.5 to GitHub Pages"

echo.
echo 6. Main branch'e push ediliyor...
git push origin main

echo.
echo ========================================
echo   Deployment Tamamlandı!
echo ========================================
echo.
echo GitHub Actions otomatik olarak:
echo 1. Build yapacak
echo 2. gh-pages branch'ine deploy edecek
echo 3. Site canlıya çıkacak
echo.
echo URL: https://KULLANICI_ADI.github.io/crm-web/
echo.
echo GitHub Actions durumunu kontrol et:
echo https://github.com/KULLANICI_ADI/crm-web/actions
echo.

pause