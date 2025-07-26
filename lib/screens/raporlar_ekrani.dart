import 'package:universal_html/html.dart' as html;
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:crm/models/basvuru_model.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class RaporlarEkrani extends StatefulWidget {
  const RaporlarEkrani({super.key});

  @override
  State<RaporlarEkrani> createState() => _RaporlarEkraniState();
}

class _RaporlarEkraniState extends State<RaporlarEkrani> {
  final BasvuruServisi _basvuruServisi = BasvuruServisi();
  List<BasvuruModel> _currentBasvurular = [];

  Future<void> _exportToCsv() async {
    if (_currentBasvurular.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak veri bulunmuyor.')),
      );
      return;
    }

    List<List<dynamic>> rows = [];
    // Başlık satırı
    rows.add(['ID', 'Müşteri ID', 'Başvuru Türü', 'Durum', 'Oluşturulma Tarihi']);

    for (var basvuru in _currentBasvurular) {
      rows.add([
        basvuru.id,
        basvuru.musteriId,
        basvuru.basvuruTuru,
        basvuru.durum.displayName,
        basvuru.olusturulmaTarihi.toDate().toIso8601String(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      // Web için indirme işlemi
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'basvuru_raporu_${DateTime.now().toIso8601String()}.csv';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobil ve masaüstü için kaydetme işlemi
      final String directory = (await getApplicationDocumentsDirectory()).path;
      final path = '$directory/basvuru_raporu_${DateTime.now().toIso8601String()}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor kaydedildi: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar ve İstatistikler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<BasvuruModel>>(
        stream: _basvuruServisi.getTumBasvurularStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Raporlanacak başvuru verisi bulunmuyor.'));
          }

          _currentBasvurular = snapshot.data!; // Veriyi state'e al
          final basvurular = snapshot.data!;
          final Map<BasvuruDurumu, int> durumSayilari = {};

          for (var basvuru in basvurular) {
            durumSayilari[basvuru.durum] = (durumSayilari[basvuru.durum] ?? 0) + 1;
          }

          final List<PieChartSectionData> sections = [];
          final List<Color> colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];
          int renkIndex = 0;

          durumSayilari.forEach((durum, sayi) {
            if (sayi > 0) {
              sections.add(PieChartSectionData(
                color: colors[renkIndex % colors.length],
                value: sayi.toDouble(),
                title: '${sayi.toInt()}\n${durum.displayName}',
                radius: 100,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ));
              renkIndex++;
            }
          });

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Başvuru Durum Dağılımı', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Raporu Dışa Aktar (CSV)'),
                    onPressed: _exportToCsv,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 