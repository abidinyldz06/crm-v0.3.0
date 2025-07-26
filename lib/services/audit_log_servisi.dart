import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuditAction {
  login,
  logout,
  create,
  read,
  update,
  delete,
  export,
  permission_change,
}

class AuditLogServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Audit log kaydı oluştur
  Future<void> log({
    required AuditAction action,
    required String resource,
    String? resourceId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('audit_logs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'action': action.name,
        'resource': resource,
        'resourceId': resourceId,
        'details': details,
        'timestamp': Timestamp.now(),
        'ipAddress': await _getIpAddress(),
        'userAgent': await _getUserAgent(),
      });
    } catch (e) {
      print('Audit log hatası: $e');
    }
  }

  // Kullanıcı girişi logla
  Future<void> logLogin(String email) async {
    await log(
      action: AuditAction.login,
      resource: 'auth',
      details: {'email': email},
    );
  }

  // Kullanıcı çıkışı logla
  Future<void> logLogout() async {
    await log(
      action: AuditAction.logout,
      resource: 'auth',
    );
  }

  // Veri oluşturma logla
  Future<void> logCreate(String resource, String resourceId, Map<String, dynamic> data) async {
    await log(
      action: AuditAction.create,
      resource: resource,
      resourceId: resourceId,
      details: {'data': data},
    );
  }

  // Veri güncelleme logla
  Future<void> logUpdate(String resource, String resourceId, Map<String, dynamic> changes) async {
    await log(
      action: AuditAction.update,
      resource: resource,
      resourceId: resourceId,
      details: {'changes': changes},
    );
  }

  // Veri silme logla
  Future<void> logDelete(String resource, String resourceId) async {
    await log(
      action: AuditAction.delete,
      resource: resource,
      resourceId: resourceId,
    );
  }

  // Veri dışa aktarma logla
  Future<void> logExport(String resource, int recordCount) async {
    await log(
      action: AuditAction.export,
      resource: resource,
      details: {'recordCount': recordCount},
    );
  }

  // Yetki değişikliği logla
  Future<void> logPermissionChange(String userId, String oldRole, String newRole) async {
    await log(
      action: AuditAction.permission_change,
      resource: 'user',
      resourceId: userId,
      details: {
        'oldRole': oldRole,
        'newRole': newRole,
      },
    );
  }

  // Audit loglarını getir (admin için)
  Stream<List<Map<String, dynamic>>> getAuditLogs({
    String? userId,
    AuditAction? action,
    String? resource,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _db.collection('audit_logs');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (action != null) {
      query = query.where('action', isEqualTo: action.name);
    }
    if (resource != null) {
      query = query.where('resource', isEqualTo: resource);
    }
    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }

  // IP adresi alma (web için)
  Future<String> _getIpAddress() async {
    // Gerçek uygulamada bu bilgi server tarafından alınmalı
    return 'N/A';
  }

  // User agent alma (web için)
  Future<String> _getUserAgent() async {
    // Gerçek uygulamada bu bilgi browser'dan alınmalı
    return 'N/A';
  }
} 