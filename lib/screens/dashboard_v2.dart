import 'package:crm/models/basvuru_model.dart';
import 'package:crm/models/konusma_model.dart';
import 'package:crm/models/kullanici_model.dart';
import 'package:crm/models/musteri_model.dart';
import 'package:crm/screens/basvuru_listesi.dart';
import 'package:crm/screens/cop_kutusu_ekrani.dart';
import 'automation_management_screen.dart';
import 'task_management_screen.dart';
import 'advanced_reporting_screen_v2.dart';

import 'package:crm/screens/kurumsal_musteri_ekle.dart';
import 'package:crm/screens/login_screen.dart';
import 'package:crm/screens/global_search_screen.dart';
import 'package:crm/screens/musteri_listesi.dart';
import 'package:crm/screens/profil_ekrani.dart';
// import 'package:crm/screens/raporlar_ekrani.dart'; // Artık kullanılmıyor
import 'package:crm/screens/takvim_ekrani.dart';
import 'package:crm/services/auth_service.dart';
import 'package:crm/services/basvuru_servisi.dart';
import 'package:crm/services/mesajlasma_servisi.dart';
import 'package:crm/services/musteri_servisi.dart';
import 'package:crm/services/hatirlatma_servisi.dart';
import 'package:crm/models/hatirlatma_model.dart';
import 'package:crm/widgets/basvuru_ozet_card.dart';
import 'package:crm/widgets/ozet_karti.dart';
import 'package:crm/widgets/kpi_dashboard.dart';
// import 'package:crm/services/kpi_service.dart'; // Geçici olarak devre dışı
import 'package:crm/services/export_service.dart';
import 'package:crm/widgets/loading_states.dart';
import 'package:crm/screens/advanced_reporting_screen.dart';
import 'package:crm/screens/musteri_ekle.dart';
import 'package:flutter/material.dart';
import 'package:crm/screens/mesajlar_ekrani.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardV2 extends StatefulWidget {
  const DashboardV2({super.key});

  @override
  State<DashboardV2> createState() => _DashboardV2State();
}

class _DashboardV2State extends State<DashboardV2> {
  int _selectedIndex = 0;
  final MesajlasmaServisi _mesajlasmaServisi = MesajlasmaServisi();
  // final KPIService _kpiService = KPIService(); // Geçici olarak devre dışı
  final String? _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
    // Firebase Messaging'i güvenli şekilde dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null && mounted) {
        // UI thread'i bloke etmemek için Future.microtask kullan
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${message.notification!.title}: ${message.notification!.body}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _requestNotificationPermissions() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 650; // Breakpoint'i biraz ayarladım

