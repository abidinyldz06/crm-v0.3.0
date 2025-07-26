import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiEntegrasyonServisi {
  // WhatsApp Business API (Örnek: Twilio)
  static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  static const String _twilioWhatsappFrom = 'whatsapp:+14155238886'; // Twilio sandbox number
  
  // Email API (Örnek: SendGrid)
  static const String _sendGridApiKey = 'YOUR_SENDGRID_API_KEY';
  
  // SMS API (Örnek: Twilio)
  static const String _twilioSmsFrom = '+1234567890'; // Your Twilio phone number

  // WhatsApp mesajı gönder
  Future<bool> sendWhatsAppMessage({
    required String toNumber,
    required String message,
  }) async {
    try {
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}';
      
      final response = await http.post(
        Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioWhatsappFrom,
          'To': 'whatsapp:$toNumber',
          'Body': message,
        },
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('WhatsApp mesaj gönderme hatası: $e');
      return false;
    }
  }

  // Email gönder
  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String content,
    String? fromEmail = 'noreply@vizdanismanlik.com',
    String? fromName = 'Vize Danışmanlık CRM',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [{'email': toEmail}],
            }
          ],
          'from': {
            'email': fromEmail,
            'name': fromName,
          },
          'subject': subject,
          'content': [
            {
              'type': 'text/html',
              'value': content,
            }
          ],
        }),
      );
      
      return response.statusCode == 202;
    } catch (e) {
      print('Email gönderme hatası: $e');
      return false;
    }
  }

  // SMS gönder
  Future<bool> sendSMS({
    required String toNumber,
    required String message,
  }) async {
    try {
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}';
      
      final response = await http.post(
        Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioSmsFrom,
          'To': toNumber,
          'Body': message,
        },
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('SMS gönderme hatası: $e');
      return false;
    }
  }

  // Toplu mesaj gönderimi (Email)
  Future<void> sendBulkEmail({
    required List<String> toEmails,
    required String subject,
    required String content,
  }) async {
    for (String email in toEmails) {
      await sendEmail(
        toEmail: email,
        subject: subject,
        content: content,
      );
      // Rate limiting için kısa bekleme
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  // Şablon bazlı email gönderimi
  Future<bool> sendTemplateEmail({
    required String toEmail,
    required String templateType,
    required Map<String, dynamic> templateData,
  }) async {
    String subject = '';
    String content = '';
    
    switch (templateType) {
      case 'welcome':
        subject = 'Hoş Geldiniz!';
        content = '''
          <h2>Sayın ${templateData['name']},</h2>
          <p>Vize Danışmanlık sistemimize hoş geldiniz!</p>
          <p>Başvurunuz alınmıştır ve en kısa sürede size dönüş yapılacaktır.</p>
          <br>
          <p>Saygılarımızla,<br>Vize Danışmanlık Ekibi</p>
        ''';
        break;
      case 'status_update':
        subject = 'Başvuru Durumu Güncellendi';
        content = '''
          <h2>Sayın ${templateData['name']},</h2>
          <p>Başvurunuzun durumu güncellenmiştir.</p>
          <p><strong>Yeni Durum:</strong> ${templateData['status']}</p>
          <p><strong>Açıklama:</strong> ${templateData['description'] ?? 'Detaylar için danışmanınızla iletişime geçebilirsiniz.'}</p>
          <br>
          <p>Saygılarımızla,<br>Vize Danışmanlık Ekibi</p>
        ''';
        break;
      case 'reminder':
        subject = 'Hatırlatma: ${templateData['subject']}';
        content = '''
          <h2>Sayın ${templateData['name']},</h2>
          <p>${templateData['message']}</p>
          <br>
          <p>Saygılarımızla,<br>Vize Danışmanlık Ekibi</p>
        ''';
        break;
    }
    
    return await sendEmail(
      toEmail: toEmail,
      subject: subject,
      content: content,
    );
  }
} 