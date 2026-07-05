import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/collector_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import 'collector_tracking_screen.dart';

class WarehouseDispatchDashboard extends StatefulWidget {
  const WarehouseDispatchDashboard({super.key});

  @override
  State<WarehouseDispatchDashboard> createState() => _WarehouseDispatchDashboardState();
}

class _WarehouseDispatchDashboardState extends State<WarehouseDispatchDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final CollectorService _collectorService = CollectorService();

  List<dynamic> _pendingRequests = [];
  List<dynamic> _allDispatches = [];
  List<dynamic> _collectors = [];

  bool _isLoadingPending = false;
  bool _isLoadingDispatches = false;
  bool _isLoadingCollectors = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadPendingRequests();
    _loadAllDispatches();
    _loadCollectors();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoadingPending = true);
    try {
      final response = await _apiService.get('/dispatch/pending');
      if (response['success'] == true) {
        setState(() {
          _pendingRequests = response['data'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading pending dispatches: $e');
    } finally {
      setState(() => _isLoadingPending = false);
    }
  }

  Future<void> _loadAllDispatches() async {
    setState(() => _isLoadingDispatches = true);
    try {
      final response = await _apiService.get('/dispatch/my-dispatches');
      if (response['success'] == true) {
        setState(() {
          _allDispatches = response['data'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading dispatches: $e');
    } finally {
      setState(() => _isLoadingDispatches = false);
    }
  }

  Future<void> _loadCollectors() async {
    setState(() => _isLoadingCollectors = true);
    try {
      final data = await _collectorService.getCollectors();
      setState(() {
        _collectors = data;
      });
    } catch (e) {
      debugPrint('Error loading collectors: $e');
    } finally {
      setState(() => _isLoadingCollectors = false);
    }
  }

  Future<void> _respondToRequest(int dispatchId, String action) async {
    try {
      final response = await _apiService.post('/dispatch/$dispatchId/respond', {
        'action': action,
      });
      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${action == 'ACCEPT' ? 'accepted' : 'rejected'} successfully.')),
        );
        _loadAllData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to respond: $e')),
      );
    }
  }

  Future<void> _assignCollector(int dispatchId, int? collectorId) async {
    try {
      final response = await _apiService.post('/dispatch/$dispatchId/assign-collector', {
        if (collectorId != null) 'collectorId': collectorId,
      });
      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collector assigned successfully.')),
        );
        _loadAllData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign collector: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistics & Dispatch Manager'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: isDark ? Colors.white : Colors.black,
          tabs: const [
            Tab(text: 'New Requests', icon: Icon(Icons.notifications_active_outlined)),
            Tab(text: 'Assign Jobs', icon: Icon(Icons.assignment_outlined)),
            Tab(text: 'Ongoing Tasks', icon: Icon(Icons.local_shipping_outlined)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNewRequestsTab(isDark, accentColor),
            _buildAssignJobsTab(isDark, accentColor),
            _buildOngoingTab(isDark, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRequestsTab(bool isDark, Color accentColor) {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState('No pending delivery requests', Icons.mark_email_read_outlined, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final req = _pendingRequests[index];
        final order = req['order'] ?? {};
        final items = order['items'] as List<dynamic>? ?? [];
        final material = items.isNotEmpty ? (items[0]['listing']?['category'] ?? 'Recyclables') : 'Recyclables';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request #${req['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildInfoRow('Seller:', order['seller']?['name'] ?? 'Household Seller'),
                _buildInfoRow('Pickup:', req['pickupLocation'] ?? 'Seller Address'),
                const SizedBox(height: 6),
                _buildInfoRow('Buyer:', order['buyer']?['name'] ?? 'Household Buyer'),
                _buildInfoRow('Deliver To:', req['deliveryLocation'] ?? 'Buyer Address'),
                const SizedBox(height: 6),
                _buildInfoRow('Material:', material),
                _buildInfoRow('Distance:', '${req['estimatedDistance'] ?? '0'} km'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _respondToRequest(req['id'], 'REJECT'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject & Route Next'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _respondToRequest(req['id'], 'ACCEPT'),
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                        child: const Text('Accept Logistics'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignJobsTab(bool isDark, Color accentColor) {
    final unassigned = _allDispatches.where((d) => d['dispatchStatus'] == 'ACCEPTED' && d['collectorId'] == null).toList();

    if (_isLoadingDispatches) {
      return const Center(child: CircularProgressIndicator());
    }
    if (unassigned.isEmpty) {
      return _buildEmptyState('No accepted orders waiting for assignment', Icons.check_circle_outline, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unassigned.length,
      itemBuilder: (context, index) {
        final job = unassigned[index];
        final order = job['order'] ?? {};
        final sellerName = order['seller']?['name'] ?? 'Seller';
        final buyerName = order['buyer']?['name'] ?? 'Buyer';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dispatch Job #${job['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      icon: const Icon(Icons.flash_on, size: 16, color: Colors.amber),
                      label: const Text('Auto-Assign Nearest', style: TextStyle(fontSize: 11)),
                      onPressed: () => _assignCollector(job['id'], null),
                    ),
                  ],
                ),
                const Divider(height: 16),
                _buildInfoRow('From Seller:', sellerName),
                _buildInfoRow('To Buyer:', buyerName),
                _buildInfoRow('Est. Distance:', '${job['estimatedDistance'] ?? 0} km'),
                const SizedBox(height: 12),
                const Text(
                  'Select Collector to Dispatch:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _isLoadingCollectors
                    ? const Center(child: LinearProgressIndicator())
                    : _collectors.isEmpty
                        ? Text(
                            'No collectors registered. Add collectors under the Collectors tab on dashboard.',
                            style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _collectors.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, cIdx) {
                              final col = _collectors[cIdx];
                              final isOnline = col['availabilityStatus'] == 'ONLINE' || col['availabilityStatus'] == 'ON_DUTY';
                              final activeTasks = col['activeOrdersCount'] ?? 0;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? Colors.white.withValues(alpha: 0.01) : Colors.black.withValues(alpha: 0.01),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 4,
                                      backgroundColor: isOnline ? Colors.green : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            col['user']?['name'] ?? 'Collector',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          Text(
                                            'Vehicle: ${col['vehicleType'] ?? 'Motorcycle'} | Active: $activeTasks',
                                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        minimumSize: Size.zero,
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: isOnline ? () => _assignCollector(job['id'], col['userId']) : null,
                                      child: const Text('Assign', style: TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOngoingTab(bool isDark, Color accentColor) {
    final ongoing = _allDispatches.where((d) => 
      d['dispatchStatus'] != 'PENDING_ACCEPTANCE' && 
      d['dispatchStatus'] != 'ACCEPTED' && 
      d['dispatchStatus'] != 'COMPLETED' && 
      d['dispatchStatus'] != 'REJECTED' && 
      d['dispatchStatus'] != 'CANCELLED'
    ).toList();

    if (_isLoadingDispatches) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ongoing.isEmpty) {
      return _buildEmptyState('No ongoing logistics deliveries at this moment', Icons.local_shipping_outlined, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ongoing.length,
      itemBuilder: (context, index) {
        final task = ongoing[index];
        final order = task['order'] ?? {};
        final collectorName = task['collector']?['name'] ?? 'Assigned Collector';
        final status = task['dispatchStatus']?.toString().replaceAll('_', ' ') ?? 'ASSIGNED';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Task #${task['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                _buildInfoRow('Seller:', order['seller']?['name'] ?? 'Seller'),
                _buildInfoRow('Buyer:', order['buyer']?['name'] ?? 'Buyer'),
                _buildInfoRow('Collector:', collectorName),
                _buildInfoRow('Contact:', task['collector']?['contactNo'] ?? 'No phone'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Track Live Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 38),
                  ),
                  onPressed: () {
                    final colMap = {
                      'userId': task['collectorId'],
                      'id': task['collectorId'],
                      'user': {
                        'name': collectorName,
                        'contactNo': task['collector']?['contactNo'],
                      }
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectorTrackingScreen(collector: colMap),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
