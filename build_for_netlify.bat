@echo off
echo Building Flutter Web for Netlify...
flutter clean
flutter pub get
flutter build web --release --base-href / --no-tree-shake-icons
echo /*    /index.html   200 > build\web\_redirects
echo Build completed! Upload build/web folder to Netlify.
pause