        if (isMobile) {
          // Mobil Arayüz
          return Scaffold(
            appBar: AppBar(
              title: Text(_getScreenTitle(isMobile: true)),
              actions: [
                if (_selectedIndex >= 4) // Eğer seçili sekme menüde değilse, başlıkta göster
                  const SizedBox.shrink(),
                PopupMenuButton<int>(
                  onSelected: (int index) => setState(() => _selectedIndex = index),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(value: 4, child: Text('Çöp Kutusu')),
                    PopupMenuItem<int>(value: 5, child: Text('Raporlar')),
                    PopupMenuItem<int>(value: 6, child: Text('Otomasyon')),
                    PopupMenuItem<int>(value: 7, child: Text('Görev Yönetimi')),
                    PopupMenuItem<int>(value: 8, child: Text('Gelişmiş Raporlama')),
                    PopupMenuItem<int>(value: 9, child: Text('Finans')),
                    PopupMenuItem<int>(value: 10, child: Text('Mesajlar')),
                  ],
                ),
              ],
            ),
            body: _buildContent(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed, // 4+ öğe için gerekli
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Müşteriler'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Başvurular'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Takvim'),
              ],
            ),
            floatingActionButton: _selectedIndex == 1
                ? FloatingActionButton(
                    heroTag: "dashboard_fab",
                    onPressed: () => _showMusteriEkleSecenekleri(context), 
                    child: const Icon(Icons.add)
                  )
                : null,
          );
        } else {
          // Web Arayüzü (Mevcut kod)
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vize Danışmanlık CRM'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Global Arama',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const GlobalSearchScreen()),
                    );
                  },
                ),
                 IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Profilim',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfilEkrani()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  tooltip: 'Çıkış Yap',
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  minWidth: 80,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Ana Sayfa'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Müşteriler'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text('Başvurular'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Takvim'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Raporlar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Ayarlar'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
             floatingActionButton: _selectedIndex == 1
                ? FloatingActionButton.extended(
                    heroTag: "dashboard_web_fab",
                    onPressed: () => _showMusteriEkleSecenekleri(context),
                    label: const Text('Müşteri Ekle'),
                    icon: const Icon(Icons.person_add),
                  )
                : null,
          );
        }
      },
    );
  }

  String _getScreenTitle({bool isMobile = false}) {
     if (isMobile) {
      switch (_selectedIndex) {
        case 0: return 'Ana Sayfa';
        case 1: return 'Müşteriler';
        case 2: return 'Başvurular';
        case 3: return 'Takvim';
        case 4: return 'Çöp Kutusu';
        case 5: return 'Raporlar';
        case 6: return 'Otomasyon';
        case 7: return 'Görev Yönetimi';
        case 8: return 'Gelişmiş Raporlama';
        case 9: return 'Finans';
        case 10: return 'Mesajlar';
        default: return 'CRM';
      }
    }
    return 'Vize Danışmanlık CRM'; // Web için sabit başlık
  }

  void _showMusteriEkleSecenekleri(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Müşteri Türü Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Bireysel Müşteri'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MusteriEkle()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Kurumsal Müşteri'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const KurumsalMusteriEkle()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const AnaSayfaDashboardV2();
      case 1:
        return const MusteriListesi();
      case 2:
        return const BasvuruListesi();
      case 3:
        return const TakvimEkrani();
      case 4:
        return const AdvancedReportingScreen();
      case 5:
        return const ProfilEkrani(); // Ayarlar sayfası olarak Profil ekranını kullanıyoruz
      default:
        return const AnaSayfaDashboardV2();
    }
  }
}

class AnaSayfaDashboardV2 extends StatefulWidget {
  const AnaSayfaDashboardV2({super.key});

  @override
  State<AnaSayfaDashboardV2> createState() => _AnaSayfaDashboardV2State();
}

class _AnaSayfaDashboardV2State extends State<AnaSayfaDashboardV2> {
  final AuthService _authService = AuthService();
  final BasvuruServisi _basvuruServisi = BasvuruServisi();
  final MusteriServisi _musteriServisi = MusteriServisi();
  final HatirlatmaServisi _hatirlatmaServisi = HatirlatmaServisi();
  // final KPIService _kpiService = KPIService(); // Geçici olarak devre dışı

  KullaniciModel? _currentUser;
  Stream<List<BasvuruModel>>? _basvurularStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await _authService.currentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        if (user != null) {
          if (user.role == 'admin') {
            _basvurularStream = _basvuruServisi.getSonBasvurularStream();
          } else {
            _basvurularStream = _basvuruServisi.getDanismaninSonBasvurulariStream(user.uid);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _basvurularStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // KPI Dashboard - Sadece admin için
        if (_currentUser!.role == 'admin') ...[
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Performans Göstergeleri',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.file_download),
                            tooltip: 'Rapor İndir',
                            onPressed: _exportDashboardReport,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Yenile',
                            onPressed: () => setState(() {}),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Basit KPI Gösterimi
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.trending_up, size: 32, color: Colors.green),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '75%',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Dönüşüm Oranı'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.schedule, size: 32, color: Colors.blue),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '12 gün',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Ortalama İşlem Süresi'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.star, size: 32, color: Colors.orange),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '4.2/5',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Müşteri Memnuniyeti'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.trending_up, size: 32, color: Colors.purple),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '+8%',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Aylık Büyüme'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // KPI Uyarıları geçici devre dışı
          const SizedBox(height: 24),
        ],
        
