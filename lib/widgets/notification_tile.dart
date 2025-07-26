import 'package:flutter/material.dart';
import 'package:crm/services/advanced_notification_service.dart';
import 'package:crm/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? null : Colors.blue.shade50,
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: notification.isRead ? null : Colors.blue.shade700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (notification.priority == NotificationPriority.yüksek ||
                    notification.priority == NotificationPriority.kritik)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification.priority),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPriorityText(notification.priority),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'read':
                onTap();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Okundu işaretle'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.basvuruOlusturuldu:
        iconData = Icons.add_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.basvuruDurumGuncellendi:
        iconData = Icons.update;
        iconColor = Colors.orange;
        break;
      case NotificationType.danismanAtandi:
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case NotificationType.hatirlatma:
        iconData = Icons.alarm;
        iconColor = Colors.red;
        break;
      case NotificationType.mesaj:
        iconData = Icons.message;
        iconColor = Colors.purple;
        break;
      case NotificationType.randevu:
        iconData = Icons.calendar_today;
        iconColor = Colors.indigo;
        break;
      case NotificationType.sistem:
        iconData = Icons.settings;
        iconColor = Colors.grey;
        break;
      case NotificationType.genel:
        iconData = Icons.notifications;
        iconColor = Colors.blue;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('dd.MM.yyyy HH:mm').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.düşük:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.yüksek:
        return Colors.orange;
      case NotificationPriority.kritik:
        return Colors.red;
    }
  }

  String _getPriorityText(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.düşük:
        return 'DÜŞÜK';
      case NotificationPriority.normal:
        return 'NORMAL';
      case NotificationPriority.yüksek:
        return 'YÜKSEK';
      case NotificationPriority.kritik:
        return 'ACİL';
    }
  }
} 