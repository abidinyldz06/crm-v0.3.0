import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriModel {
  final String id;
  final String ad;
  final String soyad;
  final String telefon;
  final String email;
  final String adres;
  final String? notlar;
  final String olusturanDanismanId;
  final String basvuruUlkesi;
  final Timestamp olusturulmaTarihi;
  final bool isDeleted;
  final String? kurumsalMusteriId;
  final String? tcNo;
  final String? pasaportNo;
  final DateTime? dogumTarihi;
  final DateTime? guncellemeTarihi;
  final bool aktif;

  String get adSoyad => '$ad $soyad';

  MusteriModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.telefon,
    required this.email,
    required this.adres,
    this.notlar,
    required this.olusturanDanismanId,
    required this.basvuruUlkesi,
    required this.olusturulmaTarihi,
    this.isDeleted = false,
    this.kurumsalMusteriId,
    this.tcNo,
    this.pasaportNo,
    this.dogumTarihi,
    this.guncellemeTarihi,
    this.aktif = true,
  });

  // Firestore'dan veri okumak için
  factory MusteriModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MusteriModel(
      id: doc.id,
      ad: data['ad'] ?? '',
      soyad: data['soyad'] ?? '',
      telefon: data['telefon'] ?? '',
      email: data['email'] ?? '',
      adres: data['adres'] ?? '',
      notlar: data['notlar'],
      olusturanDanismanId: data['olusturanDanismanId'] ?? '',
      basvuruUlkesi: data['basvuruUlkesi'] ?? '',
      olusturulmaTarihi: data['olusturulmaTarihi'] ?? Timestamp.now(),
      isDeleted: data['isDeleted'] ?? false,
      kurumsalMusteriId: data['kurumsalMusteriId'],
      tcNo: data['tcNo'],
      pasaportNo: data['pasaportNo'],
      dogumTarihi: data['dogumTarihi'] != null ? (data['dogumTarihi'] as Timestamp).toDate() : null,
      guncellemeTarihi: data['guncellemeTarihi'] != null ? (data['guncellemeTarihi'] as Timestamp).toDate() : null,
      aktif: data['aktif'] ?? true,
    );
  }

  // Firestore'a veri yazmak için
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'soyad': soyad,
      'telefon': telefon,
      'email': email,
      'adres': adres,
      'notlar': notlar,
      'olusturanDanismanId': olusturanDanismanId,
      'basvuruUlkesi': basvuruUlkesi,
      'olusturulmaTarihi': olusturulmaTarihi,
      'isDeleted': isDeleted,
      'kurumsalMusteriId': kurumsalMusteriId,
      'tcNo': tcNo,
      'pasaportNo': pasaportNo,
      'dogumTarihi': dogumTarihi != null ? Timestamp.fromDate(dogumTarihi!) : null,
      'guncellemeTarihi': guncellemeTarihi != null ? Timestamp.fromDate(guncellemeTarihi!) : null,
      'aktif': aktif,
    };
  }
} 