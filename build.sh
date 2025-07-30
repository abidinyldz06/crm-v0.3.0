#!/bin/bash

# Netlify Build Script for Flutter Web
echo "🚀 Starting Flutter Web build for Netlify..."

# Flutter kurulumu kontrol et
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/.flutter
    export PATH="$PATH:/opt/buildhome/.flutter/bin"
fi

# Flutter doctor
echo "🔍 Flutter doctor..."
flutter doctor

# Dependencies yükle
echo "📦 Installing dependencies..."
flutter pub get

# Web build
echo "🏗️ Building for web..."
flutter build web --release --base-href / --no-tree-shake-icons

# _redirects dosyası oluştur
echo "📄 Creating _redirects file..."
echo "/*    /index.html   200" > build/web/_redirects

echo "✅ Build completed successfully!"