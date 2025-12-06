import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../widgets/curved/curved_card.dart';

/// Notifications Screen - Premium curvy design with categorized notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  final List<Map<String, dynamic>> _notifications = [
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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softGreyBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) =>
                  _buildNotificationCard(_notifications[index], index, isDark),
            ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, int index, bool isDark) {
    final isUnread = !notification['read'];
    final type = notification['type'] as String;
    final iconData = _getNotificationIcon(type);
    final iconColor = _getNotificationColor(type);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
        child: Dismissible(
          key: Key(notification['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _dismissNotification(notification['id']),
          child: CurvedCard(
            radius: DesignTokens.radiusMedium,
            backgroundColor: isDark
                ? (isUnread
                    ? AppColors.darkCard.withValues(alpha: 0.9)
                    : AppColors.darkCard)
                : (isUnread
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7)),
            shadows: isUnread
                ? [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            child: InkWell(
              onTap: () => _handleNotificationTap(notification),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        isUnread ? FontWeight.bold : FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.darkText,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['message'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.mediumGrey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.mediumGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notification['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing24),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something happens',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    );
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (!notification['read']) {
      setState(() => notification['read'] = true);
    }
    // Handle navigation based on type
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_rounded;
      case 'message':
        return Icons.message_rounded;
      case 'alert':
        return Icons.trending_up_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.primaryGreen;
      case 'message':
        return AppColors.info;
      case 'alert':
        return AppColors.warning;
      case 'system':
        return AppColors.ecoTeal;
      default:
        return AppColors.primaryGreen;
    }
  }
}
