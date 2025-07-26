import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskPriority {
  dusuk,
  normal,
  yuksek,
  kritik;

  String get displayName {
    switch (this) {
      case TaskPriority.dusuk:
        return 'Düşük';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.yuksek:
        return 'Yüksek';
      case TaskPriority.kritik:
        return 'Kritik';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.dusuk:
        return Colors.green;
      case TaskPriority.normal:
        return Colors.blue;
      case TaskPriority.yuksek:
        return Colors.orange;
      case TaskPriority.kritik:
        return Colors.red;
    }
  }
}

enum TaskStatus {
  beklemede,
  devamEdiyor,
  tamamlandi,
  iptalEdildi,
  onayBekliyor;

  String get displayName {
    switch (this) {
      case TaskStatus.beklemede:
        return 'Beklemede';
      case TaskStatus.devamEdiyor:
        return 'Devam Ediyor';
      case TaskStatus.tamamlandi:
        return 'Tamamlandı';
      case TaskStatus.iptalEdildi:
        return 'İptal Edildi';
      case TaskStatus.onayBekliyor:
        return 'Onay Bekliyor';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.beklemede:
        return Colors.grey;
      case TaskStatus.devamEdiyor:
        return Colors.blue;
      case TaskStatus.tamamlandi:
        return Colors.green;
      case TaskStatus.iptalEdildi:
        return Colors.red;
      case TaskStatus.onayBekliyor:
        return Colors.orange;
    }
  }
}

enum TaskType {
  musteriGorusmesi,
  belgeHazirlama,
  takipAramasi,
  randevuPlanlama,
  raporHazirlama,
  onaySureci,
  hatirlatma,
  diger;

  String get displayName {
    switch (this) {
      case TaskType.musteriGorusmesi:
        return 'Müşteri Görüşmesi';
      case TaskType.belgeHazirlama:
        return 'Belge Hazırlama';
      case TaskType.takipAramasi:
        return 'Takip Araması';
      case TaskType.randevuPlanlama:
        return 'Randevu Planlama';
      case TaskType.raporHazirlama:
        return 'Rapor Hazırlama';
      case TaskType.onaySureci:
        return 'Onay Süreci';
      case TaskType.hatirlatma:
        return 'Hatırlatma';
      case TaskType.diger:
        return 'Diğer';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskType.musteriGorusmesi:
        return Icons.phone;
      case TaskType.belgeHazirlama:
        return Icons.description;
      case TaskType.takipAramasi:
        return Icons.call_made;
      case TaskType.randevuPlanlama:
        return Icons.calendar_today;
      case TaskType.raporHazirlama:
        return Icons.assessment;
      case TaskType.onaySureci:
        return Icons.verified;
      case TaskType.hatirlatma:
        return Icons.notification_important;
      case TaskType.diger:
        return Icons.task;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedTo;
  final String? assignedBy;
  final String? customerId;
  final String? applicationId;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final bool isAutomated;
  final String? automationRuleId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.assignedTo,
    this.assignedBy,
    this.customerId,
    this.applicationId,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.metadata,
    this.isAutomated = false,
    this.automationRuleId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: TaskType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'diğer'),
        orElse: () => TaskType.diger,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'normal'),
        orElse: () => TaskPriority.normal,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'beklemede'),
        orElse: () => TaskStatus.beklemede,
      ),
      assignedTo: data['assignedTo'] ?? '',
      assignedBy: data['assignedBy'],
      customerId: data['customerId'],
      applicationId: data['applicationId'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'],
      isAutomated: data['isAutomated'] ?? false,
      automationRuleId: data['automationRuleId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'customerId': customerId,
      'applicationId': applicationId,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'metadata': metadata,
      'isAutomated': isAutomated,
      'automationRuleId': automationRuleId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? assignedBy,
    String? customerId,
    String? applicationId,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isAutomated,
    String? automationRuleId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      customerId: customerId ?? this.customerId,
      applicationId: applicationId ?? this.applicationId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isAutomated: isAutomated ?? this.isAutomated,
      automationRuleId: automationRuleId ?? this.automationRuleId,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != TaskStatus.tamamlandi;
  bool get isDueToday => dueDate.day == DateTime.now().day && 
                        dueDate.month == DateTime.now().month && 
                        dueDate.year == DateTime.now().year;
  bool get isDueSoon => dueDate.isBefore(DateTime.now().add(const Duration(days: 3))) && 
                       status != TaskStatus.tamamlandi;
} 