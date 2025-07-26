import 'package:cloud_firestore/cloud_firestore.dart';

class KurumsalMusteriModel {
  final String id;
  final String sirketAdi;
  final String? vergiNo;
  final String? telefon;
  final String? email;
  final String? adres;
  final String? notlar;
  final String olusturanDanismanId;
  final Timestamp olusturulmaTarihi;
  final bool isDeleted;

  KurumsalMusteriModel({
    required this.id,
    required this.sirketAdi,
    this.vergiNo,
    this.telefon,
    this.email,
    this.adres,
    this.notlar,
    required this.olusturanDanismanId,
    required this.olusturulmaTarihi,
    this.isDeleted = false,
  });

  factory KurumsalMusteriModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KurumsalMusteriModel(
      id: doc.id,
      sirketAdi: data['sirketAdi'] ?? '',
      vergiNo: data['vergiNo'],
      telefon: data['telefon'],
      email: data['email'],
      adres: data['adres'],
      notlar: data['notlar'],
      olusturanDanismanId: data['olusturanDanismanId'] ?? '',
      olusturulmaTarihi: data['olusturulmaTarihi'] ?? Timestamp.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sirketAdi': sirketAdi,
      'vergiNo': vergiNo,
      'telefon': telefon,
      'email': email,
      'adres': adres,
      'notlar': notlar,
      'olusturanDanismanId': olusturanDanismanId,
      'olusturulmaTarihi': olusturulmaTarihi,
      'isDeleted': isDeleted,
    };
  }
} 