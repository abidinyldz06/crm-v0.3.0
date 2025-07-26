import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/kullanici_model.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sifreSifirla(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      // Hata yönetimi burada yapılabilir, örneğin kullanıcıya bir mesaj gösterilebilir.
      rethrow;
    }
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      return (doc.data() as Map<String, dynamic>)['role'];
    }
    return null;
  }

  Future<KullaniciModel?> currentUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("DEBUG (AuthService): _auth.currentUser değeri null. Kullanıcı girişi yapılmamış veya oturum bilgisi bekleniyor.");
      return null;
    }

    print("DEBUG (AuthService): Auth kullanıcısı bulundu: ${user.uid}. Firestore belgesi alınıyor...");
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print("DEBUG (AuthService): Firestore'da ${user.uid} için kullanıcı belgesi bulunamadı!");
        return null;
      }
      
      print("DEBUG (AuthService): Firestore belgesi bulundu. Model oluşturuluyor...");
      return KullaniciModel.fromFirestore(doc);
    } catch (e) {
      print("DEBUG (AuthService): Firestore'dan belge alınırken hata oluştu: $e");
      return null;
    }
  }

  // 2FA kod üretimi
  String generate2FACode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 2FA kodunu kullanıcıya gönder
  Future<void> send2FACode(String email) async {
    final code = generate2FACode();
    final expiry = DateTime.now().add(Duration(minutes: 5));
    
    // Kodu Firestore'a kaydet
    await _db.collection('2fa_codes').doc(email).set({
      'code': code,
      'expiry': expiry,
      'used': false,
    });
    
    // Email ile kodu gönder (API entegrasyon servisi kullanarak)
    // Bu kısım gerçek uygulamada yapılmalı
    print('2FA Kodu: $code'); // Test için
  }

  // 2FA kodunu doğrula
  Future<bool> verify2FACode(String email, String code) async {
    try {
      final doc = await _db.collection('2fa_codes').doc(email).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final expiry = (data['expiry'] as Timestamp).toDate();
      final isUsed = data['used'] as bool;
      final savedCode = data['code'] as String;
      
      if (DateTime.now().isAfter(expiry) || isUsed || savedCode != code) {
        return false;
      }
      
      // Kodu kullanıldı olarak işaretle
      await doc.reference.update({'used': true});
      return true;
    } catch (e) {
      print('2FA doğrulama hatası: $e');
      return false;
    }
  }

  // Güvenli giriş (2FA ile)
  Future<UserCredential?> signInWithEmailAnd2FA({
    required String email,
    required String password,
    required String twoFACode,
  }) async {
    try {
      // Önce 2FA kodunu doğrula
      final isCodeValid = await verify2FACode(email, twoFACode);
      if (!isCodeValid) {
        throw Exception('Geçersiz veya süresi dolmuş 2FA kodu');
      }
      
      // Sonra normal giriş yap
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('2FA ile giriş hatası: $e');
      rethrow;
    }
  }
} 