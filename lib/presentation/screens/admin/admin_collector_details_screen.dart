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

  final List<String> _warehouses = [
    'ABC Warehouse',
    'Green Warehouse',
    'EcoHub',
    'RecyclePoint',
    'CleanCity Hub',
    'WasteWise Center',
    'GreenEarth Depot',
    'EcoCenter',
    'RecycleMax Depot',
    'Sustainable Hub',
  ];

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
          IconButton(
            icon: const Icon(Icons.edit, color: AdminColors.textWhite),
            onPressed: () => _showEditDialog(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AdminColors.textWhite),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditDialog();
                  break;
                case 'toggle_status':
                  if (_collector.status == 'active') {
                    _showSuspendDialog();
                  } else {
                    _showActivateDialog();
                  }
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AdminColors.textSecondary, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Profile'),
                  ],
                ),
              ),
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
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AdminColors.error, size: 20),
                    SizedBox(width: 12),
                    Text('Delete Collector',
                        style: TextStyle(color: AdminColors.error)),
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
            _buildPerformanceStatsCard(),
            const SizedBox(height: 16),
            _buildRecentCollectionsCard(),
            const SizedBox(height: 16),
            _buildRatingBreakdownCard(),
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

          // Rating Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final starValue = index + 1;
                if (_collector.rating >= starValue) {
                  return const Icon(Icons.star,
                      color: Color(0xFFFBBF24), size: 24);
                } else if (_collector.rating >= starValue - 0.5) {
                  return const Icon(Icons.star_half,
                      color: Color(0xFFFBBF24), size: 24);
                } else {
                  return const Icon(Icons.star_border,
                      color: Color(0xFFFBBF24), size: 24);
                }
              }),
              const SizedBox(width: 8),
              Text(
                '${_collector.rating}/5.0',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ],
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

  Widget _buildPerformanceStatsCard() {
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
            'Performance Stats',
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
                  icon: Icons.inventory_2,
                  iconColor: AdminColors.success,
                  value: _collector.totalPickups.toString(),
                  label: 'Total Pickups',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  icon: Icons.check_circle,
                  iconColor: AdminColors.accentBlue,
                  value: _collector.completedTasks.toString(),
                  label: 'Completed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  icon: Icons.analytics,
                  iconColor: AdminColors.accentOrange,
                  value: '${_collector.performancePercent}%',
                  label: 'Performance',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  icon: Icons.access_time,
                  iconColor: AdminColors.accentPurple,
                  value: _collector.lastCollection,
                  label: 'Last Active',
                  isSmallValue: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool isSmallValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallValue ? 16 : 24,
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

  Widget _buildRecentCollectionsCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Collections',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last ${_collector.recentCollections.length} pickups',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showComingSoonSnackbar('View All Collections'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AdminColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_collector.recentCollections.length, (index) {
            final collection = _collector.recentCollections[index];
            return Column(
              children: [
                _buildCollectionItem(collection),
                if (index < _collector.recentCollections.length - 1)
                  const Divider(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCollectionItem(RecentCollection collection) {
    final isCompleted = collection.status == 'completed';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: collection.iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getMaterialIcon(collection.material),
            size: 20,
            color: collection.iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collected ${collection.weight}kg ${collection.material}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 12, color: AdminColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    collection.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time,
                      size: 12, color: AdminColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    collection.timestamp,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? AdminColors.success.withOpacity(0.1)
                : AdminColors.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.pending,
                size: 14,
                color: isCompleted
                    ? AdminColors.success
                    : AdminColors.accentOrange,
              ),
              const SizedBox(width: 4),
              Text(
                isCompleted ? 'Done' : 'Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? AdminColors.success
                      : AdminColors.accentOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getMaterialIcon(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.settings;
      case 'e-waste':
        return Icons.computer;
      default:
        return Icons.recycling;
    }
  }

  Widget _buildRatingBreakdownCard() {
    final breakdown = _collector.ratingBreakdown;
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
            'Rating Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Overall Rating
          Row(
            children: [
              Text(
                _collector.rating.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < _collector.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFFBBF24),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${breakdown.totalReviews} reviews',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating Bars
          _buildRatingBar(5, breakdown.fiveStars, breakdown.totalReviews),
          const SizedBox(height: 8),
          _buildRatingBar(4, breakdown.fourStars, breakdown.totalReviews),
          const SizedBox(height: 8),
          _buildRatingBar(3, breakdown.threeStars, breakdown.totalReviews),
          const SizedBox(height: 8),
          _buildRatingBar(2, breakdown.twoStars, breakdown.totalReviews),
          const SizedBox(height: 8),
          _buildRatingBar(1, breakdown.oneStar, breakdown.totalReviews),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '$stars',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AdminColors.textSecondary,
            ),
          ),
        ),
        const Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AdminColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AdminColors.primaryGreen),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            '$count (${(percentage * 100).toInt()}%)',
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isActive = _collector.status == 'active';
    return Row(
      children: [
        Expanded(
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
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showAssignWarehouseDialog,
            icon: const Icon(Icons.warehouse, color: AdminColors.accentBlue),
            label: const Text(
              'Assign Warehouse',
              style: TextStyle(
                color: AdminColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AdminColors.accentBlue,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AdminColors.error),
            SizedBox(width: 12),
            Text('Delete Collector?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${_collector.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Collector deleted successfully'),
                    ],
                  ),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAssignWarehouseDialog() {
    String selectedWarehouse = _collector.warehouseName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warehouse, color: AdminColors.accentBlue),
              SizedBox(width: 12),
              Text('Assign Warehouse'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a warehouse to assign to this collector:',
                style: TextStyle(color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedWarehouse,
                decoration: InputDecoration(
                  labelText: 'Warehouse',
                  prefixIcon: const Icon(Icons.warehouse),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _warehouses
                    .map((warehouse) => DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedWarehouse = value!;
                  });
                },
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
                setState(() {
                  _collector.warehouseName = selectedWarehouse;
                });
                Navigator.pop(context);
                _showSuccessSnackbar(
                    'Warehouse assigned: $selectedWarehouse');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _collector.name);
    final contactController = TextEditingController(text: _collector.contact);
    final emailController = TextEditingController(text: _collector.email);
    final areaController = TextEditingController(text: _collector.area);
    String selectedWarehouse = _collector.warehouseName;
    String selectedStatus = _collector.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit, color: AdminColors.primaryGreen),
              SizedBox(width: 12),
              Text('Edit Collector'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedWarehouse,
                    decoration: InputDecoration(
                      labelText: 'Warehouse',
                      prefixIcon: const Icon(Icons.warehouse),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _warehouses
                        .map((warehouse) => DropdownMenuItem(
                              value: warehouse,
                              child: Text(warehouse),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedWarehouse = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: areaController,
                    decoration: InputDecoration(
                      labelText: 'Area',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.toggle_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(
                          value: 'on_leave', child: Text('On Leave')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _collector.name = nameController.text;
                    _collector.contact = contactController.text;
                    _collector.email = emailController.text;
                    _collector.warehouseName = selectedWarehouse;
                    _collector.area = areaController.text;
                    _collector.status = selectedStatus;
                  });
                  Navigator.pop(context);
                  _showSuccessSnackbar('Collector updated successfully');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
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

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Text('$feature - Coming Soon!'),
          ],
        ),
        backgroundColor: AdminColors.accentBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
