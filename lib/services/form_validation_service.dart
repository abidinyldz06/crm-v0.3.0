class FormValidationService {
  static final FormValidationService _instance = FormValidationService._internal();
  factory FormValidationService() => _instance;
  FormValidationService._internal();

  // E-posta validasyonu
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  // Telefon validasyonu
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Telefon opsiyonel
    }
    
    // Türkiye telefon formatları: +90, 0, veya direkt
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Geçerli bir telefon numarası girin (örn: 05xxxxxxxxx)';
    }
    
    return null;
  }

  // Ad/Soyad validasyonu
  String? validateName(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gereklidir';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName en az 2 karakter olmalıdır';
    }
    
    if (value.trim().length > 50) {
      return '$fieldName en fazla 50 karakter olabilir';
    }
    
    // Sadece harf, boşluk ve Türkçe karakterler
    final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName sadece harf içerebilir';
    }
    
    return null;
  }

  // Şifre validasyonu
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    
    if (value.length > 128) {
      return 'Şifre en fazla 128 karakter olabilir';
    }
    
    // En az bir harf ve bir rakam
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    
    return null;
  }

  // Şifre tekrar validasyonu
  String? validatePasswordConfirm(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }
    
    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  // Genel metin validasyonu
  String? validateText(String? value, {
    required String fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName gereklidir';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      if (minLength != null && value.trim().length < minLength) {
        return '$fieldName en az $minLength karakter olmalıdır';
      }
      
      if (maxLength != null && value.trim().length > maxLength) {
        return '$fieldName en fazla $maxLength karakter olabilir';
      }
    }
    
    return null;
  }

  // URL validasyonu
  String? validateUrl(String? value, {bool required = false}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return 'URL gereklidir';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value!.trim())) {
      return 'Geçerli bir URL girin (http:// veya https:// ile başlamalı)';
    }
    
    return null;
  }

  // Sayı validasyonu
  String? validateNumber(String? value, {
    required String fieldName,
    bool required = true,
    double? min,
    double? max,
  }) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName gereklidir';
    }
    
    final number = double.tryParse(value!.trim());
    if (number == null) {
      return '$fieldName geçerli bir sayı olmalıdır';
    }
    
    if (min != null && number < min) {
      return '$fieldName en az $min olmalıdır';
    }
    
    if (max != null && number > max) {
      return '$fieldName en fazla $max olabilir';
    }
    
    return null;
  }

  // TC Kimlik No validasyonu
  String? validateTcKimlik(String? value, {bool required = false}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return 'TC Kimlik No gereklidir';
    }
    
    final cleanValue = value!.replaceAll(RegExp(r'\D'), '');
    
    if (cleanValue.length != 11) {
      return 'TC Kimlik No 11 haneli olmalıdır';
    }
    
    if (cleanValue[0] == '0') {
      return 'TC Kimlik No 0 ile başlayamaz';
    }
    
    // TC Kimlik No algoritması
    final digits = cleanValue.split('').map(int.parse).toList();
    
    int oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    int evenSum = digits[1] + digits[3] + digits[5] + digits[7];
    
    int check1 = (oddSum * 7 - evenSum) % 10;
    int check2 = (oddSum + evenSum + digits[9]) % 10;
    
    if (check1 != digits[9] || check2 != digits[10]) {
      return 'Geçersiz TC Kimlik No';
    }
    
    return null;
  }

  // Vergi No validasyonu
  String? validateVergiNo(String? value, {bool required = false}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Vergi No gereklidir';
    }
    
    final cleanValue = value!.replaceAll(RegExp(r'\D'), '');
    
    if (cleanValue.length != 10) {
      return 'Vergi No 10 haneli olmalıdır';
    }
    
    return null;
  }

  // Tarih validasyonu
  String? validateDate(String? value, {
    required String fieldName,
    bool required = true,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName gereklidir';
    }
    
    final date = DateTime.tryParse(value!);
    if (date == null) {
      return '$fieldName geçerli bir tarih olmalıdır';
    }
    
    if (minDate != null && date.isBefore(minDate)) {
      return '$fieldName ${_formatDate(minDate)} tarihinden sonra olmalıdır';
    }
    
    if (maxDate != null && date.isAfter(maxDate)) {
      return '$fieldName ${_formatDate(maxDate)} tarihinden önce olmalıdır';
    }
    
    return null;
  }

  // Yaş validasyonu
  String? validateAge(String? value, {
    required String fieldName,
    bool required = true,
    int? minAge,
    int? maxAge,
  }) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName gereklidir';
    }
    
    final age = int.tryParse(value!.trim());
    if (age == null) {
      return '$fieldName geçerli bir yaş olmalıdır';
    }
    
    if (minAge != null && age < minAge) {
      return '$fieldName en az $minAge olmalıdır';
    }
    
    if (maxAge != null && age > maxAge) {
      return '$fieldName en fazla $maxAge olabilir';
    }
    
    return null;
  }

  // Yardımcı metod: Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Çoklu validasyon
  String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}