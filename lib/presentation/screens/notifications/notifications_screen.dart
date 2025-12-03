import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> notifications = [
      {
        'id': '1',
        'title': 'Order Delivered',
        'message': 'Your order #ORD-2024-001 has been successfully delivered.',
        'time': '2 hours ago',
        'type': 'order',
        'read': false,
      },
      {
        'id': '2',
        'title': 'New Message',
        'message': 'Green Earth Recyclers sent you a message.',
        'time': '5 hours ago',
        'type': 'message',
        'read': false,
      },
      {
        'id': '3',
        'title': 'Price Alert',
        'message': 'Plastic prices have increased by 5% today.',
        'time': '1 day ago',
        'type': 'alert',
        'read': true,
      },
      {
        'id': '4',
        'title': 'System Update',
        'message': 'We have updated our privacy policy.',
        'time': '2 days ago',
        'type': 'system',
        'read': true,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.1) : AppTheme.lightGray.withOpacity(0.5),
                ),
              ),
              color: !notification['read'] 
                  ? (isDark ? AppTheme.darkPrimaryGreen.withOpacity(0.05) : AppTheme.primaryGreen.withOpacity(0.05))
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardSurface : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.darkSecondaryGreen.withOpacity(0.3) : AppTheme.lightGray,
                  ),
                ),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  notification['title'],
                  style: TextStyle(
                    fontWeight: !notification['read'] ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary.withOpacity(0.7) : AppTheme.textLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Handle notification tap
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'message':
        return Icons.message_outlined;
      case 'alert':
        return Icons.trending_up;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
