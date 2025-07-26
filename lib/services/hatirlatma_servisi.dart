import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/hatirlatma_model.dart';

class HatirlatmaServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createHatirlatma({
    required String basvuruId,
    required String danismanId,
    required String mesaj,
    required Timestamp hatirlatmaTarihi,
  }) async {
    await _db.collection('hatirlatmalar').add({
      'basvuruId': basvuruId,
      'danismanId': danismanId,
      'mesaj': mesaj,
      'hatirlatmaTarihi': hatirlatmaTarihi,
      'tamamlandi': false,
    });
  }

  Stream<List<HatirlatmaModel>> getDanismanHatirlatmalari(String danismanId) {
    return _db.collection('hatirlatmalar')
        .where('danismanId', isEqualTo: danismanId)
        .where('tamamlandi', isEqualTo: false)
        .orderBy('hatirlatmaTarihi', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => HatirlatmaModel.fromFirestore(doc)).toList());
  }

  Future<void> tamamlaHatirlatma(String id) async {
    await _db.collection('hatirlatmalar').doc(id).update({'tamamlandi': true});
  }
} 