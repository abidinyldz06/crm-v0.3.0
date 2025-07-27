import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService extends ChangeNotifier {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  String? get fcmToken => _fcmToken;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> initialize() async {
    try {
      // Permission isteme
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('FCM: Kullanıcı bildirim izni verdi');
        
        // FCM token alma
        _fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $_fcmToken');
        
        // Token değişikliklerini dinle
        _firebaseMessaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          print('FCM Token yenilendi: $token');
          // Token'ı backend'e gönder
          _sendTokenToServer(token);
        });

        // Foreground mesajları dinle
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Background'dan açılan mesajları dinle
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        
        // Uygulama kapalıyken gelen mesajları kontrol et
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessage(initialMessage);
        }

        // Kaydedilmiş bildirimleri yükle
        await _loadNotifications();
        
        // Token'ı backend'e gönder
        if (_fcmToken != null) {
          await _sendTokenToServer(_fcmToken!);
        }
        
      } else {
        print('FCM: Kullanıcı bildirim izni vermedi');
      }
    } catch (e) {
      print('FCM Initialize Error: $e');
    }
  }

  // Foreground'da gelen mesajları işle
  void _handleForegroundMessage(RemoteMessage message) {
    print('FCM Foreground Message: ${message.notification?.title}');
    
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Bildirim',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'type': message.data['type'] ?? 'general',
    };

    _addNotification(notification);
  }

  // Background'dan açılan mesajları işle
  void _handleBackgroundMessage(RemoteMessage message) {
    print('FCM Background Message: ${message.notification?.title}');
    
    // Mesaj tipine göre sayfa yönlendirmesi yapılabilir
    final type = message.data['type'];
    final targetPage = message.data['targetPage'];
    
    print('Message Type: $type, Target Page: $targetPage');
    
    // Bu bilgileri kullanarak uygun sayfaya yönlendirme yapılabilir
    // Navigator context'i burada mevcut olmadığı için
    // bu işlem main.dart'ta veya uygun bir yerde yapılmalı
  }

  // Bildirim ekleme
  void _addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    _saveNotifications();
    notifyListeners();
  }

  // Manuel bildirim ekleme (test için)
  void addManualNotification({
    required String title,
    required String body,
    String type = 'manual',
    Map<String, dynamic>? data,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'type': type,
    };

    _addNotification(notification);
  }

  // Bildirimi okundu olarak işaretle
  void markAsRead(String notificationId) {
    print('markAsRead çağrıldı: $notificationId');
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    print('Bulunan index: $index');
    if (index != -1 && !_notifications[index]['isRead']) {
      _notifications[index]['isRead'] = true;
      _unreadCount--;
      print('Bildirim okundu olarak işaretlendi. Yeni unread count: $_unreadCount');
      _saveNotifications();
      notifyListeners();
    } else {
      print('Bildirim bulunamadı veya zaten okunmuş');
    }
  }

  // Tüm bildirimleri okundu olarak işaretle
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _unreadCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  // Bildirimi sil
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      if (!_notifications[index]['isRead']) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
      _saveNotifications();
      notifyListeners();
    }
  }

  // Tüm bildirimleri temizle
  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  // Bildirimleri kaydet
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(_notifications);
      await prefs.setString('fcm_notifications', notificationsJson);
      await prefs.setInt('fcm_unread_count', _unreadCount);
    } catch (e) {
      print('Bildirimler kaydedilirken hata: $e');
    }
  }

  // Bildirimleri yükle
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('fcm_notifications');
      final unreadCount = prefs.getInt('fcm_unread_count') ?? 0;
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded.cast<Map<String, dynamic>>();
        _unreadCount = unreadCount;
        notifyListeners();
      }
    } catch (e) {
      print('Bildirimler yüklenirken hata: $e');
    }
  }

  // Token'ı backend'e gönder
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Burada token'ı backend API'nize gönderebilirsiniz
      // Örnek: HTTP POST request
      print('Token backend\'e gönderiliyor: $token');
      
      // Backend API call örneği:
      // final response = await http.post(
      //   Uri.parse('https://your-backend.com/api/fcm-token'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'token': token, 'userId': currentUserId}),
      // );
      
    } catch (e) {
      print('Token backend\'e gönderilirken hata: $e');
    }
  }

  // Test bildirimi gönder
  void sendTestNotification() {
    addManualNotification(
      title: 'Test Bildirimi',
      body: 'Bu bir test bildirimidir. FCM servisi çalışıyor!',
      type: 'test',
      data: {'action': 'test', 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  // Bildirim türüne göre ikon döndür
  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.assignment;
      case 'appointment':
        return Icons.schedule;
      case 'approval':
        return Icons.check_circle;
      case 'system':
        return Icons.system_update;
      case 'message':
        return Icons.message;
      case 'customer':
        return Icons.person_add;
      case 'test':
        return Icons.bug_report;
      default:
        return Icons.notifications;
    }
  }

  // Bildirim türüne göre renk döndür
  Color getNotificationColor(String type) {
    switch (type) {
      case 'application':
        return Colors.blue;
      case 'appointment':
        return Colors.orange;
      case 'approval':
        return Colors.green;
      case 'system':
        return Colors.purple;
      case 'message':
        return Colors.indigo;
      case 'customer':
        return Colors.teal;
      case 'test':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}