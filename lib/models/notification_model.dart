import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  basvuruOlusturuldu,
  basvuruDurumGuncellendi,
  danismanAtandi,
  mesaj,
  genel,
  hatirlatma,
  randevu,
  sistem
}

enum NotificationPriority {
  dusuk,
  normal,
  yuksek,
  kritik
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final String? userId;
  final String? basvuruId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.userId,
    this.basvuruId,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.genel,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == data['priority'] || 
               (data['priority'] == 'düşük' && e == NotificationPriority.dusuk) ||
               (data['priority'] == 'yüksek' && e == NotificationPriority.yuksek),
        orElse: () => NotificationPriority.normal,
      ),
      userId: data['userId'],
      basvuruId: data['basvuruId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null ? (data['readAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'userId': userId,
      'basvuruId': basvuruId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    String? userId,
    String? basvuruId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      basvuruId: basvuruId ?? this.basvuruId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
