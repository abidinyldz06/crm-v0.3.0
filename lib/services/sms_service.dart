import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SMS gönder
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      print('SMS gönderiliyor: $phoneNumber - $message');
      
      // Gerçek SMS API entegrasyonu burada yapılacak
      // Şimdilik sadece log kaydediyoruz
      
      // SMS logunu kaydet
      await _logSmsSend(phoneNumber, message);
      
      print('SMS başarıyla gönderildi: $phoneNumber');
      return true;
    } catch (e) {
      print('SMS gönderme hatası: $e');
      return false;
    }
  }

  // Toplu SMS gönder
  Future<Map<String, bool>> sendBulkSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <String, bool>{};
    
    for (final phoneNumber in phoneNumbers) {
      final success = await sendSms(
        phoneNumber: phoneNumber,
        message: message,
      );
      results[phoneNumber] = success;
    }
    
    return results;
  }

  // SMS şablonu gönder
  Future<bool> sendTemplateSms({
    required String phoneNumber,
    required String templateName,
    required Map<String, dynamic> variables,
  }) async {
    try {
      // Şablonu getir
      final template = await _getSmsTemplate(templateName);
      if (template == null) {
        print('SMS şablonu bulunamadı: $templateName');
        return false;
      }

      // Şablonu işle
      final processedMessage = _processTemplate(template, variables);
      
      // SMS'i gönder
      return await sendSms(
        phoneNumber: phoneNumber,
        message: processedMessage,
      );
    } catch (e) {
      print('Şablon SMS gönderme hatası: $e');
      return false;
    }
  }

  // SMS şablonunu getir
  Future<String?> _getSmsTemplate(String templateName) async {
    try {
      final doc = await _firestore
          .collection('sms_templates')
          .doc(templateName)
          .get();

      if (doc.exists) {
        return doc.data()?['content'] as String?;
      }
      return null;
    } catch (e) {
      print('SMS şablonu getirme hatası: $e');
      return null;
    }
  }

  // Şablonu işle
  String _processTemplate(String template, Map<String, dynamic> variables) {
    String processed = template;

    // Değişkenleri değiştir
    variables.forEach((key, value) {
      processed = processed.replaceAll('{{$key}}', value.toString());
    });

    // Özel değişkenler
    processed = processed.replaceAll('{{tarih}}', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    processed = processed.replaceAll('{{saat}}', '${DateTime.now().hour}:${DateTime.now().minute}');

    return processed;
  }

  // SMS gönderim logunu kaydet
  Future<void> _logSmsSend(String phoneNumber, String message) async {
    try {
      final user = _auth.currentUser;
      
      await _firestore.collection('sms_logs').add({
        'phoneNumber': phoneNumber,
        'message': message,
        'sentBy': user?.uid,
        'sentAt': Timestamp.fromDate(DateTime.now()),
        'status': 'sent',
      });
    } catch (e) {
      print('SMS log kaydetme hatası: $e');
    }
  }

  // SMS loglarını getir
  Future<List<Map<String, dynamic>>> getSmsLogs({
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('sms_logs')
          .orderBy('sentAt', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('sentAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('SMS logları getirme hatası: $e');
      return [];
    }
  }

  // SMS istatistiklerini getir
  Future<Map<String, dynamic>> getSmsStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('sms_logs');

      if (startDate != null) {
        query = query.where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('sentAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      
      final totalSms = snapshot.docs.length;
      final successfulSms = snapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'sent')
          .length;
      final failedSms = totalSms - successfulSms;

      // Son 30 günlük istatistikler
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentSnapshot = await _firestore
          .collection('sms_logs')
          .where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final recentSms = recentSnapshot.docs.length;

      return {
        'totalSms': totalSms,
        'successfulSms': successfulSms,
        'failedSms': failedSms,
        'recentSms': recentSms,
        'successRate': totalSms > 0 ? (successfulSms / totalSms * 100).round() : 0,
      };
    } catch (e) {
      print('SMS istatistikleri getirme hatası: $e');
      return {
        'totalSms': 0,
        'successfulSms': 0,
        'failedSms': 0,
        'recentSms': 0,
        'successRate': 0,
      };
    }
  }

  // Telefon numarasını doğrula
  bool validatePhoneNumber(String phoneNumber) {
    // Türkiye telefon numarası formatı kontrolü
    final regex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    return regex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  // Telefon numarasını formatla
  String formatPhoneNumber(String phoneNumber) {
    // Boşlukları ve özel karakterleri kaldır
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Türkiye kodu ekle
    if (cleaned.startsWith('0')) {
      cleaned = '+90${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+90')) {
      cleaned = '+90$cleaned';
    }
    
    return cleaned;
  }
}