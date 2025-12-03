import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// Reminder card widget to be used on dashboard
class ReminderCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ReminderCard({
    Key? key,
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notification_important,
    this.iconColor = AppTheme.primaryGreen,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              if (onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 18),
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Example static reminders that can be shown on dashboard
class RemindersSection extends StatefulWidget {
  const RemindersSection({Key? key}) : super(key: key);

  @override
  State<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<RemindersSection> {
  List<Map<String, dynamic>> _reminders = [
    {
      'id': 1,
      'title': 'Pickup Scheduled',
      'message': 'Your pickup is scheduled today at 4:00 PM',
      'time': '2h',
      'icon': Icons.local_shipping,
      'color': const Color(0xFF2196F3),
    },
    {
      'id': 2,
      'title': 'Listing Expiring Soon',
      'message': 'Your "Plastic Bottles" listing expires in 2 days',
      'time': '1d',
      'icon': Icons.warning_amber,
      'color': const Color(0xFFFFA726),
    },
    {
      'id': 3,
      'title': 'Order Update',
      'message': 'Your order #ORDER0123 has been collected',
      'time': '3h',
      'icon': Icons.check_circle,
      'color': const Color(0xFF4CAF50),
    },
  ];

  void _dismissReminder(int id) {
    setState(() {
      _reminders.removeWhere((reminder) => reminder['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder dismissed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Reminders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _reminders.map((reminder) {
              return ReminderCard(
                title: reminder['title'],
                message: reminder['message'],
                time: reminder['time'],
                icon: reminder['icon'],
                iconColor: reminder['color'],
                onTap: () {
                  // Navigate to relevant screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${reminder['title']}...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onDismiss: () => _dismissReminder(reminder['id']),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
