import 'package:cloud_firestore/cloud_firestore.dart';

class HatirlatmaModel {
  final String id;
  final String basvuruId;
  final String danismanId;
  final String mesaj;
  final Timestamp hatirlatmaTarihi;
  final bool tamamlandi;

  HatirlatmaModel({
    required this.id,
    required this.basvuruId,
    required this.danismanId,
    required this.mesaj,
    required this.hatirlatmaTarihi,
    this.tamamlandi = false,
  });

  factory HatirlatmaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HatirlatmaModel(
      id: doc.id,
      basvuruId: data['basvuruId'] ?? '',
      danismanId: data['danismanId'] ?? '',
      mesaj: data['mesaj'] ?? '',
      hatirlatmaTarihi: data['hatirlatmaTarihi'] ?? Timestamp.now(),
      tamamlandi: data['tamamlandi'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basvuruId': basvuruId,
      'danismanId': danismanId,
      'mesaj': mesaj,
      'hatirlatmaTarihi': hatirlatmaTarihi,
      'tamamlandi': tamamlandi,
    };
  }
} 