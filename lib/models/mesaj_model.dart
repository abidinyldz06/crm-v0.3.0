import 'package:cloud_firestore/cloud_firestore.dart';

class MesajModel {
  final String id;
  final String gonderenId;
  final String metin;
  final Timestamp gonderilmeTarihi;
  
  MesajModel({
    required this.id,
    required this.gonderenId,
    required this.metin,
    required this.gonderilmeTarihi,
  });

  factory MesajModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MesajModel(
      id: doc.id,
      gonderenId: data['gonderenId'] ?? '',
      metin: data['metin'] ?? '',
      gonderilmeTarihi: data['gonderilmeTarihi'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gonderenId': gonderenId,
      'metin': metin,
      'gonderilmeTarihi': gonderilmeTarihi,
    };
  }
} 