import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/musteri_model.dart';
import '../models/basvuru_model.dart';
import '../models/kurumsal_musteri_model.dart';

class DashboardStats {
  final int toplamMusteri;
  final int toplamBasvuru;
  final int yeniBasvuru;
  final int islemdekiBasvuru;
  final int tamamlananBasvuru;
  final Map<BasvuruDurumu, int> basvuruDurumDagilimi;
  final List<MapEntry<DateTime, int>> son7GunTrend;
  final Map<String, int> aylikBasvurular;

  DashboardStats({
    required this.toplamMusteri,
    required this.toplamBasvuru,
    required this.yeniBasvuru,
    required this.islemdekiBasvuru,
    required this.tamamlananBasvuru,
    required this.basvuruDurumDagilimi,
    required this.son7GunTrend,
    required this.aylikBasvurular,
  });
}

class DashboardStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache için static değişkenler - süre artırıldı
  static Map<String, dynamic>? _cachedSummary;
  static DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // 2'den 5'e çıkarıldı

  // Dashboard özeti - cache ile optimize edilmiş
  Stream<Map<String, dynamic>> getDashboardSummary() {
    final now = DateTime.now();
    
    // Cache kontrolü
    if (_cachedSummary != null && _lastCacheTime != null) {
      if (now.difference(_lastCacheTime!) < _cacheDuration) {
        return Stream.value(_cachedSummary!);
      }
    }

    return Rx.combineLatest5(
      getTotalCustomers(),
      getTotalCorporateCustomers(),
      getTotalApplications(),
      getThisMonthCustomers(),
      getThisMonthApplications(),
      (int customers, int corporateCustomers, int applications, int thisMonthCustomers, int thisMonthApplications) {
        final summary = {
          'totalCustomers': customers + corporateCustomers,
          'totalApplications': applications,
          'thisMonthCustomers': thisMonthCustomers,
          'thisMonthApplications': thisMonthApplications,
        };
        
        // Cache'i güncelle
        _cachedSummary = summary;
        _lastCacheTime = now;
        
        return summary;
      },
    ).distinct();
  }

  // Toplam müşteri sayısı - optimize edilmiş
  Stream<int> getTotalCustomers() {
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .distinct()
        .debounceTime(const Duration(milliseconds: 500)); // Debounce eklendi
  }

  // Toplam kurumsal müşteri sayısı - optimize edilmiş
  Stream<int> getTotalCorporateCustomers() {
    return _firestore
        .collection('corporate_customers')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .distinct()
        .debounceTime(const Duration(milliseconds: 500)); // Debounce eklendi
  }

  // Toplam başvuru sayısı - optimize edilmiş
  Stream<int> getTotalApplications() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .distinct()
        .debounceTime(const Duration(milliseconds: 500)); // Debounce eklendi
  }

  // Bu ay eklenen müşteri sayısı - optimize edilmiş
  Stream<int> getThisMonthCustomers() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .distinct()
        .debounceTime(const Duration(milliseconds: 500)); // Debounce eklendi
  }

  // Bu ay eklenen başvuru sayısı - optimize edilmiş
  Stream<int> getThisMonthApplications() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .distinct()
        .debounceTime(const Duration(milliseconds: 500)); // Debounce eklendi
  }

  // Başvuru durumu dağılımı - optimize edilmiş
  Stream<Map<String, double>> getApplicationStatusDistribution() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .limit(50) // Limit eklendi
        .snapshots()
        .map((snapshot) {
      final Map<String, int> statusCounts = {};
      
      for (var doc in snapshot.docs) {
        final status = doc.data()['durum'] ?? 'Bilinmiyor';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      
      return statusCounts.map((key, value) => MapEntry(key, value.toDouble()));
    })
    .distinct()
    .debounceTime(const Duration(milliseconds: 1000)); // Debounce eklendi
  }

  // Son 7 günlük başvuru trendi - optimize edilmiş
  Stream<Map<String, double>> getWeeklyApplicationTrend() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .limit(100) // Limit eklendi
        .snapshots()
        .map((snapshot) {
      final Map<String, int> dailyCounts = {};
      
      // Son 7 günü hazırla
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';
        dailyCounts[dateKey] = 0;
      }
      
      // Başvuruları günlere göre say
      for (var doc in snapshot.docs) {
        final timestamp = doc.data()['olusturulmaTarihi'] as Timestamp;
        final date = timestamp.toDate();
        final dateKey = '${date.day}/${date.month}';
        dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      }
      
      return dailyCounts.map((key, value) => MapEntry(key, value.toDouble()));
    })
    .distinct()
    .debounceTime(const Duration(milliseconds: 1000)); // Debounce eklendi
  }

  // Son aktiviteler - optimize edilmiş (limit azaltıldı)
  Stream<List<Map<String, dynamic>>> getRecentActivities() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .orderBy('olusturulmaTarihi', descending: true)
        .limit(3) // 5'ten 3'e düşürüldü
        .snapshots()
        .map((snapshot) {
      final activities = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['olusturulmaTarihi'] as Timestamp;
        final musteriAdi = data['musteriAdi'] ?? 'Bilinmeyen Müşteri';
        
        activities.add({
          'title': 'Yeni başvuru eklendi',
          'subtitle': musteriAdi,
          'time': _formatTimeAgo(timestamp.toDate()),
          'icon': Icons.assignment_add,
        });
      }
      
      return activities;
    })
    .distinct()
    .debounceTime(const Duration(milliseconds: 1000)); // Debounce eklendi
  }

  // İlerleme istatistikleri - optimize edilmiş
  Stream<Map<String, dynamic>> getProgressStats() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .limit(100) // Limit eklendi
        .snapshots()
        .map((snapshot) {
      int tamamlanan = 0;
      int toplam = snapshot.docs.length;
      
      for (var doc in snapshot.docs) {
        final durum = doc.data()['durum'] as String?;
        if (durum == 'Tamamlandı' || durum == 'Onaylandı') {
          tamamlanan++;
        }
      }
      
      final progress = toplam > 0 ? tamamlanan / toplam : 0.0;
      
      return {
        'progress': progress,
        'tamamlanan': tamamlanan,
        'toplam': toplam,
      };
    })
    .distinct()
    .debounceTime(const Duration(milliseconds: 1000)); // Debounce eklendi
  }

  // Zaman formatı yardımcı fonksiyonu
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  // Danışmana göre başvuru dağılımı
  Stream<Map<String, double>> getApplicationsByConsultant() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
      final Map<String, int> consultantCounts = {};
      
      for (var doc in snapshot.docs) {
        final danismanId = doc.data()['atananDanismanId'] as String?;
        if (danismanId != null) {
          // Danışman adını al
          final danismanDoc = await _firestore.collection('users').doc(danismanId).get();
          String danismanAdi = 'Bilinmeyen Danışman';
          
          if (danismanDoc.exists) {
            final danismanData = danismanDoc.data()!;
            danismanAdi = danismanData['ad'] ?? 'Bilinmeyen Danışman';
          }
          
          consultantCounts[danismanAdi] = (consultantCounts[danismanAdi] ?? 0) + 1;
        }
      }
      
      return consultantCounts.map((key, value) => MapEntry(key, value.toDouble()));
    });
  }

  // Ülkeye göre başvuru dağılımı
  Stream<Map<String, double>> getApplicationsByCountry() {
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final Map<String, int> countryCounts = {};
      
      for (var doc in snapshot.docs) {
        final ulke = doc.data()['basvuruUlkesi'] ?? 'Bilinmiyor';
        countryCounts[ulke] = (countryCounts[ulke] ?? 0) + 1;
      }
      
      return countryCounts.map((key, value) => MapEntry(key, value.toDouble()));
    });
  }

  // Cache'i temizle
  void clearCache() {
    _cachedSummary = null;
    _lastCacheTime = null;
  }

  // Eksik fonksiyonlar
  Stream<int> getTotalCustomers() {
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTotalApplications() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getThisMonthCustomers() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _firestore
        .collection('customers')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getThisMonthApplications() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTotalCorporateCustomers() {
    return _firestore
        .collection('corporate_customers')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

// Gelişmiş dashboard istatistikleri
  Stream<DashboardStats> getAdvancedStats() {
    return Rx.combineLatest7(
      getTotalCustomers(),
      getTotalApplications(),
      getApplicationsByStatus('yeni'),
      getApplicationsByStatus('islemde'),
      getApplicationsByStatus('tamamlandi'),
      getApplicationStatusDistributionAdvanced(),
      getLast7DaysTrend(),
      (totalCustomers, totalApplications, newApps, inProgressApps, completedApps, statusDistribution, weeklyTrend) {
        return DashboardStats(
          toplamMusteri: totalCustomers,
          toplamBasvuru: totalApplications,
          yeniBasvuru: newApps,
          islemdekiBasvuru: inProgressApps,
          tamamlananBasvuru: completedApps,
          basvuruDurumDagilimi: statusDistribution,
          son7GunTrend: weeklyTrend,
          aylikBasvurular: {}, // Bu ayrı bir stream'den gelecek
        );
      },
    );
  }

  // Duruma göre başvuru sayısı
  Stream<int> getApplicationsByStatus(String status) {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('durum', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Gelişmiş durum dağılımı
  Stream<Map<BasvuruDurumu, int>> getApplicationStatusDistributionAdvanced() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final Map<BasvuruDurumu, int> distribution = {
        BasvuruDurumu.yeni: 0,
        BasvuruDurumu.islemde: 0,
        BasvuruDurumu.tamamlandi: 0,
        BasvuruDurumu.iptal: 0,
      };

      for (var doc in snapshot.docs) {
        final statusString = doc.data()['durum'] ?? 'yeni';
        final status = BasvuruDurumu.values.firstWhere(
          (e) => e.name == statusString,
          orElse: () => BasvuruDurumu.yeni,
        );
        distribution[status] = (distribution[status] ?? 0) + 1;
      }

      return distribution;
    });
  }

  // Son 7 günlük trend
  Stream<List<MapEntry<DateTime, int>>> getLast7DaysTrend() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .snapshots()
        .map((snapshot) {
      final Map<DateTime, int> dailyCounts = {};
      
      // Son 7 günü başlat
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        dailyCounts[date] = 0;
      }

      // Başvuruları günlere göre say
      for (var doc in snapshot.docs) {
        final timestamp = doc.data()['olusturulmaTarihi'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dayKey = DateTime(date.year, date.month, date.day);
          if (dailyCounts.containsKey(dayKey)) {
            dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
          }
        }
      }

      return dailyCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    });
  }

  // Aylık başvuru dağılımı
  Stream<Map<String, int>> getMonthlyApplications() {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);

    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
        .snapshots()
        .map((snapshot) {
      final Map<String, int> monthlyCounts = {};
      
      // Son 6 ayı başlat
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthKey = _getMonthName(date.month);
        monthlyCounts[monthKey] = 0;
      }

      // Başvuruları aylara göre say
      for (var doc in snapshot.docs) {
        final timestamp = doc.data()['olusturulmaTarihi'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final monthKey = _getMonthName(date.month);
          if (monthlyCounts.containsKey(monthKey)) {
            monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
          }
        }
      }

      return monthlyCounts;
    });
  }

  // Ay adını getir
  String _getMonthName(int month) {
    const monthNames = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return monthNames[month];
  }

  // Performans metrikleri
  Stream<Map<String, dynamic>> getPerformanceMetrics() {
    return Rx.combineLatest3(
      getAverageProcessingTime(),
      getCompletionRate(),
      getCustomerSatisfactionRate(),
      (avgTime, completionRate, satisfactionRate) => {
        'averageProcessingTime': avgTime,
        'completionRate': completionRate,
        'satisfactionRate': satisfactionRate,
      },
    );
  }

  // Ortalama işlem süresi (gün)
  Stream<double> getAverageProcessingTime() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .where('durum', isEqualTo: 'tamamlandi')
        .limit(50)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;

      double totalDays = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['olusturulmaTarihi'] as Timestamp?;
        final completedAt = data['tamamlanmaTarihi'] as Timestamp?;

        if (createdAt != null && completedAt != null) {
          final duration = completedAt.toDate().difference(createdAt.toDate());
          totalDays += duration.inDays;
          count++;
        }
      }

      return count > 0 ? totalDays / count : 0.0;
    });
  }

  // Tamamlanma oranı
  Stream<double> getCompletionRate() {
    return _firestore
        .collection('applications')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;

      int totalApps = snapshot.docs.length;
      int completedApps = snapshot.docs
          .where((doc) => doc.data()['durum'] == 'tamamlandi')
          .length;

      return (completedApps / totalApps) * 100;
    });
  }

  // Müşteri memnuniyet oranı (örnek - gerçek uygulamada anket verilerinden gelir)
  Stream<double> getCustomerSatisfactionRate() {
    // Şimdilik sabit değer, gerçek uygulamada anket verilerinden gelir
    return Stream.value(85.0);
  }
}