import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../help/help_center_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../settings/delete_account_screen.dart';
import '../legal/terms_conditions_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/data_usage_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Customize how RecyConnect looks on your device',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 24),

            // Theme Toggle Card
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final isDark = themeProvider.isDarkMode;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Theme Preview
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    AppTheme.darkSurface,
                                    AppTheme.darkCardSurface,
                                  ]
                                : [
                                    AppTheme.primaryGreen,
                                    AppTheme.secondaryGreen,
                                  ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark
                                  ? AppTheme.darkPrimaryGreen
                                  : Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDark ? 'Dark Theme' : 'Light Theme',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.darkTextPrimary
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isDark
                                        ? 'Dark greenish theme active'
                                        : 'White + green theme active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Toggle Switch
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Switch between light and dark themes',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: 1.1,
                              child: Switch(
                                value: isDark,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                                activeColor: AppTheme.darkPrimaryGreen,
                                activeTrackColor:
                                    AppTheme.darkPrimaryGreen.withValues(alpha: 0.5),
                                inactiveThumbColor: AppTheme.primaryGreen,
                                inactiveTrackColor:
                                    AppTheme.primaryGreen.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Theme Options Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkPrimaryGreen.withValues(alpha: 0.3)
                      : AppTheme.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkPrimaryGreen
                        : AppTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your theme preference will be saved and applied across all screens.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Help & Support Section
            _buildSectionHeader(context, 'Help & Support'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              'Help Center',
              'Browse FAQs and get support',
              Icons.help_center,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // Notifications Section
            _buildSectionHeader(context, 'Notifications'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              'Notification Settings',
              'Manage notification preferences',
              Icons.notifications,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // Legal Section
            _buildSectionHeader(context, 'Legal'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              'Terms & Conditions',
              'View terms of service',
              Icons.description,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              context,
              'Privacy Policy',
              'How we protect your data',
              Icons.privacy_tip,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              context,
              'Data Usage Policy',
              'How we use your information',
              Icons.storage,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataUsagePolicyScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              'Delete Account',
              'Permanently delete your account',
              Icons.delete_forever,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
              ),
              textColor: AppTheme.errorRed,
              iconColor: AppTheme.errorRed,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkPrimaryGreen
                : AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? AppTheme.darkTextPrimary : AppTheme.textDark;
    final defaultIconColor = isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.darkSecondaryGreen.withValues(alpha: 0.3)
                : AppTheme.lightGray,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? defaultIconColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? defaultIconColor,
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
                      color: textColor ?? defaultTextColor,
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
            Icon(
              Icons.chevron_right,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
