import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Email şablonları
  static const Map<String, Map<String, String>> emailTemplates = {
    'basvuru_durumu_degisti': {
      'subject': 'Başvuru Durumu Güncellendi',
      'body': 'Sayın {{musteriAdi}}, başvurunuzun durumu güncellendi.',
    },
    'randevu_yaklasti': {
      'subject': 'Randevu Hatırlatması',
      'body': 'Sayın {{musteriAdi}}, yarın randevunuz bulunmaktadır.',
    },
  };

  // SMS şablonları
  static const Map<String, Map<String, String>> smsTemplates = {
    'basvuru_durumu_degisti': {
      'message': '{{musteriAdi}}, başvurunuz güncellendi.',
    },
    'randevu_yaklasti': {
      'message': '{{musteriAdi}}, yarın randevunuz var.',
    },
  };

  // Email şablonu getir
  Future<Map<String, String>?> getEmailTemplate(String templateName) async {
    return emailTemplates[templateName];
  }

  // SMS şablonu getir
  Future<Map<String, String>?> getSMSTemplate(String templateName) async {
    return smsTemplates[templateName];
  }

  // Şablon işleme
  Map<String, String> processTemplate(
    Map<String, String> template,
    Map<String, dynamic> data,
  ) {
    final Map<String, String> processed = {};
    
    template.forEach((key, value) {
      String processedValue = value;
      
      data.forEach((dataKey, dataValue) {
        final placeholder = '{{$dataKey}}';
        if (processedValue.contains(placeholder)) {
          processedValue = processedValue.replaceAll(
            placeholder,
            dataValue?.toString() ?? '',
          );
        }
      });
      
      processed[key] = processedValue;
    });
    
    return processed;
  }
}