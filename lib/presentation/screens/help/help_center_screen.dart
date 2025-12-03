import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'faqs_screen.dart';
import 'contact_support_screen.dart';
import 'report_problem_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Help Center'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find answers to common questions or get in touch with support',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar (Static UI)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                      : AppTheme.lightGray,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textLight.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Help Categories
            Text(
              'Browse Topics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Category Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildCategoryCard(
                  context,
                  'Listings',
                  'Learn about creating and managing your listings',
                  Icons.list_alt,
                  const Color(0xFF4CAF50),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Listings')),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  'Pickup',
                  'Scheduling and managing pickups',
                  Icons.local_shipping,
                  const Color(0xFF2196F3),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Pickup')),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  'Orders',
                  'Track and manage your orders',
                  Icons.receipt_long,
                  const Color(0xFFFFA726),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Orders')),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  'Account',
                  'Profile and account settings',
                  Icons.account_circle,
                  const Color(0xFF9C27B0),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Account')),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  'Payments',
                  'Payment methods and transactions',
                  Icons.payment,
                  const Color(0xFFE91E63),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Payments')),
                  ),
                ),
                _buildCategoryCard(
                  context,
                  'Safety',
                  'Safety tips and guidelines',
                  Icons.security,
                  const Color(0xFF00BCD4),
                  isDark,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqsScreen(category: 'Safety')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Need More Help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),

            _buildActionCard(
              context,
              'Contact Support',
              'Get in touch with our support team',
              Icons.support_agent,
              isDark,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              'Report a Problem',
              'Let us know about any issues you\'re facing',
              Icons.report_problem,
              isDark,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportProblemScreen()),
              ),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              'FAQs',
              'Browse frequently asked questions',
              Icons.quiz,
              isDark,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                : AppTheme.lightGray,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                size: 24,
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
                      fontSize: 16,
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
