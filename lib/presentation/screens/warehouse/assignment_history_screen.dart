import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/collector_service.dart';
import '../../../core/theme/app_theme.dart';

class AssignmentHistoryScreen extends StatefulWidget {
  const AssignmentHistoryScreen({super.key});

  @override
  State<AssignmentHistoryScreen> createState() => _AssignmentHistoryScreenState();
}

class _AssignmentHistoryScreenState extends State<AssignmentHistoryScreen> {
  final CollectorService _collectorService = CollectorService();
  
  List<dynamic> _trips = [];
  List<dynamic> _collectors = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  int? _selectedCollectorId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchCollectors();
    _fetchHistory();
  }

  Future<void> _fetchCollectors() async {
    try {
      final list = await _collectorService.getCollectors();
      setState(() {
        _collectors = list;
      });
    } catch (e) {
      debugPrint('Failed to load collectors list: $e');
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? startStr;
      String? endStr;
      if (_startDate != null) {
        startStr = _startDate!.toIso8601String();
      }
      if (_endDate != null) {
        // End of the day
        endStr = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59).toIso8601String();
      }

      final list = await _collectorService.getWarehouseTrips(
        collectorId: _selectedCollectorId,
        status: _selectedStatus,
        startDate: startStr,
        endDate: endStr,
      );

      setState(() {
        _trips = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load assignment history: $e';
        _isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCollectorId = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _fetchHistory();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment History'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Collector filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCollectorId,
                        decoration: InputDecoration(
                          labelText: 'Collector',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('All Collectors'),
                          ),
                          ..._collectors.map((c) {
                            final userObj = c['user'] as Map<String, dynamic>? ?? c;
                            return DropdownMenuItem<int>(
                              value: userObj['id'] as int,
                              child: Text(userObj['name'] ?? 'Collector'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCollectorId = val);
                          _fetchHistory();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Status filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem<String>(value: null, child: Text('All Statuses')),
                          DropdownMenuItem<String>(value: 'ASSIGNED', child: Text('Assigned')),
                          DropdownMenuItem<String>(value: 'IN_TRANSIT', child: Text('In Transit')),
                          DropdownMenuItem<String>(value: 'COMPLETED', child: Text('Completed')),
                          DropdownMenuItem<String>(value: 'CANCELLED', child: Text('Cancelled')),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedStatus = val);
                          _fetchHistory();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Date range picker trigger button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
                              : 'Select Date Range',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          foregroundColor: AppTheme.primaryGreen,
                          side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Reset filters
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // History Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _trips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No records match filters',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _trips.length,
                            itemBuilder: (context, index) {
                              final trip = _trips[index];
                              final collectorName = trip['collector']?['name'] ?? 'Unknown Collector';
                              final collectorId = trip['collector']?['collectorId'] ?? 'N/A';
                              final status = trip['status'] ?? 'UNKNOWN';
                              final DateTime date = DateTime.parse(trip['createdAt']);
                              final tasks = List<dynamic>.from(trip['tasks'] ?? []);
                              final double distance = (trip['totalDistance'] ?? 0).toDouble();

                              Color statusColor = Colors.grey;
                              if (status == 'COMPLETED') statusColor = Colors.green;
                              if (status == 'ASSIGNED') statusColor = Colors.blue;
                              if (status == 'IN_TRANSIT') statusColor = Colors.orange;
                              if (status == 'CANCELLED') statusColor = Colors.red;

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Trip #${trip['id']}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Collector: $collectorName ($collectorId)',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Dispatched: ${_dateFormatter.format(date)}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          Text(
                                            'Stops: ${tasks.length} • Est. Distance: ${distance.toStringAsFixed(1)} km',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      const Divider(height: 1),
                                      Container(
                                        color: Colors.grey[50],
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Route Sequence details:',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 8),
                                            ...tasks.map((task) {
                                              final taskStatus = task['status'] ?? 'ASSIGNED';
                                              final taskWeight = task['estimatedWeight'] ?? 0;
                                              final taskCategory = task['materialCategory'] ?? 'Recyclable';
                                              final isDelivered = taskStatus == 'COMPLETED';

                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isDelivered ? Icons.check_circle : Icons.radio_button_unchecked,
                                                      color: isDelivered ? Colors.green : Colors.grey,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Order #${task['orderId']}: $taskCategory ($taskWeight kg)',
                                                        style: const TextStyle(fontSize: 13),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: isDelivered ? Colors.green : Colors.grey),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        taskStatus.toString().replaceAll('_', ' '),
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          color: isDelivered ? Colors.green : Colors.grey[700],
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
