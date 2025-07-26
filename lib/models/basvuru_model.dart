import 'package:cloud_firestore/cloud_firestore.dart';

enum BasvuruDurumu {
  yeni,
  islemde,
  tamamlandi,
  iptal;

  String get displayName {
    switch (this) {
      case BasvuruDurumu.yeni:
        return 'Yeni Başvuru';
      case BasvuruDurumu.islemde:
        return 'İşlemde';
      case BasvuruDurumu.tamamlandi:
        return 'Tamamlandı';
      case BasvuruDurumu.iptal:
        return 'İptal Edildi';
    }
  }
}

class BasvuruModel {
  final String id;
  final String musteriId;
  final String basvuruTuru;
  final String? atananDanismanId;
  final Timestamp olusturulmaTarihi;
  final List<Map<String, dynamic>> dosyalar;
  final bool isDeleted;
  final BasvuruDurumu durum;

  BasvuruModel({
    required this.id,
    required this.musteriId,
    required this.basvuruTuru,
    this.atananDanismanId,
    required this.olusturulmaTarihi,
    this.dosyalar = const [],
    this.isDeleted = false,
    this.durum = BasvuruDurumu.yeni,
  });

  factory BasvuruModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BasvuruModel(
      id: doc.id,
      musteriId: data['musteriId'] ?? '',
      basvuruTuru: data['basvuruTuru'] ?? '',
      atananDanismanId: data['atananDanismanId'],
      olusturulmaTarihi: data['olusturulmaTarihi'] ?? Timestamp.now(),
      dosyalar: List<Map<String, dynamic>>.from(data['dosyalar'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
      durum: BasvuruDurumu.values.firstWhere(
        (e) => e.name == (data['durum'] ?? 'yeni'),
        orElse: () => BasvuruDurumu.yeni,
      ),
    );
  }

  factory BasvuruModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return BasvuruModel(
      id: id,
      musteriId: data['musteriId'] ?? '',
      basvuruTuru: data['basvuruTuru'] ?? '',
      atananDanismanId: data['atananDanismanId'],
      olusturulmaTarihi: data['olusturulmaTarihi'] ?? Timestamp.now(),
      dosyalar: List<Map<String, dynamic>>.from(data['dosyalar'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
      durum: BasvuruDurumu.values.firstWhere(
        (e) => e.name == (data['durum'] ?? 'yeni'),
        orElse: () => BasvuruDurumu.yeni,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'musteriId': musteriId,
      'basvuruTuru': basvuruTuru,
      'atananDanismanId': atananDanismanId,
      'olusturulmaTarihi': olusturulmaTarihi,
      'dosyalar': dosyalar,
      'isDeleted': isDeleted,
      'durum': durum.name,
    };
  }
} 