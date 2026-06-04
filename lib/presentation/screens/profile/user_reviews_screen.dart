import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/rewards_service.dart';

class UserReviewsScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const UserReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  Map<String, dynamic>? _reviewData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = context.read<RewardsService>();
    final result = await service.fetchUserReviews(widget.userId);

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _reviewData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load reviews';
          _isLoading = false;
        });
      }
    }
  }

  void _showReportDialog(int orderId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Report Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please specify the reason why you believe this review violates our policies or is suspicious:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter report reason...',
                  hintStyle: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkCardSurface : AppTheme.backgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reason'), backgroundColor: AppTheme.errorRed),
                  );
                  return;
                }
                
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                
                final service = context.read<RewardsService>();
                final response = await service.reportReview(orderId, reason);
                
                if (!mounted) return;
                
                if (response['success'] == true) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Review reported successfully. Administrators will review it.'), backgroundColor: AppTheme.primaryGreen),
                  );
                  _loadReviews(); // Refresh review listings
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Failed to report review'), backgroundColor: AppTheme.errorRed),
                  );
                }
              },
              child: const Text('Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Reviews'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadReviews, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryHeader(isDark),
                        _buildReviewsList(isDark),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader(bool isDark) {
    final stats = _reviewData?['stats'] ?? {};
    final total = stats['totalReviews'] ?? 0;
    final avg = stats['averageRating'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < avg.round() ? Icons.star : Icons.star_border,
                        size: 20,
                        color: const Color(0xFFFFA726),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildCategoryProgressBar('Overall Satisfaction', stats['avgOverallSatisfaction'], isDark),
                    _buildCategoryProgressBar('Product Quality', stats['avgProductQuality'], isDark),
                    _buildCategoryProgressBar('Material Accuracy', stats['avgMaterialAccuracy'], isDark),
                    _buildCategoryProgressBar('Communication', stats['avgCommunication'], isDark),
                    _buildCategoryProgressBar('Delivery Experience', stats['avgDeliveryExperience'], isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressBar(String label, dynamic value, bool isDark) {
    final double rating = value != null ? (value as num).toDouble() : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rating / 5.0,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  rating >= 4 ? AppTheme.primaryGreen : (rating >= 3 ? const Color(0xFFFFA726) : AppTheme.errorRed),
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              rating > 0 ? rating.toStringAsFixed(1) : '-',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(bool isDark) {
    final reviews = (_reviewData?['reviews'] as List?) ?? [];
    
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No reviews received yet',
              style: TextStyle(fontSize: 16, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'User Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final reviewer = review['reviewer'] ?? {};
            final reviewerName = reviewer['name'] ?? 'Anonymous Recycler';
            final reviewerRole = reviewer['role'] ?? 'user';
            final rating = review['rating'] ?? 0;
            final feedback = review['feedback'] ?? '';
            final orderId = review['orderId'];
            final createdAtStr = review['createdAt'] != null
                ? review['createdAt'].toString().substring(0, 10)
                : '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: isDark ? AppTheme.darkCardSurface : Colors.white,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen).withValues(alpha: 0.2),
                              child: Text(
                                reviewerName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reviewerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  reviewerRole.toUpperCase(),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          createdAtStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (starIdx) {
                        return Icon(
                          starIdx < rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: const Color(0xFFFFA726),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.isNotEmpty ? feedback : 'No feedback comment provided.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: feedback.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showReportDialog(orderId),
                          icon: const Icon(Icons.report_problem_outlined, size: 14, color: AppTheme.errorRed),
                          label: const Text(
                            'Report',
                            style: TextStyle(fontSize: 12, color: AppTheme.errorRed),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
