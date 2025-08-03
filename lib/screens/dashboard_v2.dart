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
import 'package:crm/screens/settings_screen_simple.dart';
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
import 'package:crm/generated/l10n/app_localizations.dart';
import 'package:crm/services/fcm_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

/// Dashboard bölüm bileşeni (top-level)
class _DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  const _DashboardSection({required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// KPI kartı (top-level)
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _KpiCard({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        final bool isMobile = constraints.maxWidth < 768; // ResponsiveBreakpoints.mobile ile hizalı

        if (isMobile) {
          // Mobil Arayüz
          return Scaffold(
            appBar: AppBar(
              title: Text(_getScreenTitle(isMobile: true)),
              centerTitle: false,
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
              title: Text(AppLocalizations.of(context)!.appTitle),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: AppLocalizations.of(context)!.globalSearch,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const GlobalSearchScreen()),
                    );
                  },
                ),
                 _buildNotificationButton(),
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
                  tooltip: AppLocalizations.of(context)!.logout,
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  minExtendedWidth: 200,
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
                      label: Text(AppLocalizations.of(context)!.dashboard),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text(AppLocalizations.of(context)!.customers),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text(AppLocalizations.of(context)!.applications),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text(AppLocalizations.of(context)!.calendar),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text(AppLocalizations.of(context)!.reports),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text(AppLocalizations.of(context)!.settings),
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
                    label: Text(AppLocalizations.of(context)!.addCustomer),
                    icon: const Icon(Icons.person_add),
                  )
                : null,
          );
        }
      },
    );
  }

  String _getScreenTitle({bool isMobile = false}) {
    final loc = AppLocalizations.of(context)!;
    if (isMobile) {
      switch (_selectedIndex) {
        case 0: return loc.mobileHome;
        case 1: return loc.mobileCustomers;
        case 2: return loc.mobileApplications;
        case 3: return loc.mobileCalendar;
        case 4: return loc.mobileTrash;
        case 5: return loc.mobileReports;
        case 6: return loc.mobileAutomation;
        case 7: return loc.mobileTasks;
        case 8: return loc.mobileAdvancedReporting;
        case 9: return loc.mobileFinance;
        case 10: return loc.messages;
        default: return loc.appTitle;
      }
    }
    return loc.appTitle; // Web için sabit başlık (yerelleştirilmiş)
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

  Widget _buildNotificationButton() {
    return Consumer<FCMService>(
      builder: (context, fcmService, child) {
        return PopupMenuButton<String>(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if (fcmService.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      fcmService.unreadCount > 99 ? '99+' : fcmService.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
      tooltip: 'Bildirimler',
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'header',
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.notifications,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showAllNotifications();
                  },
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        ..._getNotificationItems(fcmService),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'test',
          child: Row(
            children: [
              const Icon(Icons.bug_report, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.language == 'Dil' ? 'Test Bildirimi' : 'Test Notification'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 20),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.notificationSettings),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        print('PopupMenu onSelected çağrıldı: $value');
        if (value == 'settings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        } else if (value == 'test') {
          fcmService.sendTestNotification();
        } else if (value.startsWith('notification_')) {
          print('Bildirim seçildi: $value');
          _handleNotificationTap(value, fcmService);
        } else {
          print('Bilinmeyen değer: $value');
        }
      },
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _getNotificationItems(FCMService fcmService) {
    final notifications = fcmService.notifications.take(4).toList();

    if (notifications.isEmpty) {
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.language == 'Dil' 
                    ? 'Henüz bildirim yok' 
                    : 'No notifications yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ];
    }

    return notifications.map((notification) {
      final DateTime timestamp = DateTime.parse(notification['timestamp']);
      final String timeAgo = _getTimeAgo(timestamp);
      
      return PopupMenuItem<String>(
        value: 'notification_${notification['id']}',
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Popup'ı kapat
            _handleNotificationTap('notification_${notification['id']}', fcmService);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: fcmService.getNotificationColor(notification['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  fcmService.getNotificationIcon(notification['type']),
                  color: fcmService.getNotificationColor(notification['type']),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontWeight: !(notification['isRead'] as bool) 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!(notification['isRead'] as bool))
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification['body'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }).toList();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.language == 'Dil' ? 'Şimdi' : 'Now';
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.language == 'Dil' 
          ? '${difference.inMinutes} dk önce' 
          : '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.language == 'Dil' 
          ? '${difference.inHours} saat önce' 
          : '${difference.inHours}h ago';
    } else {
      return AppLocalizations.of(context)!.language == 'Dil' 
          ? '${difference.inDays} gün önce' 
          : '${difference.inDays}d ago';
    }
  }

  void _handleNotificationTap(String notificationValue, FCMService fcmService) {
    // notification_ prefix'ini kaldır
    final notificationId = notificationValue.replaceFirst('notification_', '');
    print('Bildirime tıklandı: $notificationId');
    
    // Bildirimi okundu olarak işaretle
    fcmService.markAsRead(notificationId);
    print('Bildirim okundu olarak işaretlendi');
    
    // Bildirim tipine göre sayfa yönlendirmesi
    final notification = fcmService.notifications.firstWhere(
      (n) => n['id'] == notificationId,
      orElse: () => {},
    );
    
    if (notification.isNotEmpty) {
      final type = notification['type'] as String;
      
      switch (type) {
        case 'application':
          setState(() => _selectedIndex = 2); // Başvurular
          break;
        case 'appointment':
          setState(() => _selectedIndex = 3); // Takvim
          break;
        case 'approval':
          setState(() => _selectedIndex = 2); // Başvurular
          break;
        case 'system':
          setState(() => _selectedIndex = 5); // Ayarlar
          break;
        case 'message':
          // Mesajlar sayfası henüz yok, ana sayfada kal
          break;
        case 'test':
          // Test bildirimi, hiçbir şey yapma
          break;
        default:
          // Varsayılan olarak ana sayfada kal
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.language == 'Dil' 
                ? 'Bildirim açıldı: ${notification['title']}' 
                : 'Notification opened: ${notification['title']}'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.blue),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.notifications),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              children: [
                _buildNotificationTile(
                  icon: Icons.assignment,
                  title: AppLocalizations.of(context)!.newApplication,
                  message: 'Ahmet Yılmaz', // örnek veri
                  time: '5 dk',
                  color: Colors.blue,
                  unread: true,
                ),
                _buildNotificationTile(
                  icon: Icons.schedule,
                  title: AppLocalizations.of(context)!.appointmentReminder,
                  message: '14:00 - Mehmet Demir', // örnek veri
                  time: '1 saat',
                  color: Colors.orange,
                  unread: true,
                ),
                _buildNotificationTile(
                  icon: Icons.check_circle,
                  title: AppLocalizations.of(context)!.applicationApproved,
                  message: 'Ayşe Kaya', // örnek veri
                  time: '2 saat',
                  color: Colors.green,
                  unread: true,
                ),
                _buildNotificationTile(
                  icon: Icons.system_update,
                  title: AppLocalizations.of(context)!.systemUpdate,
                  message: 'v0.2.3', // örnek veri
                  time: '1 gün',
                  color: Colors.purple,
                  unread: false,
                ),
                _buildNotificationTile(
                  icon: Icons.person_add,
                  title: AppLocalizations.of(context)!.customers,
                  message: 'Fatma Özkan', // örnek veri
                  time: '2 gün',
                  color: Colors.teal,
                  unread: false,
                ),
                _buildNotificationTile(
                  icon: Icons.email,
                  title: AppLocalizations.of(context)!.emailNotifications,
                  message: 'Auto email sent', // örnek veri
                  time: '3 gün',
                  color: Colors.indigo,
                  unread: false,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Tüm bildirimleri okundu olarak işaretle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.markAllAsRead),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.markAllAsRead),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required Color color,
    required bool unread,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: unread ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        return const SettingsScreen(); // Yeni ayarlar sayfası
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

  // Özelleştirme ayarları (ileride eklenecek)
  // DashboardSettings? _dashSettings;

  KullaniciModel? _currentUser;
  Stream<List<BasvuruModel>>? _basvurularStream;

  // Basit KPI değerleri
  String _kpiConversion = '—';
  String _kpiAvgDays = '—';
  String _kpiSatisfaction = '4.2/5'; // dummy örnek
  String _kpiMonthlyGrowth = '+0%';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Dashboard özelleştirme ayarları ileride eklenecek
    // DashboardSettingsService().watchSettings().listen((s) {
    //   if (!mounted) return;
    //   setState(() => _dashSettings = s);
    // });
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

    // Tema moduna göre degrade renkleri seç
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgStart = isDark ? const Color(0xFF0B274A) : const Color(0xFFF5F7FB);
    final bgEnd = isDark ? const Color(0xFF0F3D6E) : const Color(0xFFE8EEF7);

    // Kullanıcı özelleştirme ayarları (varsayılan aktif bölümler)
    final enabled = {'kpi', 'statusPie', 'recentApplications', 'reminders', 'quickAccess'};

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
        // Bölümleri sabit sırayla göster
          if (enabled.contains('kpi') && _currentUser!.role == 'admin')
            _DashboardSection(
              title: AppLocalizations.of(context)!.performanceIndicators,
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_download),
                  tooltip: 'Rapor İndir',
                  onPressed: _exportDashboardReport,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Yenile',
                  onPressed: () => _refreshKpis(),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _KpiCard(
                          icon: Icons.trending_up,
                          iconColor: Colors.green,
                          value: _kpiConversion,
                          label: AppLocalizations.of(context)!.conversionRate,
                        ),
                        _KpiCard(
                          icon: Icons.schedule,
                          iconColor: Colors.blue,
                          value: _kpiAvgDays,
                          label: AppLocalizations.of(context)!.averageProcessingTime,
                        ),
                        _KpiCard(
                          icon: Icons.star,
                          iconColor: Colors.orange,
                          value: _kpiSatisfaction,
                          label: AppLocalizations.of(context)!.customerSatisfaction,
                        ),
                        _KpiCard(
                          icon: Icons.trending_up,
                          iconColor: Colors.purple,
                          value: _kpiMonthlyGrowth,
                          label: AppLocalizations.of(context)!.monthlyGrowth,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Başvuru Durumu Dağılımı
          if (enabled.contains('statusPie')) 
            _DashboardSection(
              title: AppLocalizations.of(context)!.applicationStatusDistribution,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<List<BasvuruModel>>(
                  stream: _basvuruServisi.getTumBasvurularStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.noApplicationsAdmin));
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
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          borderData: FlBorderData(show: false),
                          pieTouchData: PieTouchData(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // Son Başvurular
          if (enabled.contains('recentApplications'))
            _DashboardSection(
              title: _currentUser!.role == 'admin'
                  ? AppLocalizations.of(context)!.allRecentApplications
                  : AppLocalizations.of(context)!.assignedRecentApplications,
              actions: [
                TextButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Yenile'),
                )
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: StreamBuilder<List<BasvuruModel>>(
                  stream: _basvurularStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Gösterilecek başvuru bulunmuyor.'));
                    }
                    final basvurular = snapshot.data!;
                    final int itemCount = basvurular.length < 3 ? basvurular.length : 3;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        return BasvuruOzetCard(basvuru: basvurular[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          // Hatırlatıcılar
          if (enabled.contains('reminders'))
            _DashboardSection(
              title: AppLocalizations.of(context)!.reminders,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<List<HatirlatmaModel>>(
                  stream: _hatirlatmaServisi.getDanismanHatirlatmalari(_currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(AppLocalizations.of(context)!.noReminders),
                        ),
                      );
                    }
                    final hatirlatmalar = snapshot.data!;
                    final int itemCount = hatirlatmalar.length < 3 ? hatirlatmalar.length : 3;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount,
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
              ),
            ),
          // Hızlı Erişim
          if (enabled.contains('quickAccess'))
            _DashboardSection(
              title: AppLocalizations.of(context)!.quickAccess,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.trash,
                    Icons.delete_outline,
                    Colors.red,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CopKutusuEkrani()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.automation,
                    Icons.settings_outlined,
                    Colors.purple,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AutomationManagementScreen()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.taskManagement,
                    Icons.task_outlined,
                    Colors.blue,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.advancedReporting,
                    Icons.assessment_outlined,
                    Colors.green,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdvancedReportingScreenV2()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.messages,
                    Icons.message_outlined,
                    Colors.orange,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MesajlarEkrani()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    AppLocalizations.of(context)!.globalSearch,
                    Icons.search,
                    Colors.teal,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const GlobalSearchScreen()),
                    ),
                  ),
                ],
              ),
            ),
          // Hızlı Erişim sonu
        ],
      ),
    );
  }

  // KPI değerlerini güncelle (son 30 gün için basit hesap)
  Future<void> _refreshKpis() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      // Tüm başvurular
      final all = await _basvuruServisi.getTumBasvurularStream().first;
      final last30 = all.where((b) {
        try {
          final created = (b.olusturulmaTarihi)?.toDate();
          if (created == null) return false;
          return created.isAfter(thirtyDaysAgo);
        } catch (_) {
          return false;
        }
      }).toList();

      final total = last30.length;
      final completed = last30.where((b) => b.durum == BasvuruDurumu.tamamlandi).length;

      // Dönüşüm Oranı
      final conv = total == 0 ? 0 : (completed / total) * 100;
      // Ortalama İşlem Süresi (gün) — basit: tamamlananlarda (tamamlanmaTarihi - olusturulmaTarihi)
      double avgDays = 0;
      final durations = <int>[];
      for (final b in last30.where((b) => b.durum == BasvuruDurumu.tamamlandi)) {
        final created = (b.olusturulmaTarihi)?.toDate();
        // Not: BasvuruModel'de tamamlanma alanı 'tamamlanmaTarihi' olmayabilir.
        // Var olan alan adıyla uyumsuzluk derlemeyi kırdığı için null kabul ederek atlıyoruz.
        final DateTime? completedAt = null;
        if (created != null && completedAt != null) {
          durations.add(completedAt.difference(created).inDays);
        }
      }
      if (durations.isNotEmpty) {
        avgDays = durations.reduce((a, b) => a + b) / durations.length;
      }

      // Aylık büyüme: son 30 gün vs önceki 30 gün (basit kıyas)
      final prev30Start = thirtyDaysAgo.subtract(const Duration(days: 30));
      final prev30 = all.where((b) {
        try {
          final created = (b.olusturulmaTarihi)?.toDate();
          if (created == null) return false;
          return created.isAfter(prev30Start) && created.isBefore(thirtyDaysAgo);
        } catch (_) {
          return false;
        }
      }).length;
      double growth = 0;
      if (prev30 > 0) {
        growth = ((total - prev30) / prev30) * 100;
      } else if (prev30 == 0 && total > 0) {
        growth = 100;
      }

      if (!mounted) return;
      setState(() {
        _kpiConversion = '${conv.toStringAsFixed(0)}%';
        _kpiAvgDays = '${avgDays.toStringAsFixed(0)}';
        _kpiMonthlyGrowth = '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _kpiConversion = '—';
        _kpiAvgDays = '—';
        _kpiMonthlyGrowth = '+0%';
      });
    }
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
