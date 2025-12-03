import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';

// Data Models
class RecentCollection {
  final String material;
  final int weight;
  final String location;
  final String timestamp;
  final String status;
  final Color iconColor;

  RecentCollection({
    required this.material,
    required this.weight,
    required this.location,
    required this.timestamp,
    required this.status,
    required this.iconColor,
  });
}

class RatingBreakdown {
  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final int twoStars;
  final int oneStar;
  final int totalReviews;

  RatingBreakdown({
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.twoStars,
    required this.oneStar,
    required this.totalReviews,
  });
}

class CollectorProfile {
  final String id;
  String name;
  String contact;
  String email;
  String warehouseName;
  String area;
  final double rating;
  String status;
  final DateTime joinedDate;
  final int totalPickups;
  final int completedTasks;
  final int performancePercent;
  final String lastCollection;
  final List<RecentCollection> recentCollections;
  final RatingBreakdown ratingBreakdown;

  CollectorProfile({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.warehouseName,
    required this.area,
    required this.rating,
    required this.status,
    required this.joinedDate,
    required this.totalPickups,
    required this.completedTasks,
    required this.performancePercent,
    required this.lastCollection,
    required this.recentCollections,
    required this.ratingBreakdown,
  });

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AdminCollectorDetailsScreen extends StatefulWidget {
  const AdminCollectorDetailsScreen({super.key});

  @override
  State<AdminCollectorDetailsScreen> createState() =>
      _AdminCollectorDetailsScreenState();
}

class _AdminCollectorDetailsScreenState
    extends State<AdminCollectorDetailsScreen> {
  late CollectorProfile _collector;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
  }

  void _initializeDummyData() {
    _collector = CollectorProfile(
      id: 'COL001',
      name: 'Ahmed Khan',
      contact: '+92-300-1234567',
      email: 'ahmed.khan@ecowaste.com',
      warehouseName: 'Green Warehouse',
      area: 'Downtown, Lahore',
      rating: 4.8,
      status: 'active',
      joinedDate: DateTime(2024, 1, 15),
      totalPickups: 245,
      completedTasks: 232,
      performancePercent: 95,
      lastCollection: '2 hours ago',
      recentCollections: [
        RecentCollection(
          material: 'Plastic',
          weight: 50,
          location: 'Downtown',
          timestamp: '2 hours ago',
          status: 'completed',
          iconColor: AdminColors.accentBlue,
        ),
        RecentCollection(
          material: 'Paper',
          weight: 30,
          location: 'Westside',
          timestamp: '5 hours ago',
          status: 'completed',
          iconColor: AdminColors.success,
        ),
        RecentCollection(
          material: 'Metal',
          weight: 45,
          location: 'Uptown',
          timestamp: '1 day ago',
          status: 'completed',
          iconColor: AdminColors.accentOrange,
        ),
        RecentCollection(
          material: 'E-Waste',
          weight: 25,
          location: 'Eastend',
          timestamp: '2 days ago',
          status: 'pending',
          iconColor: AdminColors.accentPurple,
        ),
        RecentCollection(
          material: 'Plastic',
          weight: 60,
          location: 'Downtown',
          timestamp: '3 days ago',
          status: 'completed',
          iconColor: AdminColors.accentBlue,
        ),
      ],
      ratingBreakdown: RatingBreakdown(
        fiveStars: 120,
        fourStars: 25,
        threeStars: 8,
        twoStars: 2,
        oneStar: 1,
        totalReviews: 156,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AdminColors.success;
      case 'inactive':
        return AdminColors.error;
      case 'on_leave':
        return AdminColors.accentOrange;
      default:
        return AdminColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'on_leave':
        return 'On Leave';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.cancel;
      case 'on_leave':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Collector Details',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AdminColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AdminColors.textWhite),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'toggle_status') {
                if (_collector.status == 'active') {
                  _showSuspendDialog();
                } else {
                  _showActivateDialog();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      _collector.status == 'active'
                          ? Icons.block
                          : Icons.check_circle,
                      color: _collector.status == 'active'
                          ? AdminColors.error
                          : AdminColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(_collector.status == 'active'
                        ? 'Suspend Account'
                        : 'Activate Account'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildContactInfoCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminColors.primaryGreen.withOpacity(0.1),
            AdminColors.cardBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AdminColors.primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AdminColors.primaryGreen,
                width: 3,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.local_shipping,
                color: AdminColors.primaryGreen,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            _collector.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(_collector.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(_collector.status),
                  size: 18,
                  color: _getStatusColor(_collector.status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(_collector.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(_collector.status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              Icons.phone, 'Contact', _collector.contact, AdminColors.success),
          const Divider(height: 24),
          _buildContactRow(Icons.email, 'Email', _collector.email,
              AdminColors.accentBlue),
          const Divider(height: 24),
          _buildContactRow(Icons.warehouse, 'Warehouse',
              _collector.warehouseName, AdminColors.accentOrange),
          const Divider(height: 24),
          _buildContactRow(Icons.location_on, 'Area', _collector.area,
              AdminColors.accentPurple),
          const Divider(height: 24),
          _buildContactRow(
              Icons.calendar_today,
              'Joined',
              DateFormat('MMMM dd, yyyy').format(_collector.joinedDate),
              AdminColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildContactRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 2),
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

  Widget _buildActionButtons() {
    final isActive = _collector.status == 'active';
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          if (isActive) {
            _showSuspendDialog();
          } else {
            _showActivateDialog();
          }
        },
        icon: Icon(
          isActive ? Icons.block : Icons.check_circle,
          color: isActive ? AdminColors.error : AdminColors.success,
        ),
        label: Text(
          isActive ? 'Suspend Collector' : 'Activate Collector',
          style: TextStyle(
            color: isActive ? AdminColors.error : AdminColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isActive ? AdminColors.error : AdminColors.success,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dialogs
  void _showSuspendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AdminColors.error),
            SizedBox(width: 12),
            Text('Suspend Collector?'),
          ],
        ),
        content: Text(
          'Are you sure you want to suspend ${_collector.name}? They won\'t be able to make pickups.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _collector.status = 'inactive';
              });
              Navigator.pop(context);
              _showSuccessSnackbar('Collector suspended successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showActivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AdminColors.success),
            SizedBox(width: 12),
            Text('Activate Collector?'),
          ],
        ),
        content: Text(
          'Are you sure you want to activate ${_collector.name}? They will be able to make pickups again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _collector.status = 'active';
              });
              Navigator.pop(context);
              _showSuccessSnackbar('Collector activated successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
