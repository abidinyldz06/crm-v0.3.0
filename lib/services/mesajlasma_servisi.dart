import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/konusma_model.dart';
import '../models/mesaj_model.dart';

class MesajlasmaServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final String _konusmalarCollection = 'conversations';
  final String _mesajlarSubCollection = 'messages';

  String? get _uid => _auth.currentUser?.uid;

  // Mevcut kullanıcının dahil olduğu konuşmaları getir
  Stream<List<KonusmaModel>> getKonusmalarim() {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection(_konusmalarCollection)
        .where('uyeler', arrayContains: _uid)
        .orderBy('sonMesajTarihi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KonusmaModel.fromFirestore(doc))
            .toList());
  }

  // Belirli bir konuşmadaki mesajları getir
  Stream<List<MesajModel>> getMesajlar(String konusmaId) {
    return _firestore
        .collection(_konusmalarCollection)
        .doc(konusmaId)
        .collection(_mesajlarSubCollection)
        .orderBy('gonderilmeTarihi', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MesajModel.fromFirestore(doc))
            .toList());
  }

  // Yeni mesaj gönder
  Future<void> mesajGonder(String konusmaId, String metin) async {
    if (_uid == null) throw Exception('Mesaj göndermek için giriş yapmalısınız.');
    if (metin.trim().isEmpty) return;

    final mesajData = {
      'gonderenId': _uid,
      'metin': metin.trim(),
      'gonderilmeTarihi': Timestamp.now(),
    };
    
    final konusmaRef = _firestore.collection(_konusmalarCollection).doc(konusmaId);

    // Mesajı sub-collection'a ekle
    await konusmaRef.collection(_mesajlarSubCollection).add(mesajData);

    // Konuşmanın ana belgesini (son mesaj bilgisi) güncelle
    await konusmaRef.update({
      'sonMesaj': metin.trim(),
      'sonMesajTarihi': Timestamp.now(),
      // Okunmamış mesaj sayılarını diğer kullanıcılar için artır
      'okunmamisSayilari': {
        for (var uye in (await konusmaRef.get()).data()!['uyeler'])
          if (uye != _uid) '$uye': FieldValue.increment(1)
      },
    });
  }

  // Konuşmadaki mesajları okundu olarak işaretle
  Future<void> konusmayiOkunduIsaretle(String konusmaId) async {
    if (_uid == null) return;
    await _firestore.collection(_konusmalarCollection).doc(konusmaId).update({
      'okunmamisSayilari.$_uid': 0,
    });
  }

  // Yeni konuşma başlat
  Future<String> yeniKonusmaBaslat(List<String> uyeIdleri, String ilkMesaj) async {
    if (_uid == null) throw Exception('Konuşma başlatmak için giriş yapmalısınız.');
    if (!uyeIdleri.contains(_uid)) {
      uyeIdleri.add(_uid!); // Kendisini de üyelere ekle
    }

    final konusmaData = {
      'uyeler': uyeIdleri,
      'sonMesaj': ilkMesaj,
      'sonMesajTarihi': Timestamp.now(),
      'okunmamisSayilari': { for (var uid in uyeIdleri) uid : 0 },
    };

    final konusmaRef = await _firestore.collection(_konusmalarCollection).add(konusmaData);
    
    // İlk mesajı gönder
    await mesajGonder(konusmaRef.id, ilkMesaj);
    
    return konusmaRef.id;
  }
} 