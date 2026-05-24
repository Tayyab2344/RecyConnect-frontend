import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/recycle_loader.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../collector/collector_map_screen.dart';

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

  Future<void> _loadCollectorData() async {
    if (mounted) {
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

      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _profile = results[1] as Map<String, dynamic>;
        _tasks = results[2] as List<dynamic>;
        _history = results[3] as List<dynamic>;
        _earnings = results[4] as Map<String, dynamic>;
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

  Future<void> _setAvailability(String status) async {
    try {
      await _collectorService.updateAvailability(
        availabilityStatus: status,
        dutyStatus: status == 'OFFLINE' ? 'OFF_DUTY' : 'ON_DUTY',
      );
      await _loadCollectorData();
      _showMessage('Status updated');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _syncLocation({int? taskId, String? status}) async {
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
      await _loadCollectorData();
      _showMessage('Location synced');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSyncingLocation = false);
    }
  }

  Future<void> _acceptTask(Map<String, dynamic> task) async {
    try {
      await _collectorService.acceptTask(task['id'] as int);
      await _loadCollectorData();
      _showMessage('Task accepted');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _updateTaskStatus(Map<String, dynamic> task, String status) async {
    try {
      await _collectorService.updateTaskStatus(task['id'] as int, status);
      await _syncLocation(taskId: task['id'] as int, status: status);
      await _loadCollectorData();
      _showMessage(_statusLabel(status));
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _openMaps(Map<String, dynamic> task, {bool destination = false}) async {
    final latKey = destination ? 'destinationLatitude' : 'sourceLatitude';
    final lngKey = destination ? 'destinationLongitude' : 'sourceLongitude';
    final addressKey = destination ? 'destinationAddress' : 'sourceAddress';

    final lat = task[latKey];
    final lng = task[lngKey];
    final query = lat != null && lng != null
        ? '$lat,$lng'
        : Uri.encodeComponent(task[addressKey]?.toString() ?? '');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Unable to open maps', isError: true);
    }
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
          ? const Center(child: RecycleLoader())
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
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppTheme.earthBrown.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_shipping_outlined, color: AppTheme.earthBrown),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collector Console',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildShiftCard(Map<String, dynamic>? profile, Map<String, dynamic> summary) {
    final status = summary['onlineStatus']?.toString() ??
        profile?['availabilityStatus']?.toString() ??
        'OFFLINE';
    final warehouse = profile?['warehouse'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse?['businessName'] ?? warehouse?['name'] ?? 'Assigned warehouse',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field logistics and verification',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _setAvailability(status == 'OFFLINE' ? 'ON_DUTY' : 'OFFLINE'),
                  icon: Icon(status == 'OFFLINE' ? Icons.play_arrow : Icons.pause),
                  label: Text(status == 'OFFLINE' ? 'Check in' : 'Check out'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Break mode',
                onPressed: () => _setAvailability('BREAK'),
                icon: const Icon(Icons.coffee_outlined),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Sync location',
                onPressed: _isSyncingLocation ? null : () => _syncLocation(),
                icon: _isSyncingLocation
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> summary, int activeCount) {
    final wallet = _earnings['wallet'] as Map<String, dynamic>? ?? {};
    final stats = [
      _StatData('Active', '$activeCount', Icons.route_outlined, AppTheme.infoBlue),
      _StatData('Done', '${summary['completedTasks'] ?? _history.length}', Icons.task_alt, AppTheme.primaryGreen),
      _StatData('Weight', '${_numText(summary['totalCollectedKg'])} kg', Icons.scale_outlined, AppTheme.earthBrown),
      _StatData('Earnings', 'Rs ${_numText(wallet['totalEarned'] ?? 0)}', Icons.account_balance_wallet_outlined, AppTheme.accentPurple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (_, index) => _buildStatTile(stats[index]),
    );
  }

  Widget _buildStatTile(_StatData stat) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(stat.icon, color: stat.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Tasks', Icons.assignment_outlined, () => _goToTab(1))),
        const SizedBox(width: 10),
        Expanded(child: _buildActionButton('Map', Icons.map_outlined, () => _goToTab(2))),
        const SizedBox(width: 10),
        Expanded(child: _buildActionButton('SOS', Icons.sos_outlined, _showSafetySheet, color: AppTheme.errorRed)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    final resolvedColor = color ?? AppTheme.primaryGreen;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: resolvedColor),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        foregroundColor: resolvedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTasksScreen() {
    final active = _tasks.where((task) => !_isTerminal(task['status']?.toString())).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCollectorData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildScreenTitle('Assigned Tasks', '${active.length} active operations'),
            const SizedBox(height: 16),
            if (active.isEmpty)
              _buildEmptyPanel('No assigned tasks', 'Your warehouse has not assigned a pickup or delivery yet.')
            else
              ...active.map((task) => _buildTaskCard(task as Map<String, dynamic>)),
            const SizedBox(height: 16),
            _buildSectionHeader('History'),
            const SizedBox(height: 10),
            if (_history.isEmpty)
              _buildEmptyPanel('No completed records', 'Completed deliveries will be stored here.')
            else
              ..._history.take(8).map((task) => _buildTaskCard(task as Map<String, dynamic>, history: true)),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, {bool compact = false, bool history = false}) {
    final status = task['status']?.toString() ?? 'ASSIGNED';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_taskIcon(task['taskType']?.toString()), color: color, size: 20),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${task['materialCategory'] ?? 'Material'} | ${_numText(task['estimatedWeight'])} ${task['unit'] ?? 'kg'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 12),
              _buildAddressLine(Icons.trip_origin, task['sourceAddress']?.toString() ?? 'Pickup source'),
              const SizedBox(height: 6),
              _buildAddressLine(Icons.flag_outlined, task['destinationAddress']?.toString() ?? 'Destination'),
              if (!compact && !history) ...[
                const SizedBox(height: 12),
                _buildTaskActions(task),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskActions(Map<String, dynamic> task) {
    final status = task['status']?.toString() ?? 'ASSIGNED';
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

    return _wideAction('Open navigation', Icons.navigation_outlined, () => _openMaps(task));
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
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.earthBrown.withOpacity(0.12),
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
              colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.7)],
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
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: (earning['status'] == 'PAID' ? AppTheme.primaryGreen : AppTheme.warningOrange).withOpacity(0.12),
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
        color: AppTheme.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.16)),
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
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
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
                    color: AppTheme.primaryGreen.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
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
    final bool hasOtp = task['otpCode'] != null;

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
                      color: AppTheme.warningOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warningOrange.withOpacity(0.2)),
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
                    color: AppTheme.infoBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.infoBlue.withOpacity(0.2)),
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
                children: incidentTypes.map((type) => ChoiceChip(
                  label: Text(type, style: const TextStyle(fontSize: 12)),
                  selected: selectedType == type,
                  selectedColor: AppTheme.errorRed.withOpacity(0.16),
                  onSelected: (selected) {
                    setSheetState(() => selectedType = selected ? type : null);
                  },
                )).toList(),
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
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(action),
          ),
      ],
    );
  }

  Widget _buildEmptyPanel(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: AppTheme.textLight),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
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
        color: color.withOpacity(0.12),
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

class _StatData {
  const _StatData(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _RoutePreviewPainter extends CustomPainter {
  const _RoutePreviewPainter({required this.lineColor, required this.nodeColor});

  final Color lineColor;
  final Color nodeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.18, size.width * 0.54, size.height * 0.48)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.76, size.width * 0.86, size.height * 0.26);
    canvas.drawPath(path, paint);

    final nodePaint = Paint()..color = nodeColor;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.72), 8, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.26), 8, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
