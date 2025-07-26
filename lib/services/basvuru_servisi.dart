import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/services/kullanici_servisi.dart';
import 'package:crm/services/hatirlatma_servisi.dart';
import 'package:crm/services/mesajlasma_servisi.dart';
import 'package:crm/services/api_entegrasyon_servisi.dart';
import 'package:crm/services/storage_servisi.dart';
import 'dart:math';

class BasvuruServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBasvuru({required String musteriId, required String basvuruTuru}) async {
    try {
      final kullaniciServisi = KullaniciServisi();
      final danismanlar = await kullaniciServisi.getConsultants();
      if (danismanlar.isEmpty) {
        throw Exception('Atanacak danışman bulunamadı.');
      }
      final randomDanisman = danismanlar[Random().nextInt(danismanlar.length)];
      
      final docRef = await _db.collection('applications').add({
        'musteriId': musteriId,
        'basvuruTuru': basvuruTuru,
        'atananDanismanId': randomDanisman.uid,
        'olusturulmaTarihi': Timestamp.now(),
        'dosyalar': [],
        'isDeleted': false,
        'durum': BasvuruDurumu.yeni.name,
      });
      
      // Otomatik hatırlatıcı ekle (1 gün sonrası için)
      final hatirlatmaServisi = HatirlatmaServisi();
      final birGunSonra = Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
      await hatirlatmaServisi.createHatirlatma(
        basvuruId: docRef.id,
        danismanId: randomDanisman.uid,
        mesaj: 'Başvuru takibi: $basvuruTuru - Müşteri ID: $musteriId',
        hatirlatmaTarihi: birGunSonra,
      );
    } catch (e) {
      print('Başvuru oluşturma hatası: $e');
      rethrow;
    }
  }
  
  Stream<List<BasvuruModel>> getSonBasvurularStream() {
    return _db
        .collection('applications')
        .orderBy('olusturulmaTarihi', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList());
  }

  Stream<List<BasvuruModel>> getTumBasvurularStream() {
    return _db
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .orderBy('olusturulmaTarihi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList());
  }

  // Belirli bir danışmana atanan başvuruları getir
  Stream<List<BasvuruModel>> getDanismaninBasvurulariStream(String danismanId) {
    return _db
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('atananDanismanId', isEqualTo: danismanId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList());
  }

  // Belirli bir danışmana atanan son 10 başvuruyu getir
  Stream<List<BasvuruModel>> getDanismaninSonBasvurulariStream(String danismanId) {
    return _db
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('atananDanismanId', isEqualTo: danismanId)
        .orderBy('olusturulmaTarihi', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList());
  }
  
  // Başvurularda arama yap (Müşteri Adı veya Başvuru ID'si ile)
  // Not: Bu basit arama, küçük veri setleri için uygundur. 
  // Büyük veri setleri için daha gelişmiş bir arama servisi (örn. Algolia) gerekir.
  Stream<List<BasvuruModel>> searchBasvurular(String query) {
    return getTumBasvurularStream().asyncMap((basvurular) async {
      if (query.isEmpty) {
        return basvurular;
      }
      
      final lowerCaseQuery = query.toLowerCase();
      final List<MusteriModel?> musteriler = await Future.wait(
        basvurular.map((basvuru) => MusteriServisi().getMusteriById(basvuru.musteriId))
      );

      final List<BasvuruModel> sonuclar = [];
      for (int i = 0; i < basvurular.length; i++) {
        final musteri = musteriler[i];
        if (musteri != null && musteri.adSoyad.toLowerCase().contains(lowerCaseQuery)) {
          sonuclar.add(basvurular[i]);
        } else if (basvurular[i].id.toLowerCase().contains(lowerCaseQuery)) {
           sonuclar.add(basvurular[i]);
        }
      }
      return sonuclar;
    });
  }

  Future<BasvuruModel?> getBasvuruById(String id) async {
    try {
      final doc = await _db.collection('applications').doc(id).get();
      if (doc.exists) {
        return BasvuruModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Başvuru getirme hatası: $e');
    }
    return null;
  }

  Future<void> danismanAta(String basvuruId, String danismanId) async {
    await _db.collection('applications').doc(basvuruId).update({
      'atananDanismanId': danismanId,
    });
  }

  // Silinmiş başvuruları getir
  Stream<List<BasvuruModel>> getSilinmisBasvurularStream() {
    return _db
        .collection('applications')
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BasvuruModel.fromFirestore(doc))
            .toList());
  }

  Future<void> dosyaEkle(String basvuruId, Map<String, dynamic> dosyaBilgisi) async {
    await _db.collection('applications').doc(basvuruId).update({
      'dosyalar': FieldValue.arrayUnion([dosyaBilgisi]),
    });
  }

  // Yeni Fonksiyon: Başvuru durumunu güncelle
  Future<void> updateBasvuruDurumu(String basvuruId, BasvuruDurumu yeniDurum) async {
    await _db.collection('applications').doc(basvuruId).update({
      'durum': yeniDurum.name,
    });
    
    // İş akışı: Durum değişikliğinde otomatik mesaj gönder
    final basvuru = await getBasvuruById(basvuruId);
    if (basvuru != null) {
      final mesajlasmaServisi = MesajlasmaServisi();
      final musteri = await MusteriServisi().getMusteriById(basvuru.musteriId);
      
      if (musteri != null) {
        String mesajIcerigi = '';
        switch (yeniDurum) {
          case BasvuruDurumu.islemde:
            mesajIcerigi = 'Sayın ${musteri.adSoyad}, başvurunuz işleme alındı.';
            break;
          case BasvuruDurumu.tamamlandi:
            mesajIcerigi = 'Sayın ${musteri.adSoyad}, başvurunuz başarıyla tamamlandı!';
            break;
          case BasvuruDurumu.iptal:
            mesajIcerigi = 'Sayın ${musteri.adSoyad}, başvurunuz iptal edildi.';
            break;
          default:
            break;
        }
        
        if (mesajIcerigi.isNotEmpty && basvuru.atananDanismanId != null) {
          // Danışman ve müşteri arasında konuşma oluştur/bul ve mesaj gönder
          // Konuşma ID'si bulunmalı veya oluşturulmalı, örnek olarak konuşma ID'si müşteri ve danışman ID'sinden türetilebilir veya ayrı bir sorgu ile bulunabilir.
          // Şimdilik örnek olarak müşteri ve danışman ID'sini birleştirerek bir konuşma ID'si oluşturuyorum:
          String konusmaId = basvuru.id; // veya uygun bir konuşma ID'si bulunmalı
          await mesajlasmaServisi.mesajGonder(
            konusmaId,
            mesajIcerigi,
          );
          
          // API entegrasyonu ile email gönder
          final apiServisi = ApiEntegrasyonServisi();
          await apiServisi.sendTemplateEmail(
            toEmail: musteri.email,
            templateType: 'status_update',
            templateData: {
              'name': musteri.adSoyad,
              'status': yeniDurum.displayName,
              'description': mesajIcerigi,
            },
          );
        }
      }
    }
  }

  // Genel Başvuru Güncelleme
  Future<void> updateBasvuru(String basvuruId, Map<String, dynamic> data) async {
    await _db.collection('applications').doc(basvuruId).update(data);
  }

  // Başvuru durumu güncelle
  Future<void> durumGuncelle(String basvuruId, BasvuruDurumu yeniDurum) async {
    await _db.collection('applications').doc(basvuruId).update({
      'durum': yeniDurum.name,
      'guncellemeTarihi': Timestamp.now(),
    });
  }

  // Belirli bir müşteriye ait başvuruları getir
  Stream<List<BasvuruModel>> getBasvurularByMusteriId(String musteriId) {
    return _db
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('musteriId', isEqualTo: musteriId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList();
          // Client-side sorting
          docs.sort((a, b) => b.olusturulmaTarihi.compareTo(a.olusturulmaTarihi));
          return docs;
        });
  }

  // Başvuruyu güvenli sil (soft delete)
  Future<void> softDeleteBasvuru(String basvuruId) async {
    await _db.collection('applications').doc(basvuruId).update({
      'isDeleted': true,
    });
  }

  // Başvurudan dosya sil
  Future<bool> basvurudanDosyaSil({
    required String basvuruId,
    required Map<String, String> dosyaBilgisi,
  }) async {
    try {
      final basvuru = await getBasvuruById(basvuruId);
      if (basvuru == null) return false;

      // Storage'dan dosyayı sil
      final storageServisi = StorageServisi();
      final silmeBasarili = await storageServisi.dosyaSil(
        dosyaUrl: dosyaBilgisi['url'] ?? '',
        musteriId: basvuru.musteriId,
        basvuruId: basvuruId,
        dosyaAdi: dosyaBilgisi['name'] ?? '',
      );

      if (silmeBasarili) {
        // Firestore'dan dosya bilgisini kaldır
        await _db.collection('applications').doc(basvuruId).update({
          'dosyalar': FieldValue.arrayRemove([dosyaBilgisi]),
        });
        return true;
      }
      
      return false;
    } catch (e) {
      print('Başvurudan dosya silme hatası: $e');
      return false;
    }
  }

  // Başvuru tamamen silindiğinde dosyaları da sil
  Future<void> hardDeleteBasvuru(String basvuruId) async {
    try {
      final basvuru = await getBasvuruById(basvuruId);
      if (basvuru != null) {
        // Önce dosyaları sil
        final storageServisi = StorageServisi();
        await storageServisi.basvuruDosyalariniSil(
          musteriId: basvuru.musteriId,
          basvuruId: basvuruId,
        );
        
        // Sonra Firestore'dan sil
        await _db.collection('applications').doc(basvuruId).delete();
      }
    } catch (e) {
      print('Başvuru tamamen silme hatası: $e');
      rethrow;
    }
  }
} 