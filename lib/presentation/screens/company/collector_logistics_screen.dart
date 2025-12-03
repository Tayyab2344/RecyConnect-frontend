import 'package:flutter/material.dart';

class CollectorLogisticsScreen extends StatelessWidget {
  const CollectorLogisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pickups = [
      {
        'id': 'PU-2024-091',
        'collector': 'Fast Logistics Inc.',
        'material': 'Aluminum Scrap',
        'quantity': '50 tons',
        'from': 'Green Warehouse Co.',
        'to': 'Company Facility A',
        'status': 'in_transit',
        'eta': '2 hours',
        'progress': 0.6,
      },
      {
        'id': 'PU-2024-092',
        'collector': 'Eco Transport LLC',
        'material': 'Mixed Plastic',
        'quantity': '30 tons',
        'from': 'EcoSupply Ltd.',
        'to': 'Company Facility B',
        'status': 'scheduled',
        'eta': 'Tomorrow, 10 AM',
        'progress': 0.0,
      },
      {
        'id': 'PU-2024-093',
        'collector': 'Green Fleet Co.',
        'material': 'Glass Bottles',
        'quantity': '20 tons',
        'from': 'RecyclePro Inc.',
        'to': 'Company Facility A',
        'status': 'completed',
        'eta': '-',
        'progress': 1.0,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Collector Logistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pickups.length,
          itemBuilder: (context, index) {
            final pickup = pickups[index];
            final statusColor = pickup['status'] == 'in_transit'
                ? const Color(0xFF2196F3)
                : pickup['status'] == 'scheduled'
                    ? const Color(0xFFFFA726)
                    : const Color(0xFF4CAF50);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pickup['id'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (pickup['status'] as String).toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pickup['material'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pickup['quantity'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Route visualization
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pickup['from'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF9C27B0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pickup['to'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  if (pickup['status'] != 'completed') ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: pickup['progress'] as double,
                        backgroundColor: statusColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(Icons.local_shipping, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                        pickup['collector'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      if (pickup['status'] == 'in_transit') ...[
                        Icon(Icons.schedule, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          'ETA: ${pickup['eta']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (pickup['status'] == 'in_transit') ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Track Live'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                              side: const BorderSide(color: Color(0xFF2196F3)),
                            ),
                          ),
                        ),
                      ],
                      if (pickup['status'] == 'completed') ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('View Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (pickup['status'] == 'scheduled') ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Modify'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFFA726),
                              side: const BorderSide(color: Color(0xFFFFA726)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9C27B0),
                          side: const BorderSide(color: Color(0xFF9C27B0)),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF9C27B0),
        icon: const Icon(Icons.add),
        label: const Text('Request Pickup'),
      ),
    );
  }
}
