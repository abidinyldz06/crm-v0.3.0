import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musteri_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'storage_servisi.dart';
import 'basvuru_servisi.dart';
import 'error_handler_service.dart';

class MusteriServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'customers';
  final ErrorHandlerService _errorHandler = ErrorHandlerService();

  Future<String> musteriEkle(MusteriModel musteri) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw AppError(
          message: "Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.",
          type: ErrorType.permission,
        );
      }
      
      // Veri validasyonu
      if (musteri.ad.trim().isEmpty) {
        throw AppError(
          message: "Müşteri adı boş olamaz.",
          type: ErrorType.validation,
        );
      }
      
      if (musteri.email.trim().isEmpty) {
        throw AppError(
          message: "E-posta adresi boş olamaz.",
          type: ErrorType.validation,
        );
      }
      
      final musteriData = musteri.toMap();
      musteriData['olusturanDanismanId'] = user.uid;
      musteriData['olusturulmaTarihi'] = Timestamp.now();
      musteriData['isDeleted'] = false;

      final docRef = await _firestore.collection(_collectionPath).add(musteriData);
      return docRef.id;
    } catch (e) {
      throw _errorHandler.handleError(e);
    }
  }

  // Eski Map versiyonu için backward compatibility
  Future<String> musteriEkleMap(Map<String, dynamic> musteriData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw AppError(
          message: "Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.",
          type: ErrorType.permission,
        );
      }
      
      // Veri validasyonu
      if (musteriData['ad']?.toString().trim().isEmpty ?? true) {
        throw AppError(
          message: "Müşteri adı boş olamaz.",
          type: ErrorType.validation,
        );
      }
      
      if (musteriData['email']?.toString().trim().isEmpty ?? true) {
        throw AppError(
          message: "E-posta adresi boş olamaz.",
          type: ErrorType.validation,
        );
      }
      
      musteriData['olusturanDanismanId'] = user.uid;
      musteriData['olusturulmaTarihi'] = Timestamp.now();
      musteriData['isDeleted'] = false;

      final docRef = await _firestore.collection(_collectionPath).add(musteriData);
      return docRef.id;
    } catch (e) {
      throw _errorHandler.handleError(e);
    }
  }

  Future<MusteriModel?> musteriGetir(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw AppError(
          message: "Geçersiz müşteri ID'si.",
          type: ErrorType.validation,
        );
      }

      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        return MusteriModel.fromFirestore(doc);
      }
      
      throw AppError(
        message: "Müşteri bulunamadı.",
        type: ErrorType.firebase,
        code: 'not-found',
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw _errorHandler.handleError(e);
    }
  }

  // ID ile tek bir müşteri getir
  Future<MusteriModel?> getMusteriById(String id) async {
    try {
      final doc = await _firestore.collection('customers').doc(id).get();
      if (doc.exists) {
        return MusteriModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Müşteri getirilirken hata: $e");
      return null;
    }
  }

  // ID ile tek bir müşteriyi stream olarak dinle
  Stream<MusteriModel?> getMusteriByIdStream(String id) {
    return _firestore.collection('customers').doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return MusteriModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Tüm müşterileri anlık olarak dinle
  Stream<List<MusteriModel>> getMusterilerStream() {
    return _firestore.collection('customers')
        .where('isDeleted', isEqualTo: false)
        .orderBy('olusturulmaTarihi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusteriModel.fromFirestore(doc))
            .where((musteri) => !musteri.isDeleted)
            .toList());
  }

  // Müşterileri isme göre ara
  Stream<List<MusteriModel>> searchMusteri(String query) {
    if (query.isEmpty) {
      return getMusterilerStream();
    }
    return _firestore.collection('customers')
        .where('ad', isGreaterThanOrEqualTo: query)
        .where('ad', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusteriModel.fromFirestore(doc))
            .where((musteri) => !musteri.isDeleted)
            .toList());
  }

  // Müşteriyi güvenli sil (soft delete)
  Future<void> softDeleteMusteri(String id) async {
    await _firestore.collection('customers').doc(id).update({
      'isDeleted': true,
    });
  }

  // Silinmiş müşterileri getir
  Stream<List<MusteriModel>> getSilinmisMusterilerStream() {
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusteriModel.fromFirestore(doc))
            .toList());
  }

  // Belirli bir kurumsal müşteriye bağlı irtibat kişilerini getir
  Stream<List<MusteriModel>> getIrtibatKisileriStream(String kurumsalMusteriId) {
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .where('kurumsalMusteriId', isEqualTo: kurumsalMusteriId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MusteriModel.fromFirestore(doc))
            .toList());
  }

  // Müşteri bilgilerini güncelle
  Future<void> updateMusteri(String id, Map<String, dynamic> data) async {
    try {
      if (id.trim().isEmpty) {
        throw AppError(
          message: "Geçersiz müşteri ID'si.",
          type: ErrorType.validation,
        );
      }

      // Veri validasyonu
      if (data['ad']?.toString().trim().isEmpty ?? false) {
        throw AppError(
          message: "Müşteri adı boş olamaz.",
          type: ErrorType.validation,
        );
      }

      await _firestore.collection('customers').doc(id).update(data);
    } catch (e) {
      if (e is AppError) rethrow;
      throw _errorHandler.handleError(e);
    }
  }

  // Müşteriyi tamamen sil (hard delete) - dikkatli kullanılmalı
  Future<void> hardDeleteMusteri(String musteriId) async {
    try {
      // Önce müşteriye ait tüm başvuruları sil
      final basvuruServisi = BasvuruServisi();
      final basvurular = await basvuruServisi.getBasvurularByMusteriId(musteriId).first;
      
      for (var basvuru in basvurular) {
        await basvuruServisi.hardDeleteBasvuru(basvuru.id);
      }
      
      // Müşteriye ait tüm dosyaları sil
      final storageServisi = StorageServisi();
      await storageServisi.musteriDosyalariniSil(musteriId: musteriId);
      
      // Son olarak müşteriyi Firestore'dan sil
      await _firestore.collection(_collectionPath).doc(musteriId).delete();
      
    } catch (e) {
      print('Müşteri tamamen silme hatası: $e');
      rethrow;
    }
  }

  // Silinmiş müşteriyi geri yükle
  Future<void> restoreMusteri(String musteriId) async {
    await _firestore.collection(_collectionPath).doc(musteriId).update({
      'isDeleted': false,
    });
  }
} 