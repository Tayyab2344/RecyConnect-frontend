import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/warehouse_service.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  final WarehouseService _warehouseService = WarehouseService();
  List<dynamic> _expenses = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _expenseCategories = [
    'TRANSPORTATION',
    'FUEL',
    'LABOR',
    'PACKAGING',
    'STORAGE',
    'UTILITIES',
    'MAINTENANCE',
    'OTHER'
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final data = await _warehouseService.getExpenses(
      category: _selectedFilter == 'All' ? null : _selectedFilter,
    );
    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense(int id) async {
    final success = await _warehouseService.deleteExpense(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
      _loadExpenses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete expense')),
      );
    }
  }

  void _showAddExpenseSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddExpenseForm(
          categories: _expenseCategories,
          onExpenseAdded: () {
            Navigator.pop(context);
            _loadExpenses();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Operating Expenses',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () => _showAddExpenseSheet(isDark),
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(isDark),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadExpenses,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _expenses.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final exp = _expenses[index];
                            return _buildExpenseCard(exp, isDark);
                          },
                        ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(isDark),
        backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    final filters = ['All', ..._expenseCategories];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final label = filters[index];
          final isSelected = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedFilter = label);
                  _loadExpenses();
                }
              },
              selectedColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(dynamic exp, bool isDark) {
    final date = DateTime.tryParse(exp['date'] ?? '') ?? DateTime.now();
    final formattedDate = "${date.day}/${date.month}/${date.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkSecondaryGreen : AppTheme.lightGray)
              .withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getCategoryColor(exp['category']).withOpacity(0.1),
                child: Icon(
                  _getCategoryIcon(exp['category']),
                  color: _getCategoryColor(exp['category']),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp['category'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp['description'] ?? 'No description',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10,
                      color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'PKR ${(exp['amount'] as num).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              if (exp['receipt'] != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.receipt, size: 20, color: Colors.blue),
                  onPressed: () => _viewReceiptDialog(exp['receipt']),
                )
              ],
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => _deleteExpense(exp['id']),
              )
            ],
          )
        ],
      ),
    );
  }

  void _viewReceiptDialog(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Expense Receipt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Image.network(url, fit: BoxFit.contain),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'TRANSPORTATION':
        return Icons.local_shipping;
      case 'FUEL':
        return Icons.local_gas_station;
      case 'LABOR':
        return Icons.engineering;
      case 'PACKAGING':
        return Icons.inventory_2;
      case 'STORAGE':
        return Icons.warehouse;
      case 'UTILITIES':
        return Icons.power;
      case 'MAINTENANCE':
        return Icons.build;
      default:
        return Icons.payment;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'TRANSPORTATION':
        return Colors.blue;
      case 'FUEL':
        return Colors.red;
      case 'LABOR':
        return Colors.orange;
      case 'PACKAGING':
        return Colors.purple;
      case 'STORAGE':
        return Colors.teal;
      case 'UTILITIES':
        return Colors.amber;
      case 'MAINTENANCE':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: (isDark ? AppTheme.darkTextSecondary : AppTheme.textLight)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses recorded yet.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpenseForm extends StatefulWidget {
  final List<String> categories;
  final VoidCallback onExpenseAdded;

  const AddExpenseForm({
    super.key,
    required this.categories,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _warehouseService = WarehouseService();

  String? _selectedCategory;
  File? _receiptImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _receiptImage = File(picked.path);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    setState(() => _isSaving = true);
    final amt = double.tryParse(_amountController.text) ?? 0.0;

    final result = await _warehouseService.addExpense(
      category: _selectedCategory!,
      amount: amt,
      description: _descController.text,
      receipt: _receiptImage,
    );

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      widget.onExpenseAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to add expense')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Operational Expense',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Expense Category'),
                items: widget.categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val);
                },
                validator: (val) => val == null ? 'Please select category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (PKR)',
                  prefixText: 'Rs ',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter amount';
                  if (double.tryParse(val) == null) return 'Please enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Short Description'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickReceipt,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  child: _receiptImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 28),
                            SizedBox(height: 8),
                            Text('Attach Receipt Image (Optional)', style: TextStyle(fontSize: 12)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_receiptImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.darkPrimaryGreen : AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
