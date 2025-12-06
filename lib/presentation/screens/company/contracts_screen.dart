import 'package:flutter/material.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contracts = [
      {
        'id': 'CNT-2024-001',
        'supplier': 'Green Warehouse Co.',
        'material': 'Aluminum Scrap',
        'frequency': 'Monthly',
        'quantity': '500 tons/month',
        'rate': '\$450/ton',
        'startDate': 'Jan 1, 2024',
        'endDate': 'Dec 31, 2024',
        'status': 'active',
        'nextPickup': '5 days',
      },
      {
        'id': 'CNT-2024-002',
        'supplier': 'EcoSupply Ltd.',
        'material': 'Mixed Plastic',
        'frequency': 'Bi-weekly',
        'quantity': '200 tons/delivery',
        'rate': '\$320/ton',
        'startDate': 'Feb 15, 2024',
        'endDate': 'Feb 15, 2025',
        'status': 'active',
        'nextPickup': '12 days',
      },
      {
        'id': 'CNT-2024-003',
        'supplier': 'RecyclePro Inc.',
        'material': 'Glass Bottles',
        'frequency': 'Weekly',
        'quantity': '150 tons/week',
        'rate': '\$180/ton',
        'startDate': 'Mar 1, 2024',
        'endDate': 'Aug 31, 2024',
        'status': 'expiring',
        'nextPickup': '2 days',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Recurring Contracts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            final isActive = contract['status'] == 'active';
            final isExpiring = contract['status'] == 'expiring';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isExpiring 
                      ? const Color(0xFFFFA726).withOpacity(0.5)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  width: isExpiring ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contract['id'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpiring
                              ? const Color(0xFFFFA726).withOpacity(0.1)
                              : const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isExpiring ? 'EXPIRING SOON' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isExpiring ? const Color(0xFFFFA726) : const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contract['material'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                        contract['supplier'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'Frequency',
                          contract['frequency'] as String,
                          Icons.repeat,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Quantity',
                          contract['quantity'] as String,
                          Icons.scale,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Rate',
                          contract['rate'] as String,
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Next pickup in ${contract['nextPickup']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF2196F3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Valid: ${contract['startDate']} - ${contract['endDate']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            side: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      if (isExpiring) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Renew'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA726),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new contract')),
          );
        },
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('New Contract'),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
