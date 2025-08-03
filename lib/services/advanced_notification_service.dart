import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

/// Bu servis, veriyi NotificationModel (lib/models/notification_model.dart) ile hizalar.
/// Firestore alan adları NotificationModel.toFirestore / fromFirestore ile uyumludur.
class NotificationData {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String userId;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    required this.userId,
  });

  factory NotificationData.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    // NotificationModel ile uyumlu alanlar
    final typeStr = map['type'] as String?;
    final NotificationType t = NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => NotificationType.genel,
    );
    return NotificationData(
      id: doc.id,
      title: map['title'] ?? '',
      message: map['message'] ?? (map['body'] ?? ''),
      type: t,
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message, // NotificationModel ile hizalı alan adı
      'type': type.toString().split('.').last,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'userId': userId,
    };
  }
}

class AdvancedNotificationService {
  static final AdvancedNotificationService _instance = AdvancedNotificationService._internal();
  factory AdvancedNotificationService() => _instance;
  AdvancedNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // notifications_screen.dart uyumluluğu için ek arabirimler
  // Okunmamış bildirim sayısı
  Stream<int> get unreadCountStream => getUnreadNotificationCount();

  // Bildirimler açık mı?
  Future<bool> get notificationsEnabled async {
    final prefs = await getNotificationPreferences();
    // En az bir tercih açık ise etkin kabul edelim
    return prefs.values.any((v) => v == true);
  }

  // Bildirim ayarları haritası
  Future<Map<String, bool>> get notificationSettings async {
    return await getNotificationPreferences();
  }

