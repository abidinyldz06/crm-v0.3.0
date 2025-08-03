import 'package:crm/models/kullanici_model.dart';
import 'package:flutter/material.dart';

enum Permission {
  // Müşteri işlemleri
  musteriGoruntule,
  musteriEkle,
  musteriDuzenle,
  musteriSil,
  
  // Başvuru işlemleri
  basvuruGoruntule,
  basvuruEkle,
  basvuruDuzenle,
  basvuruSil,
  basvuruDanismanAta,
  
  // (Finans işlemleri kaldırıldı)
  teklifOlustur,
  
  // Raporlama
  raporGoruntule,
  raporIndir,
  
  // Yönetim
  kullaniciYonet,
  sistemAyarlari,
  
  // Mesajlaşma
  mesajGonder,
  tumMesajlariGor,
}

class PermissionServisi {
  static final Map<String, Set<Permission>> _rolePermissions = {
    'admin': Permission.values.toSet(), // Admin tüm yetkilere sahip
    'consultant': {
      Permission.musteriGoruntule,
      Permission.musteriEkle,
      Permission.musteriDuzenle,
      Permission.basvuruGoruntule,
      Permission.basvuruEkle,
      Permission.basvuruDuzenle,
      Permission.teklifOlustur,
      Permission.raporGoruntule,
      Permission.mesajGonder,
    },
    'viewer': {
      Permission.musteriGoruntule,
      Permission.basvuruGoruntule,
      Permission.raporGoruntule,
    },
  };

  // Kullanıcının belirli bir yetkiye sahip olup olmadığını kontrol et
  static bool hasPermission(KullaniciModel user, Permission permission) {
    final permissions = _rolePermissions[user.role] ?? {};
    return permissions.contains(permission);
  }

  // Kullanıcının birden fazla yetkiden herhangi birine sahip olup olmadığını kontrol et
  static bool hasAnyPermission(KullaniciModel user, List<Permission> permissions) {
    final userPermissions = _rolePermissions[user.role] ?? {};
    return permissions.any((p) => userPermissions.contains(p));
  }

  // Kullanıcının tüm belirtilen yetkilere sahip olup olmadığını kontrol et
  static bool hasAllPermissions(KullaniciModel user, List<Permission> permissions) {
    final userPermissions = _rolePermissions[user.role] ?? {};
    return permissions.every((p) => userPermissions.contains(p));
  }

  // Rol için tüm yetkileri getir
  static Set<Permission> getPermissionsForRole(String role) {
    return _rolePermissions[role] ?? {};
  }

  // Yetki kontrolü widget'ı
  static Widget withPermission({
    required KullaniciModel user,
    required Permission permission,
    required Widget child,
    Widget? fallback,
  }) {
    if (hasPermission(user, permission)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

// Yetki kontrolü için extension
extension PermissionCheck on KullaniciModel {
  bool can(Permission permission) {
    return PermissionServisi.hasPermission(this, permission);
  }

  bool canAny(List<Permission> permissions) {
    return PermissionServisi.hasAnyPermission(this, permissions);
  }

  bool canAll(List<Permission> permissions) {
    return PermissionServisi.hasAllPermissions(this, permissions);
  }
}
