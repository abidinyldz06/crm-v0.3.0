import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musteri_model.dart';
import '../models/basvuru_model.dart';
import '../models/task_model.dart';

class AdvancedReportingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Performans metriklerini getir
  Future<Map<String, dynamic>> getPerformanceMetrics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final customerMetrics = await _getCustomerMetrics(startDate, endDate);
      final applicationMetrics = await _getApplicationMetrics(startDate, endDate);
      final taskMetrics = await _getTaskMetrics(startDate, endDate);
      // Finans metrikleri kaldırıldı
      final conversionRates = await _getConversionRates(startDate, endDate);

      return {
        'customers': customerMetrics,
        'applications': applicationMetrics,
        'tasks': taskMetrics,
        // 'financial': financialMetrics, // KALDIRILDI
        'conversionRates': conversionRates,
      };
    } catch (e) {
      print('Performans metrikleri hatası: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _getCustomerMetrics(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('musteriler')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final customers = snapshot.docs.map((doc) => MusteriModel.fromFirestore(doc)).toList();
    
    final totalCustomers = customers.length;
    final newCustomers = customers.where((c) => c.olusturulmaTarihi.toDate().isAfter(start)).length;
    final corporateCustomers = customers.where((c) => c.kurumsalMusteriId != null).length;
    final individualCustomers = totalCustomers - corporateCustomers;

    final monthlyGrowth = _calculateMonthlyGrowth(customers, start, end);

    return {
      'total': totalCustomers,
      'new': newCustomers,
      'corporate': corporateCustomers,
      'individual': individualCustomers,
      'monthlyGrowth': monthlyGrowth,
    };
  }

  Future<Map<String, dynamic>> _getApplicationMetrics(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('basvurular')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final applications = snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList();
    
    final totalApplications = applications.length;
    final completedApplications = applications.where((a) => a.durum == BasvuruDurumu.tamamlandi).length;
    final pendingApplications = applications.where((a) => a.durum == BasvuruDurumu.yeni).length;
    final inProgressApplications = applications.where((a) => a.durum == BasvuruDurumu.islemde).length;

    final averageProcessingTime = _calculateAverageProcessingTime(applications);

    return {
      'total': totalApplications,
      'completed': completedApplications,
      'pending': pendingApplications,
      'inProgress': inProgressApplications,
      'averageProcessingTime': averageProcessingTime,
    };
  }

  Future<Map<String, dynamic>> _getTaskMetrics(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();

    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.tamamlandi).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.yuksek || t.priority == TaskPriority.kritik).length;

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'overdue': overdueTasks,
      'highPriority': highPriorityTasks,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).roundToDouble() : 0.0,
    };
  }

  // Finans metrikleri KALDIRILDI
  // Future<Map<String, dynamic>> _getFinancialMetrics(DateTime start, DateTime end) async { ... }

  Future<Map<String, dynamic>> _getConversionRates(DateTime start, DateTime end) async {
    final customerSnapshot = await _firestore
        .collection('musteriler')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final applicationSnapshot = await _firestore
        .collection('basvurular')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final customers = customerSnapshot.docs.length;
    final applications = applicationSnapshot.docs.length;
    final completedApplications = applicationSnapshot.docs
        .where((doc) => doc.data()['durum'] == 'tamamlandi')
        .length;

    return {
      'leadToCustomer': customers > 0 ? (customers / (customers + 50) * 100).roundToDouble() : 0.0,
      'customerToApplication': customers > 0 ? (applications / customers * 100).roundToDouble() : 0.0,
      'applicationToCompletion': applications > 0 ? (completedApplications / applications * 100).roundToDouble() : 0.0,
    };
  }

  // Trend analizi
  Future<Map<String, dynamic>> getTrendAnalysis({
    required String metric,
    required String groupBy,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      switch (metric) {
        case 'customers':
          return await _getCustomerTrends(groupBy, startDate, endDate);
        case 'applications':
          return await _getApplicationTrends(groupBy, startDate, endDate);
        // case 'revenue':
        //   return await _getRevenueTrends(groupBy, startDate, endDate); // KALDIRILDI
        case 'tasks':
          return await _getTaskTrends(groupBy, startDate, endDate);
        default:
          return {};
      }
    } catch (e) {
      print('Trend analizi hatası: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _getCustomerTrends(String groupBy, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('musteriler')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final customers = snapshot.docs.map((doc) => MusteriModel.fromFirestore(doc)).toList();
    final groupedData = _groupDataByPeriod(customers, groupBy, (customer) => customer.olusturulmaTarihi.toDate());

    return {
      'data': groupedData,
      'growthRate': _calculateGrowthRate(groupedData),
    };
  }

  Future<Map<String, dynamic>> _getApplicationTrends(String groupBy, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('basvurular')
        .where('olusturulmaTarihi', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('olusturulmaTarihi', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final applications = snapshot.docs.map((doc) => BasvuruModel.fromFirestore(doc)).toList();
    final groupedData = _groupDataByPeriod(applications, groupBy, (app) => app.olusturulmaTarihi.toDate());

    return {
      'data': groupedData,
      'growthRate': _calculateGrowthRate(groupedData),
    };
  }

  // Gelir trendleri KALDIRILDI
  // Future<Map<String, dynamic>> _getRevenueTrends(String groupBy, DateTime start, DateTime end) async { ... }

  Future<Map<String, dynamic>> _getTaskTrends(String groupBy, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();

    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    final groupedData = _groupDataByPeriod(tasks, groupBy, (task) => task.createdAt);

    return {
      'data': groupedData,
      'growthRate': _calculateGrowthRate(groupedData),
    };
  }

  // Özel rapor oluşturma
  Future<Map<String, dynamic>> generateCustomReport({
    required List<String> metrics,
    required String period,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final startDate = _getStartDate(period);
      final endDate = DateTime.now();

      final report = <String, dynamic>{};
      
      for (final metric in metrics) {
        switch (metric) {
          case 'performance':
            report['performance'] = await getPerformanceMetrics(
              startDate: startDate,
              endDate: endDate,
            );
            break;
          case 'trends':
            report['trends'] = await getTrendAnalysis(
              metric: 'customers',
              groupBy: 'day',
              startDate: startDate,
              endDate: endDate,
            );
            break;
          case 'comparison':
            report['comparison'] = await _generateComparisonReport(startDate, endDate);
            break;
        }
      }

      return report;
    } catch (e) {
      print('Özel rapor oluşturma hatası: $e');
      return {};
    }
  }

  // Yardımcı metodlar
  double _calculateMonthlyGrowth(List<dynamic> data, DateTime start, DateTime end) {
    if (data.isEmpty) return 0.0;
    
    final midPoint = start.add(Duration(days: (end.difference(start).inDays / 2).round()));
    final firstHalf = data.where((item) => item.createdAt.isBefore(midPoint)).length;
    final secondHalf = data.length - firstHalf;
    
    if (firstHalf == 0) return secondHalf > 0 ? 100.0 : 0.0;
    return ((secondHalf - firstHalf) / firstHalf * 100).roundToDouble();
  }

  double _calculateAverageProcessingTime(List<BasvuruModel> applications) {
    if (applications.isEmpty) return 0.0;
    
    int totalDays = 0;
    int count = 0;
    
    for (final app in applications) {
      if (app.olusturulmaTarihi != null) {
        final duration = DateTime.now().difference(app.olusturulmaTarihi.toDate());
        totalDays += duration.inDays;
        count++;
      }
    }
    
    return count > 0 ? (totalDays / count).roundToDouble() : 0.0;
  }

  Map<String, int> _groupDataByPeriod(List<dynamic> data, String groupBy, DateTime Function(dynamic) dateExtractor) {
    final grouped = <String, int>{};
    
    for (final item in data) {
      final date = dateExtractor(item);
      String key;
      
      switch (groupBy) {
        case 'day':
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          break;
        case 'week':
          final week = ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).floor();
          key = '${date.year}-W${week.toString().padLeft(2, '0')}';
          break;
        case 'month':
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          break;
        default:
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      grouped[key] = (grouped[key] ?? 0) + 1;
    }
    
    return grouped;
  }

  double _calculateGrowthRate(Map<String, int> data) {
    if (data.length < 2) return 0.0;
    
    final sortedKeys = data.keys.toList()..sort();
    final firstValue = data[sortedKeys.first] ?? 0;
    final lastValue = data[sortedKeys.last] ?? 0;
    
    if (firstValue == 0) return lastValue > 0 ? 100.0 : 0.0;
    return ((lastValue - firstValue) / firstValue * 100).roundToDouble();
  }

  DateTime _getStartDate(String period) {
    final now = DateTime.now();
    switch (period) {
      case '7days':
        return now.subtract(Duration(days: 7));
      case '30days':
        return now.subtract(Duration(days: 30));
      case '90days':
        return now.subtract(Duration(days: 90));
      case '1year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(Duration(days: 30));
    }
  }

  Future<Map<String, dynamic>> _generateComparisonReport(DateTime start, DateTime end) async {
    final previousStart = start.subtract(Duration(days: end.difference(start).inDays));
    final previousEnd = start;

    final currentMetrics = await getPerformanceMetrics(startDate: start, endDate: end);
    final previousMetrics = await getPerformanceMetrics(startDate: previousStart, endDate: previousEnd);

    return {
      'current': currentMetrics,
      'previous': previousMetrics,
      'changes': _calculateChanges(currentMetrics, previousMetrics),
    };
  }

  Map<String, double> _calculateChanges(Map<String, dynamic> current, Map<String, dynamic> previous) {
    final changes = <String, double>{};
    
    current.forEach((key, value) {
      if (value is Map<String, dynamic> && previous[key] is Map<String, dynamic>) {
        final currentMap = value as Map<String, dynamic>;
        final previousMap = previous[key] as Map<String, dynamic>;
        
        currentMap.forEach((subKey, subValue) {
          if (subValue is num && previousMap[subKey] is num) {
            final currentVal = subValue.toDouble();
            final previousVal = (previousMap[subKey] as num).toDouble();
            
            if (previousVal != 0) {
              changes['$key.$subKey'] = ((currentVal - previousVal) / previousVal * 100).roundToDouble();
            } else {
              changes['$key.$subKey'] = currentVal > 0 ? 100.0 : 0.0;
            }
          }
        });
      }
    });
    
    return changes;
  }
}
