import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:universal_html/html.dart' as html;

class ExportService {
  static const String _dateFormat = 'dd/MM/yyyy HH:mm';
  
  // CSV Export
  static Future<String?> exportToCSV({
    required List<dynamic> data,
    required String fileName,
    required List<String> headers,
    required List<String> Function(dynamic) rowMapper,
  }) async {
    try {
      final List<List<String>> csvData = [headers];
      
      for (var item in data) {
        csvData.add(rowMapper(item));
      }
      
      final String csvString = const ListToCsvConverter().convert(csvData);
      
      if (kIsWeb) {
        // Web için download
        _downloadFileWeb(csvString, '$fileName.csv', 'text/csv');
        return 'Web download başlatıldı';
      } else {
        // Desktop/Mobile için dosya kaydetme
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName.csv');
        await file.writeAsString(csvString);
        return file.path;
      }
    } catch (e) {
      print('CSV export hatası: $e');
      return null;
    }
  }

  // Başvuru listesi CSV export
  static Future<String?> exportApplicationsToCSV(List<BasvuruModel> applications) {
    return exportToCSV(
      data: applications,
      fileName: 'basvurular_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      headers: [
        'ID',
        'Müşteri Adı',
        'Kategori',
        'Durum',
        'Oluşturulma Tarihi',
        'Tamamlanma Tarihi',
        'Danışman',
        'Açıklama',
      ],
      rowMapper: (dynamic basvuru) => [
        basvuru.id ?? '',
        basvuru.musteriId ?? '',
        basvuru.basvuruTuru ?? '',
        basvuru.durum.displayName,
        DateFormat(_dateFormat).format(basvuru.olusturulmaTarihi.toDate()),
        '', // Tamamlanma tarihi yok
        basvuru.atananDanismanId ?? '',
        '', // Açıklama yok
      ],
    );
  }

  // Müşteri listesi CSV export
  static Future<String?> exportCustomersToCSV(List<MusteriModel> customers) {
    return exportToCSV(
      data: customers,
      fileName: 'musteriler_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      headers: [
        'ID',
        'Ad Soyad',
        'Email',
        'Telefon',
        'Ülke',
        'Şehir',
        'Oluşturulma Tarihi',
        'Son Güncelleme',
        'Durum',
      ],
      rowMapper: (dynamic musteri) => [
        musteri.id ?? '',
        '${musteri.ad ?? ''} ${musteri.soyad ?? ''}',
        musteri.email ?? '',
        musteri.telefon ?? '',
        musteri.basvuruUlkesi ?? '',
        '', // Şehir yok
        DateFormat(_dateFormat).format(musteri.olusturulmaTarihi.toDate()),
        '', // Güncelleme tarihi yok
        musteri.isDeleted ? 'Pasif' : 'Aktif',
      ],
    );
  }

  // Performans raporu CSV export
  static Future<String?> exportPerformanceReportToCSV(List<Map<String, dynamic>> performanceData) {
    return exportToCSV(
      data: performanceData,
      fileName: 'performans_raporu_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      headers: [
        'Danışman Adı',
        'Toplam Başvuru',
        'Tamamlanan Başvuru',
        'Aktif Başvuru',
        'Başarı Oranı (%)',
        'Ortalama İşlem Süresi (Gün)',
      ],
      rowMapper: (dynamic data) => [
        data['danismanAdi']?.toString() ?? '',
        data['toplamBasvuru']?.toString() ?? '0',
        data['tamamlananBasvuru']?.toString() ?? '0',
        data['aktifBasvuru']?.toString() ?? '0',
        data['basariOrani']?.toStringAsFixed(1) ?? '0.0',
        data['ortalamaIslemSuresi']?.toString() ?? '0',
      ],
    );
  }

  // Finansal rapor CSV export
  static Future<String?> exportFinancialReportToCSV(Map<String, dynamic> financialData) {
    final List<Map<String, dynamic>> reportData = [
      {
        'kategori': 'Toplam Gelir',
        'deger': financialData['toplamGelir'] ?? 0,
        'aciklama': 'Tüm onaylanmış tekliflerden elde edilen toplam gelir',
      },
      {
        'kategori': 'Bu Ay Gelir',
        'deger': financialData['buAyGelir'] ?? 0,
        'aciklama': 'Bu ay içinde elde edilen gelir',
      },
      {
        'kategori': 'Geçen Ay Gelir',
        'deger': financialData['gecenAyGelir'] ?? 0,
        'aciklama': 'Geçen ay elde edilen gelir',
      },
      {
        'kategori': 'Ortalama Teklif Tutarı',
        'deger': financialData['ortalamaTeklifTutari'] ?? 0,
        'aciklama': 'Onaylanmış tekliflerin ortalama tutarı',
      },
      {
        'kategori': 'Bekleyen Ödemeler',
        'deger': financialData['bekleyenOdemeler'] ?? 0,
        'aciklama': 'Henüz tahsil edilmemiş ödemeler',
      },
    ];

    return exportToCSV(
      data: reportData,
      fileName: 'finansal_rapor_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      headers: [
        'Kategori',
        'Değer (₺)',
        'Açıklama',
        'Rapor Tarihi',
      ],
      rowMapper: (dynamic data) => [
        data['kategori']?.toString() ?? '',
        NumberFormat('#,##0.00').format(data['deger'] ?? 0),
        data['aciklama']?.toString() ?? '',
        DateFormat(_dateFormat).format(DateTime.now()),
      ],
    );
  }

  // Detaylı analitik rapor
  static Future<String?> exportDetailedAnalyticsToCSV(Map<String, dynamic> analyticsData) {
    final List<Map<String, dynamic>> reportData = [];
    
    // KPI verileri
    if (analyticsData['kpiData'] != null) {
      final kpi = analyticsData['kpiData'] as Map<String, dynamic>;
      reportData.addAll([
        {'kategori': 'KPI', 'metrik': 'Dönüşüm Oranı', 'deger': '${kpi['donusumOrani'] ?? 0}%'},
        {'kategori': 'KPI', 'metrik': 'Ortalama İşlem Süresi', 'deger': '${kpi['ortalamaIslemSuresi'] ?? 0} gün'},
        {'kategori': 'KPI', 'metrik': 'Müşteri Memnuniyeti', 'deger': '${kpi['musteriMemnuniyeti'] ?? 0}/5'},
        {'kategori': 'KPI', 'metrik': 'Aylık Büyüme', 'deger': '${kpi['aylikBuyume'] ?? 0}%'},
      ]);
    }
    
    // Durum dağılımı
    if (analyticsData['statusDistribution'] != null) {
      final distribution = analyticsData['statusDistribution'] as Map<String, int>;
      distribution.forEach((status, count) {
        reportData.add({
          'kategori': 'Durum Dağılımı',
          'metrik': status,
          'deger': count.toString(),
        });
      });
    }
    
    return exportToCSV(
      data: reportData,
      fileName: 'detayli_analitik_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      headers: [
        'Kategori',
        'Metrik',
        'Değer',
        'Rapor Tarihi',
      ],
      rowMapper: (dynamic data) => [
        data['kategori']?.toString() ?? '',
        data['metrik']?.toString() ?? '',
        data['deger']?.toString() ?? '',
        DateFormat(_dateFormat).format(DateTime.now()),
      ],
    );
  }

  // Web için dosya indirme
  static void _downloadFileWeb(String content, String fileName, String mimeType) {
    final bytes = Uint8List.fromList(content.codeUnits);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    
    html.Url.revokeObjectUrl(url);
  }

  // Rapor özeti oluşturma
  static Map<String, dynamic> generateReportSummary({
    required int totalApplications,
    required int completedApplications,
    required int activeApplications,
    required double totalRevenue,
    required double monthlyRevenue,
    required List<Map<String, dynamic>> consultantPerformance,
  }) {
    final successRate = totalApplications > 0 
        ? (completedApplications / totalApplications * 100)
        : 0.0;
    
    final averageRevenue = completedApplications > 0
        ? (totalRevenue / completedApplications)
        : 0.0;
    
    return {
      'raporTarihi': DateFormat(_dateFormat).format(DateTime.now()),
      'toplamBasvuru': totalApplications,
      'tamamlananBasvuru': completedApplications,
      'aktifBasvuru': activeApplications,
      'basariOrani': successRate.toStringAsFixed(1),
      'toplamGelir': NumberFormat('#,##0.00').format(totalRevenue),
      'aylikGelir': NumberFormat('#,##0.00').format(monthlyRevenue),
      'ortalamaGelir': NumberFormat('#,##0.00').format(averageRevenue),
      'danismanSayisi': consultantPerformance.length,
      'enIyiDanisman': consultantPerformance.isNotEmpty 
          ? consultantPerformance.first['danismanAdi']
          : 'Veri yok',
    };
  }
}