import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../widgets/curved/curved_card.dart';
import '../../../features/notification/data/models/notification_model.dart';
import '../../../features/notification/presentation/providers/notification_provider.dart';

/// Notifications Screen - Premium curvy design with real-time categorized notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Fetch user notifications from backend on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all_rounded),
                onPressed: () => _markAllAsRead(provider),
                tooltip: 'Mark all as read',
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            );
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return _buildErrorState(provider.error!, provider, isDark);
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            color: AppColors.primaryGreen,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) =>
                  _buildNotificationCard(provider.notifications[index], index, provider, isDark),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      NotificationModel notification, int index, NotificationProvider provider, bool isDark) {
    final isUnread = !notification.isRead;
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

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
          key: Key(notification.id.toString()),
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
          onDismissed: (_) => _dismissNotification(notification.id, provider),
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
              onTap: () => _handleNotificationTap(notification, provider),
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
                                  notification.title,
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
                            notification.message,
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
                                _formatTime(notification.createdAt),
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

  Widget _buildErrorState(String message, NotificationProvider provider, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            ElevatedButton(
              onPressed: provider.fetchNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead(NotificationProvider provider) async {
    await provider.markAllAsRead();
    if (mounted) {
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
  }

  void _dismissNotification(int id, NotificationProvider provider) async {
    await provider.deleteNotification(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification deleted'),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
        ),
      );
    }
  }

  void _handleNotificationTap(NotificationModel notification, NotificationProvider provider) {
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    // Trigger action URL / Deep Link navigation if present
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      final route = notification.actionUrl!;
      
      // Smart router pattern matching
      if (route.startsWith('/orders/')) {
        final orderId = route.substring(8);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to Order #$orderId')),
        );
        // Example: Navigator.pushNamed(context, '/order_details', arguments: orderId);
      } else if (route.startsWith('/chat/')) {
        final conversationId = route.substring(6);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening Chat #$conversationId')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action: $route')),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return Icons.local_shipping_rounded;
      case 'PAYMENT':
        return Icons.account_balance_wallet_rounded;
      case 'CHAT':
        return Icons.message_rounded;
      case 'PICKUP':
        return Icons.rv_hookup_rounded;
      case 'AI':
        return Icons.psychology_rounded;
      case 'REWARD':
        return Icons.emoji_events_rounded;
      case 'SECURITY':
        return Icons.security_rounded;
      case 'TRACKING':
        return Icons.my_location_rounded;
      case 'SYSTEM':
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return AppColors.primaryGreen;
      case 'PAYMENT':
        return Colors.blue;
      case 'CHAT':
        return AppColors.info;
      case 'PICKUP':
        return Colors.orange;
      case 'AI':
        return Colors.purple;
      case 'REWARD':
        return Colors.amber;
      case 'SECURITY':
        return AppColors.error;
      case 'TRACKING':
        return Colors.teal;
      case 'SYSTEM':
      default:
        return AppColors.ecoTeal;
    }
  }
}
