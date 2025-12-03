import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification toggle states
  bool _orderUpdates = true;
  bool _pickupUpdates = true;
  bool _systemAlerts = true;
  bool _promotionalAlerts = false;
  bool _chatMessages = true;
  bool _listingUpdates = true;
  bool _paymentUpdates = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved settings from local storage (static implementation)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orderUpdates = prefs.getBool('orderUpdates') ?? true;
      _pickupUpdates = prefs.getBool('pickupUpdates') ?? true;
      _systemAlerts = prefs.getBool('systemAlerts') ?? true;
      _promotionalAlerts = prefs.getBool('promotionalAlerts') ?? false;
      _chatMessages = prefs.getBool('chatMessages') ?? true;
      _listingUpdates = prefs.getBool('listingUpdates') ?? true;
      _paymentUpdates = prefs.getBool('paymentUpdates') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Manage your notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what updates you want to receive',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),

            // Notification Channels Section
            _buildSectionHeader('Notification Channels', isDark),
            const SizedBox(height: 12),
            
            _buildToggleCard(
              'Push Notifications',
              'Receive notifications on your device',
              Icons.notifications_active,
              _pushNotifications,
              (value) {
                setState(() => _pushNotifications = value);
                _saveSetting('pushNotifications', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),
            
            _buildToggleCard(
              'Email Notifications',
              'Receive important updates via email',
              Icons.email,
              _emailNotifications,
              (value) {
                setState(() => _emailNotifications = value);
                _saveSetting('emailNotifications', value);
              },
              isDark,
            ),
            
            const SizedBox(height: 32),

            // Activity Notifications Section
            _buildSectionHeader('Activity Notifications', isDark),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Order Updates',
              'Get notified about order status changes',
              Icons.shopping_bag,
              _orderUpdates,
              (value) {
                setState(() => _orderUpdates = value);
                _saveSetting('orderUpdates', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Pickup Updates',
              'Notifications about scheduled pickups',
              Icons.local_shipping,
              _pickupUpdates,
              (value) {
                setState(() => _pickupUpdates = value);
                _saveSetting('pickupUpdates', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Listing Updates',
              'Updates on your posted listings',
              Icons.inventory_2,
              _listingUpdates,
              (value) {
                setState(() => _listingUpdates = value);
                _saveSetting('listingUpdates', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Payment Updates',
              'Transaction and payment notifications',
              Icons.payment,
              _paymentUpdates,
              (value) {
                setState(() => _paymentUpdates = value);
                _saveSetting('paymentUpdates', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Chat Messages',
              'New message notifications',
              Icons.message,
              _chatMessages,
              (value) {
                setState(() => _chatMessages = value);
                _saveSetting('chatMessages', value);
              },
              isDark,
            ),

            const SizedBox(height: 32),

            // System Notifications Section
            _buildSectionHeader('System Notifications', isDark),
            const SizedBox(height: 12),

            _buildToggleCard(
              'System Alerts',
              'Important app updates and announcements',
              Icons.info,
              _systemAlerts,
              (value) {
                setState(() => _systemAlerts = value);
                _saveSetting('systemAlerts', value);
              },
              isDark,
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              'Promotional Alerts',
              'Special offers and promotions',
              Icons.local_offer,
              _promotionalAlerts,
              (value) {
                setState(() => _promotionalAlerts = value);
                _saveSetting('promotionalAlerts', value);
              },
              isDark,
            ),

            const SizedBox(height: 32),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can change these settings anytime. Important security alerts will always be sent regardless of your preferences.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
              : AppTheme.lightGray,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
