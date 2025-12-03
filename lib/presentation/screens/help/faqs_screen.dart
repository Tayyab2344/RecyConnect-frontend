import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FaqsScreen extends StatefulWidget {
  final String? category;
  
  const FaqsScreen({Key? key, this.category}) : super(key: key);

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  int? _expandedIndex;

  // Static FAQ data
  final Map<String, List<Map<String, String>>> _faqs = {
    'Listings': [
      {
        'question': 'How do I create a listing?',
        'answer': 'To create a listing, go to your dashboard and tap "Sell Your Recyclables". Select the material type, add weight, upload images (optional), and add your location. Review the estimated price and submit your listing.',
      },
      {
        'question': 'What is the maximum weight I can list?',
        'answer': 'Individual users can list up to 10 kg of recyclable materials per listing. If you have more, please create multiple listings or contact a warehouse.',
      },
      {
        'question': 'Can I edit my listing after posting?',
        'answer': 'Currently, you cannot edit a listing after posting. However, you can delete pending listings and create a new one with updated information.',
      },
      {
        'question': 'How long will my listing stay active?',
        'answer': 'Listings remain active until they are collected, completed, or you choose to delete them. You will receive notifications if your listing is about to expire.',
      },
    ],
    'Pickup': [
      {
        'question': 'How does pickup work?',
        'answer': 'After your listing is accepted by a buyer or warehouse, they will arrange a pickup time with you. You will receive notifications about the pickup status.',
      },
      {
        'question': 'Can I choose my pickup time?',
        'answer': 'Yes, you can coordinate with the buyer to schedule a convenient pickup time that works for both parties.',
      },
      {
        'question': 'What if I miss a scheduled pickup?',
        'answer': 'If you miss a pickup, please contact the buyer immediately to reschedule. Repeated missed pickups may affect your account standing.',
      },
    ],
    'Orders': [
      {
        'question': 'How do I track my orders?',
        'answer': 'Go to "My Orders" from your dashboard or bottom navigation. You can filter orders by status: Active, Completed, or Cancelled.',
      },
      {
        'question': 'Can I cancel an order?',
        'answer': 'You can cancel an order only if it is still in "Pending" status. Once it has been collected, cancellation is not possible.',
      },
      {
        'question': 'How do I know when my order is complete?',
        'answer': 'You will receive a notification when your order status changes to "Completed". You can also check the status in the My Orders screen.',
      },
    ],
    'Account': [
      {
        'question': 'How do I update my profile?',
        'answer': 'Tap the Profile icon in the bottom navigation, then select "Edit Profile". You can update your name, profile picture, or other information.',
      },
      {
        'question': 'How do I change my password?',
        'answer': 'Go to Profile > Settings > Change Password. Enter your current password, then your new password twice to confirm.',
      },
      {
        'question': 'Can I delete my account?',
        'answer': 'Yes, go to Profile > Settings > Delete Account. Please note this action is permanent and cannot be undone.',
      },
    ],
    'Payments': [
      {
        'question': 'How do I receive payment for my recyclables?',
        'answer': 'Payment details are coordinated directly with the buyer. The estimated value shown on your listing is based on current material rates.',
      },
      {
        'question': 'Are there any fees?',
        'answer': 'RecyConnect does not charge any listing fees. You receive the full agreed-upon amount from your buyer.',
      },
    ],
    'Safety': [
      {
        'question': 'Is it safe to meet buyers?',
        'answer': 'For your safety, always meet in public places or arrange pickup at your location during daylight hours. Never share sensitive personal information.',
      },
      {
        'question': 'How do I report suspicious activity?',
        'answer': 'Use the "Report a Problem" feature in the Help Center or contact our support team immediately if you encounter suspicious activity.',
      },
    ],
  };

  List<Map<String, String>> get _filteredFaqs {
    if (widget.category != null && _faqs.containsKey(widget.category)) {
      return _faqs[widget.category]!;
    }
    // Return all FAQs
    return _faqs.values.expand((list) => list).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(widget.category != null ? '${ widget.category} FAQs' : 'FAQs'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.category != null
                  ? 'Find answers about ${widget.category?.toLowerCase() ?? ""}'
                  : 'Find answers to common questions',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),

            // FAQ List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFaqs[index];
                final isExpanded = _expandedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpanded
                          ? (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                          : (isDark
                              ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                              : AppTheme.lightGray),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: isDark
                                    ? AppTheme.darkPrimaryGreen
                                    : AppTheme.primaryGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Still have questions card
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
                  Text(
                    'Still have questions?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkBackground : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is here to help you 24/7',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkBackground.withOpacity(0.8)
                          : Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
                        foregroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
}
