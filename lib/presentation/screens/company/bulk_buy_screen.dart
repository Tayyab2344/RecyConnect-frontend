import 'package:flutter/material.dart';

class BulkBuyScreen extends StatefulWidget {
  const BulkBuyScreen({Key? key}) : super(key: key);

  @override
  State<BulkBuyScreen> createState() => _BulkBuyScreenState();
}

class _BulkBuyScreenState extends State<BulkBuyScreen> {
  String _selectedMaterial = 'All';
  String _selectedLocation = 'All';
  double _minWeight = 0;
  double _maxWeight = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Bulk Buy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildListings()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search materials, suppliers...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('All', _selectedMaterial == 'All', () {
            setState(() => _selectedMaterial = 'All');
          }),
          _buildChip('Plastic', _selectedMaterial == 'Plastic', () {
            setState(() => _selectedMaterial = 'Plastic');
          }),
          _buildChip('Metal', _selectedMaterial == 'Metal', () {
            setState(() => _selectedMaterial = 'Metal');
          }),
          _buildChip('Glass', _selectedMaterial == 'Glass', () {
            setState(() => _selectedMaterial = 'Glass');
          }),
          _buildChip('Paper', _selectedMaterial == 'Paper', () {
            setState(() => _selectedMaterial = 'Paper');
          }),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildListings() {
    final listings = [
      {
        'title': 'Aluminum Scrap - Industrial Grade',
        'quantity': '500 tons',
        'price': '\$450/ton',
        'purity': '98.5%',
        'supplier': 'Green Warehouse Co.',
        'location': 'New York, NY',
        'verified': true,
        'image': Icons.recycling,
      },
      {
        'title': 'Mixed Plastic - HDPE/PET',
        'quantity': '200 tons',
        'price': '\$320/ton',
        'purity': '95%',
        'supplier': 'EcoSupply Ltd.',
        'location': 'Los Angeles, CA',
        'verified': true,
        'image': Icons.delete_outline,
      },
      {
        'title': 'Glass Bottles - Clear',
        'quantity': '150 tons',
        'price': '\$180/ton',
        'purity': '99%',
        'supplier': 'RecyclePro Inc.',
        'location': 'Chicago, IL',
        'verified': false,
        'image': Icons.local_drink,
      },
      {
        'title': 'Cardboard & Paper Mix',
        'quantity': '300 tons',
        'price': '\$120/ton',
        'purity': '92%',
        'supplier': 'Paper Masters LLC',
        'location': 'Houston, TX',
        'verified': true,
        'image': Icons.description,
      },
      {
        'title': 'E-Waste Components',
        'quantity': '50 tons',
        'price': '\$850/ton',
        'purity': 'Mixed',
        'supplier': 'Tech Recycle Co.',
        'location': 'San Francisco, CA',
        'verified': true,
        'image': Icons.devices,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    listing['image'] as IconData,
                    size: 60,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (listing['verified'] as bool)
                          const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.business, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          listing['supplier'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          listing['location'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoPill(
                          Icons.scale,
                          listing['quantity'] as String,
                          const Color(0xFFFFA726),
                        ),
                        _buildInfoPill(
                          Icons.verified_outlined,
                          listing['purity'] as String,
                          const Color(0xFF4CAF50),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing['price'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showPurchaseDialog(listing);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Send Offer', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                          child: const Icon(Icons.info_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedMaterial = 'All';
                            _selectedLocation = 'All';
                            _minWeight = 0;
                            _maxWeight = 1000;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Weight Range (tons)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Row(
                    children: [
                      Text('${_minWeight.toInt()}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      Expanded(
                        child: RangeSlider(
                          values: RangeValues(_minWeight, _maxWeight),
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          activeColor: const Color(0xFF2196F3),
                          onChanged: (values) {
                            setState(() {
                              _minWeight = values.start;
                              _maxWeight = values.end;
                            });
                          },
                        ),
                      ),
                      Text('${_maxWeight.toInt()}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPurchaseDialog(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Send Purchase Offer', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing['title'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ${listing['price']}',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              Text(
                'Quantity: ${listing['quantity']}',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Your Offer (per ton)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Quantity Needed (tons)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  const SnackBar(content: Text('Offer sent successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Offer'),
            ),
          ],
        );
      },
    );
  }
}
