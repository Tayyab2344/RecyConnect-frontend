import 'package:flutter/material.dart';

class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final documents = [
      {
        'type': 'Business License',
        'status': 'verified',
        'uploadDate': 'Jan 15, 2024',
        'expiryDate': 'Jan 15, 2025',
        'icon': Icons.business_center,
      },
      {
        'type': 'Tax Registration (NTN)',
        'status': 'verified',
        'uploadDate': 'Jan 20, 2024',
        'expiryDate': '-',
        'icon': Icons.receipt_long,
      },
      {
        'type': 'Environmental Certificate',
        'status': 'pending',
        'uploadDate': 'Mar 10, 2024',
        'expiryDate': 'Mar 10, 2025',
        'icon': Icons.eco,
      },
      {
        'type': 'Vendor Agreement',
        'status': 'expired',
        'uploadDate': 'Dec 1, 2023',
        'expiryDate': 'Dec 1, 2024',
        'icon': Icons.handshake,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Compliance & Verification'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            final statusColor = doc['status'] == 'verified'
                ? const Color(0xFF4CAF50)
                : doc['status'] == 'pending'
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFE57373);

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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          doc['icon'] as IconData,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['type'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (doc['status'] as String).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Uploaded',
                          doc['uploadDate'] as String,
                          Icons.upload_file,
                        ),
                      ),
                      if (doc['expiryDate'] != '-')
                        Expanded(
                          child: _buildInfoRow(
                            'Expires',
                            doc['expiryDate'] as String,
                            Icons.event,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            side: const BorderSide(color: Color(0xFF2196F3)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (doc['status'] == 'expired' || doc['status'] == 'pending')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload, size: 18),
                            label: Text(doc['status'] == 'expired' ? 'Reupload' : 'Update'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: statusColor,
                              foregroundColor: Colors.white,
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: const Text('Upload Document'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
