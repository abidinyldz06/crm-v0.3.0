import 'package:cloud_firestore/cloud_firestore.dart';

enum SablonTuru { sozlesme, teklif, fatura, diger }

class DokumanSablonuModel {
  final String id;
  final String ad;
  final SablonTuru tur;
  final String icerik; // HTML veya Markdown formatında
  final Map<String, String> degiskenler; // {{musteriAdi}}, {{tarih}} gibi
  final Timestamp olusturulmaTarihi;
  final String olusturanId;

  DokumanSablonuModel({
    required this.id,
    required this.ad,
    required this.tur,
    required this.icerik,
    required this.degiskenler,
    required this.olusturulmaTarihi,
    required this.olusturanId,
  });

  factory DokumanSablonuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DokumanSablonuModel(
      id: doc.id,
      ad: data['ad'] ?? '',
      tur: SablonTuru.values.firstWhere(
        (e) => e.name == (data['tur'] ?? 'diger'),
        orElse: () => SablonTuru.diger,
      ),
      icerik: data['icerik'] ?? '',
      degiskenler: Map<String, String>.from(data['degiskenler'] ?? {}),
      olusturulmaTarihi: data['olusturulmaTarihi'] ?? Timestamp.now(),
      olusturanId: data['olusturanId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'tur': tur.name,
      'icerik': icerik,
      'degiskenler': degiskenler,
      'olusturulmaTarihi': olusturulmaTarihi,
      'olusturanId': olusturanId,
    };
  }
} 