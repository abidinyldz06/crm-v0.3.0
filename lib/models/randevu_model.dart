import 'package:cloud_firestore/cloud_firestore.dart';

class RandevuModel {
  final String id;
  final String musteriId;
  final String baslik;
  final String? not;
  final DateTime tarih;
  final String olusturanDanismanId;

  RandevuModel({
    required this.id,
    required this.musteriId,
    required this.baslik,
    this.not,
    required this.tarih,
    required this.olusturanDanismanId,
  });

  // Firestore'dan veri okumak için
  factory RandevuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return RandevuModel(
      id: doc.id,
      musteriId: data['musteriId'] ?? '',
      baslik: data['baslik'] ?? 'Başlık Yok',
      not: data['not'],
      tarih: (data['tarih'] as Timestamp).toDate(),
      olusturanDanismanId: data['olusturanDanismanId'] ?? '',
    );
  }

  // Firestore'a veri yazmak için
  Map<String, dynamic> toMap() {
    return {
      'musteriId': musteriId,
      'baslik': baslik,
      'not': not,
      'tarih': Timestamp.fromDate(tarih),
      'olusturanDanismanId': olusturanDanismanId,
    };
  }
} 