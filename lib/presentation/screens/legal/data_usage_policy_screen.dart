import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DataUsagePolicyScreen extends StatelessWidget {
  const DataUsagePolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Data Usage Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Usage Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: December 1, 2025',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Overview',
              'This Data Usage Policy explains how RecyConnect collects, stores, processes, and protects your data. We are committed to transparency and responsible data handling practices.',
              isDark,
            ),

            _buildSection(
              'Data Collection',
              'Types of data we collect:\n\n'
              '• Personal Data: Name, email, phone, address\n'
              '• Location Data: GPS coordinates for pickup locations\n'
              '• Image Data: Profile pictures and listing photos\n'
              '• Transaction Data: Listing details, order history\n'
              '• Device Data: Device ID, OS version, app version\n'
              '• Analytics Data: App usage, feature interactions',
              isDark,
            ),

            _buildSection(
              'Data Storage',
              'Your data is stored:\n\n'
              '• Securely on encrypted servers\n'
              '• In compliance with data protection regulations\n'
              '• In data centers with appropriate physical security\n'
              '• With regular backups for data integrity\n'
              '• With access control and monitoring systems',
              isDark,
            ),

            _buildSection(
              'Data Usage',
              'We use your data for:\n\n'
              '1. Service Delivery\n'
              '   • Facilitating transactions between users\n'
              '   • Processing listings and orders\n'
              '   • Enabling communication features\n\n'
              '2. Platform Improvement\n'
              '   • Analyzing usage patterns\n'
              '   • Enhancing user experience\n'
              '   • Developing new features\n\n'
              '3. Communication\n'
              '   • Sending notifications and updates\n'
              '   • Responding to inquiries\n'
              '   • Marketing (with consent)',
              isDark,
            ),

            _buildSection(
              'Third-Party Services',
              'We may share data with:\n\n'
              '• Cloud Storage Providers: For data hosting\n'
              '• Analytics Services: For app improvement\n'
              '• Payment Processors: For transaction processing\n'
              '• Communication Services: For email and notifications\n\n'
              'All third parties are required to maintain data security and confidentiality.',
              isDark,
            ),

            _buildSection(
              'Data Retention',
              'We retain data based on:\n\n'
              '• Account Status: Active account data is retained indefinitely\n'
              '• Deleted Accounts: 90 days for recovery purposes\n'
              '• Transaction Records: 7 years for legal compliance\n'
              '• Analytics Data: Aggregated and anonymized indefinitely',
              isDark,
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access: Request a copy of your data\n'
              '• Correction: Update incorrect information\n'
              '• Deletion: Request data removal\n'
              '• Portability: Export your data\n'
              '• Objection: Opt-out of certain data processing\n'
              '• Restriction: Limit how we process your data',
              isDark,
            ),

            _buildSection(
              'Data Security Measures',
              'We implement:\n\n'
              '• End-to-end encryption for sensitive data\n'
              '• Two-factor authentication options\n'
              '• Regular security audits and penetration testing\n'
              '• Employee training on data protection\n'
              '• Incident response procedures\n'
              '• Compliance with industry standards (ISO 27001)',
              isDark,
            ),

            _buildSection(
              'International Data Transfers',
              'Your data may be transferred and processed in countries other than your own. We ensure appropriate safeguards are in place for international transfers, including standard contractual clauses and adequacy decisions.',
              isDark,
            ),

            _buildSection(
              'Contact for Data Requests',
              'For data-related requests:\n\n'
              'Email: dataprivacy@recyconnect.com\n'
              'Response Time: Within 30 days\n'
              'Verification: Identity verification required for security',
              isDark,
            ),

            const SizedBox(height: 32),

            // Data Protection Badge
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
                    Icons.verified_user,
                    size: 40,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Protection Certified',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We adhere to international data protection standards',
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
