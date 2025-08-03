import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdvancedCharts {
  // Başvuru durumu pasta grafiği
  static Widget buildStatusPieChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Veri bulunamadı', style: TextStyle(fontSize: 16)),
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];

    int colorIndex = 0;
    data.forEach((status, count) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$count',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Başvuru Durumu Dağılımı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(data, colors),
          ],
        ),
      ),
    );
  }

  // Aylık trend çizgi grafiği
  static Widget buildMonthlyTrendChart(List<Map<String, dynamic>> data, String title) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Veri bulunamadı', style: TextStyle(fontSize: 16)),
      );
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final value = data[i]['basvuruSayisi'] ?? data[i]['musteriSayisi'] ?? data[i]['gelir'] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateInterval(spots),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length) {
                            return Text(
                              data[value.toInt()]['ay'] ?? '',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Danışman performans bar grafiği
  static Widget buildConsultantPerformanceChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Veri bulunamadı', style: TextStyle(fontSize: 16)),
      );
    }

    // En iyi 5 danışmanı al
    final topConsultants = data.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danışman Performansı (En İyi 5)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topConsultants.length) {
                            final name = topConsultants[value.toInt()]['danismanAdi'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                name.length > 10 ? '${name.substring(0, 10)}...' : name,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(
                    topConsultants.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topConsultants[index]['basariOrani'] ?? 0.0,
                          color: _getPerformanceColor(topConsultants[index]['basariOrani'] ?? 0.0),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik kartları
  static Widget buildStatisticsCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Müşteri',
          '${stats['toplamMusteri'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Toplam Başvuru',
          '${stats['toplamBasvuru'] ?? 0}',
          Icons.description,
          Colors.green,
        ),
        _buildStatCard(
          'Aktif Başvuru',
          '${stats['aktifBasvuru'] ?? 0}',
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatCard(
          'Başarı Oranı',
          '%${stats['basariOrani'] ?? '0'}',
          Icons.trending_up,
          Colors.purple,
        ),
        _buildStatCard(
          'Toplam Gelir',
          '₺${NumberFormat('#,##0').format(stats['toplamGelir'] ?? 0)}',
          Icons.attach_money,
          Colors.teal,
        ),
        _buildStatCard(
          'Bu Ay Gelir',
          '₺${NumberFormat('#,##0').format(stats['buAyGelir'] ?? 0)}',
          Icons.monetization_on,
          Colors.indigo,
        ),
      ],
    );
  }

  // Performans özet kartı
  static Widget buildPerformanceSummaryCard(List<Map<String, dynamic>> performanceData) {
    if (performanceData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Performans verisi bulunamadı'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danışman Performans Özeti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...performanceData.take(3).map((consultant) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getPerformanceColor(consultant['basariOrani'] ?? 0.0),
                    child: Text(
                      (consultant['danismanAdi'] ?? '')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultant['danismanAdi'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${consultant['toplamBasvuru']} başvuru • ${consultant['basariOrani'].toStringAsFixed(1)}% başarı',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(consultant['basariOrani'] ?? 0.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${consultant['basariOrani'].toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // Yardımcı metodlar
  static Widget _buildLegend(Map<String, int> data, List<Color> colors) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  static Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxY / 5).ceil().toDouble();
  }

  static Color _getPerformanceColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow;
    return Colors.red;
  }
}
