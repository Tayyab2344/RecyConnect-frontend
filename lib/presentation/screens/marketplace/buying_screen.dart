import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BuyingScreen extends StatefulWidget {
  const BuyingScreen({super.key});

  @override
  State<BuyingScreen> createState() => _BuyingScreenState();
}

class _BuyingScreenState extends State<BuyingScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Plastic', 'Metal', 'Paper', 'Glass', 'Electronics'];

  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Recycled Plastic Pellets',
      'category': 'Plastic',
      'price': 2.50,
      'unit': 'kg',
      'supplier': 'EcoPlastic Co.',
      'rating': 4.8,
      'stock': 500,
      'location': 'Karachi',
      'description': 'High-quality recycled plastic pellets suitable for manufacturing',
    },
    {
      'id': '2',
      'name': 'Aluminum Sheets',
      'category': 'Metal',
      'price': 15.00,
      'unit': 'kg',
      'supplier': 'MetalWorks Ltd.',
      'rating': 4.9,
      'stock': 200,
      'location': 'Lahore',
      'description': 'Premium aluminum sheets from recycled materials',
    },
    {
      'id': '3',
      'name': 'Recycled Paper Rolls',
      'category': 'Paper',
      'price': 1.20,
      'unit': 'kg',
      'supplier': 'PaperCycle Inc.',
      'rating': 4.6,
      'stock': 1000,
      'location': 'Islamabad',
      'description': 'Clean recycled paper rolls for packaging',
    },
    {
      'id': '4',
      'name': 'Glass Cullet',
      'category': 'Glass',
      'price': 0.80,
      'unit': 'kg',
      'supplier': 'GlassRecycle Pro',
      'rating': 4.7,
      'stock': 750,
      'location': 'Faisalabad',
      'description': 'Sorted glass cullet ready for remelting',
    },
    {
      'id': '5',
      'name': 'E-Waste Components',
      'category': 'Electronics',
      'price': 25.00,
      'unit': 'kg',
      'supplier': 'TechRecycle Hub',
      'rating': 4.5,
      'stock': 100,
      'location': 'Karachi',
      'description': 'Valuable components extracted from electronic waste',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'All'
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Materials'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCartDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          _buildSortFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => selectedCategory = category);
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Sort by: '),
          DropdownButton<String>(
            value: 'Price: Low to High',
            items: const [
              DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
              DropdownMenuItem(value: 'Rating', child: Text('Rating')),
              DropdownMenuItem(value: 'Stock', child: Text('Stock')),
            ],
            onChanged: (value) {},
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(product['category']),
                    color: AppTheme.primaryGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['supplier'],
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppTheme.textLight),
                          Text(
                            ' ${product['location']}',
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      'per ${product['unit']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product['description'],
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${product['rating']}'),
                const SizedBox(width: 16),
                const Icon(Icons.inventory, size: 16, color: AppTheme.textLight),
                Text(' ${product['stock']} ${product['unit']} available'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showOrderDialog(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Order'),
                ),
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
      case 'Electronics':
        return Icons.computer;
      default:
        return Icons.inventory;
    }
  }

  void _showOrderDialog(Map<String, dynamic> product) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${product['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${product['supplier']}'),
            Text('Price: \$${product['price']}/${product['unit']}'),
            Text('Available: ${product['stock']} ${product['unit']}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${product['unit']})',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
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
                const SnackBar(content: Text('Order placed successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shopping Cart'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your cart is empty'),
            SizedBox(height: 16),
            Text('Add items to your cart to see them here.'),
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