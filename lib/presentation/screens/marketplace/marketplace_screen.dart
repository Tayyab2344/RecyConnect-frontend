import 'package:flutter/material.dart';
import '../../../core/services/listing_service.dart';
import '../../../core/models/listing_model.dart';
import 'item_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ListingService _listingService = ListingService();
  late Future<Map<String, dynamic>> _listingsFuture;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _listingsFuture = _listingService.getListings(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        material: _selectedCategory,
        isMarketplace: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _loadItems();
              },
            ),
          ),
          // Category Filter (Simplified)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Plastic', 'Metal', 'Paper', 'Glass', 'E-Waste'].map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == (category == 'All' ? null : category),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = (category == 'All' || !selected) ? null : category;
                        _loadItems();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final data = snapshot.data;
                final List<Listing> listings = data != null ? data['listings'] as List<Listing> : [];
                
                if (listings.isEmpty) {
                  return const Center(child: Text('No listings found'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to detail screen (will need update)
                        // Navigator.push(...)
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: listing.decodedImages.isNotEmpty
                                  ? Image.memory(
                                      listing.decodedImages.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => 
                                          Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                                    )
                                  : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),

                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.materialType.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  Text('${listing.estimatedWeight} kg'),
                                  Text(
                                    listing.pickupAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
