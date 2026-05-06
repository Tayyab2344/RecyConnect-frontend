import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/item_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = sl<AuthService>();
  late Future<List<dynamic>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final user = await _authService.getUser();
    setState(() {
      _itemsFuture = _itemService.getItems(sellerId: user?['id'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No items in inventory'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: item['images'].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item['images'][0], 
                        width: 50, 
                        height: 50, 
                        fit: BoxFit.cover,
                        memCacheWidth: 150,
                        memCacheHeight: 150,
                      )
                    : const Icon(Icons.image),
                title: Text(item['title']),
                subtitle: Text('${item['quantity']} ${item['unit']} - \$${item['price']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _itemService.deleteItem(item['id']);
                    _loadItems();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
