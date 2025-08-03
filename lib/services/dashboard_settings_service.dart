import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardSettings {
  final List<String> enabledSections;
  final List<String> order;

  const DashboardSettings({
    required this.enabledSections,
    required this.order,
  });

  factory DashboardSettings.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const DashboardSettings(
        enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
        order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      );
    }
    final List<dynamic>? enabled = data['enabledSections'] as List<dynamic>?;
    final List<dynamic>? ord = data['order'] as List<dynamic>?;
    return DashboardSettings(
      enabledSections: (enabled ?? const ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'])
          .map((e) => e.toString())
          .toList(),
      order: (ord ?? const ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabledSections': enabledSections,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DashboardSettings copyWith({
    List<String>? enabledSections,
    List<String>? order,
  }) {
    return DashboardSettings(
      enabledSections: enabledSections ?? this.enabledSections,
      order: order ?? this.order,
    );
  }
}

class DashboardSettingsService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Path: users/{uid}/settings/dashboard
  DocumentReference<Map<String, dynamic>> _docRefFor(String uid) {
    return _firestore.collection('users').doc(uid).collection('settings').doc('dashboard');
  }

  Future<DashboardSettings> getSettings() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Oturum yoksa varsayılanları dön
      return const DashboardSettings(
        enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
        order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      );
    }
    final snap = await _docRefFor(uid).get();
    if (snap.exists) {
      return DashboardSettings.fromMap(snap.data());
    } else {
      // Varsayılanı yaz ve dön
      final defaults = const DashboardSettings(
        enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
        order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      );
      await _docRefFor(uid).set(defaults.toMap(), SetOptions(merge: true));
      return defaults;
    }
  }

  Stream<DashboardSettings> watchSettings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Oturum yoksa stream üzerinde default yayınla
      return Stream.value(const DashboardSettings(
        enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
        order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      ));
    }
    return _docRefFor(uid).snapshots().map((snap) {
      if (snap.exists) {
        return DashboardSettings.fromMap(snap.data());
      }
      return const DashboardSettings(
        enabledSections: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
        order: ['kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'],
      );
    });
    }

  Future<void> saveSettings(DashboardSettings settings) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _docRefFor(uid).set(settings.toMap(), SetOptions(merge: true));
  }
}
