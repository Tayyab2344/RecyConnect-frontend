import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/admin_service.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String? _selectedAction;
  String? _selectedRole;
  String? _selectedResourceType;
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 1;
  final int _limit = 20;
  bool _isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<String> _actions = [
    'LOGIN_SUCCESS',
    'LOGIN_FAILED',
    'LOGOUT',
    'REGISTER_INDIVIDUAL',
    'REGISTER_WAREHOUSE',
    'REGISTER_COMPANY',
    'FETCH_ME',
    'UPDATE_PROFILE',
  ];

  final List<String> _roles = [
    'individual',
    'warehouse',
    'company',
    'collector',
    'admin',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final adminService = context.read<AdminService>();
    await adminService.getLogs(
      page: _currentPage,
      limit: _limit,
      query: _searchController.text.isNotEmpty ? _searchController.text : null,
      action: _selectedAction,
      role: _selectedRole,
      resourceType: _selectedResourceType,
      from: _fromDate,
      to: _toDate,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadLogs();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedAction = null;
      _selectedRole = null;
      _selectedResourceType = null;
      _fromDate = null;
      _toDate = null;
      _currentPage = 1;
    });
    _loadLogs();
  }

  void _toggleFilters() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
      if (_isFilterExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedAction != null) count++;
    if (_selectedRole != null) count++;
    if (_fromDate != null) count++;
    if (_searchController.text.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Monitor system activities',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadLogs,
            tooltip: 'Refresh logs',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search logs by user ID, action...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.grey.shade600),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear_rounded,
                                          color: Colors.grey.shade600),
                                      onPressed: () {
                                        _searchController.clear();
                                        _currentPage = 1;
                                        _loadLogs();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {});
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (_searchController.text == value) {
                                  _currentPage = 1;
                                  _loadLogs();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _toggleFilters,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            child: Stack(
                              children: [
                                const Icon(
                                  Icons.tune_rounded,
                                  color: AppTheme.primaryGreen,
                                ),
                                if (_activeFiltersCount > 0)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.errorRed,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        '$_activeFiltersCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expandable Filters
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildModernFilterChip(
                              'Action',
                              _selectedAction,
                              _actions,
                              Icons.flash_on_rounded,
                              (value) {
                                setState(() => _selectedAction = value);
                                _currentPage = 1;
                                _loadLogs();
                              },
                            ),
                            _buildModernFilterChip(
                              'Role',
                              _selectedRole,
                              _roles,
                              Icons.person_rounded,
                              (value) {
                                setState(() => _selectedRole = value);
                                _currentPage = 1;
                                _loadLogs();
                              },
                            ),
                            _buildDateRangeChip(),
                            if (_activeFiltersCount > 0)
                              Material(
                                color: AppTheme.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _clearFilters,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.clear_rounded,
                                            size: 16, color: AppTheme.errorRed),
                                        SizedBox(width: 4),
                                        Text(
                                          'Clear All',
                                          style: TextStyle(
                                            color: AppTheme.errorRed,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: Consumer<AdminService>(
              builder: (context, adminService, child) {
                if (adminService.isLoading && adminService.logs.isEmpty) {
                  return _buildLoadingState();
                }

                if (adminService.error != null) {
                  return _buildErrorState(adminService.error!);
                }

                if (adminService.logs.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadLogs,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: adminService.logs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == adminService.logs.length) {
                        if (adminService.hasMore) {
                          return _buildLoadMoreButton(adminService.isLoading);
                        }
                        return const SizedBox(height: 16);
                      }

                      final log = adminService.logs[index];
                      return _buildModernLogItem(log, index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    String? selectedValue,
    List<String> options,
    IconData icon,
    Function(String?) onSelected,
  ) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              Icon(Icons.clear_all_rounded,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text('All ${label}s'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...options.map((option) => PopupMenuItem(
              value: option,
              child: Row(
                children: [
                  if (selectedValue == option)
                    const Icon(Icons.check_rounded,
                        size: 18, color: AppTheme.primaryGreen)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option.replaceAll('_', ' '),
                      style: TextStyle(
                        fontWeight: selectedValue == option
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selectedValue != null
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedValue != null
                ? AppTheme.primaryGreen
                : Colors.grey.shade300,
            width: selectedValue != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selectedValue != null
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              selectedValue?.replaceAll('_', ' ') ?? label,
              style: TextStyle(
                color: selectedValue != null
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade700,
                fontWeight:
                    selectedValue != null ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: selectedValue != null
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip() {
    return Material(
      color: _fromDate != null
          ? AppTheme.primaryGreen.withOpacity(0.1)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _selectDateRange,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _fromDate != null
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
              width: _fromDate != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: _fromDate != null
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                _fromDate != null && _toDate != null
                    ? '${DateFormat('MMM d').format(_fromDate!)} - ${DateFormat('MMM d').format(_toDate!)}'
                    : 'Date Range',
                style: TextStyle(
                  color: _fromDate != null
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade700,
                  fontWeight:
                      _fromDate != null ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLogItem(Map<String, dynamic> log, int index) {
    final DateTime createdAt = DateTime.parse(log['createdAt']);
    final String action = log['action'] ?? 'Unknown';
    final String actorRole = log['actorRole'] ?? 'Unknown';
    final int? userId = log['userId'];
    final color = _getActionColor(action);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showModernLogDetails(log),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getActionIcon(action), color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                action.replaceAll('_', ' '),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            _buildStatusBadge(action),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_rounded,
                                      size: 12, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    actorRole,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (userId != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'ID: $userId',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String action) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (action.contains('SUCCESS')) {
      badgeColor = AppTheme.primaryGreen;
      badgeText = 'Success';
      badgeIcon = Icons.check_circle_rounded;
    } else if (action.contains('FAILED') || action.contains('ERROR')) {
      badgeColor = AppTheme.errorRed;
      badgeText = 'Failed';
      badgeIcon = Icons.error_rounded;
    } else {
      badgeColor = Colors.grey.shade600;
      badgeText = 'Info';
      badgeIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    }
  }

  Color _getActionColor(String action) {
    if (action.contains('SUCCESS') || action.contains('REGISTER')) {
      return AppTheme.primaryGreen;
    } else if (action.contains('FAILED') || action.contains('ERROR')) {
      return AppTheme.errorRed;
    } else if (action.contains('LOGOUT')) {
      return Colors.orange;
    } else if (action.contains('UPDATE')) {
      return Colors.blue;
    }
    return AppTheme.primaryBlue;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('LOGIN')) return Icons.login_rounded;
    if (action.contains('LOGOUT')) return Icons.logout_rounded;
    if (action.contains('REGISTER')) return Icons.person_add_rounded;
    if (action.contains('UPDATE')) return Icons.edit_rounded;
    if (action.contains('FETCH')) return Icons.visibility_rounded;
    return Icons.info_rounded;
  }

  void _showModernLogDetails(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getActionColor(log['action']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getActionIcon(log['action']),
                        color: _getActionColor(log['action']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['action']?.replaceAll('_', ' ') ??
                                'Log Details',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Activity Details',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildModernDetailCard('Basic Information', [
                      _buildModernDetailRow(
                          Icons.tag_rounded, 'Log ID', log['id']?.toString()),
                      _buildModernDetailRow(Icons.person_rounded, 'User ID',
                          log['userId']?.toString()),
                      _buildModernDetailRow(
                          Icons.badge_rounded, 'Actor Role', log['actorRole']),
                      _buildModernDetailRow(
                          Icons.flash_on_rounded, 'Action', log['action']),
                    ]),
                    const SizedBox(height: 16),
                    _buildModernDetailCard('Resource Details', [
                      _buildModernDetailRow(Icons.category_rounded,
                          'Resource Type', log['resourceType']),
                      _buildModernDetailRow(Icons.fingerprint_rounded,
                          'Resource ID', log['resourceId']),
                      _buildModernDetailRow(
                        Icons.access_time_rounded,
                        'Created At',
                        log['createdAt'] != null
                            ? DateFormat('MMM d, y • h:mm:ss a')
                                .format(DateTime.parse(log['createdAt']))
                            : null,
                      ),
                    ]),
                    if (log['meta'] != null) ...[
                      const SizedBox(height: 16),
                      _buildModernDetailCard('Metadata', [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            log['meta'].toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String? value) {
    if (value == null || value == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Material(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLoading
                ? null
                : () {
                    _currentPage++;
                    _loadLogs();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen),
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.expand_more_rounded,
                            color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Load More',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Logs Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no activity logs matching your filters.\nTry adjusting your search criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (_activeFiltersCount > 0) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
