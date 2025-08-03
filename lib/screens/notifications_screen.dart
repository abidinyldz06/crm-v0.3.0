import 'package:flutter/material.dart';
import 'package:crm/services/advanced_notification_service.dart';
import 'package:crm/widgets/notification_tile.dart';
import 'package:crm/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final AdvancedNotificationService _notificationService = AdvancedNotificationService();

  late TabController _tabController;
  String _selectedFilter = 'Tümü';
  bool _showUnreadOnly = false;

  // AdvancedNotificationService → NotificationModel dönüştürücü
  NotificationModel _toNotificationModel(NotificationData n) {
    return NotificationModel(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type, // Zaten NotificationType
      priority: NotificationPriority.normal, // Varsayılan öncelik
      userId: n.userId,
      basvuruId: (n.data)['basvuruId'] as String?,
      isRead: n.isRead,
      createdAt: n.createdAt,
      readAt: null,
    );
  }

  @override
  void initState() {
    super.initState();
    // Ayar sekmesi devre dışı olduğu için length = 1
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Filtre butonu
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Tümü', child: Text('Tümü')),
              const PopupMenuItem(value: 'Başvuru', child: Text('Başvuru')),
              const PopupMenuItem(value: 'Müşteri', child: Text('Müşteri')),
              const PopupMenuItem(value: 'Sistem', child: Text('Sistem')),
              const PopupMenuItem(value: 'Hatırlatma', child: Text('Hatırlatma')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 4),
                  Text(_selectedFilter),
                ],
              ),
            ),
          ),
          // Sadece okunmamışları göster
          IconButton(
            onPressed: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
              });
            },
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_unread : Icons.mark_email_read,
              color: _showUnreadOnly ? Colors.blue : null,
            ),
            tooltip: 'Sadece okunmamışları göster',
          ),
          // Tümünü okundu işaretle
          IconButton(
            onPressed: () async {
              await _notificationService.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm bildirimler okundu olarak işaretlendi')),
              );
            },
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü okundu işaretle',
          ),
        ],
        // Ayar sekmesi geçici olarak devre dışı (serviste eksik API'ler var)
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Bildirimler',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      children: [
        // Okunmamış sayısı
        StreamBuilder<int>(
          stream: _notificationService.unreadCountStream,
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            if (unreadCount == 0) return const SizedBox.shrink();
            
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '$unreadCount okunmamış bildirim',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await _notificationService.markAllAsRead();
                    },
                    child: const Text('Tümünü okundu işaretle'),
                  ),
                ],
              ),
            );
          },
        ),

        // Bildirim listesi
        Expanded(
          child: StreamBuilder<List<NotificationModel>>(
            stream: _notificationService
                .getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Hata: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<NotificationModel> notifications = snapshot.data!;

              // Filtreleme
              if (_selectedFilter != 'Tümü') {
                notifications = notifications.where((notification) {
                  switch (_selectedFilter) {
                    case 'Başvuru':
                      return notification.type == NotificationType.basvuruOlusturuldu ||
                             notification.type == NotificationType.basvuruDurumGuncellendi ||
                             notification.type == NotificationType.danismanAtandi;
                    case 'Müşteri':
                      return notification.type == NotificationType.mesaj;
                    case 'Sistem':
                      return notification.type == NotificationType.sistem ||
                             notification.type == NotificationType.genel;
                    case 'Hatırlatma':
                      return notification.type == NotificationType.hatirlatma;
                    default:
                      return true;
                  }
                }).toList();
              }

              // Sadece okunmamışları göster
              if (_showUnreadOnly) {
                notifications = notifications.where((n) => !n.isRead).toList();
              }

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showUnreadOnly ? Icons.mark_email_read : Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showUnreadOnly 
                            ? 'Okunmamış bildirim yok'
                            : 'Henüz bildirim yok',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () async {
                      await _notificationService.markAsRead(notification.id);
                      _handleNotificationTap(notification);
                    },
                    onDelete: () async {
                      await _notificationService.deleteNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bildirim silindi')),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Ayar sekmesi geçici olarak devre dışı bırakıldı

  void _handleNotificationTap(NotificationModel notification) {
    // Bildirim türüne göre yönlendirme
    switch (notification.type) {
      case NotificationType.basvuruOlusturuldu:
      case NotificationType.basvuruDurumGuncellendi:
        if (notification.basvuruId != null) {
          // Başvuru detay sayfasına yönlendir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Başvuru detayına yönlendiriliyor: ${notification.basvuruId}')),
          );
        }
        break;
      case NotificationType.mesaj:
        // Mesaj sayfasına yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj sayfasına yönlendiriliyor')),
        );
        break;
      case NotificationType.hatirlatma:
        // Hatırlatma detayına yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatırlatma detayına yönlendiriliyor')),
        );
        break;
      default:
        // Genel bildirim
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bildirim: ${notification.title}')),
        );
    }
  }

  String _getNotificationTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.basvuruOlusturuldu:
        return 'Başvuru Oluşturuldu';
      case NotificationType.basvuruDurumGuncellendi:
        return 'Başvuru Durumu Güncellendi';
      case NotificationType.danismanAtandi:
        return 'Danışman Atandı';
      case NotificationType.hatirlatma:
        return 'Hatırlatmalar';
      case NotificationType.mesaj:
        return 'Mesajlar';
      case NotificationType.randevu:
        return 'Randevular';
      case NotificationType.sistem:
        return 'Sistem Bildirimleri';
      case NotificationType.genel:
        return 'Genel Bildirimler';
    }
  }

  String _getNotificationTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.basvuruOlusturuldu:
        return 'Yeni başvuru oluşturulduğunda bildirim al';
      case NotificationType.basvuruDurumGuncellendi:
        return 'Başvuru durumu değiştiğinde bildirim al';
      case NotificationType.danismanAtandi:
        return 'Danışman atandığında bildirim al';
      case NotificationType.hatirlatma:
        return 'Hatırlatma bildirimleri al';
      case NotificationType.mesaj:
        return 'Yeni mesaj geldiğinde bildirim al';
      case NotificationType.randevu:
        return 'Randevu bildirimleri al';
      case NotificationType.sistem:
        return 'Sistem güncellemeleri ve bakım bildirimleri';
      case NotificationType.genel:
        return 'Genel duyuru ve bildirimler';
    }
  }
}