  // Tüm bildirimleri listele (NotificationModel ile)
  Stream<List<NotificationModel>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(<NotificationModel>[]);
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return NotificationModel.fromFirestore(doc);
            }).toList());
  }

  // Bildirimleri aç/kapat
  Future<void> toggleNotifications(bool enable) async {
    final current = await getNotificationPreferences();
    // Tüm anahtarları gelen enable ile set edelim
    final updated = <String, bool>{};
    if (current.isEmpty) {
      // Varsayılan anahtarlar
      updated.addAll({
        'basvuru': enable,
        'musteri': enable,
        'odeme': enable,
        'randevu': enable,
        'sistem': enable,
        'hatirlatma': enable,
      });
    } else {
      current.forEach((k, v) => updated[k] = enable);
    }
    await saveNotificationPreferences(updated);
  }

  // Tekil bildirim ayarını güncelle
  Future<void> updateNotificationSetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() ?? {};
      final prefs = Map<String, dynamic>.from(data['notificationPreferences'] ?? {});
      prefs[key] = value;
      tx.update(docRef, {'notificationPreferences': prefs});
    });
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await sendNotification(
      userId: user.uid,
      title: 'Test Bildirimi',
      message: 'Bu bir test bildirimidir',
      type: NotificationType.genel,
      data: {'source': 'test'},
    );
  }

  // Bildirim izinlerini iste
  Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Bildirim izni hatası: $e');
      return false;
    }
  }

  // FCM token'ı al ve kaydet
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }
      return token;
    } catch (e) {
      print('FCM token alma hatası: $e');
      return null;
    }
  }

  // FCM token'ı Firestore'a kaydet
  Future<void> _saveFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': Timestamp.now(),
      });
    }
  }

  // Bildirim gönder (server-side için)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationData(
        id: '',
        title: title,
        message: message,
        type: type,
        data: data ?? {},
        createdAt: DateTime.now(),
        userId: userId,
      );

      // Firestore'a kaydet (NotificationModel şemasına uygun)
      await _firestore.collection('notifications').add(notification.toMap());

      // Push notification gönder (gerçek uygulamada server-side yapılır)
      await _sendPushNotification(userId, title, message, data);
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
    }
  }

  // Push notification gönder
  Future<void> _sendPushNotification(
    String userId,
    String title,
    String message,
    Map<String, dynamic>? data,
  ) async {
    try {
      // Kullanıcının FCM token'ını al
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // Gerçek uygulamada burada server-side API çağrısı yapılır
        print('Push notification gönderildi: $title - $message');
      }
    } catch (e) {
      print('Push notification hatası: $e');
    }
  }

  // Kullanıcının bildirimlerini getir
  Stream<List<NotificationData>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationData.fromFirestore(doc))
            .toList());
  }

  // Okunmamış bildirim sayısı
  Stream<int> getUnreadNotificationCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Bildirimi sil
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Otomatik bildirimler

  // Yeni başvuru bildirimi
  Future<void> sendNewApplicationNotification({
    required String musteriAdi,
    required String basvuruTuru,
    required String danismanId,
  }) async {
    await sendNotification(
      userId: danismanId,
      title: 'Yeni Başvuru',
      message: '$musteriAdi adlı müşteriden $basvuruTuru başvurusu geldi.',
      type: NotificationType.basvuruOlusturuldu,
      data: {
        'musteriAdi': musteriAdi,
        'basvuruTuru': basvuruTuru,
      },
    );
  }

  // Ödeme hatırlatması
  Future<void> sendPaymentReminderNotification({
    required String musteriAdi,
    required double tutar,
    required String userId,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Ödeme Hatırlatması',
      message: '$musteriAdi - ₺${tutar.toStringAsFixed(2)} ödeme bekleniyor.',
      type: NotificationType.genel,
      data: {
        'musteriAdi': musteriAdi,
        'tutar': tutar,
      },
    );
  }

  // Randevu hatırlatması
  Future<void> sendAppointmentReminderNotification({
    required String musteriAdi,
    required DateTime randevuTarihi,
    required String userId,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Randevu Hatırlatması',
      message: '$musteriAdi ile ${_formatDate(randevuTarihi)} tarihinde randevunuz var.',
      type: NotificationType.randevu,
      data: {
        'musteriAdi': musteriAdi,
        'randevuTarihi': randevuTarihi.toIso8601String(),
      },
    );
  }

  // Başvuru durum değişikliği bildirimi
  Future<void> sendApplicationStatusChangeNotification({
    required String musteriAdi,
    required String yeniDurum,
    required String userId,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Başvuru Durumu Güncellendi',
      message: '$musteriAdi adlı müşterinin başvuru durumu: $yeniDurum',
      type: NotificationType.basvuruDurumGuncellendi,
      data: {
        'musteriAdi': musteriAdi,
        'yeniDurum': yeniDurum,
      },
    );
  }

  // Sistem bildirimi
  Future<void> sendSystemNotification({
    required String title,
    required String body,
    required List<String> userIds,
    Map<String, dynamic>? data,
  }) async {
    for (String userId in userIds) {
      await sendNotification(
        userId: userId,
        title: title,
        message: body,
        type: NotificationType.sistem,
        data: data,
      );
    }
  }

  // Bildirim tercihlerini getir
  Future<Map<String, bool>> getNotificationPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final preferences = doc.data()?['notificationPreferences'] as Map<String, dynamic>?;

    return {
      'basvuru': preferences?['basvuru'] ?? true,
      'musteri': preferences?['musteri'] ?? true,
      'odeme': preferences?['odeme'] ?? true,
      'randevu': preferences?['randevu'] ?? true,
      'sistem': preferences?['sistem'] ?? true,
      'hatirlatma': preferences?['hatirlatma'] ?? true,
    };
  }

  // Bildirim tercihlerini kaydet
  Future<void> saveNotificationPreferences(Map<String, bool> preferences) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'notificationPreferences': preferences,
    });
  }

  // Bildirim geçmişini temizle
  Future<void> clearNotificationHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Yardımcı metodlar
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Bildirim dinleyicilerini başlat
  void initializeNotificationListeners() {
    // Foreground mesajları
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground mesaj alındı: ${message.notification?.title}');
      // Burada local notification gösterilebilir
    });

    // Background mesajları
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background mesaj açıldı: ${message.notification?.title}');
      // Burada ilgili sayfaya yönlendirme yapılabilir
    });

    // Token yenileme
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _saveFCMToken(token);
    });
  }
}
