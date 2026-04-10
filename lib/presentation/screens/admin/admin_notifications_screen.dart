import 'package:flutter/material.dart';
import '../../../core/constants/admin_colors.dart';
import '../../widgets/admin/admin_drawer.dart';

// Notification Data Model
class NotificationData {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
  });
}

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initDummyData();
  }

  void _initDummyData() {
    final now = DateTime.now();

    _notifications = [
      NotificationData(
        id: 'n1',
        title: 'Weekly Report Ready',
        message:
            'Your weekly revenue report is ready to view. Total revenue: Rs 1,25,000 with 234 orders completed.',
        type: 'weekly_report',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        icon: Icons.analytics,
        iconColor: AdminColors.accentBlue,
      ),
      NotificationData(
        id: 'n2',
        title: 'Price Update',
        message:
            'Plastic buying price has been updated from 100 to 110 PKR/kg. All users have been notified.',
        type: 'price_update',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: false,
        icon: Icons.attach_money,
        iconColor: AdminColors.accentOrange,
      ),
      NotificationData(
        id: 'n3',
        title: 'New Warehouse Registered',
        message:
            'New warehouse user registered: Sarah Khan from Lahore. Awaiting verification.',
        type: 'new_user',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: false,
        icon: Icons.person_add,
        iconColor: AdminColors.accentPurple,
      ),
      NotificationData(
        id: 'n4',
        title: 'January Monthly Summary',
        message:
            'Monthly summary: 1,234 active users, Rs 2,45,000 total revenue, 892 orders completed.',
        type: 'monthly_summary',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        icon: Icons.calendar_today,
        iconColor: AdminColors.primaryGreen,
      ),
      NotificationData(
        id: 'n5',
        title: 'System Maintenance Alert',
        message:
            'Scheduled system maintenance tonight at 2:00 AM. Expected downtime: 30 minutes.',
        type: 'system_alert',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        icon: Icons.warning,
        iconColor: AdminColors.accentRed,
      ),
      NotificationData(
        id: 'n6',
        title: 'New Order Received',
        message:
            'New order #12345 placed by John Doe for 50kg Plastic pickup from Downtown, Lahore.',
        type: 'new_order',
        timestamp: now.subtract(const Duration(days: 4)),
        isRead: false,
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      NotificationData(
        id: 'n7',
        title: 'Weekly Report Ready',
        message:
            'Last week\'s performance report is available. Click to view detailed analytics.',
        type: 'weekly_report',
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: true,
        icon: Icons.analytics,
        iconColor: AdminColors.accentBlue,
      ),
      NotificationData(
        id: 'n8',
        title: 'New Company Registered',
        message:
            'New company user registered: Green Tech Solutions from Islamabad. Verification complete.',
        type: 'new_user',
        timestamp: now.subtract(const Duration(days: 6)),
        isRead: true,
        icon: Icons.person_add,
        iconColor: AdminColors.accentPurple,
      ),
      NotificationData(
        id: 'n9',
        title: 'Price Update',
        message:
            'Metal buying price has been updated from 80 to 95 PKR/kg due to market changes.',
        type: 'price_update',
        timestamp: now.subtract(const Duration(days: 7)),
        isRead: false,
        icon: Icons.attach_money,
        iconColor: AdminColors.accentOrange,
      ),
      NotificationData(
        id: 'n10',
        title: 'System Alert',
        message:
            'High server load detected. Performance optimization applied automatically.',
        type: 'system_alert',
        timestamp: now.subtract(const Duration(days: 8)),
        isRead: true,
        icon: Icons.warning,
        iconColor: AdminColors.accentRed,
      ),
      NotificationData(
        id: 'n11',
        title: 'New Order Received',
        message:
            'Bulk order #12340 placed by City Recyclers for 200kg Mixed recyclables.',
        type: 'new_order',
        timestamp: now.subtract(const Duration(days: 9)),
        isRead: true,
        icon: Icons.shopping_bag,
        iconColor: AdminColors.accentBlue,
      ),
      NotificationData(
        id: 'n12',
        title: 'December Monthly Summary',
        message:
            'December summary: 1,156 active users, Rs 2,10,000 total revenue, 756 orders completed.',
        type: 'monthly_summary',
        timestamp: now.subtract(const Duration(days: 10)),
        isRead: true,
        icon: Icons.calendar_today,
        iconColor: AdminColors.primaryGreen,
      ),
      NotificationData(
        id: 'n13',
        title: 'New Individual User',
        message:
            'New individual user registered: Ahmed Ali from Karachi. Profile completed.',
        type: 'new_user',
        timestamp: now.subtract(const Duration(days: 12)),
        isRead: true,
        icon: Icons.person_add,
        iconColor: AdminColors.accentPurple,
      ),
      NotificationData(
        id: 'n14',
        title: 'Price Update',
        message:
            'Paper buying price has been updated from 25 to 30 PKR/kg effective immediately.',
        type: 'price_update',
        timestamp: now.subtract(const Duration(days: 14)),
        isRead: true,
        icon: Icons.attach_money,
        iconColor: AdminColors.accentOrange,
      ),
      NotificationData(
        id: 'n15',
        title: 'Weekly Report Ready',
        message:
            'Weekly analytics report for W51 is now available in the Reports section.',
        type: 'weekly_report',
        timestamp: now.subtract(const Duration(days: 15)),
        isRead: true,
        icon: Icons.analytics,
        iconColor: AdminColors.accentBlue,
      ),
    ];
  }

  // Get unread count
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  // Mark single notification as read
  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  // Mark all notifications as read
  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark All as Read'),
        content: const Text(
            'Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read'),
                  backgroundColor: AdminColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Delete notification
  void _deleteNotification(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.removeWhere((n) => n.id == id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted'),
                  backgroundColor: AdminColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.accentRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Simulate refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark All Read',
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      drawer: const AdminDrawer(currentRoute: 'notifications'),
      body: Column(
        children: [
          // Unread count banner
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AdminColors.accentBlue.withOpacity(0.1),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminColors.accentBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'unread notification${_unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AdminColors.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AdminColors.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(_notifications[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Notification card widget
  Widget _buildNotificationCard(NotificationData notification) {
    final cardTheme = Theme.of(context);
    final isDark = cardTheme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _markAsRead(notification.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? cardTheme.cardColor
              : isDark
                  ? const Color(
                      0xFF1E3A5F) // Dark blue tint for unread in dark mode
                  : AdminColors.accentBlue
                      .withOpacity(0.05), // Light blue tint for unread
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: notification.isRead ? 2 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left border stripe
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 4,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? (isDark
                          ? const Color(0xFF475569)
                          : AdminColors.textLight)
                      : AdminColors.accentBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row - Icon, Title, Unread indicator
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: notification.iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notification.icon,
                              color: notification.iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title and message
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 16,
                                    color: cardTheme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        cardTheme.textTheme.bodyMedium?.color,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Unread indicator
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AdminColors.accentRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Bottom row - Timestamp and Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: cardTheme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cardTheme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _deleteNotification(notification.id),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    final emptyTheme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: emptyTheme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emptyTheme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: TextStyle(
              fontSize: 14,
              color: emptyTheme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
