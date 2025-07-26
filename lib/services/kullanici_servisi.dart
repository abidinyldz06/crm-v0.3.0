import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/kullanici_model.dart';

class KullaniciServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mevcut oturum açmış kullanıcının tüm bilgilerini getirir.
  Future<KullaniciModel?> mevcutKullaniciBilgileri() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return KullaniciModel.fromFirestore(doc);
        }
      } catch (e) {
        print('Mevcut kullanıcı bilgileri alınırken hata: $e');
      }
    }
    return null;
  }

  /// ID ile tek bir kullanıcı getirir.
  Future<KullaniciModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return KullaniciModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Kullanıcı bilgisi alınırken hata: $e');
    }
    return null;
  }

  /// Rolü "danışman" olan tüm kullanıcıları getirir.
  Future<List<KullaniciModel>> getConsultants() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').where('role', isEqualTo: 'danisman').get();
      return snapshot.docs.map((doc) => KullaniciModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Danışmanları getirirken hata: $e');
      return [];
    }
  }
  
  /// Kullanıcının Firestore'daki verilerini günceller.
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Kullanıcı verileri güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Kullanıcının ayarlarını günceller.
  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı ayarları güncellenirken hata: $e');
      rethrow;
    }
  }

  /// Kullanıcının ayarlarını getirir.
  Future<Map<String, dynamic>?> getUserSettings(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['settings'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Kullanıcı ayarları alınırken hata: $e');
    }
    return null;
  }

  /// Tüm kullanıcıları getirir (admin için).
  Future<List<KullaniciModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => KullaniciModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Tüm kullanıcılar getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcı rolünü günceller (admin için).
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı rolü güncellenirken hata: $e');
      rethrow;
    }
  }
} 