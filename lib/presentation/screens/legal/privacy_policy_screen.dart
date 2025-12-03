import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: December 1, 2025',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Information We Collect',
              'We collect several types of information:\n\n'
              '• Account Information: Name, email, phone number, address\n'
              '• Profile Information: Profile picture, preferences\n'
              '• Listing Information: Material details, images, location data\n'
              '• Transaction Data: Order history, pickup details\n'
              '• Device Information: Device type, OS version, unique identifiers\n'
              '• Usage Data: App interactions, features used, time spent',
              isDark,
            ),

            _buildSection(
              '2. How We Use Your Information',
              'We use collected information to:\n\n'
              '• Provide and maintain our services\n'
              '• Process and manage your listings and orders\n'
              '• Send notifications about your account and activities\n'
              '• Improve app functionality and user experience\n'
              '• Ensure platform security and prevent fraud\n'
              '• Comply with legal obligations\n'
              '• Communicate important updates and announcements',
              isDark,
            ),

            _buildSection(
              '3. Location Data',
              'We collect location data to:\n\n'
              '• Enable pickup location features\n'
              '• Show nearby listings and users\n'
              '• Improve service delivery\n\n'
              'You can control location permissions in your device settings. Disabling location may limit certain features.',
              isDark,
            ),

            _buildSection(
              '4. Information Sharing',
              'We may share your information with:\n\n'
              '• Other Users: Profile information, listings, and contact details when necessary for transactions\n'
              '• Service Providers: Third-party services that help us operate the platform\n'
              '• Legal Requirements: When required by law or to protect our rights\n\n'
              'We do not sell your personal information to third parties.',
              isDark,
            ),

            _buildSection(
              '5. Data Security',
              'We implement industry-standard security measures including:\n\n'
              '• Encryption of sensitive data\n'
              '• Secure server infrastructure\n'
              '• Regular security audits\n'
              '• Access controls and authentication\n\n'
              'However, no method of transmission over the internet is 100% secure.',
              isDark,
            ),

            _buildSection(
              '6. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate information\n'
              '• Request deletion of your data\n'
              '• Opt-out of marketing communications\n'
              '• Export your data\n'
              '• Lodge a complaint with supervisory authorities',
              isDark,
            ),

            _buildSection(
              '7. Data Retention',
              'We retain your information:\n\n'
              '• Active accounts: As long as your account is active\n'
              '• Deleted accounts: Up to 90 days for account recovery\n'
              '• Legal requirements: As required by applicable laws\n'
              '• Transaction records: Up to 7 years for compliance',
              isDark,
            ),

            _buildSection(
              '8. Children\'s Privacy',
              'RecyConnect is not intended for users under the age of 18. We do not knowingly collect personal information from children. If we become aware of such collection, we will delete the information immediately.',
              isDark,
            ),

            _buildSection(
              '9. Cookies and Tracking',
              'We use cookies and similar technologies to:\n\n'
              '• Remember your preferences\n'
              '• Analyze app usage patterns\n'
              '• Improve functionality\n'
              '• Provide personalized experience',
              isDark,
            ),

            _buildSection(
              '10. Changes to Privacy Policy',
              'We may update this Privacy Policy periodically. We will notify you of significant changes via email or app notification. Continued use after changes constitutes acceptance.',
              isDark,
            ),

            _buildSection(
              '11. Contact Us',
              'For privacy-related questions or concerns:\n\n'
              'Email: privacy@recyconnect.com\n'
              'Phone: +92 300 1234567\n'
              'Address: Islamabad, Pakistan',
              isDark,
            ),

            const SizedBox(height: 32),

            // Privacy Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield,
                    size: 32,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We are committed to protecting your personal information',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
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

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
