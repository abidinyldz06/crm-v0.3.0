import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/automation_rule_model.dart';
import 'sms_service.dart';

class SmsAutomationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SmsService _smsService = SmsService();

  // SMS otomasyon kurallarını getir
  Future<List<AutomationRule>> getSmsAutomationRules() async {
    try {
      final snapshot = await _firestore
          .collection('sms_automation_rules')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('SMS otomasyon kuralları getirme hatası: $e');
      return [];
    }
  }

  // Aktif SMS otomasyon kurallarını getir
  Future<List<AutomationRule>> getActiveSmsAutomationRules() async {
    try {
      final snapshot = await _firestore
          .collection('sms_automation_rules')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('Aktif SMS otomasyon kuralları getirme hatası: $e');
      return [];
    }
  }

  // Belirli tetikleyici tipindeki aktif SMS kurallarını getir
  Future<List<AutomationRule>> getActiveSmsRulesByTrigger(AutomationTriggerType triggerType) async {
    try {
      final snapshot = await _firestore
          .collection('sms_automation_rules')
          .where('isActive', isEqualTo: true)
          .where('triggerType', isEqualTo: triggerType.name)
          .get();

      return snapshot.docs.map((doc) => AutomationRule.fromFirestore(doc)).toList();
    } catch (e) {
      print('SMS tetikleyici kuralları getirme hatası: $e');
      return [];
    }
  }

  // Yeni SMS otomasyon kuralı oluştur
  Future<void> createSmsAutomationRule(AutomationRule rule) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final ruleWithUser = rule.copyWith(
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('sms_automation_rules')
          .add(ruleWithUser.toFirestore());

      print('SMS otomasyon kuralı oluşturuldu: ${rule.name}');
    } catch (e) {
      print('SMS otomasyon kuralı oluşturma hatası: $e');
      rethrow;
    }
  }

  // SMS otomasyon kuralını güncelle
  Future<void> updateSmsAutomationRule(AutomationRule rule) async {
    try {
      final updatedRule = rule.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('sms_automation_rules')
          .doc(rule.id)
          .update(updatedRule.toFirestore());

      print('SMS otomasyon kuralı güncellendi: ${rule.name}');
    } catch (e) {
      print('SMS otomasyon kuralı güncelleme hatası: $e');
      rethrow;
    }
  }

  // SMS otomasyon kuralını sil
  Future<void> deleteSmsAutomationRule(String ruleId) async {
    try {
      await _firestore
          .collection('sms_automation_rules')
          .doc(ruleId)
          .delete();

      print('SMS otomasyon kuralı silindi: $ruleId');
    } catch (e) {
      print('SMS otomasyon kuralı silme hatası: $e');
      rethrow;
    }
  }

  // SMS otomasyon tetikleyicilerini işle
  Future<void> processSmsAutomationTrigger(
    AutomationTriggerType triggerType,
    Map<String, dynamic> triggerData,
  ) async {
    try {
      print('SMS otomasyon tetikleyicisi işleniyor: $triggerType');

      // Bu tetikleyici tipindeki aktif SMS kurallarını al
      final rules = await getActiveSmsRulesByTrigger(triggerType);

      if (rules.isEmpty) {
        print('Bu tetikleyici için aktif SMS kuralı bulunamadı: $triggerType');
        return;
      }

      // Her kural için SMS gönder
      for (final rule in rules) {
        await _executeSmsAutomationRule(rule, triggerData);
      }

      print('${rules.length} SMS otomasyon kuralı işlendi');
    } catch (e) {
      print('SMS otomasyon tetikleyicisi işleme hatası: $e');
    }
  }

  // SMS otomasyon kuralını çalıştır
  Future<void> _executeSmsAutomationRule(
    AutomationRule rule,
    Map<String, dynamic> triggerData,
  ) async {
    try {
      // SMS içeriğini hazırla
      final processedMessage = _processSmsTemplate(rule.emailBody, triggerData);

      // Alıcıları belirle
      final recipients = await _determineSmsRecipients(rule, triggerData);

      if (recipients.isEmpty) {
        print('SMS alıcısı bulunamadı, SMS gönderilmedi');
        return;
      }

      // SMS'i gönder
      for (final phoneNumber in recipients) {
        await _smsService.sendSms(
          phoneNumber: phoneNumber,
          message: processedMessage,
        );
      }

      // SMS otomasyon logunu kaydet
      await _logSmsAutomationExecution(rule, triggerData, recipients);

      print('SMS otomasyon kuralı çalıştırıldı: ${rule.name}');
    } catch (e) {
      print('SMS otomasyon kuralı çalıştırma hatası: ${rule.name} - $e');
    }
  }

  // SMS şablonunu işle
  String _processSmsTemplate(String template, Map<String, dynamic> data) {
    String processed = template;

    // Basit değişken değiştirme
    data.forEach((key, value) {
      processed = processed.replaceAll('{{$key}}', value.toString());
    });

    // Özel değişkenler
    processed = processed.replaceAll('{{tarih}}', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    processed = processed.replaceAll('{{saat}}', '${DateTime.now().hour}:${DateTime.now().minute}');

    return processed;
  }

  // SMS alıcılarını belirle
  Future<List<String>> _determineSmsRecipients(
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
        // Müşteri telefon numarasını ekle
        if (triggerData['musteriTelefon'] != null) {
          recipients.add(triggerData['musteriTelefon']);
        }
        break;
      case AutomationTriggerType.danismanAtandi:
        // Danışman telefon numarasını ekle
        if (triggerData['danismanTelefon'] != null) {
          recipients.add(triggerData['danismanTelefon']);
        }
        break;
      case AutomationTriggerType.musteriEklendi:
        // Yönetici telefon numaralarını ekle
        recipients.addAll(await _getManagerPhones());
        break;
      case AutomationTriggerType.randevuOlusturuldu:
        // Müşteri ve danışman telefon numaralarını ekle
        if (triggerData['musteriTelefon'] != null) {
          recipients.add(triggerData['musteriTelefon']);
        }
        if (triggerData['danismanTelefon'] != null) {
          recipients.add(triggerData['danismanTelefon']);
        }
        break;
      case AutomationTriggerType.hatirlatmaZamani:
        // Müşteri telefon numarasını ekle
        if (triggerData['musteriTelefon'] != null) {
          recipients.add(triggerData['musteriTelefon']);
        }
        break;
      case AutomationTriggerType.gunlukRapor:
      case AutomationTriggerType.haftalikRapor:
      case AutomationTriggerType.aylikRapor:
        // Yönetici telefon numaralarını ekle
        recipients.addAll(await _getManagerPhones());
        break;
    }

    return recipients.toSet().toList(); // Tekrarları kaldır
  }

  // Yönetici telefon numaralarını getir
  Future<List<String>> _getManagerPhones() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['phone'] as String?)
          .where((phone) => phone != null && phone.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      print('Yönetici telefon numaraları getirme hatası: $e');
      return [];
    }
  }

  // SMS otomasyon çalıştırma logunu kaydet
  Future<void> _logSmsAutomationExecution(
    AutomationRule rule,
    Map<String, dynamic> triggerData,
    List<String> recipients,
  ) async {
    try {
      await _firestore.collection('sms_automation_logs').add({
        'ruleId': rule.id,
        'ruleName': rule.name,
        'triggerType': rule.triggerType.name,
        'triggerData': triggerData,
        'recipients': recipients,
        'executedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'success',
      });
    } catch (e) {
      print('SMS otomasyon log kaydetme hatası: $e');
    }
  }

  // SMS otomasyon istatistiklerini getir
  Future<Map<String, dynamic>> getSmsAutomationStats() async {
    try {
      final rulesSnapshot = await _firestore.collection('sms_automation_rules').get();
      final logsSnapshot = await _firestore.collection('sms_automation_logs').get();

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
      print('SMS otomasyon istatistikleri getirme hatası: $e');
      return {
        'totalRules': 0,
        'activeRules': 0,
        'totalExecutions': 0,
        'recentExecutions': 0,
      };
    }
  }
} 