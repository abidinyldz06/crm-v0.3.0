import 'package:cloud_firestore/cloud_firestore.dart';

class KullaniciModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? role;

  KullaniciModel({
    required this.uid,
    this.email,
    this.displayName,
    this.role,
  });

  bool get isAdmin => role == 'admin';
  String? get ad => displayName;
  
  factory KullaniciModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KullaniciModel(
      uid: doc.id,
      email: data.containsKey('email') ? data['email'] : '',
      displayName: data.containsKey('displayName') ? data['displayName'] : '',
      role: data.containsKey('role') ? data['role'] : 'consultant',
    );
  }

  factory KullaniciModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return KullaniciModel(
      uid: id,
      email: data.containsKey('email') ? data['email'] : '',
      displayName: data.containsKey('displayName') ? data['displayName'] : '',
      role: data.containsKey('role') ? data['role'] : 'consultant',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
} 