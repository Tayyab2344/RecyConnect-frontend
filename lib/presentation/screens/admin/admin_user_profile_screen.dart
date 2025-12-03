import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';

// Data Models
class UserProfile {
  final String name;
  String email;
  String contact;
  String address;
  final String type;
  final DateTime joinedDate;
  int totalSales;
  int totalPurchases;
  final int totalOrders;
  final String lastActivity;
  final double? rating;
  final List<Document>? documents;
  final List<Activity> recentActivities;
  bool isSuspended;

  UserProfile({
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    required this.type,
    required this.joinedDate,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalOrders,
    required this.lastActivity,
    this.rating,
    this.documents,
    required this.recentActivities,
    this.isSuspended = false,
  });
}

class Document {
  final String name;
  final String type;
  final String url;

  Document({
    required this.name,
    required this.type,
    required this.url,
  });
}

class Activity {
  final String title;
  final String timestamp;
  final String status;
  final IconData icon;
  final Color color;

  Activity({
    required this.title,
    required this.timestamp,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class Transaction {
  final String id;
  final String type; // 'Sale' or 'Purchase'
  final String material; // 'Plastic', 'Paper', 'Metal', 'E-Waste'
  final double weight; // in kg
  final int amount; // in PKR
  final DateTime date;
  final String status; // 'Completed', 'Pending', 'Cancelled'

  Transaction({
    required this.id,
    required this.type,
    required this.material,
    required this.weight,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class AdminUserProfileScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userType;

  const AdminUserProfileScreen({
    super.key,
    this.userId,
    this.userName,
    this.userType,
  });

  @override
  State<AdminUserProfileScreen> createState() => _AdminUserProfileScreenState();
}

class _AdminUserProfileScreenState extends State<AdminUserProfileScreen> {
  late UserProfile userProfile;
  late List<Transaction> transactions;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    transactions = _generateTransactions();
  }

  void _loadUserProfile() {
    // Dummy data - In real app, this would be fetched from API using userId
    userProfile = UserProfile(
      name: widget.userName ?? 'Ahmed Hassan',
      email: 'ahmed.hassan@email.com',
      contact: '+92-300-1234567',
      address: 'Street ABC, Block 5, Gulberg, Lahore, Pakistan',
      type: widget.userType ?? 'Warehouse',
      joinedDate: DateTime(2024, 1, 15),
      totalSales: 50000,
      totalPurchases: 30000,
      totalOrders: 45,
      lastActivity: '2 hours ago',
      rating: 4.5,
      isSuspended: false,
      documents: widget.userType == 'Warehouse'
          ? [
              Document(
                  name: 'CNIC Copy',
                  type: 'PDF',
                  url: 'https://example.com/cnic.pdf'),
            ]
          : widget.userType == 'Company'
              ? [
                  Document(
                      name: 'CNIC Copy',
                      type: 'PDF',
                      url: 'https://example.com/cnic.pdf'),
                  Document(
                      name: 'NTN Certificate',
                      type: 'PDF',
                      url: 'https://example.com/ntn.pdf'),
                  Document(
                      name: 'Utility Bills',
                      type: 'PDF',
                      url: 'https://example.com/bills.pdf'),
                ]
              : null,
      recentActivities: [
        Activity(
          title: 'Sold 50kg plastic',
          timestamp: '2 hours ago',
          status: 'Completed',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        Activity(
          title: 'Purchased 30kg paper',
          timestamp: '5 hours ago',
          status: 'Completed',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        Activity(
          title: 'Order #12345 placed',
          timestamp: '1 day ago',
          status: 'Pending',
          icon: Icons.access_time,
          color: Colors.orange,
        ),
        Activity(
          title: 'Payment received',
          timestamp: '2 days ago',
          status: 'Completed',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        Activity(
          title: 'Profile updated',
          timestamp: '3 days ago',
          status: 'Info',
          icon: Icons.info,
          color: Colors.blue,
        ),
      ],
    );
  }

  List<Transaction> _generateTransactions() {
    final materials = ['Plastic', 'Paper', 'Metal', 'E-Waste'];
    final types = ['Sale', 'Purchase'];
    final statuses = ['Completed', 'Completed', 'Completed', 'Pending', 'Cancelled'];

    return List.generate(20, (index) {
      final daysAgo = index;
      final type = types[index % 2];
      final material = materials[index % 4];
      final status = statuses[index % 5];

      return Transaction(
        id: 'TXN${1000 + index}',
        type: type,
        material: material,
        weight: (10 + (index * 3.5)) % 100,
        amount: (5000 + (index * 1500)) % 50000 + 1000,
        date: DateTime.now().subtract(Duration(days: daysAgo)),
        status: status,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildContactInformation(),
            const SizedBox(height: 16),
            _buildStatistics(),
            const SizedBox(height: 16),
            if (userProfile.type == 'Warehouse' ||
                userProfile.type == 'Company')
              _buildDocuments(),
            if (userProfile.type == 'Warehouse' ||
                userProfile.type == 'Company')
              const SizedBox(height: 16),
            _buildActivityHistory(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'User Profile',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AdminColors.primaryGreen,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'suspend',
              child: Row(
                children: [
                  Icon(
                    userProfile.isSuspended ? Icons.check_circle : Icons.block,
                    size: 20,
                    color: userProfile.isSuspended ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(userProfile.isSuspended
                      ? 'Unsuspend Account'
                      : 'Suspend Account'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Account'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'transactions',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('View Transaction History'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'suspend':
        if (userProfile.isSuspended) {
          _showUnsuspendDialog(context);
        } else {
          _showSuspendDialog(context);
        }
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
      case 'transactions':
        _showTransactionHistoryBottomSheet(context);
        break;
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AdminColors.primaryGreen.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.primaryGreen.withOpacity(0.2),
              border: Border.all(color: AdminColors.primaryGreen, width: 3),
            ),
            child: Center(
              child: Text(
                _getInitials(userProfile.name),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            userProfile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // User Type Badge
          _buildUserTypeBadge(),
          const SizedBox(height: 8),
          // Status Badge
          _buildStatusBadge(),
          const SizedBox(height: 12),
          // Rating (if applicable)
          if (userProfile.rating != null) _buildRating(),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildUserTypeBadge() {
    Color badgeColor;
    switch (userProfile.type) {
      case 'Individual':
        badgeColor = Colors.green;
        break;
      case 'Warehouse':
        badgeColor = Colors.orange;
        break;
      case 'Company':
        badgeColor = Colors.purple;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        userProfile.type,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isSuspended = userProfile.isSuspended;
    final statusColor = isSuspended ? Colors.red : Colors.green;
    final statusText = isSuspended ? '🚫 Suspended' : '✅ Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildRating() {
    final rating = userProfile.rating!;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          fullStars,
          (index) => const Icon(
            Icons.star,
            color: Colors.amber,
            size: 20,
          ),
        ),
        if (hasHalfStar)
          const Icon(
            Icons.star_half,
            color: Colors.amber,
            size: 20,
          ),
        ...List.generate(
          5 - fullStars - (hasHalfStar ? 1 : 0),
          (index) => const Icon(
            Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)}/5',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInformation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Icons.email,
              'Email',
              userProfile.email,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildContactRow(
              Icons.phone,
              'Contact',
              userProfile.contact,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildContactRow(
              Icons.location_on,
              'Address',
              userProfile.address,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildContactRow(
              Icons.calendar_today,
              'Joined',
              DateFormat('MMMM dd, yyyy').format(userProfile.joinedDate),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    Icons.attach_money,
                    '${userProfile.totalSales.toStringAsFixed(0)} PKR',
                    'Total Sales',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    Icons.shopping_cart,
                    '${userProfile.totalPurchases.toStringAsFixed(0)} PKR',
                    'Total Purchases',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    Icons.inventory_2,
                    '${userProfile.totalOrders}',
                    'Total Orders',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    Icons.access_time,
                    userProfile.lastActivity,
                    'Last Active',
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments() {
    if (userProfile.documents == null || userProfile.documents!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...userProfile.documents!
                .map((doc) => _buildDocumentCard(doc))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Document doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Text(
                  doc.type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${doc.name}...')),
              );
            },
            child: const Text('View'),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${doc.name}...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHistory() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View All coming soon')),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: AdminColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...userProfile.recentActivities
                .asMap()
                .entries
                .map((entry) => _buildActivityRow(
                      entry.value,
                      isLast: entry.key ==
                          userProfile.recentActivities.length - 1,
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(Activity activity, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                activity.status,
                style: TextStyle(
                  fontSize: 11,
                  color: activity.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isSuspended = userProfile.isSuspended;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                if (isSuspended) {
                  _showUnsuspendDialog(context);
                } else {
                  _showSuspendDialog(context);
                }
              },
              icon: Icon(
                isSuspended ? Icons.check_circle : Icons.block,
                size: 20,
              ),
              label: Text(isSuspended ? 'Unsuspend User' : 'Suspend User'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isSuspended ? Colors.green : Colors.red,
                side: BorderSide(
                  color: isSuspended ? Colors.green : Colors.red,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showNotificationDialog(context),
              icon: const Icon(Icons.notifications, size: 20),
              label: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suspend User?'),
          content: Text(
            'Are you sure you want to suspend ${userProfile.name}? They won\'t be able to access the system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userProfile.isSuspended = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${userProfile.name} has been suspended'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Suspend'),
            ),
          ],
        );
      },
    );
  }

  void _showUnsuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsuspend User?'),
          content: Text(
            'Are you sure you want to unsuspend ${userProfile.name}? They will be able to access the system again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userProfile.isSuspended = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${userProfile.name} has been unsuspended'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Unsuspend'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: Text(
            'Are you sure you want to permanently delete ${userProfile.name}\'s account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${userProfile.name}\'s account has been deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final ValueNotifier<int> characterCount = ValueNotifier<int>(0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Notification to ${userProfile.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLength: 200,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter your message...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  characterCount.value = value.length;
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<int>(
                valueListenable: characterCount,
                builder: (context, count, child) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$count/200 characters',
                      style: TextStyle(
                        fontSize: 12,
                        color: count > 200 ? Colors.red : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isNotEmpty &&
                    messageController.text.length <= 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Notification sent to ${userProfile.name} successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AdminColors.primaryGreen,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Transaction List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isSale = transaction.type == 'Sale';
    final typeColor = isSale ? Colors.green : Colors.blue;
    final statusColor = transaction.status == 'Completed'
        ? Colors.green
        : transaction.status == 'Pending'
            ? Colors.orange
            : Colors.red;

    IconData materialIcon;
    switch (transaction.material) {
      case 'Plastic':
        materialIcon = Icons.water_drop;
        break;
      case 'Paper':
        materialIcon = Icons.description;
        break;
      case 'Metal':
        materialIcon = Icons.build;
        break;
      case 'E-Waste':
        materialIcon = Icons.devices;
        break;
      default:
        materialIcon = Icons.category;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(materialIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transaction.id,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.type,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          transaction.material,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.amount} PKR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 12,
                color: AdminColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(transaction.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AdminColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
