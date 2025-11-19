import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  final List<Map<String, dynamic>> myListings = [
    {
      'id': '1',
      'name': 'Mixed Plastic Bottles',
      'category': 'Plastic',
      'price': 1.80,
      'unit': 'kg',
      'quantity': 150,
      'status': 'Active',
      'views': 24,
      'inquiries': 3,
      'datePosted': '2 days ago',
    },
    {
      'id': '2',
      'name': 'Cardboard Boxes',
      'category': 'Paper',
      'price': 0.90,
      'unit': 'kg',
      'quantity': 300,
      'status': 'Sold',
      'views': 45,
      'inquiries': 8,
      'datePosted': '1 week ago',
    },
    {
      'id': '3',
      'name': 'Aluminum Cans',
      'category': 'Metal',
      'price': 3.20,
      'unit': 'kg',
      'quantity': 75,
      'status': 'Pending',
      'views': 12,
      'inquiries': 1,
      'datePosted': '1 day ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Materials'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalytics(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCards(),
          _buildTabBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myListings.length,
              itemBuilder: (context, index) {
                return _buildListingCard(myListings[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddListingDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Listing', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Active Listings', '2', Icons.list, AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Views', '81', Icons.visibility, AppTheme.accentBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Inquiries', '12', Icons.message, AppTheme.warningOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Earnings', '\$245', Icons.attach_money, AppTheme.lightGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'My Listings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: 'All',
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Sold', child: Text('Sold')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final isActive = listing['status'] == 'Active';
    final isSold = listing['status'] == 'Sold';
    final isPending = listing['status'] == 'Pending';
    
    Color statusColor = AppTheme.textLight;
    if (isActive) statusColor = AppTheme.primaryGreen;
    if (isSold) statusColor = AppTheme.accentBlue;
    if (isPending) statusColor = AppTheme.warningOrange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(listing['category']),
                    color: AppTheme.primaryGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted ${listing['datePosted']}',
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    listing['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '\$${listing['price'].toStringAsFixed(2)}/${listing['unit']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Text('Qty: ${listing['quantity']} ${listing['unit']}'),
                const Spacer(),
                if (isSold)
                  const Text(
                    'SOLD',
                    style: TextStyle(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.visibility, size: 16, color: AppTheme.textLight),
                Text(' ${listing['views']} views'),
                const SizedBox(width: 16),
                const Icon(Icons.message, size: 16, color: AppTheme.textLight),
                Text(' ${listing['inquiries']} inquiries'),
                const Spacer(),
                if (isActive) ...[
                  TextButton(
                    onPressed: () => _editListing(listing),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => _pauseListing(listing),
                    child: const Text('Pause'),
                  ),
                ] else if (isPending) ...[
                  TextButton(
                    onPressed: () => _activateListing(listing),
                    child: const Text('Activate'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Plastic':
        return Icons.recycling;
      case 'Metal':
        return Icons.hardware;
      case 'Paper':
        return Icons.description;
      case 'Glass':
        return Icons.wine_bar;
      default:
        return Icons.inventory;
    }
  }

  void _showAddListingDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedCategory = 'Plastic';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Listing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Plastic', 'Metal', 'Paper', 'Glass', 'Electronics']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per kg (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing created successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Create Listing'),
          ),
        ],
      ),
    );
  }

  void _editListing(Map<String, dynamic> listing) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${listing['name']}')),
    );
  }

  void _pauseListing(Map<String, dynamic> listing) {
    setState(() {
      listing['status'] = 'Pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${listing['name']} paused')),
    );
  }

  void _activateListing(Map<String, dynamic> listing) {
    setState(() {
      listing['status'] = 'Active';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${listing['name']} activated')),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sales Analytics'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Revenue: \$245'),
            Text('Best Selling Category: Paper'),
            Text('Average Price: \$1.97/kg'),
            Text('Total Materials Sold: 375 kg'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}