import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/randevu_model.dart';

class RandevuServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'appointments';

  // Yeni randevu oluştur
  Future<void> addRandevu(Map<String, dynamic> randevuData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Randevu oluşturmak için giriş yapmalısınız.");
    }
    
    randevuData['olusturanDanismanId'] = user.uid;
    
    await _firestore.collection(_collectionPath).add(randevuData);
  }

  // Belirli bir aydaki randevuları getir
  Stream<List<RandevuModel>> getRandevular(DateTime ay) {
    DateTime ayinIlkGunu = DateTime(ay.year, ay.month, 1);
    DateTime ayinSonGunu = DateTime(ay.year, ay.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection(_collectionPath)
        .where('tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(ayinIlkGunu))
        .where('tarih', isLessThanOrEqualTo: Timestamp.fromDate(ayinSonGunu))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RandevuModel.fromFirestore(doc)).toList();
    });
  }
} 