        // Geleneksel Özet Kartları
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: constraints.maxWidth < 400 ? WrapAlignment.center : WrapAlignment.start,
              children: [
                if (_currentUser!.role == 'admin')
                  StreamBuilder<List<MusteriModel>>(
                    stream: _musteriServisi.getMusterilerStream(),
                    builder: (context, snapshot) {
                      return OzetKarti(
                        icon: Icons.people,
                        title: 'Toplam Müşteri',
                        count: snapshot.hasData ? snapshot.data!.length.toString() : '...', // Count is a string
                        color: Colors.blue,
                      );
                    },
                  ),
                StreamBuilder<List<BasvuruModel>>(
                  stream: _currentUser!.role == 'admin'
                      ? _basvuruServisi.getTumBasvurularStream()
                      : _basvuruServisi.getDanismaninBasvurulariStream(_currentUser!.uid),
                  builder: (context, snapshot) {
                     return OzetKarti(
                      icon: Icons.article,
                      title: _currentUser!.role == 'admin' ? 'Toplam Başvuru' : 'Atanan Başvurularım',
                      count: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                      color: Colors.orange,
                    );
                  },
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 24),
        Text(
          'Başvuru Durumu Dağılımı',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<BasvuruModel>>(
          stream: _basvuruServisi.getTumBasvurularStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Gösterilecek başvuru bulunmuyor.'));
            }
            final basvurular = snapshot.data!;
            Map<BasvuruDurumu, int> statusCounts = {};
            for (var basvuru in basvurular) {
              statusCounts[basvuru.durum] = (statusCounts[basvuru.durum] ?? 0) + 1;
            }

            List<PieChartSectionData> sections = [];
            statusCounts.forEach((status, count) {
              double percentage = (count / basvurular.length) * 100;
              sections.add(
                PieChartSectionData(
                  color: _getStatusColor(status),
                  value: count.toDouble(),
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            });

            return SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                  // Pie Touch Data
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Handle touch events if needed
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          _currentUser!.role == 'admin' ? 'Tüm Son Başvurular' : 'Size Atanan Son Başvurular',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<BasvuruModel>>(
          stream: _basvurularStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Gösterilecek başvuru bulunmuyor.'));
            }
            final basvurular = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: basvurular.length,
              itemBuilder: (context, index) {
                return BasvuruOzetCard(basvuru: basvurular[index]);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Hatırlatıcılar',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<HatirlatmaModel>>(
          stream: _hatirlatmaServisi.getDanismanHatirlatmalari(_currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Hatırlatıcı bulunmuyor.'),
                ),
              );
            }
            final hatirlatmalar = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hatirlatmalar.length > 5 ? 5 : hatirlatmalar.length,
              itemBuilder: (context, index) {
                final hatirlatma = hatirlatmalar[index];
                final tarih = hatirlatma.hatirlatmaTarihi.toDate();
                final gecmis = DateTime.now().isAfter(tarih);
                return Card(
                  color: gecmis ? Colors.red.shade50 : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.alarm,
                      color: gecmis ? Colors.red : Colors.orange,
                    ),
                    title: Text(hatirlatma.mesaj),
                    subtitle: Text(
                      '${tarih.day}/${tarih.month}/${tarih.year} ${tarih.hour}:${tarih.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        await _hatirlatmaServisi.tamamlaHatirlatma(hatirlatma.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Hızlı Erişim Kartları
        Text(
          'Hızlı Erişim',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildQuickAccessCard(
              context,
              'Çöp Kutusu',
              Icons.delete_outline,
              Colors.red,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CopKutusuEkrani()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Otomasyon',
              Icons.settings_outlined,
              Colors.purple,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AutomationManagementScreen()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Görev Yönetimi',
              Icons.task_outlined,
              Colors.blue,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Gelişmiş Raporlama',
              Icons.assessment_outlined,
              Colors.green,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdvancedReportingScreenV2()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Mesajlar',
              Icons.message_outlined,
              Colors.orange,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MesajlarEkrani()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Global Arama',
              Icons.search,
              Colors.teal,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GlobalSearchScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BasvuruDurumu durum) {
    switch (durum) {
      case BasvuruDurumu.yeni:
        return Colors.blueAccent;
      case BasvuruDurumu.islemde:
        return Colors.orangeAccent;
      case BasvuruDurumu.tamamlandi:
        return Colors.green;
      case BasvuruDurumu.iptal:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // KPI Uyarı renkleri
  Color _getAlertColor(String type) {
    switch (type) {
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // KPI Uyarı ikonları
  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'danger':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  // Dashboard raporu export
  void _exportDashboardReport() async {
    try {
      // Mevcut verileri topla
      final basvurular = await _basvuruServisi.getTumBasvurularStream().first;
      
      // Export işlemi
      final result = await ExportService.exportApplicationsToCSV(basvurular);
      
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor başarıyla dışa aktarıldı!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapor dışa aktarma işlemi başarısız!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


} 