import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/order_service.dart';

// Widget to show ratings & reviews dialog after order completion
class RatingsReviewsDialog extends StatefulWidget {
  final int orderId;
  final String sellerName;

  const RatingsReviewsDialog({
    super.key,
    required this.orderId,
    required this.sellerName,
  });

  @override
  State<RatingsReviewsDialog> createState() => _RatingsReviewsDialogState();
}

class _RatingsReviewsDialogState extends State<RatingsReviewsDialog> {
  final OrderService _orderService = OrderService();
  
  double _overallSatisfaction = 0;
  double _productQuality = 0;
  double _materialAccuracy = 0;
  double _communication = 0;
  double _deliveryExperience = 0;

  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_overallSatisfaction == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate Overall Satisfaction'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _orderService.submitOrderReview(
        widget.orderId,
        _overallSatisfaction,
        _feedbackController.text.trim(),
        productQuality: _productQuality > 0 ? _productQuality.toInt() : null,
        materialAccuracy: _materialAccuracy > 0 ? _materialAccuracy.toInt() : null,
        communication: _communication > 0 ? _communication.toInt() : null,
        deliveryExperience: _deliveryExperience > 0 ? _deliveryExperience.toInt() : null,
        overallSatisfaction: _overallSatisfaction.toInt(),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rate_review,
                      size: 48,
                      color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Center(
                  child: Text(
                    'Rate Your Experience',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                Center(
                  child: Text(
                    'How was your transaction with ${widget.sellerName}?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(),

                // Category Star Ratings
                _buildCategoryRatingRow('Overall Satisfaction *', _overallSatisfaction, (val) {
                  setState(() => _overallSatisfaction = val);
                }),
                _buildCategoryRatingRow('Product Quality', _productQuality, (val) {
                  setState(() => _productQuality = val);
                }),
                _buildCategoryRatingRow('Material Accuracy', _materialAccuracy, (val) {
                  setState(() => _materialAccuracy = val);
                }),
                _buildCategoryRatingRow('Communication', _communication, (val) {
                  setState(() => _communication = val);
                }),
                _buildCategoryRatingRow('Delivery Experience', _deliveryExperience, (val) {
                  setState(() => _deliveryExperience = val);
                }),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Feedback Text Box
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Share your experience details (optional)',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textLight.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkCardSurface : AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRatingRow(String categoryName, double currentRating, Function(double) onRatingChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    index < currentRating ? Icons.star : Icons.star_border,
                    size: 28,
                    color: const Color(0xFFFFA726),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the ratings dialog
void showRatingsDialog(BuildContext context, int orderId, String sellerName) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => RatingsReviewsDialog(
      orderId: orderId,
      sellerName: sellerName,
    ),
  );
}
