import 'package:flutter/material.dart';
import 'package:crm/models/basvuru_model.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';

class AdvancedReportingScreen extends StatefulWidget {
  const AdvancedReportingScreen({super.key});

  @override
  State<AdvancedReportingScreen> createState() => _AdvancedReportingScreenState();
}

class _AdvancedReportingScreenState extends State<AdvancedReportingScreen> {
  final BasvuruServisi _basvuruServisi = BasvuruServisi();
  final MusteriServisi _musteriServisi = MusteriServisi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Raporlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genel İstatistikler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<dynamic>>(
                    stream: _musteriServisi.getMusterilerStream(),
                    builder: (context, musteriSnapshot) {
                      return StreamBuilder<List<BasvuruModel>>(
                        stream: _basvuruServisi.getTumBasvurularStream(),
                        builder: (context, basvuruSnapshot) {
                          final musteriSayisi = musteriSnapshot.hasData ? musteriSnapshot.data!.length : 0;
                          final basvuruSayisi = basvuruSnapshot.hasData ? basvuruSnapshot.data!.length : 0;
                          
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: Colors.blue.shade50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.people, size: 32, color: Colors.blue),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$musteriSayisi',
                                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const Text('Toplam Müşteri'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Card(
                                      color: Colors.green.shade50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.assignment, size: 32, color: Colors.green),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$basvuruSayisi',
                                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const Text('Toplam Başvuru'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başvuru Durumu Dağılımı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<BasvuruModel>>(
                    stream: _basvuruServisi.getTumBasvurularStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final basvurular = snapshot.data!;
                      final yeniSayisi = basvurular.where((b) => b.durum == BasvuruDurumu.yeni).length;
                      final islemdeSayisi = basvurular.where((b) => b.durum == BasvuruDurumu.islemde).length;
                      final tamamlananSayisi = basvurular.where((b) => b.durum == BasvuruDurumu.tamamlandi).length;
                      final iptalSayisi = basvurular.where((b) => b.durum == BasvuruDurumu.iptal).length;
                      
                      return Column(
                        children: [
                          _buildStatusRow('Yeni Başvurular', yeniSayisi, Colors.blue),
                          _buildStatusRow('İşlemde', islemdeSayisi, Colors.orange),
                          _buildStatusRow('Tamamlanan', tamamlananSayisi, Colors.green),
                          _buildStatusRow('İptal Edilen', iptalSayisi, Colors.red),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hızlı İşlemler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.file_download),
                          label: const Text('Rapor İndir'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rapor indirme özelliği yakında...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yenile'),
                          onPressed: () {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}