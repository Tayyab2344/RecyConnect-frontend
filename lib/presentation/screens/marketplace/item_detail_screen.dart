import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  double _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(item['title'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['images'].isNotEmpty)
              Image.network(item['images'][0], width: double.infinity, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'], style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('\$${item['price']} per ${item['unit']}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
                  const SizedBox(height: 8),
                  Text('Available Quantity: ${item['quantity']} ${item['unit']}'),
                  const SizedBox(height: 16),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  Text(item['description'] ?? 'No description'),
                  const SizedBox(height: 16),
                  Text('Seller: ${item['seller']['name'] ?? 'Unknown'}'),
                  const SizedBox(height: 24),
                  // Quantity and Buy button removed as payment is disabled
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
