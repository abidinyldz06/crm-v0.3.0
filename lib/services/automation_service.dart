import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/automation_rule_model.dart';
import 'email_service.dart';

class AutomationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailService _emailService = EmailService();

  // Otomasyon kurallarını getir
  Future<List<AutomationRule>> getAutomationRules() async {
    try {
      final snapshot = await _firestore
          .collection('automation_rules')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('Otomasyon kuralları getirme hatası: $e');
      return [];
    }
  }

  // Aktif otomasyon kurallarını getir
  Future<List<AutomationRule>> getActiveAutomationRules() async {
    try {
      final snapshot = await _firestore
          .collection('automation_rules')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('Aktif otomasyon kuralları getirme hatası: $e');
      return [];
    }
  }

  // Belirli tetikleyici tipindeki aktif kuralları getir
  Future<List<AutomationRule>> getActiveRulesByTrigger(AutomationTriggerType triggerType) async {
    try {
      final snapshot = await _firestore
          .collection('automation_rules')
          .where('isActive', isEqualTo: true)
          .where('triggerType', isEqualTo: triggerType.name)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('Tetikleyici kuralları getirme hatası: $e');
      return [];
    }
  }

  // Yeni otomasyon kuralı oluştur
  Future<void> createAutomationRule(AutomationRule rule) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final ruleWithUser = rule.copyWith(
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('automation_rules')
          .add(ruleWithUser.toFirestore());

      print('Otomasyon kuralı oluşturuldu: ${rule.name}');
    } catch (e) {
      print('Otomasyon kuralı oluşturma hatası: $e');
      rethrow;
    }
  }

  // Otomasyon kuralını güncelle
  Future<void> updateAutomationRule(AutomationRule rule) async {
    try {
      final updatedRule = rule.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('automation_rules')
          .doc(rule.id)
          .update(updatedRule.toFirestore());

      print('Otomasyon kuralı güncellendi: ${rule.name}');
    } catch (e) {
      print('Otomasyon kuralı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Otomasyon kuralını sil
  Future<void> deleteAutomationRule(String ruleId) async {
    try {
      await _firestore
          .collection('automation_rules')
          .doc(ruleId)
          .delete();

      print('Otomasyon kuralı silindi: $ruleId');
    } catch (e) {
      print('Otomasyon kuralı silme hatası: $e');
      rethrow;
    }
  }

  // Otomasyon kuralını etkinleştir/devre dışı bırak
  Future<void> toggleAutomationRule(String ruleId, bool isActive) async {
    try {
      await _firestore
          .collection('automation_rules')
          .doc(ruleId)
          .update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('Otomasyon kuralı durumu değiştirildi: $ruleId - $isActive');
    } catch (e) {
      print('Otomasyon kuralı durum değiştirme hatası: $e');
      rethrow;
    }
  }

  // Otomasyon tetikleyicilerini işle
  Future<void> processAutomationTrigger(
    AutomationTriggerType triggerType,
    Map<String, dynamic> triggerData,
  ) async {
    try {
      print('Otomasyon tetikleyicisi işleniyor: $triggerType');

      // Bu tetikleyici tipindeki aktif kuralları al
      final rules = await getActiveRulesByTrigger(triggerType);

      if (rules.isEmpty) {
        print('Bu tetikleyici için aktif kural bulunamadı: $triggerType');
        return;
      }

      // Her kural için e-posta gönder
      for (final rule in rules) {
        await _executeAutomationRule(rule, triggerData);
      }

      print('${rules.length} otomasyon kuralı işlendi');
    } catch (e) {
      print('Otomasyon tetikleyicisi işleme hatası: $e');
    }
  }

  // Otomasyon kuralını çalıştır
  Future<void> _executeAutomationRule(
    AutomationRule rule,
    Map<String, dynamic> triggerData,
  ) async {
    try {
      // E-posta içeriğini hazırla
      final processedSubject = _processEmailTemplate(rule.emailSubject, triggerData);
      final processedBody = _processEmailTemplate(rule.emailBody, triggerData);

      // Alıcıları belirle
      final recipients = await _determineRecipients(rule, triggerData);

      if (recipients.isEmpty) {
        print('Alıcı bulunamadı, e-posta gönderilmedi');
        return;
      }

      // E-postayı gönder
      await _emailService.sendAutomationEmail(
        recipients: recipients,
        subject: processedSubject,
        body: processedBody,
      );

      // Otomasyon logunu kaydet
      await _logAutomationExecution(rule, triggerData, recipients);

      print('Otomasyon kuralı çalıştırıldı: ${rule.name}');
    } catch (e) {
      print('Otomasyon kuralı çalıştırma hatası: ${rule.name} - $e');
    }
  }

  // E-posta şablonunu işle
  String _processEmailTemplate(String template, Map<String, dynamic> data) {
    String processed = template;

    // Basit değişken değiştirme
    data.forEach((key, value) {
      processed = processed.replaceAll('{{$key}}', value.toString());
    });

    // Özel değişkenler
    processed = processed.replaceAll('{{tarih}}', DateTime.now().toString());
    processed = processed.replaceAll('{{saat}}', '${DateTime.now().hour}:${DateTime.now().minute}');

    return processed;
  }

  // Alıcıları belirle
  Future<List<String>> _determineRecipients(
    AutomationRule rule,
    Map<String, dynamic> triggerData,
  ) async {
    final recipients = <String>[];

    // Kuralda belirtilen alıcılar varsa onları ekle
    if (rule.recipients != null && rule.recipients!.isNotEmpty) {
      recipients.addAll(rule.recipients!);
    }

    // Tetikleyici tipine göre varsayılan alıcıları ekle
    switch (rule.triggerType) {
      case AutomationTriggerType.basvuruOlusturuldu:
      case AutomationTriggerType.basvuruDurumGuncellendi:
        // Müşteri e-postasını ekle
        if (triggerData['musteriEmail'] != null) {
          recipients.add(triggerData['musteriEmail']);
        }
        break;
      case AutomationTriggerType.danismanAtandi:
        // Danışman e-postasını ekle
        if (triggerData['danismanEmail'] != null) {
          recipients.add(triggerData['danismanEmail']);
        }
        break;
      case AutomationTriggerType.musteriEklendi:
        // Yönetici e-postalarını ekle
        recipients.addAll(await _getManagerEmails());
        break;
      case AutomationTriggerType.randevuOlusturuldu:
        // Müşteri ve danışman e-postalarını ekle
        if (triggerData['musteriEmail'] != null) {
          recipients.add(triggerData['musteriEmail']);
        }
        if (triggerData['danismanEmail'] != null) {
          recipients.add(triggerData['danismanEmail']);
        }
        break;
      case AutomationTriggerType.hatirlatmaZamani:
        // Müşteri e-postasını ekle
        if (triggerData['musteriEmail'] != null) {
          recipients.add(triggerData['musteriEmail']);
        }
        break;
      case AutomationTriggerType.gunlukRapor:
      case AutomationTriggerType.haftalikRapor:
      case AutomationTriggerType.aylikRapor:
        // Yönetici e-postalarını ekle
        recipients.addAll(await _getManagerEmails());
        break;
    }

    return recipients.toSet().toList(); // Tekrarları kaldır
  }

  // Yönetici e-postalarını getir
  Future<List<String>> _getManagerEmails() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['email'] as String)
          .where((email) => email.isNotEmpty)
          .toList();
    } catch (e) {
      print('Yönetici e-postaları getirme hatası: $e');
      return [];
    }
  }

  // Otomasyon çalıştırma logunu kaydet
  Future<void> _logAutomationExecution(
    AutomationRule rule,
    Map<String, dynamic> triggerData,
    List<String> recipients,
  ) async {
    try {
      await _firestore.collection('automation_logs').add({
        'ruleId': rule.id,
        'ruleName': rule.name,
        'triggerType': rule.triggerType.name,
        'triggerData': triggerData,
        'recipients': recipients,
        'executedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'success',
      });
    } catch (e) {
      print('Otomasyon log kaydetme hatası: $e');
    }
  }

  // Otomasyon istatistiklerini getir
  Future<Map<String, dynamic>> getAutomationStats() async {
    try {
      final rulesSnapshot = await _firestore.collection('automation_rules').get();
      final logsSnapshot = await _firestore.collection('automation_logs').get();

      final totalRules = rulesSnapshot.docs.length;
      final activeRules = rulesSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length;
      final totalExecutions = logsSnapshot.docs.length;

      // Son 30 günlük çalıştırma sayısı
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentExecutions = logsSnapshot.docs
          .where((doc) => (doc.data()['executedAt'] as Timestamp).toDate().isAfter(thirtyDaysAgo))
          .length;

      return {
        'totalRules': totalRules,
        'activeRules': activeRules,
        'totalExecutions': totalExecutions,
        'recentExecutions': recentExecutions,
      };
    } catch (e) {
      print('Otomasyon istatistikleri getirme hatası: $e');
      return {
        'totalRules': 0,
        'activeRules': 0,
        'totalExecutions': 0,
        'recentExecutions': 0,
      };
    }
  }
} 