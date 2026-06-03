import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/admin_service.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_user_profile_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';

  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _adminService.getUsers();
      setState(() {
        _allUsers = users.map<Map<String, dynamic>>((u) {
          final map = Map<String, dynamic>.from(u);
          // Normalize role to display label
          final role = (map['role'] ?? '').toString().toLowerCase();
          String type;
          switch (role) {
            case 'warehouse':
              type = 'Warehouse';
              break;
            case 'company':
              type = 'Company';
              break;
            case 'collector':
              type = 'Collector';
              break;
            default:
              type = 'Individual';
          }
          map['type'] = type;
          // Build display name
          final name = (map['name'] ?? map['businessName'] ?? map['companyName'] ?? map['email'] ?? 'Unknown').toString();
          map['name'] = name;
          // Generate initials
          final parts = name.trim().split(' ');
          map['initials'] = parts.length >= 2
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
          // Map suspended status
          map['isSuspended'] = map['verificationStatus'] == 'SUSPENDED';
          // Parse date
          map['joinedDate'] = DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now();
          // Contact
          map['contact'] = map['contactNo'] ?? '';
          map['email'] = map['email'] ?? '';
          return map;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    List<Map<String, dynamic>> filtered = List.from(_allUsers);

    // Filter by tab
    final tabIndex = _tabController.index;
    if (tabIndex == 1) {
      filtered = filtered.where((user) => user['type'] == 'Individual').toList();
    } else if (tabIndex == 2) {
      filtered = filtered.where((user) => user['type'] == 'Warehouse').toList();
    } else if (tabIndex == 3) {
      filtered = filtered.where((user) => user['type'] == 'Company').toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final contact = user['contact'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            contact.contains(query);
      }).toList();
    }

    // Apply sorting
    if (_selectedSortOption != null) {
      switch (_selectedSortOption!) {
        case 'name_asc':
          filtered.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
          break;
        case 'name_desc':
          filtered.sort((a, b) => (b['name'] ?? '').toString().compareTo((a['name'] ?? '').toString()));
          break;
        case 'newest':
          filtered.sort((a, b) => (b['joinedDate'] as DateTime).compareTo(a['joinedDate'] as DateTime));
          break;
        case 'oldest':
          filtered.sort((a, b) => (a['joinedDate'] as DateTime).compareTo(b['joinedDate'] as DateTime));
          break;
      }
    }

    return filtered;
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  String _getFilterLabel(String? option) {
    switch (option) {
      case 'name_asc':
        return 'Name (A-Z)';
      case 'name_desc':
        return 'Name (Z-A)';
      case 'newest':
        return 'Newest Members';
      case 'oldest':
        return 'Oldest Members';
      default:
        return 'None';
    }
  }

  void _applySort(String sortBy) {
    setState(() {
      _selectedSortOption = sortBy;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Filter applied: ${_getFilterLabel(sortBy)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetSort() {
    setState(() {
      _selectedSortOption = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Filter cleared', style: TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Users Management',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: theme.appBarTheme.foregroundColor),
            tooltip: 'Filter Users',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: theme.cardColor,
            onSelected: (value) {
              if (value == 'reset') {
                _resetSort();
              } else {
                _applySort(value);
              }
            },
            itemBuilder: (BuildContext context) {
              final menuTheme = Theme.of(context);
              return [
              // Header
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Sort Users By',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: menuTheme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const PopupMenuDivider(),

              // SALES Section
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.attach_money,
                        size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text('Sales',
                        style: TextStyle(
                            fontSize: 12,
                            color: menuTheme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sales_high',
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Highest Sales First')),
                    if (_selectedSortOption == 'sales_high')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sales_low',
                child: Row(
                  children: [
                    const Icon(Icons.trending_down,
                        color: AppColors.accentOrange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Lowest Sales First')),
                    if (_selectedSortOption == 'sales_low')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // PURCHASES Section
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart,
                        size: 16, color: AppColors.accentBlue),
                    const SizedBox(width: 8),
                    Text('Purchases',
                        style: TextStyle(
                            fontSize: 12,
                            color: menuTheme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'purchases_high',
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Highest Purchases First')),
                    if (_selectedSortOption == 'purchases_high')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'purchases_low',
                child: Row(
                  children: [
                    const Icon(Icons.trending_down,
                        color: AppColors.accentOrange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Lowest Purchases First')),
                    if (_selectedSortOption == 'purchases_low')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // DATE Section
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.accentPurple),
                    const SizedBox(width: 8),
                    Text('Join Date',
                        style: TextStyle(
                            fontSize: 12,
                            color: menuTheme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'newest',
                child: Row(
                  children: [
                    const Icon(Icons.new_releases, color: AppColors.accentBlue, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Newest Members First')),
                    if (_selectedSortOption == 'newest')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'oldest',
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Oldest Members First')),
                    if (_selectedSortOption == 'oldest')
                      const Icon(Icons.check,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // RESET Option
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Clear Filter',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ];
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.cardColor,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {}); // Refresh to apply filter
              },
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All Users'),
                Tab(text: 'Individual'),
                Tab(text: 'Warehouse'),
                Tab(text: 'Company'),
              ],
            ),
          ),
        ),
      ),
      drawer: const AdminDrawer(currentRoute: 'users'),
      body: Column(
        children: [
          // Search Bar (toggleable)
          if (_isSearchVisible)
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or contact...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryGreen,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

          // User Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : theme.cardColor,
            child: Text(
              '${filteredUsers.length} ${filteredUsers.length == 1 ? 'User' : 'Users'} Found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),

          // Filter Indicator Banner
          if (_selectedSortOption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt,
                      size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sorted by: ${_getFilterLabel(_selectedSortOption)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetSort,
                    icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),

          // User Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(_error!, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _fetchUsers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      )
                    : filteredUsers.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchUsers,
                            color: AppColors.primaryGreen,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _buildUserCard(user);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isSuspended = user['isSuspended'] ?? false;
    final typeColor = _getUserTypeColor(user['type']);
    final cardTheme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value * (isSuspended ? 0.7 : 1.0),
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSuspended
              ? Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Modern Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [typeColor, typeColor.withValues(alpha: 0.6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user['initials'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cardTheme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildUserTypeBadge(user['type']),
                        ],
                      ),
                      if (isSuspended) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.error, width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.block,
                                size: 12,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Suspended',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    const SizedBox(height: 4),
                    Text(
                      user['email'],
                      style: TextStyle(
                        fontSize: 13,
                        color: cardTheme.textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 12,
                          color: cardTheme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user['contact'],
                          style: TextStyle(
                            fontSize: 12,
                            color: cardTheme.textTheme.bodySmall?.color,
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

          // Info Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 11,
                          color: cardTheme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [user['city'], user['area']].where((e) => e != null && e.toString().isNotEmpty).join(', ').isNotEmpty
                            ? [user['city'], user['area']].where((e) => e != null && e.toString().isNotEmpty).join(', ')
                            : 'Not set',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Joined',
                        style: TextStyle(
                          fontSize: 11,
                          color: cardTheme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy').format(user['joinedDate'] as DateTime),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Modern View Profile Button with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                        AdminUserProfileScreen(
                          userId: user['id']?.toString() ?? user['email'],
                          userName: user['name'],
                          userType: user['type'],
                        ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'View Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildUserTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getUserTypeColor(type).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getUserTypeColor(type),
        ),
      ),
    );
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'Individual':
        return AppColors.success;
      case 'Warehouse':
        return AppColors.accentOrange;
      case 'Company':
        return AppColors.accentPurple;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    final emptyTheme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            color: emptyTheme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emptyTheme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: emptyTheme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

}
