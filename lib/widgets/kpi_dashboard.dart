import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class KPIDashboard extends StatelessWidget {
  final Map<String, dynamic> kpiData;
  
  const KPIDashboard({
    super.key,
    required this.kpiData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ana KPI Kartları
        _buildMainKPICards(),
        const SizedBox(height: 24),
        
        // Performans Göstergeleri
        _buildPerformanceIndicators(),
        const SizedBox(height: 24),
        
        // Trend Analizi
        _buildTrendAnalysis(),
      ],
    );
  }

  Widget _buildMainKPICards() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildKPICard(
          'Dönüşüm Oranı',
          '${kpiData['donusumOrani'] ?? 0}%',
          Icons.trending_up,
          Colors.green,
          _getTrendIcon(kpiData['donusumTrend'] ?? 0),
        ),
        _buildKPICard(
          'Ortalama İşlem Süresi',
          '${kpiData['ortalamaIslemSuresi'] ?? 0} gün',
          Icons.schedule,
          Colors.blue,
          _getTrendIcon(kpiData['islemSuresiTrend'] ?? 0),
        ),
        _buildKPICard(
          'Müşteri Memnuniyeti',
          '${kpiData['musteriMemnuniyeti'] ?? 0}/5',
          Icons.star,
          Colors.orange,
          _getTrendIcon(kpiData['memnuniyetTrend'] ?? 0),
        ),
        _buildKPICard(
          'Aylık Büyüme',
          '${kpiData['aylikBuyume'] ?? 0}%',
          Icons.trending_up,
          Colors.purple,
          _getTrendIcon(kpiData['buyumeTrend'] ?? 0),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, Widget trendIcon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 24, color: color),
                trendIcon,
              ],
            ),
            const SizedBox(height: 12),
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
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicators() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performans Göstergeleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Hedef vs Gerçekleşen
            _buildProgressIndicator(
              'Aylık Hedef',
              kpiData['aylikGerceklesen'] ?? 0,
              kpiData['aylikHedef'] ?? 100,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            
            _buildProgressIndicator(
              'Yıllık Hedef',
              kpiData['yillikGerceklesen'] ?? 0,
              kpiData['yillikHedef'] ?? 1200,
              Colors.green,
            ),
            const SizedBox(height: 12),
            
            _buildProgressIndicator(
              'Gelir Hedefi',
              kpiData['gelirGerceklesen'] ?? 0,
              kpiData['gelirHedefi'] ?? 500000,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String title, double current, double target, Color color) {
    final percentage = target > 0 ? (current / target * 100).clamp(0, 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${NumberFormat('#,##0').format(current)} / ${NumberFormat('#,##0').format(target)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}% tamamlandı',
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analizi (Son 7 Gün)',
              style: TextStyle(
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
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                          if (value.toInt() < days.length) {
                            return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
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
                    // Başvuru trendi
                    LineChartBarData(
                      spots: _getWeeklyTrendSpots(kpiData['haftalikBasvuru'] ?? []),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    // Tamamlanan işlemler
                    LineChartBarData(
                      spots: _getWeeklyTrendSpots(kpiData['haftalikTamamlanan'] ?? []),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Yeni Başvurular', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Tamamlanan', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _getTrendIcon(double trend) {
    if (trend > 0) {
      return Icon(Icons.trending_up, color: Colors.green, size: 16);
    } else if (trend < 0) {
      return Icon(Icons.trending_down, color: Colors.red, size: 16);
    } else {
      return Icon(Icons.trending_flat, color: Colors.grey, size: 16);
    }
  }

  List<FlSpot> _getWeeklyTrendSpots(List<dynamic> data) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i] ?? 0).toDouble()));
    }
    return spots;
  }
}