import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_message_helper.dart';
import '../../widgets/recycle_loader.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();

  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _transactionService.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorMessageHelper.showErrorSnackBar(
          context,
          message: 'Failed to load transactions: ${e.toString()}',
          onRetry: _loadTransactions,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Earnings'),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: RecycleLoader(
                color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              ),
            )
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your financial history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final txn = _transactions[index];
                      // Determine type based on your business logic (example: if amount starts with '-', it's an outbound payment)
                      final isCredit = txn['type'] == 'CREDIT'; 
                      final amountColor = isCredit ? Colors.green : Colors.red;
                      final typeIcon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCardSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkSecondaryGreen.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: amountColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(typeIcon, color: amountColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    txn['description'] ?? 'Transaction',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    txn['createdAt'] != null 
                                      ? DateFormat('MMM d, y • h:mm a').format(DateTime.parse(txn['createdAt'])) 
                                      : 'Unknown Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs ${txn['amount']?.toString() ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: amountColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  txn['status'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
