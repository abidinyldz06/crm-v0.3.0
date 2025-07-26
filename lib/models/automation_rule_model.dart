import 'package:cloud_firestore/cloud_firestore.dart';

enum AutomationTriggerType {
  basvuruOlusturuldu,
  basvuruDurumGuncellendi,
  danismanAtandi,
  musteriEklendi,
  randevuOlusturuldu,
  hatirlatmaZamani,
  gunlukRapor,
  haftalikRapor,
  aylikRapor,
}

extension AutomationTriggerTypeExtension on AutomationTriggerType {
  String get displayName {
    switch (this) {
      case AutomationTriggerType.basvuruOlusturuldu:
        return 'Başvuru Oluşturuldu';
      case AutomationTriggerType.basvuruDurumGuncellendi:
        return 'Başvuru Durumu Güncellendi';
      case AutomationTriggerType.danismanAtandi:
        return 'Danışman Atandı';
      case AutomationTriggerType.musteriEklendi:
        return 'Müşteri Eklendi';
      case AutomationTriggerType.randevuOlusturuldu:
        return 'Randevu Oluşturuldu';
      case AutomationTriggerType.hatirlatmaZamani:
        return 'Hatırlatma Zamanı';
      case AutomationTriggerType.gunlukRapor:
        return 'Günlük Rapor';
      case AutomationTriggerType.haftalikRapor:
        return 'Haftalık Rapor';
      case AutomationTriggerType.aylikRapor:
        return 'Aylık Rapor';
    }
  }

  String get description {
    switch (this) {
      case AutomationTriggerType.basvuruOlusturuldu:
        return 'Yeni bir başvuru oluşturulduğunda tetiklenir';
      case AutomationTriggerType.basvuruDurumGuncellendi:
        return 'Başvuru durumu değiştirildiğinde tetiklenir';
      case AutomationTriggerType.danismanAtandi:
        return 'Bir danışman atandığında tetiklenir';
      case AutomationTriggerType.musteriEklendi:
        return 'Yeni müşteri eklendiğinde tetiklenir';
      case AutomationTriggerType.randevuOlusturuldu:
        return 'Yeni randevu oluşturulduğunda tetiklenir';
      case AutomationTriggerType.hatirlatmaZamani:
        return 'Hatırlatma zamanı geldiğinde tetiklenir';
      case AutomationTriggerType.gunlukRapor:
        return 'Günlük rapor zamanında tetiklenir';
      case AutomationTriggerType.haftalikRapor:
        return 'Haftalık rapor zamanında tetiklenir';
      case AutomationTriggerType.aylikRapor:
        return 'Aylık rapor zamanında tetiklenir';
    }
  }
}

class AutomationRule {
  final String id;
  final String name;
  final String description;
  final AutomationTriggerType triggerType;
  final String emailSubject;
  final String emailBody;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final Map<String, dynamic>? conditions;
  final List<String>? recipients;

  AutomationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.triggerType,
    required this.emailSubject,
    required this.emailBody,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.conditions,
    this.recipients,
  });

  factory AutomationRule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AutomationRule(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      triggerType: AutomationTriggerType.values.firstWhere(
        (e) => e.name == data['triggerType'],
        orElse: () => AutomationTriggerType.basvuruOlusturuldu,
      ),
      emailSubject: data['emailSubject'] ?? '',
      emailBody: data['emailBody'] ?? '',
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      conditions: data['conditions'],
      recipients: data['recipients'] != null 
          ? List<String>.from(data['recipients'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'triggerType': triggerType.name,
      'emailSubject': emailSubject,
      'emailBody': emailBody,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'conditions': conditions,
      'recipients': recipients,
    };
  }

  AutomationRule copyWith({
    String? id,
    String? name,
    String? description,
    AutomationTriggerType? triggerType,
    String? emailSubject,
    String? emailBody,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? conditions,
    List<String>? recipients,
  }) {
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      triggerType: triggerType ?? this.triggerType,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      conditions: conditions ?? this.conditions,
      recipients: recipients ?? this.recipients,
    );
  }

  @override
  String toString() {
    return 'AutomationRule(id: $id, name: $name, triggerType: $triggerType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationRule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 