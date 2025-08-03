import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/advanced_reporting_service.dart';

// AppTheme sınıfını tanımlıyorum
class AppTheme {
  static const Color primaryColor = Color(0xFF0D47A1);
}

class AdvancedReportingScreenV2 extends StatefulWidget {
  const AdvancedReportingScreenV2({Key? key}) : super(key: key);

  @override
  State<AdvancedReportingScreenV2> createState() => _AdvancedReportingScreenV2State();
}

class _AdvancedReportingScreenV2State extends State<AdvancedReportingScreenV2> {
  final AdvancedReportingService _reportingService = AdvancedReportingService();
  
  Map<String, dynamic> _performanceMetrics = {};
  Map<String, dynamic> _trendData = {};
  bool _isLoading = true;
  String _selectedPeriod = '30';
  String _selectedMetric = 'customers';
  String _selectedGroupBy = 'day';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: int.parse(_selectedPeriod)));
      
      // Performans metriklerini yükle
      final metrics = await _reportingService.getPerformanceMetrics(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Trend verilerini yükle
      final trends = await _reportingService.getTrendAnalysis(
        metric: _selectedMetric,
        startDate: startDate,
        endDate: endDate,
        groupBy: _selectedGroupBy,
      );
      
      setState(() {
        _performanceMetrics = metrics;
        _trendData = trends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yükleme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Raporlama'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
            tooltip: 'Rapor İndir',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildKPICards(),
                  const SizedBox(height: 24),
                  _buildTrendChart(),
                  const SizedBox(height: 24),
                  _buildDetailedMetrics(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapor Filtreleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Periyot',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '7', child: Text('Son 7 Gün')),
                      DropdownMenuItem(value: '30', child: Text('Son 30 Gün')),
                      DropdownMenuItem(value: '90', child: Text('Son 90 Gün')),
                      DropdownMenuItem(value: '365', child: Text('Son 1 Yıl')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPeriod = value!);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMetric,
                    decoration: const InputDecoration(
                      labelText: 'Metrik',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'customers', child: Text('Müşteriler')),
                      DropdownMenuItem(value: 'applications', child: Text('Başvurular')),
                      DropdownMenuItem(value: 'revenue', child: Text('Gelir')),
                      DropdownMenuItem(value: 'tasks', child: Text('Görevler')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedMetric = value!);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGroupBy,
                    decoration: const InputDecoration(
                      labelText: 'Gruplama',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('Günlük')),
                      DropdownMenuItem(value: 'week', child: Text('Haftalık')),
                      DropdownMenuItem(value: 'month', child: Text('Aylık')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedGroupBy = value!);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    final customerMetrics = _performanceMetrics['customerMetrics'] ?? {};
    final applicationMetrics = _performanceMetrics['applicationMetrics'] ?? {};
    final taskMetrics = _performanceMetrics['taskMetrics'] ?? {};
    final financialMetrics = _performanceMetrics['financialMetrics'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performans Göstergeleri (KPI)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildKPICard(
              'Toplam Müşteri',
              '${customerMetrics['totalCustomers'] ?? 0}',
              Icons.people,
              Colors.blue,
              '${customerMetrics['monthlyGrowth']?.toStringAsFixed(1) ?? '0'}%',
            ),
            _buildKPICard(
              'Toplam Başvuru',
              '${applicationMetrics['totalApplications'] ?? 0}',
              Icons.assignment,
              Colors.green,
              '${applicationMetrics['successRate'] ?? 0}%',
            ),
            _buildKPICard(
              'Tamamlanan Görev',
              '${taskMetrics['completedTasks'] ?? 0}',
              Icons.task_alt,
              Colors.orange,
              '${taskMetrics['completionRate'] ?? 0}%',
            ),
            _buildKPICard(
              'Aylık Gelir',
              '₺${(financialMetrics['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.purple,
              '${financialMetrics['revenueGrowth']?.toStringAsFixed(1) ?? '0'}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('-') == false;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final trendData = _trendData['data'] as Map<String, dynamic>? ?? {};
    final data = trendData.entries.toList();
    
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Trend verisi bulunamadı',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMetricDisplayName(_selectedMetric)} Trendi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Büyüme: ${_trendData['totalGrowth']?.toStringAsFixed(1) ?? '0'}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: (_trendData['totalGrowth'] ?? 0) >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            final key = data[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatDateKey(key),
                                style: const TextStyle(fontSize: 10),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
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

  Widget _buildDetailedMetrics() {
    final customerMetrics = _performanceMetrics['customerMetrics'] ?? {};
    final applicationMetrics = _performanceMetrics['applicationMetrics'] ?? {};
    final taskMetrics = _performanceMetrics['taskMetrics'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detaylı Metrikler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Müşteri Dağılımı',
                [
                  {'label': 'Kurumsal', 'value': customerMetrics['customerTypeDistribution']?['corporate'] ?? 0},
                  {'label': 'Bireysel', 'value': customerMetrics['customerTypeDistribution']?['individual'] ?? 0},
                ],
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Başvuru Durumu',
                [
                  {'label': 'Tamamlandı', 'value': applicationMetrics['statusDistribution']?['completed'] ?? 0},
                  {'label': 'Devam Ediyor', 'value': applicationMetrics['statusDistribution']?['inProgress'] ?? 0},
                  {'label': 'Beklemede', 'value': applicationMetrics['statusDistribution']?['pending'] ?? 0},
                ],
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Görev Durumu',
                [
                  {'label': 'Tamamlandı', 'value': taskMetrics['completedTasks'] ?? 0},
                  {'label': 'Geciken', 'value': taskMetrics['overdueTasks'] ?? 0},
                  {'label': 'Yüksek Öncelik', 'value': taskMetrics['highPriorityTasks'] ?? 0},
                ],
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, List<Map<String, dynamic>> data, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...data.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    item['value'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getMetricDisplayName(String metric) {
    switch (metric) {
      case 'customers':
        return 'Müşteri';
      case 'applications':
        return 'Başvuru';
      case 'revenue':
        return 'Gelir';
      case 'tasks':
        return 'Görev';
      default:
        return 'Metrik';
    }
  }

  String _formatDateKey(String key) {
    if (key.contains('-')) {
      final parts = key.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}';
      } else if (parts.length >= 2) {
        return '${parts[1]}/${parts[0]}';
      }
    }
    return key;
  }

  Future<void> _exportReport() async {
    try {
      // Rapor dışa aktarma işlemi burada yapılacak
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapor dışa aktarma özelliği yakında eklenecek')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor dışa aktarma hatası: $e')),
      );
    }
  }
}
