import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RecyConnect Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using RecyConnect, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms of Service, please do not use our services.',
              isDark,
            ),

            _buildSection(
              '2. User Responsibilities',
              'Users are responsible for:\n\n'
              '• Providing accurate information about recyclable materials\n'
              '• Maintaining the quality and condition of listed items as described\n'
              '• Being available for scheduled pickups\n'
              '• Treating other users with respect and professionalism\n'
              '• Complying with local recycling regulations and laws',
              isDark,
            ),

            _buildSection(
              '3. Listing Guidelines',
              'Individual users may list up to 10 kg of recyclable materials per listing. All listings must:\n\n'
              '• Accurately describe the material type and condition\n'
              '• Include realistic weight estimates\n'
              '• Provide accurate pickup location information\n'
              '• Comply with local environmental regulations',
              isDark,
            ),

            _buildSection(
              '4. Prohibited Activities',
              'Users must not:\n\n'
              '• Post false or misleading information\n'
              '• List hazardous or illegal materials\n'
              '• Engage in fraudulent activities\n'
              '• Harass or threaten other users\n'
              '• Manipulate prices or engage in price fixing\n'
              '• Use the platform for any illegal purposes',
              isDark,
            ),

            _buildSection(
              '5. Payment and Fees',
              'RecyConnect does not charge listing fees for individual users. All payment arrangements are made directly between buyers and sellers. RecyConnect is not responsible for payment disputes.',
              isDark,
            ),

            _buildSection(
              '6. Privacy and Data',
              'We collect and process user data as described in our Privacy Policy. By using RecyConnect, you consent to such processing and warrant that all data provided is accurate.',
              isDark,
            ),

            _buildSection(
              '7. Intellectual Property',
              'All content on RecyConnect, including text, graphics, logos, and software, is the property of RecyConnect or its licensors and is protected by copyright and trademark laws.',
              isDark,
            ),

            _buildSection(
              '8. Limitation of Liability',
              'RecyConnect acts as a platform connecting buyers and sellers. We are not responsible for:\n\n'
              '• Quality or accuracy of listed materials\n'
              '• Completion of transactions\n'
              '• Disputes between users\n'
              '• Any damages or losses incurred through use of our platform',
              isDark,
            ),

            _buildSection(
              '9. Account Termination',
              'We reserve the right to suspend or terminate accounts that violate these terms. Users may delete their accounts at any time through the app settings.',
              isDark,
            ),

            _buildSection(
              '10. Changes to Terms',
              'We may update these terms from time to time. Users will be notified of significant changes. Continued use of the platform after changes constitutes acceptance of the new terms.',
              isDark,
            ),

            _buildSection(
              '11. Contact Us',
              'If you have questions about these Terms of Service, please contact us at:\n\n'
              'Email: support@recyconnect.com\n'
              'Phone: +92 300 1234567',
              isDark,
            ),

            const SizedBox(height: 32),

            // Agreement Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.darkPrimaryGreen, AppTheme.darkSecondaryGreen]
                      : [const Color(0xFF00BFA5), const Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 48,
                    color: isDark ? AppTheme.darkBackground : Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your agreement to these terms is appreciated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Together we\'re building a sustainable future',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkBackground.withOpacity(0.8)
                          : Colors.white.withOpacity(0.9),
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
