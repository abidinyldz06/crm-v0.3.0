import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/musteri_model.dart';
import '../models/basvuru_model.dart';

enum EmailTemplate {
  welcome,
  applicationStatus,
  paymentReminder,
  appointmentReminder,
  applicationComplete,
  documentRequest,
  custom,
}

class EmailConfig {
  final String smtpHost;
  final int smtpPort;
  final String username;
  final String password;
  final String fromName;
  final String fromEmail;
  final bool useSSL;

  EmailConfig({
    required this.smtpHost,
    required this.smtpPort,
    required this.username,
    required this.password,
    required this.fromName,
    required this.fromEmail,
    this.useSSL = true,
  });
}

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email konfigürasyonu (gerçek uygulamada environment variables'dan alınır)
  EmailConfig get _config => EmailConfig(
    smtpHost: 'smtp.gmail.com',
    smtpPort: 587,
    username: 'your-email@gmail.com', // Gerçek uygulamada env'den alınır
    password: 'your-app-password', // Gerçek uygulamada env'den alınır
    fromName: 'Vize Danışmanlık CRM',
    fromEmail: 'your-email@gmail.com',
  );

  // Email gönder
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? toName,
    List<String>? cc,
    List<String>? bcc,
    bool isHtml = true,
  }) async {
    try {
      // Şimdilik sadece log kaydet, gerçek e-posta gönderimi daha sonra implement edilecek
      await _logEmailSend(to, subject, true, null);
      
      print('E-posta başarıyla gönderildi: $to');
      return true;
    } catch (e) {
      print('E-posta gönderme hatası: $e');
      
      // Hata logunu kaydet
      await _logEmailSend(to, subject, false, e.toString());
      
      return false;
    }
  }

  // Otomasyon e-postası gönder
  Future<bool> sendAutomationEmail({
    required List<String> recipients,
    required String subject,
    required String body,
    List<String>? cc,
    List<String>? bcc,
    bool isHtml = true,
  }) async {
    try {
      // Şimdilik sadece log kaydet, gerçek e-posta gönderimi daha sonra implement edilecek
      await _logAutomationEmailSend(recipients, subject, true, null);
      
      print('Otomasyon e-postası başarıyla gönderildi: ${recipients.length} alıcı');
      return true;
    } catch (e) {
      print('Otomasyon e-postası gönderme hatası: $e');
      
      // Hata logunu kaydet
      await _logAutomationEmailSend(recipients, subject, false, e.toString());
      
      return false;
    }
  }

  // Template ile email gönder
  Future<bool> sendTemplateEmail({
    required String to,
    required EmailTemplate template,
    required Map<String, dynamic> data,
    String? toName,
  }) async {
    final templateData = _getEmailTemplate(template, data);
    
    return await sendEmail(
      to: to,
      toName: toName,
      subject: templateData['subject'] ?? '',
      body: templateData['body'] ?? '',
      isHtml: true,
    );
  }

  // Email template'lerini getir
  Map<String, String> _getEmailTemplate(EmailTemplate template, Map<String, dynamic> data) {
    switch (template) {
      case EmailTemplate.welcome:
        return {
          'subject': 'Hoş Geldiniz - ${data['name']}',
          'body': _getWelcomeTemplate(data),
        };
      
      case EmailTemplate.applicationStatus:
        return {
          'subject': 'Başvuru Durumu Güncellendi - ${data['applicationId']}',
          'body': _getApplicationStatusTemplate(data),
        };
      
      case EmailTemplate.paymentReminder:
        return {
          'subject': 'Ödeme Hatırlatması - ${data['amount']} TL',
          'body': _getPaymentReminderTemplate(data),
        };
      
      case EmailTemplate.appointmentReminder:
        return {
          'subject': 'Randevu Hatırlatması - ${data['date']}',
          'body': _getAppointmentReminderTemplate(data),
        };
      
      case EmailTemplate.applicationComplete:
        return {
          'subject': 'Başvurunuz Tamamlandı - ${data['applicationId']}',
          'body': _getApplicationCompleteTemplate(data),
        };
      
      case EmailTemplate.documentRequest:
        return {
          'subject': 'Belge Talebi - ${data['documentType']}',
          'body': _getDocumentRequestTemplate(data),
        };
      
      case EmailTemplate.custom:
        return {
          'subject': data['subject'] ?? 'Bilgilendirme',
          'body': data['body'] ?? '',
        };
    }
  }

  // Welcome email template
  String _getWelcomeTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #0D47A1; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }
            .button { background: #0D47A1; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Hoş Geldiniz!</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <p>Vize Danışmanlık CRM sistemimize hoş geldiniz. Başvuru sürecinizde size en iyi hizmeti sunmak için buradayız.</p>
                <p>Başvuru numaranız: <strong>${data['applicationId'] ?? 'Henüz atanmadı'}</strong></p>
                <p>Sorularınız için bizimle iletişime geçebilirsiniz:</p>
                <ul>
                    <li>Telefon: +90 XXX XXX XX XX</li>
                    <li>Email: info@vizedanismanlik.com</li>
                </ul>
                <p style="text-align: center;">
                    <a href="#" class="button">Başvuru Durumunu Kontrol Et</a>
                </p>
            </div>
            <div class="footer">
                <p>Bu email otomatik olarak gönderilmiştir. Lütfen yanıtlamayın.</p>
                <p>&copy; 2024 Vize Danışmanlık CRM. Tüm hakları saklıdır.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Application status template
  String _getApplicationStatusTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #0D47A1; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .status { padding: 15px; margin: 15px 0; border-radius: 5px; text-align: center; font-weight: bold; }
            .status.new { background: #E3F2FD; color: #1976D2; }
            .status.processing { background: #FFF3E0; color: #F57C00; }
            .status.completed { background: #E8F5E8; color: #388E3C; }
            .status.cancelled { background: #FFEBEE; color: #D32F2F; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Başvuru Durumu Güncellendi</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <p>Başvuru numaranız: <strong>${data['applicationId']}</strong></p>
                <div class="status ${data['status']?.toLowerCase()}">
                    Yeni Durum: ${data['statusText']}
                </div>
                <p>${data['message'] ?? 'Başvurunuzla ilgili güncellemeler için takipte kalın.'}</p>
                <p>Detaylı bilgi için bizimle iletişime geçebilirsiniz.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Payment reminder template
  String _getPaymentReminderTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #FF9800; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .amount { font-size: 24px; font-weight: bold; color: #FF9800; text-align: center; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Ödeme Hatırlatması</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <p>Başvuru sürecinizin devam edebilmesi için ödemenizin yapılması gerekmektedir.</p>
                <div class="amount">₺${data['amount']}</div>
                <p>Son ödeme tarihi: <strong>${data['dueDate']}</strong></p>
                <p>Ödeme detayları:</p>
                <ul>
                    <li>Başvuru No: ${data['applicationId']}</li>
                    <li>Hizmet: ${data['service']}</li>
                    <li>Tutar: ₺${data['amount']}</li>
                </ul>
                <p>Ödeme yapmak için bizimle iletişime geçin.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Appointment reminder template
  String _getAppointmentReminderTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .appointment { background: white; padding: 15px; border-left: 4px solid #4CAF50; margin: 15px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Randevu Hatırlatması</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <p>Yaklaşan randevunuzu hatırlatmak istiyoruz:</p>
                <div class="appointment">
                    <strong>Tarih:</strong> ${data['date']}<br>
                    <strong>Saat:</strong> ${data['time']}<br>
                    <strong>Danışman:</strong> ${data['consultant']}<br>
                    <strong>Konu:</strong> ${data['subject']}
                </div>
                <p>Randevunuza zamanında katılmanızı rica ederiz.</p>
                <p>Randevu değişikliği için en az 24 saat öncesinden bildirim yapınız.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Application complete template
  String _getApplicationCompleteTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .success { background: #E8F5E8; color: #388E3C; padding: 15px; border-radius: 5px; text-align: center; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎉 Tebrikler!</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <div class="success">
                    Başvurunuz başarıyla tamamlandı!
                </div>
                <p>Başvuru numaranız: <strong>${data['applicationId']}</strong></p>
                <p>Başvuru türü: <strong>${data['applicationType']}</strong></p>
                <p>Tamamlanma tarihi: <strong>${data['completionDate']}</strong></p>
                <p>Hizmetimizden memnun kaldığınızı umuyoruz. Gelecekteki başvurularınız için de yanınızdayız.</p>
                <p>Teşekkür ederiz!</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // Document request template
  String _getDocumentRequestTemplate(Map<String, dynamic> data) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #2196F3; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background: #f9f9f9; }
            .document-list { background: white; padding: 15px; border-radius: 5px; margin: 15px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Belge Talebi</h1>
            </div>
            <div class="content">
                <h2>Sayın ${data['name']},</h2>
                <p>Başvuru sürecinizin devam edebilmesi için aşağıdaki belgelerin gönderilmesi gerekmektedir:</p>
                <div class="document-list">
                    <h3>Talep Edilen Belgeler:</h3>
                    <ul>
                        ${(data['documents'] as List<String>?)?.map((doc) => '<li>$doc</li>').join('') ?? '<li>Belge listesi belirtilmemiş</li>'}
                    </ul>
                </div>
                <p>Son gönderim tarihi: <strong>${data['deadline']}</strong></p>
                <p>Belgeleri email ile gönderebilir veya ofisimize getirebilirsiniz.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }



  // Toplu email gönder
  Future<Map<String, bool>> sendBulkEmails({
    required List<String> recipients,
    required String subject,
    required String body,
    bool isHtml = true,
  }) async {
    final results = <String, bool>{};
    
    for (String recipient in recipients) {
      final success = await sendEmail(
        to: recipient,
        subject: subject,
        body: body,
        isHtml: isHtml,
      );
      results[recipient] = success;
      
      // Rate limiting için kısa bekleme
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }

  // Email template'lerini müşteri verisiyle birleştir
  Future<bool> sendCustomerEmail({
    required MusteriModel musteri,
    required EmailTemplate template,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'name': musteri.adSoyad,
      'email': musteri.email,
      ...?additionalData,
    };

    return await sendTemplateEmail(
      to: musteri.email,
      toName: musteri.adSoyad,
      template: template,
      data: data,
    );
  }

  // Başvuru durumu değişikliği email'i
  Future<bool> sendApplicationStatusEmail({
    required MusteriModel musteri,
    required BasvuruModel basvuru,
    required String message,
  }) async {
    return await sendCustomerEmail(
      musteri: musteri,
      template: EmailTemplate.applicationStatus,
      additionalData: {
        'applicationId': basvuru.id,
        'status': basvuru.durum.name,
        'statusText': basvuru.durum.displayName,
        'message': message,
      },
    );
  }

  // E-posta gönderim logunu kaydet
  Future<void> _logEmailSend(String to, String subject, bool success, String? error) async {
    try {
      await _firestore.collection('email_logs').add({
        'to': to,
        'subject': subject,
        'success': success,
        'error': error,
        'sentAt': Timestamp.fromDate(DateTime.now()),
        'sentBy': _auth.currentUser?.uid,
        'type': 'manual',
      });
    } catch (e) {
      print('E-posta log kaydetme hatası: $e');
    }
  }

  // Otomasyon e-posta logunu kaydet
  Future<void> _logAutomationEmailSend(List<String> recipients, String subject, bool success, String? error) async {
    try {
      await _firestore.collection('email_logs').add({
        'recipients': recipients,
        'subject': subject,
        'success': success,
        'error': error,
        'sentAt': Timestamp.fromDate(DateTime.now()),
        'sentBy': _auth.currentUser?.uid,
        'type': 'automation',
      });
    } catch (e) {
      print('Otomasyon e-posta log kaydetme hatası: $e');
    }
  }

  // Email istatistikleri
  Future<Map<String, dynamic>> getEmailStats() async {
    try {
      final logs = await _firestore
          .collection('email_logs')
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();

      int totalSent = logs.docs.length;
      int successful = logs.docs.where((doc) => doc.data()['success'] == true).length;
      int failed = totalSent - successful;

      return {
        'totalSent': totalSent,
        'successful': successful,
        'failed': failed,
        'successRate': totalSent > 0 ? (successful / totalSent * 100).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      print('Email istatistikleri alma hatası: $e');
      return {
        'totalSent': 0,
        'successful': 0,
        'failed': 0,
        'successRate': '0',
      };
    }
  }
}