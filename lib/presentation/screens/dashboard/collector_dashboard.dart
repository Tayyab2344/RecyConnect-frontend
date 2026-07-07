import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/premium_design_system.dart';
import '../../widgets/premium/premium_components.dart';
import '../../widgets/skeleton_loader.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../collector/collector_map_screen.dart';
import '../auth/login_screen.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  final CollectorService _collectorService = CollectorService();
  final LocationService _locationService = LocationService();
  final PageController _pageController = PageController();

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isSyncingLocation = false;
  String? _error;
  Map<String, dynamic> _dashboard = {};
  Map<String, dynamic> _profile = {};
  List<dynamic> _tasks = [];
  List<dynamic> _history = [];
  Map<String, dynamic> _earnings = {};
  int _activeTasksTab = 0;
  List<dynamic> _availableTasks = [];

  static const List<String> _taskProgression = [
    'EN_ROUTE_TO_PICKUP',
    'ARRIVED_AT_SOURCE',
    'PICKED_UP',
    'IN_TRANSIT',
    'ARRIVED_AT_DESTINATION',
  ];

  @override
  void initState() {
    super.initState();
    _loadCollectorData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCollectorData({bool showSkeleton = true}) async {
    if (mounted && showSkeleton) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _collectorService.getDashboard(),
        _collectorService.getProfile(),
        _collectorService.getTasks(),
        _collectorService.getTasks(history: true),
        _collectorService.getEarnings(),
      ]);

      final profile = results[1] as Map<String, dynamic>;
      final isIndependent = profile['profile']?['collectorType'] == 'INDEPENDENT';

      List<dynamic> availableJobs = [];
      if (isIndependent) {
        try {
          availableJobs = await _collectorService.getAvailableTasks();
        } catch (e) {
          debugPrint('Error getting available tasks: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _profile = profile;
        _tasks = results[2] as List<dynamic>;
        _history = results[3] as List<dynamic>;
        _earnings = results[4] as Map<String, dynamic>;
        _availableTasks = availableJobs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  Future<void> _setAvailability(String status) async {
    _showLoadingDialog();
    try {
      await _collectorService.updateAvailability(
        availabilityStatus: status,
        dutyStatus: status == 'OFFLINE' ? 'OFF_DUTY' : 'ON_DUTY',
      );
      await _loadCollectorData(showSkeleton: false);
      if (mounted) Navigator.pop(context);
      _showMessage('Status updated');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _syncLocation({int? taskId, String? status, bool reload = true}) async {
    setState(() => _isSyncingLocation = true);
    try {
      final location = await _locationService.getCurrentLocationWithTimeout();
      if (location == null) {
        _showMessage('Unable to access current location', isError: true);
        return;
      }
      await _collectorService.recordLocation(
        taskId: taskId,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        status: status,
      );
      if (reload) {
        await _loadCollectorData(showSkeleton: false);
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSyncingLocation = false);
    }
  }

  /// Accept the task only (ASSIGNED → ACCEPTED) without starting the route.
  /// Lets the collector accept multiple orders and choose which to start.
  Future<void> _acceptTask(Map<String, dynamic> task) async {
    _showLoadingDialog();
    try {
      await _collectorService.acceptTask(task['id'] as int);
      await _loadCollectorData(showSkeleton: false);
      if (mounted) Navigator.pop(context);
      _showMessage('Task accepted — tap "Start Order" when ready');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showMessage(e.toString(), isError: true);
    }
  }

  /// Start the route for an already-accepted task (ACCEPTED → EN_ROUTE_TO_PICKUP).
  Future<void> _startRouteForTask(Map<String, dynamic> task) async {
    _showLoadingDialog();
    try {
      await _collectorService.updateTaskStatus(task['id'] as int, 'EN_ROUTE_TO_PICKUP');
      await _syncLocation(taskId: task['id'] as int, status: 'EN_ROUTE_TO_PICKUP', reload: false);
      await _loadCollectorData(showSkeleton: false);
      if (mounted) Navigator.pop(context);
      _showMessage('Route started');
      _goToTab(2); // Switch to the map screen
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _updateTaskStatus(Map<String, dynamic> task, String status) async {
    _showLoadingDialog();
    try {
      await _collectorService.updateTaskStatus(task['id'] as int, status);
      await _syncLocation(taskId: task['id'] as int, status: status, reload: false);
      await _loadCollectorData(showSkeleton: false);
      if (mounted) Navigator.pop(context);
      _showMessage(_statusLabel(status));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showMessage(e.toString(), isError: true);
    }
  }

  void _openMaps(Map<String, dynamic> task) {
    _goToTab(2); // Directly open the in-app map tab instead of Google Maps app
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
      ),
    );
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? SkeletonLoader.list()
          : _error != null
              ? _buildErrorState()
              : PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _selectedIndex = index),
                  children: [
                    _buildHomeScreen(),
                    _buildTasksScreen(),
                    _buildMapScreen(),
                    const MessagesScreen(),
                    _buildProfileScreen(),
                  ],
                ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textLight),
              const SizedBox(height: 16),
              Text(
                'Collector data is unavailable',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _error!.replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadCollectorData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    final auth = context.watch<AuthService>();
    final profile = (_dashboard['profile'] ?? _profile['profile']) as Map<String, dynamic>?;
    final summary = (_dashboard['summary'] ?? {}) as Map<String, dynamic>;
    final activeTasks = _tasks.where((task) => !_isTerminal(task['status']?.toString())).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCollectorData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTopBar(auth.userName ?? 'Collector'),
            const SizedBox(height: 16),
            _buildShiftCard(profile, summary),
            const SizedBox(height: 16),
            _buildStatsGrid(summary, activeTasks.length),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildSectionHeader('Active Route', action: 'View all', onTap: () => _goToTab(1)),
            const SizedBox(height: 10),
            if (activeTasks.isEmpty)
              _buildEmptyPanel('No active tasks', 'Assigned pickups and deliveries will appear here.')
            else
              ...activeTasks.take(3).map((task) => _buildTaskCard(task as Map<String, dynamic>, compact: true)),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String name) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Hero(
            tag: 'collector_avatar',
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: PremiumDesignSystem.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: PremiumDesignSystem.glowEffect(PremiumDesignSystem.primary, intensity: 0.2),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COLLECTOR CONSOLE',
                  style: PremiumDesignSystem.overline.copyWith(
                    color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PremiumDesignSystem.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              icon: Icon(
                Icons.notifications_none_outlined,
                color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
              ),
              tooltip: 'Notifications',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Map<String, dynamic>? profile, Map<String, dynamic> summary) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = summary['onlineStatus']?.toString() ??
        profile?['availabilityStatus']?.toString() ??
        'OFFLINE';
    final warehouse = profile?['warehouse'] as Map<String, dynamic>?;

    final isOffline = status == 'OFFLINE';
    final statusColor = _statusColor(status);

    return GlassCard(
      enableHover: true,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: PremiumDesignSystem.glowEffect(statusColor, intensity: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warehouse?['businessName'] ?? warehouse?['name'] ?? 'Assigned Warehouse',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PremiumDesignSystem.subtitle1.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field logistics & route verification',
                      style: PremiumDesignSystem.caption.copyWith(
                        color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: isOffline
                    ? PremiumButton(
                        text: 'Go On Duty',
                        icon: Icons.play_arrow_rounded,
                        gradient: PremiumDesignSystem.primaryGradient,
                        height: 48,
                        onPressed: () => _setAvailability('ON_DUTY'),
                      )
                    : Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: PremiumDesignSystem.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PremiumDesignSystem.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: PremiumDesignSystem.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'On Duty Active',
                              style: TextStyle(
                                color: PremiumDesignSystem.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Break mode',
                child: InkWell(
                  onTap: () => _setAvailability('BREAK'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.coffee_outlined,
                      color: status == 'BREAK' 
                          ? PremiumDesignSystem.accentOrange 
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Sync Location',
                child: InkWell(
                  onTap: _isSyncingLocation ? null : () => _syncLocation(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: _isSyncingLocation
                        ? const Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(PremiumDesignSystem.primary),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            color: _isSyncingLocation 
                                ? PremiumDesignSystem.primary 
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> summary, int activeCount) {
    final wallet = _earnings['wallet'] as Map<String, dynamic>? ?? {};

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      children: [
        PremiumStatCard(
          title: 'Active Route',
          value: '$activeCount',
          icon: Icons.route_outlined,
          gradient: PremiumDesignSystem.blueGradient,
          iconColor: PremiumDesignSystem.accentBlue,
        ),
        PremiumStatCard(
          title: 'Tasks Done',
          value: '${summary['completedTasks'] ?? _history.length}',
          icon: Icons.task_alt_rounded,
          gradient: PremiumDesignSystem.primaryGradient,
          iconColor: PremiumDesignSystem.primary,
        ),
        PremiumStatCard(
          title: 'Total Weight',
          value: '${_numText(summary['totalCollectedKg'])} kg',
          icon: Icons.scale_rounded,
          gradient: PremiumDesignSystem.orangeGradient,
          iconColor: PremiumDesignSystem.accentOrange,
        ),
        PremiumStatCard(
          title: 'Total Earned',
          value: 'Rs ${_numText(wallet['totalEarned'] ?? 0)}',
          icon: Icons.account_balance_wallet_rounded,
          gradient: PremiumDesignSystem.purpleGradient,
          iconColor: PremiumDesignSystem.accentPurple,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Task Console',
            Icons.assignment_outlined,
            () => _goToTab(1),
            gradient: PremiumDesignSystem.primaryGradient,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            'Live Map',
            Icons.map_outlined,
            () => _goToTab(2),
            gradient: PremiumDesignSystem.blueGradient,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            'SOS Alert',
            Icons.sos_outlined,
            _showSafetySheet,
            gradient: PremiumDesignSystem.errorGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {required Gradient gradient}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: PremiumDesignSystem.softShadowSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PremiumDesignSystem.subtitle2.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksScreen() {
    final active = _tasks.where((task) => !_isTerminal(task['status']?.toString())).toList();
    final isIndependent = _profile['profile']?['collectorType'] == 'INDEPENDENT';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCollectorData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildScreenTitle(isIndependent ? 'Logistics Board' : 'Assigned Tasks', isIndependent ? 'Freelance & dispatch hub' : '${active.length} active operations'),
            const SizedBox(height: 16),
            if (isIndependent) ...[
              _buildSegmentControl(),
              const SizedBox(height: 16),
            ],
            if (!isIndependent || _activeTasksTab == 0) ...[
              _buildSectionHeader('Active Assignments (${active.length})'),
              const SizedBox(height: 10),
              if (active.isEmpty)
                _buildEmptyPanel('No assigned tasks', 'No pickup or delivery assignments are active.')
              else
                ...active.map((task) => _buildTaskCard(task as Map<String, dynamic>)),
              const SizedBox(height: 16),
              _buildSectionHeader('Completed History'),
              const SizedBox(height: 10),
              if (_history.isEmpty)
                _buildEmptyPanel('No completed records', 'Completed deliveries will be stored here.')
              else
                ..._history.take(8).map((task) => _buildTaskCard(task as Map<String, dynamic>, history: true)),
            ] else ...[
              _buildSectionHeader('Available Freelance Jobs (${_availableTasks.length})'),
              const SizedBox(height: 10),
              if (_availableTasks.isEmpty)
                _buildEmptyPanel('No jobs available', 'There are no unclaimed tasks in your area.')
              else
                ..._availableTasks.map((task) => _buildAvailableTaskCard(task as Map<String, dynamic>)),
            ],
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentControl() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTasksTab = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _activeTasksTab == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _activeTasksTab == 0 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTasksTab = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _activeTasksTab == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  'Available Jobs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _activeTasksTab == 1 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTaskCard(Map<String, dynamic> task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final materialCategory = task['materialCategory'] ?? 'Material';
    final estimatedWeight = task['estimatedWeight'] ?? 0;
    final unit = task['unit'] ?? 'kg';
    final sourceAddress = task['sourceAddress'] ?? '';
    final destinationAddress = task['destinationAddress'] ?? '';
    final deliveryFee = task['deliveryFee'] ?? 0.0;

    return GlassCard(
      enableHover: true,
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$materialCategory pick up',
                style: PremiumDesignSystem.subtitle2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                ),
              ),
              Text(
                'Rs ${deliveryFee.toStringAsFixed(0)}',
                style: PremiumDesignSystem.subtitle2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.scale_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Weight: ${_numText(estimatedWeight)} $unit',
                style: PremiumDesignSystem.body2.copyWith(color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'From: $sourceAddress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PremiumDesignSystem.caption.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_outlined, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'To: $destinationAddress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PremiumDesignSystem.caption.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _claimAvailableTask(task['id'] as int),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Claim Pick Up Job', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimAvailableTask(int taskId) async {
    _showLoadingDialog();
    try {
      await _collectorService.acceptTask(taskId);
      await _loadCollectorData(showSkeleton: false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job claimed successfully! Check "My Tasks" to start navigation.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _activeTasksTab = 0);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _buildTaskCard(Map<String, dynamic> task, {bool compact = false, bool history = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = task['status']?.toString() ?? 'ASSIGNED';
    final statusColor = _statusColor(status);
    final taskType = task['taskType']?.toString();
    final materialCategory = task['materialCategory'] ?? 'Material';
    final estimatedWeight = task['estimatedWeight'];
    final unit = task['unit'] ?? 'kg';

    return GlassCard(
      enableHover: true,
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => _showTaskDetails(task),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _taskIcon(taskType),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _taskTypeLabel(taskType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumDesignSystem.subtitle2.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$materialCategory | ${_numText(estimatedWeight)} $unit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumDesignSystem.caption.copyWith(
                        color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 14),
          _buildAddressLine(Icons.trip_origin_rounded, task['sourceAddress']?.toString() ?? 'Pickup source'),
          const SizedBox(height: 8),
          _buildAddressLine(Icons.flag_rounded, task['destinationAddress']?.toString() ?? 'Destination'),
          if (!compact && !history) ...[
            const SizedBox(height: 14),
            _buildTaskActions(task),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskActions(Map<String, dynamic> task) {
    final status = task['status']?.toString() ?? 'ASSIGNED';

    // ── ASSIGNED: Accept or Decline ──
    if (status == 'ASSIGNED') {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _acceptTask(task),
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Decline Assignment'),
                  content: const Text('Are you sure you want to decline this delivery assignment?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Decline', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                _updateTaskStatus(task, 'REJECTED');
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            child: const Text('Decline'),
          ),
        ],
      );
    }

    // ── ACCEPTED: Start Order (collector chooses when to begin) ──
    if (status == 'ACCEPTED') {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _startRouteForTask(task),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Order'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => _openMaps(task),
            icon: const Icon(Icons.navigation_outlined),
          ),
        ],
      );
    }

    if (status == 'VERIFIED') {
      return _wideAction('Confirm pickup', Icons.inventory_2_outlined, () => _updateTaskStatus(task, 'PICKED_UP'));
    }

    if (status == 'ARRIVED_AT_DESTINATION') {
      return _wideAction('Delivery confirmation', Icons.fact_check_outlined, () => _showDeliveryDialog(task));
    }

    final next = _nextStatus(status);
    if (next == 'VERIFY') {
      return _wideAction('Verify weight and material', Icons.scale_outlined, () => _showVerificationDialog(task));
    }
    if (next != null) {
      return _wideAction(_statusActionLabel(next), Icons.arrow_forward, () => _updateTaskStatus(task, next));
    }

    return _wideAction('Open built-in map', Icons.map_outlined, () => _openMaps(task));
  }

  Widget _wideAction(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildMapScreen() {
    final active = _tasks.where((task) => !_isTerminal(task['status']?.toString())).toList();
    final current = active.isEmpty ? null : active.first as Map<String, dynamic>;

    if (current == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_outlined, size: 64, color: AppTheme.textLight),
                const SizedBox(height: 16),
                Text(
                  'No Active Route Available',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign a task or accept an en-route job to access real-time map tracking & turn-by-turn navigation.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadCollectorData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CollectorMapScreen(
      task: current,
      onBack: () => _goToTab(0),
      onTaskUpdated: _loadCollectorData,
    );
  }

  Widget _buildProfileScreen() {
    final profile = (_profile['profile'] ?? _dashboard['profile']) as Map<String, dynamic>?;
    final user = profile?['user'] as Map<String, dynamic>? ?? context.watch<AuthService>().currentUser ?? {};
    final warehouse = profile?['warehouse'] as Map<String, dynamic>?;
    final wallet = _earnings['wallet'] as Map<String, dynamic>? ?? {};
    final earningsList = _earnings['earnings'] as List<dynamic>? ?? [];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCollectorData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildScreenTitle('Profile', user['collectorId']?.toString() ?? 'Collector account'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.earthBrown.withValues(alpha: 0.12),
                    child: const Icon(Icons.person, color: AppTheme.earthBrown, size: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user['name']?.toString() ?? 'Collector',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    user['contactNo']?.toString() ?? user['phone']?.toString() ?? 'No contact number',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileTile(Icons.badge_outlined, 'Employee ID', user['collectorId']?.toString() ?? profile?['employeeId']?.toString() ?? '-'),
            _buildProfileTile(Icons.warehouse_outlined, 'Warehouse', warehouse?['businessName']?.toString() ?? warehouse?['name']?.toString() ?? '-'),
            _buildProfileTile(Icons.verified_user_outlined, 'Reliability', '${_numText(profile?['reliabilityScore'] ?? 100)}%'),
            _buildProfileTile(Icons.task_alt, 'Completed Tasks', '${profile?['completedTasks'] ?? _history.length}'),
            _buildProfileTile(Icons.scale_outlined, 'Collected Weight', '${_numText(profile?['totalCollectedKg'])} kg'),
            const SizedBox(height: 16),

            // ── Earnings Wallet Section ──
            _buildSectionHeader('Earnings Wallet'),
            const SizedBox(height: 10),
            _buildEarningsWallet(wallet, earningsList),
            const SizedBox(height: 16),
            _buildSafetyPanel(),
            const SizedBox(height: 16),
            _buildLogoutTile(),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  // ── Earnings Wallet Widget ──
  Widget _buildEarningsWallet(Map<String, dynamic> wallet, List<dynamic> earningsList) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${_numText(wallet['totalEarned'] ?? 0)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          'Rs ${_numText(wallet['pendingAmount'] ?? 0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.white30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paid', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          'Rs ${_numText(wallet['paidAmount'] ?? 0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (earningsList.isEmpty)
          _buildEmptyPanel('No earnings yet', 'Complete deliveries to start earning.')
        else
          ...earningsList.take(5).map((e) {
            final earning = e as Map<String, dynamic>;
            final task = earning['task'] as Map<String, dynamic>? ?? {};
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: (earning['status'] == 'PAID' ? AppTheme.primaryGreen : AppTheme.warningOrange).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      earning['status'] == 'PAID' ? Icons.check_circle_outline : Icons.schedule,
                      color: earning['status'] == 'PAID' ? AppTheme.primaryGreen : AppTheme.warningOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _taskTypeLabel(task['taskType']?.toString()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          task['materialCategory']?.toString() ?? 'Task #${earning['taskId']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs ${_numText(earning['amount'])}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Report unsafe pickup conditions, blocked routes, unavailable customers, or emergency incidents from the field.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showSafetySheet,
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Report issue'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.16)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _showLogoutDialog,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.logout, color: AppTheme.errorRed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.errorRed,
                        ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.errorRed),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: AppTheme.errorRed),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout from your collector account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textLight)),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop(); // Pop the logout dialog
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _buildScreenTitle(_taskTypeLabel(task['taskType']?.toString()), _statusLabel(task['status']?.toString())),
            const SizedBox(height: 12),
            _buildDetailBlock('Pickup Source', [
              task['sourceName']?.toString(),
              task['sourceContact']?.toString(),
              task['sourceAddress']?.toString(),
            ]),
            _buildDetailBlock('Destination', [
              task['destinationName']?.toString(),
              task['destinationContact']?.toString(),
              task['destinationAddress']?.toString(),
            ]),
            _buildDetailBlock('Waste Information', [
              '${task['materialCategory'] ?? 'Material'} ${task['materialType'] ?? ''}'.trim(),
              '${_numText(task['estimatedWeight'])} ${task['unit'] ?? 'kg'} listed weight',
              task['notes']?.toString(),
              task['instructions']?.toString(),
            ]),
            const SizedBox(height: 12),
            _buildTaskActions(task),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBlock(String title, List<String?> lines) {
    final visibleLines = lines.where((line) => line != null && line.trim().isNotEmpty).cast<String>().toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...visibleLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight)),
            ),
          ),
        ],
      ),
    );
  }

  // ── VERIFICATION DIALOG (with camera proof photo) ──
  void _showVerificationDialog(Map<String, dynamic> task) {
    final weightController = TextEditingController(text: _numText(task['estimatedWeight']));
    final categoryController = TextEditingController(text: task['materialCategory']?.toString() ?? '');
    final materialController = TextEditingController(text: task['materialType']?.toString() ?? '');
    final notesController = TextEditingController();
    List<XFile> proofFiles = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Verify Waste'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Verified weight (kg)', prefixIcon: Icon(Icons.scale_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Verified category', prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: materialController,
                  decoration: const InputDecoration(labelText: 'Material type', prefixIcon: Icon(Icons.recycling)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes_outlined)),
                ),
                const SizedBox(height: 14),
                // Proof Photo Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text('Proof Photos (${proofFiles.length})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                              if (image != null) {
                                setDialogState(() => proofFiles.add(image));
                              }
                            },
                            icon: const Icon(Icons.add_a_photo, size: 16),
                            label: const Text('Take Photo', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      if (proofFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: proofFiles.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(File(proofFiles[i].path), width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => proofFiles.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final weight = double.tryParse(weightController.text.trim());
                if (weight == null || weight <= 0) {
                  _showMessage('Enter a valid verified weight', isError: true);
                  return;
                }
                if (proofFiles.isEmpty) {
                  _showMessage('Proof photo is required. Please take a picture of the weighing scale.', isError: true);
                  return;
                }
                Navigator.pop(context);
                try {
                  await _collectorService.verifyWaste(
                    taskId: task['id'] as int,
                    verifiedWeight: weight,
                    verifiedCategory: categoryController.text.trim(),
                    verifiedMaterial: materialController.text.trim(),
                    notes: notesController.text.trim(),
                    proofFiles: proofFiles,
                  );
                  await _loadCollectorData();
                  _showMessage('Waste verified');
                } catch (e) {
                  _showMessage(e.toString(), isError: true);
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  // ── DELIVERY DIALOG (with OTP + camera proof) ──
  void _showDeliveryDialog(Map<String, dynamic> task) {
    final receiverController = TextEditingController(text: task['destinationName']?.toString() ?? '');
    final contactController = TextEditingController(text: task['destinationContact']?.toString() ?? '');
    final weightController = TextEditingController(text: _numText(task['verification']?['verifiedWeight'] ?? task['estimatedWeight']));
    final conditionController = TextEditingController(text: 'Good');
    final notesController = TextEditingController();
    final otpController = TextEditingController();
    List<XFile> proofFiles = [];
    final bool hasOtp = task['hasOtp'] == true; // Disabled PIN verification per request

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Confirm Delivery'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // OTP PIN Entry
                if (hasOtp) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.pin_outlined, size: 18, color: AppTheme.warningOrange),
                            const SizedBox(width: 8),
                            const Text('Delivery PIN Required', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask the receiver for the 4-digit delivery PIN to confirm handover.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 12),
                          decoration: const InputDecoration(
                            hintText: '● ● ● ●',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(controller: receiverController, decoration: const InputDecoration(labelText: 'Receiver name')),
                const SizedBox(height: 10),
                TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Receiver contact')),
                const SizedBox(height: 10),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Received weight (kg)'),
                ),
                const SizedBox(height: 10),
                TextField(controller: conditionController, decoration: const InputDecoration(labelText: 'Package condition')),
                const SizedBox(height: 10),
                TextField(controller: notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
                const SizedBox(height: 14),
                // Proof Photo Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.infoBlue),
                          const SizedBox(width: 8),
                          Text('Delivery Proof (${proofFiles.length})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                              if (image != null) {
                                setDialogState(() => proofFiles.add(image));
                              }
                            },
                            icon: const Icon(Icons.add_a_photo, size: 16),
                            label: const Text('Take Photo', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      if (proofFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: proofFiles.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(File(proofFiles[i].path), width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => proofFiles.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (hasOtp && otpController.text.trim().length != 4) {
                  _showMessage('Enter the 4-digit delivery PIN', isError: true);
                  return;
                }
                Navigator.pop(context);
                try {
                  await _collectorService.confirmDelivery(
                    taskId: task['id'] as int,
                    receiverName: receiverController.text.trim(),
                    receiverContact: contactController.text.trim(),
                    receivedWeight: double.tryParse(weightController.text.trim()),
                    packageCondition: conditionController.text.trim(),
                    notes: notesController.text.trim(),
                    receiverConfirmation: 'CONFIRMED_BY_COLLECTOR',
                    otpCode: otpController.text.trim(),
                    proofFiles: proofFiles,
                  );
                  await _loadCollectorData();
                  _showMessage('Delivery completed');
                } catch (e) {
                  _showMessage(e.toString(), isError: true);
                }
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  // ── SAFETY / INCIDENT REPORTING SHEET (operational form) ──
  void _showSafetySheet() {
    final descriptionController = TextEditingController();
    String? selectedType;
    XFile? proofImage;
    final activeTasks = _tasks.where((task) => !_isTerminal(task['status']?.toString())).toList();
    final activeTaskId = activeTasks.isNotEmpty ? activeTasks.first['id'] as int? : null;

    const incidentTypes = [
      'Customer unavailable',
      'Unsafe pickup site',
      'Route blocked',
      'Vehicle breakdown',
      'Material mismatch',
      'Emergency support',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScreenTitle('Report Incident', 'File a safety or logistics incident'),
              const SizedBox(height: 16),
              // Incident type selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: incidentTypes.map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? AppTheme.errorRed 
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.errorRed.withValues(alpha: 0.16),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[200],
                    onSelected: (selected) {
                      setSheetState(() => selectedType = selected ? type : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Describe the incident',
                  hintText: 'Provide details about the situation...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 14),
              // Proof photo
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                      if (image != null) {
                        setSheetState(() => proofImage = image);
                      }
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(proofImage == null ? 'Add Photo Proof' : 'Photo Added ✓'),
                  ),
                  if (proofImage != null) ...[
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(proofImage!.path), width: 44, height: 44, fit: BoxFit.cover),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (selectedType == null) {
                      _showMessage('Select an incident type', isError: true);
                      return;
                    }
                    if (descriptionController.text.trim().isEmpty) {
                      _showMessage('Provide a description', isError: true);
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      await _collectorService.reportIncident(
                        taskId: activeTaskId,
                        type: selectedType!,
                        description: descriptionController.text.trim(),
                        proofImage: proofImage,
                      );
                      _showMessage('Incident reported for warehouse review');
                    } catch (e) {
                      _showMessage(e.toString(), isError: true);
                    }
                  },
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit Report'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? action, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: PremiumDesignSystem.h4.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: PremiumDesignSystem.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action,
                  style: PremiumDesignSystem.subtitle2.copyWith(
                    color: PremiumDesignSystem.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyPanel(String title, String subtitle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      enableHover: false,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 28,
              color: isDark ? PremiumDesignSystem.darkTextTertiary : PremiumDesignSystem.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PremiumDesignSystem.subtitle1.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? PremiumDesignSystem.darkTextPrimary : PremiumDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PremiumDesignSystem.caption.copyWith(
              color: isDark ? PremiumDesignSystem.darkTextSecondary : PremiumDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryGreen,
      unselectedItemColor: AppTheme.textLight,
      onTap: _goToTab,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  String? _nextStatus(String status) {
    if (status == 'ARRIVED_AT_SOURCE') return 'VERIFY';
    final index = _taskProgression.indexOf(status);
    if (index == -1 || index == _taskProgression.length - 1) return null;
    return _taskProgression[index + 1];
  }

  bool _isTerminal(String? status) => ['COMPLETED', 'CANCELLED', 'REJECTED'].contains(status);

  String _statusLabel(String? status) {
    final value = (status ?? '').replaceAll('_', ' ').toLowerCase();
    if (value.isEmpty) return 'Unknown';
    return value.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  String _statusActionLabel(String status) {
    switch (status) {
      case 'EN_ROUTE_TO_PICKUP':
        return 'Start navigation';
      case 'ARRIVED_AT_SOURCE':
        return 'Mark arrived';
      case 'PICKED_UP':
        return 'Confirm pickup';
      case 'IN_TRANSIT':
        return 'Start transport';
      case 'ARRIVED_AT_DESTINATION':
        return 'Arrived at destination';
      default:
        return _statusLabel(status);
    }
  }

  String _taskTypeLabel(String? type) {
    switch (type) {
      case 'SELLER_TO_WAREHOUSE':
        return 'Seller to Warehouse';
      case 'SELLER_TO_BUYER':
        return 'Seller to Buyer';
      case 'WAREHOUSE_TO_BUYER':
        return 'Warehouse to Buyer';
      case 'BUYER_REQUESTED_PICKUP':
        return 'Buyer Requested Pickup';
      default:
        return 'Collector Task';
    }
  }

  IconData _taskIcon(String? type) {
    switch (type) {
      case 'WAREHOUSE_TO_BUYER':
        return Icons.warehouse_outlined;
      case 'SELLER_TO_BUYER':
        return Icons.local_shipping_outlined;
      case 'BUYER_REQUESTED_PICKUP':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.recycling;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'ASSIGNED':
        return AppTheme.warningOrange;
      case 'ACCEPTED':
      case 'EN_ROUTE_TO_PICKUP':
      case 'IN_TRANSIT':
        return AppTheme.infoBlue;
      case 'ARRIVED_AT_SOURCE':
      case 'VERIFIED':
      case 'PICKED_UP':
      case 'ARRIVED_AT_DESTINATION':
        return AppTheme.earthBrown;
      case 'COMPLETED':
      case 'DELIVERED':
      case 'ONLINE':
      case 'ON_DUTY':
        return AppTheme.primaryGreen;
      case 'CANCELLED':
      case 'REJECTED':
      case 'OFFLINE':
        return AppTheme.errorRed;
      case 'BREAK':
        return AppTheme.warningOrange;
      default:
        return AppTheme.textLight;
    }
  }

  String _numText(dynamic value) {
    if (value == null) return '0';
    final number = value is num ? value : num.tryParse(value.toString());
    if (number == null) return value.toString();
    return number % 1 == 0 ? number.toInt().toString() : number.toStringAsFixed(1);
  }
}


