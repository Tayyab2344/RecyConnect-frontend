import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReturnRefundPolicyScreen extends StatelessWidget {
  const ReturnRefundPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Return & Refund Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return & Refund Policy',
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

            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
               color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFA726).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF57C00),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57C00),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'As a peer-to-peer marketplace for recyclable materials, transactions are between individual users. RecyConnect facilitates connections but does not directly handle payments or material exchanges.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              'General Policy',
              'Due to the nature of recyclable materials and peer-to-peer transactions:\n\n'
              '• All sales are generally considered final\n'
              '• Returns and refunds are determined by individual buyers and sellers\n'
              '• RecyConnect encourages clear communication before transactions\n'
              '• Users should verify material quality during pickup',
              isDark,
            ),

            _buildSection(
              'Acceptable Reasons for Returns',
              'Returns may be considered if:\n\n'
              '• Material is significantly different from description\n'
              '• Weight is substantially less than listed\n'
              '• Material contains prohibited or hazardous items\n'
              '• Material quality does not match listing\n\n'
              'Both parties must agree to the return before processing.',
              isDark,
            ),

            _buildSection(
              'Return Process',
              'If you need to return materials:\n\n'
              '1. Contact the seller within 24 hours of pickup\n'
              '2. Provide clear photos documenting the issue\n'
              '3. Explain the discrepancy in detail\n'
              '4. Attempt to reach a mutually agreeable solution\n'
              '5. If unresolved, contact RecyConnect support',
              isDark,
            ),

            _buildSection(
              'Refund Timeframe',
              'If both parties agree to a refund:\n\n'
              '• Direct Payment: Refund handled between users immediately\n'
              '• Platform Payment: 5-7 business days\n'
              '• Original payment method will be used\n'
              '• Users will receive confirmation via email',
              isDark,
            ),

            _buildSection(
              'Dispute Resolution',
              'If you cannot resolve a dispute:\n\n'
              '1. Report the issue through the app\n'
              '2. Provide all relevant evidence (photos, messages)\n'
              '3. RecyConnect will review within 3-5 business days\n'
              '4. Mediation will be offered if appropriate\n'
              '5. Final decisions will be communicated to both parties',
              isDark,
            ),

            _buildSection(
              'Non-Refundable Scenarios',
              'Refunds will not be processed for:\n\n'
              '• Buyer\'s remorse or change of mind\n'
              '• Materials accurately described and delivered\n'
              '• Pickup delays caused by buyer\n'
              '• Minor variations in weight (within 5%)\n'
              '• Failure to inspect materials during pickup',
              isDark,
            ),

            _buildSection(
              'Seller Responsibilities',
              'Sellers must:\n\n'
              '• Provide accurate descriptions and weights\n'
              '• Ensure materials match listings\n'
              '• Allow inspection during pickup\n'
              '• Respond to return requests within 48 hours\n'
              '• Act in good faith to resolve issues',
              isDark,
            ),

            _buildSection(
              'Buyer Responsibilities',
              'Buyers must:\n\n'
              '• Inspect materials during pickup\n'
              '• Report issues immediately\n'
              '• Provide evidence of discrepancies\n'
              '• Communicate respectfully with sellers\n'
              '• Follow return process guidelines',
              isDark,
            ),

            _buildSection(
              'RecyConnect\'s Role',
              'RecyConnect will:\n\n'
              '• Provide a platform for communication\n'
              '• Mediate disputes when necessary\n'
              '• Take action against users violating policies\n'
              '• Maintain transaction records for reference\n\n'
              'RecyConnect is not responsible for direct transaction disputes but will facilitate resolution.',
              isDark,
            ),

            _buildSection(
              'Contact Us',
              'For return and refund assistance:\n\n'
              'Email: returns@recyconnect.com\n'
              'Phone: +92 300 1234567\n'
              'Response Time: Within 24 hours',
              isDark,
            ),

            const SizedBox(height: 32),

            // Best Practices Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 32,
                    color: isDark ? AppTheme.darkBackground : Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tips for Smooth Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Always verify materials during pickup\n'
                    '• Take photos for your records\n'
                    '• Communicate clearly with the other party\n'
                    '• Report issues within 24 hours',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? AppTheme.darkBackground.withOpacity(0.9)
                          : Colors.white.withOpacity(0.95),
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
