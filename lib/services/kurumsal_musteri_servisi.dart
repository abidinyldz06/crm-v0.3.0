import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/kurumsal_musteri_model.dart';

class KurumsalMusteriServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'corporate_customers';

  // Yeni kurumsal müşteri ekle
  Future<String> addKurumsalMusteri(Map<String, dynamic> musteriData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("İşlem yapmak için giriş yapmalısınız.");
    }
    
    musteriData['olusturanDanismanId'] = user.uid;
    musteriData['olusturulmaTarihi'] = Timestamp.now();
    
    final docRef = await _firestore.collection(_collectionPath).add(musteriData);
    return docRef.id;
  }

  // Tüm kurumsal müşterileri getir
  Stream<List<KurumsalMusteriModel>> getKurumsalMusterilerStream() {
    return _firestore
        .collection(_collectionPath)
        .where('isDeleted', isEqualTo: false)
        .orderBy('sirketAdi')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KurumsalMusteriModel.fromFirestore(doc))
            .toList());
  }

  // ID ile tek bir kurumsal müşteri getir
  Future<KurumsalMusteriModel?> getKurumsalMusteriById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        return KurumsalMusteriModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Kurumsal müşteri getirilirken hata: $e');
    }
    return null;
  }

  // Kurumsal müşteri bilgilerini güncelle
  Future<void> updateKurumsalMusteri(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collectionPath).doc(id).update(data);
  }

  Future<void> softDeleteKurumsalMusteri(String id) async {
    await _firestore.collection(_collectionPath).doc(id).update({'isDeleted': true});
  }
} 