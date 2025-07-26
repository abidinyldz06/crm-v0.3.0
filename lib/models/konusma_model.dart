import 'package:cloud_firestore/cloud_firestore.dart';

class KonusmaModel {
  final String id;
  final List<String> uyeler; // Konuşmadaki kullanıcıların UID'leri
  final String sonMesaj;
  final Timestamp sonMesajTarihi;
  final Map<String, int> okunmamisSayilari; // Her kullanıcı için okunmamış mesaj sayısı

  KonusmaModel({
    required this.id,
    required this.uyeler,
    required this.sonMesaj,
    required this.sonMesajTarihi,
    required this.okunmamisSayilari,
  });

  factory KonusmaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KonusmaModel(
      id: doc.id,
      uyeler: List<String>.from(data['uyeler'] ?? []),
      sonMesaj: data['sonMesaj'] ?? '',
      sonMesajTarihi: data['sonMesajTarihi'] ?? Timestamp.now(),
      okunmamisSayilari: Map<String, int>.from(data['okunmamisSayilari'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uyeler': uyeler,
      'sonMesaj': sonMesaj,
      'sonMesajTarihi': sonMesajTarihi,
      'okunmamisSayilari': okunmamisSayilari,
    };
  }
} 