import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardWidgets {
  // İstatistik kartı - küçültülmüş
  static Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // 20'den 12'ye düşürüldü
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), // 12'den 8'e düşürüldü
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 20), // 24'ten 20'ye düşürüldü
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
                ],
              ),
              const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22, // 28'den 22'ye düşürüldü
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2), // 4'ten 2'ye düşürüldü
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, // 14'ten 12'ye düşürüldü
                  color: Colors.grey[600],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10, // 12'den 10'a düşürüldü
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Quick action butonu - küçültülmüş
  static Widget quickActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // 16'dan 12'ye düşürüldü
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // 12'den 8'e düşürüldü
                decoration: BoxDecoration(
                  color: (color ?? Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color ?? Colors.blue, size: 20), // 24'ten 20'ye düşürüldü
              ),
              const SizedBox(height: 6), // 8'den 6'ya düşürüldü
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10, // 12'den 10'a düşürüldü
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pasta grafik - küçültülmüş
  static Widget pieChart({
    required Map<String, double> data,
    required String title,
    double height = 150, // 200'den 150'ye düşürüldü
  }) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 16'dan 12'ye düşürüldü
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14, // 16'dan 14'e düşürüldü
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
            SizedBox(
              height: height,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    final index = data.keys.toList().indexOf(entry.key);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.value.toInt()}',
                      color: colors[index % colors.length],
                      radius: 45, // 60'tan 45'e düşürüldü
                      titleStyle: const TextStyle(
                        fontSize: 10, // 12'den 10'a düşürüldü
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 30, // 40'tan 30'a düşürüldü
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
            Wrap(
              spacing: 12, // 16'dan 12'ye düşürüldü
              runSpacing: 6, // 8'den 6'ya düşürüldü
              children: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, // 12'den 10'a düşürüldü
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3), // 4'ten 3'e düşürüldü
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 10), // 12'den 10'a düşürüldü
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Çizgi grafik - küçültülmüş
  static Widget lineChart({
    required Map<String, double> data,
    required String title,
    double height = 150, // 200'den 150'ye düşürüldü
  }) {
    final entries = data.entries.toList();
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 16'dan 12'ye düşürüldü
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14, // 16'dan 14'e düşürüldü
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30, // 40'tan 30'a düşürüldü
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30, // 40'tan 30'a düşürüldü
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            return Text(
                              entries[value.toInt()].key,
                              style: const TextStyle(fontSize: 8), // 10'dan 8'e düşürüldü
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
                      spots: entries.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2, // 3'ten 2'ye düşürüldü
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

  // Son aktiviteler listesi - küçültülmüş
  static Widget recentActivities({
    required List<Map<String, dynamic>> activities,
    required String title,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 16'dan 12'ye düşürüldü
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14, // 16'dan 14'e düşürüldü
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
            if (activities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 20'den 16'ya düşürüldü
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 36, color: Colors.grey[400]), // 48'den 36'ya düşürüldü
                      const SizedBox(height: 6), // 8'den 6'ya düşürüldü
                      Text(
                        'Henüz aktivite yok',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12), // font size eklendi
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length, // Limit eklendi
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Padding azaltıldı
                    leading: CircleAvatar(
                      radius: 12, // 20'den 12'ye düşürüldü
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(
                        activity['icon'] ?? Icons.info,
                        color: Colors.blue,
                        size: 16, // 20'den 16'ya düşürüldü
                      ),
                    ),
                    title: Text(
                      activity['title'] ?? '',
                      style: const TextStyle(fontSize: 12), // 14'ten 12'ye düşürüldü
                    ),
                    subtitle: Text(
                      activity['subtitle'] ?? '',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]), // 12'den 10'a düşürüldü
                    ),
                    trailing: Text(
                      activity['time'] ?? '',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]), // 12'den 10'a düşürüldü
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Progress kartı - küçültülmüş
  static Widget progressCard({
    required String title,
    required double progress,
    required String value,
    required String total,
    Color? color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 16'dan 12'ye düşürüldü
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12, // 14'ten 12'ye düşürüldü
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6), // 8'den 6'ya düşürüldü
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12), // 16'dan 12'ye düşürüldü
                Text(
                  '$value/$total',
                  style: const TextStyle(
                    fontSize: 10, // 12'den 10'a düşürüldü
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2), // 4'ten 2'ye düşürüldü
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10, // 12'den 10'a düşürüldü
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard grid layout - optimize edilmiş
  static Widget dashboardGrid({
    required List<Widget> children,
    int crossAxisCount = 2,
    double childAspectRatio = 1.8, // 1.5'ten 1.8'e çıkarıldı (daha küçük kutucuklar)
  }) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 12, // 16'dan 12'ye düşürüldü
      mainAxisSpacing: 12, // 16'dan 12'ye düşürüldü
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
} 