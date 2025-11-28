import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/admin_colors.dart';
import '../../../core/constants/modern_colors.dart';
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

  // Sample user data - 40 users with varied data
  List<Map<String, dynamic>> _allUsers = [];
  String? _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _generateDummyUsers();
  }

  void _generateDummyUsers() {
    _allUsers = [
      // Original users
      {
        'name': 'Ahmed Khan',
        'email': 'ahmed.khan@email.com',
        'contact': '+92 300 1234567',
        'type': 'Individual',
        'sales': 25000,
        'purchases': 15000,
        'initials': 'AK',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 6, 15),
      },
      {
        'name': 'Green Warehouse Ltd',
        'email': 'contact@greenwarehouse.com',
        'contact': '+92 321 9876543',
        'type': 'Warehouse',
        'sales': 150000,
        'purchases': 80000,
        'initials': 'GW',
        'isSuspended': true,
        'joinedDate': DateTime(2024, 3, 10),
      },
      {
        'name': 'Fatima Ali',
        'email': 'fatima.ali@email.com',
        'contact': '+92 333 4567890',
        'type': 'Individual',
        'sales': 12500,
        'purchases': 8000,
        'initials': 'FA',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 8, 20),
      },
      {
        'name': 'EcoTech Industries',
        'email': 'info@ecotech.com',
        'contact': '+92 42 12345678',
        'type': 'Company',
        'sales': 450000,
        'purchases': 200000,
        'initials': 'ET',
        'isSuspended': false,
        'joinedDate': DateTime(2025, 2, 5),
      },
      {
        'name': 'Hassan Raza',
        'email': 'hassan.raza@email.com',
        'contact': '+92 345 7890123',
        'type': 'Individual',
        'sales': 18000,
        'purchases': 10500,
        'initials': 'HR',
        'isSuspended': true,
        'joinedDate': DateTime(2024, 7, 12),
      },
      {
        'name': 'City Waste Solutions',
        'email': 'admin@citywaste.com',
        'contact': '+92 51 8765432',
        'type': 'Warehouse',
        'sales': 320000,
        'purchases': 180000,
        'initials': 'CW',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 4, 18),
      },
      // 20 NEW USERS with varied data
      {
        'name': 'Ahmed Ali',
        'email': 'ahmed.ali@email.com',
        'contact': '+92 301 1111111',
        'type': 'Individual',
        'sales': 1500,
        'purchases': 800,
        'initials': 'AA',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 1, 10),
      },
      {
        'name': 'Fatima Khan',
        'email': 'fatima.khan@email.com',
        'contact': '+92 302 2222222',
        'type': 'Individual',
        'sales': 25000,
        'purchases': 15000,
        'initials': 'FK',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 12, 15),
      },
      {
        'name': 'GreenHub Warehouse',
        'email': 'contact@greenhub.com',
        'contact': '+92 303 3333333',
        'type': 'Warehouse',
        'sales': 80000,
        'purchases': 50000,
        'initials': 'GH',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 3, 20),
      },
      {
        'name': 'EcoTech Solutions',
        'email': 'info@ecotechsol.com',
        'contact': '+92 304 4444444',
        'type': 'Company',
        'sales': 150000,
        'purchases': 100000,
        'initials': 'ES',
        'isSuspended': false,
        'joinedDate': DateTime(2025, 2, 28),
      },
      {
        'name': 'Zain Ahmed',
        'email': 'zain.ahmed@email.com',
        'contact': '+92 305 5555555',
        'type': 'Individual',
        'sales': 5000,
        'purchases': 3000,
        'initials': 'ZA',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 5, 8),
      },
      {
        'name': 'Sara Malik',
        'email': 'sara.malik@email.com',
        'contact': '+92 306 6666666',
        'type': 'Individual',
        'sales': 9500,
        'purchases': 6000,
        'initials': 'SM',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 11, 22),
      },
      {
        'name': 'RecyclePoint Hub',
        'email': 'info@recyclepoint.com',
        'contact': '+92 307 7777777',
        'type': 'Warehouse',
        'sales': 65000,
        'purchases': 40000,
        'initials': 'RP',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 6, 30),
      },
      {
        'name': 'PlasticCorp Industries',
        'email': 'contact@plasticcorp.com',
        'contact': '+92 308 8888888',
        'type': 'Company',
        'sales': 95000,
        'purchases': 60000,
        'initials': 'PC',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 9, 14),
      },
      {
        'name': 'Ali Hassan',
        'email': 'ali.hassan@email.com',
        'contact': '+92 309 9999999',
        'type': 'Individual',
        'sales': 15500,
        'purchases': 9000,
        'initials': 'AH',
        'isSuspended': true,
        'joinedDate': DateTime(2024, 1, 5),
      },
      {
        'name': 'Maria Fatima',
        'email': 'maria.fatima@email.com',
        'contact': '+92 310 1010101',
        'type': 'Individual',
        'sales': 22000,
        'purchases': 13500,
        'initials': 'MF',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 10, 18),
      },
      {
        'name': 'EcoHub Storage',
        'email': 'admin@ecohub.com',
        'contact': '+92 311 1111222',
        'type': 'Warehouse',
        'sales': 45000,
        'purchases': 28000,
        'initials': 'EH',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 2, 14),
      },
      {
        'name': 'GreenTech Ltd',
        'email': 'info@greentech.com',
        'contact': '+92 312 2222333',
        'type': 'Company',
        'sales': 120000,
        'purchases': 75000,
        'initials': 'GT',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 11, 8),
      },
      {
        'name': 'Usman Ali',
        'email': 'usman.ali@email.com',
        'contact': '+92 313 3333444',
        'type': 'Individual',
        'sales': 8500,
        'purchases': 5000,
        'initials': 'UA',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 7, 25),
      },
      {
        'name': 'Ayesha Khan',
        'email': 'ayesha.khan@email.com',
        'contact': '+92 314 4444555',
        'type': 'Individual',
        'sales': 19500,
        'purchases': 12000,
        'initials': 'AYK',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 4, 9),
      },
      {
        'name': 'WasteHub Facility',
        'email': 'contact@wastehub.com',
        'contact': '+92 315 5555666',
        'type': 'Warehouse',
        'sales': 55000,
        'purchases': 35000,
        'initials': 'WH',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 12, 3),
      },
      {
        'name': 'Tech Recyclers Inc',
        'email': 'info@techrecyclers.com',
        'contact': '+92 316 6666777',
        'type': 'Company',
        'sales': 85000,
        'purchases': 52000,
        'initials': 'TR',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 7, 21),
      },
      {
        'name': 'Bilal Ahmed',
        'email': 'bilal.ahmed@email.com',
        'contact': '+92 317 7777888',
        'type': 'Individual',
        'sales': 11000,
        'purchases': 7000,
        'initials': 'BA',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 9, 16),
      },
      {
        'name': 'Hina Malik',
        'email': 'hina.malik@email.com',
        'contact': '+92 318 8888999',
        'type': 'Individual',
        'sales': 17500,
        'purchases': 10000,
        'initials': 'HM',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 5, 27),
      },
      {
        'name': 'CleanPoint Warehouse',
        'email': 'admin@cleanpoint.com',
        'contact': '+92 319 9990000',
        'type': 'Warehouse',
        'sales': 72000,
        'purchases': 45000,
        'initials': 'CP',
        'isSuspended': true,
        'joinedDate': DateTime(2024, 8, 11),
      },
      {
        'name': 'MetalWorks Corp',
        'email': 'contact@metalworks.com',
        'contact': '+92 320 0001111',
        'type': 'Company',
        'sales': 135000,
        'purchases': 82000,
        'initials': 'MW',
        'isSuspended': false,
        'joinedDate': DateTime(2025, 1, 19),
      },
      {
        'name': 'Farhan Rashid',
        'email': 'farhan.rashid@email.com',
        'contact': '+92 321 1112222',
        'type': 'Individual',
        'sales': 6500,
        'purchases': 4000,
        'initials': 'FR',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 6, 8),
      },
      {
        'name': 'Sana Ahmed',
        'email': 'sana.ahmed@email.com',
        'contact': '+92 322 2223333',
        'type': 'Individual',
        'sales': 14000,
        'purchases': 8500,
        'initials': 'SA',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 9, 22),
      },
      {
        'name': 'RecycleMax Depot',
        'email': 'info@recyclemax.com',
        'contact': '+92 323 3334444',
        'type': 'Warehouse',
        'sales': 88000,
        'purchases': 54000,
        'initials': 'RM',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 1, 28),
      },
      {
        'name': 'Polymer Industries',
        'email': 'contact@polymer.com',
        'contact': '+92 324 4445555',
        'type': 'Company',
        'sales': 105000,
        'purchases': 65000,
        'initials': 'PI',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 10, 5),
      },
      {
        'name': 'Omar Khan',
        'email': 'omar.khan@email.com',
        'contact': '+92 325 5556666',
        'type': 'Individual',
        'sales': 20000,
        'purchases': 12500,
        'initials': 'OK',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 3, 17),
      },
      {
        'name': 'Nida Fatima',
        'email': 'nida.fatima@email.com',
        'contact': '+92 326 6667777',
        'type': 'Individual',
        'sales': 3500,
        'purchases': 2000,
        'initials': 'NF',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 4, 12),
      },
      {
        'name': 'GreenStore Warehouse',
        'email': 'admin@greenstore.com',
        'contact': '+92 327 7778888',
        'type': 'Warehouse',
        'sales': 60000,
        'purchases': 38000,
        'initials': 'GS',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 7, 6),
      },
      {
        'name': 'Sustainable Solutions',
        'email': 'info@sustainable.com',
        'contact': '+92 328 8889999',
        'type': 'Company',
        'sales': 98000,
        'purchases': 61000,
        'initials': 'SS',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 12, 2),
      },
      {
        'name': 'Imran Ali',
        'email': 'imran.ali@email.com',
        'contact': '+92 329 9990001',
        'type': 'Individual',
        'sales': 13500,
        'purchases': 8000,
        'initials': 'IA',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 10, 14),
      },
      {
        'name': 'Maryam Hassan',
        'email': 'maryam.hassan@email.com',
        'contact': '+92 330 0001112',
        'type': 'Individual',
        'sales': 16000,
        'purchases': 9500,
        'initials': 'MH',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 6, 24),
      },
      {
        'name': 'EcoCenter Warehouse',
        'email': 'contact@ecocenter.com',
        'contact': '+92 331 1112223',
        'type': 'Warehouse',
        'sales': 75000,
        'purchases': 47000,
        'initials': 'EC',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 2, 19),
      },
      {
        'name': 'Waste Management Inc',
        'email': 'info@wastemanagement.com',
        'contact': '+92 332 2223334',
        'type': 'Company',
        'sales': 112000,
        'purchases': 70000,
        'initials': 'WM',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 11, 26),
      },
      {
        'name': 'Kamran Ahmed',
        'email': 'kamran.ahmed@email.com',
        'contact': '+92 333 3334445',
        'type': 'Individual',
        'sales': 10500,
        'purchases': 6500,
        'initials': 'KA',
        'isSuspended': false,
        'joinedDate': DateTime(2023, 8, 7),
      },
      {
        'name': 'Rabia Khan',
        'email': 'rabia.khan@email.com',
        'contact': '+92 334 4445556',
        'type': 'Individual',
        'sales': 21000,
        'purchases': 13000,
        'initials': 'RK',
        'isSuspended': false,
        'joinedDate': DateTime(2024, 4, 3),
      },
    ];
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
        case 'sales_high':
          filtered.sort((a, b) => (b['sales'] as int).compareTo(a['sales'] as int));
          break;
        case 'sales_low':
          filtered.sort((a, b) => (a['sales'] as int).compareTo(b['sales'] as int));
          break;
        case 'purchases_high':
          filtered.sort((a, b) => (b['purchases'] as int).compareTo(a['purchases'] as int));
          break;
        case 'purchases_low':
          filtered.sort((a, b) => (a['purchases'] as int).compareTo(b['purchases'] as int));
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
      case 'sales_high':
        return 'Highest Sales';
      case 'sales_low':
        return 'Lowest Sales';
      case 'purchases_high':
        return 'Highest Purchases';
      case 'purchases_low':
        return 'Lowest Purchases';
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
        backgroundColor: AdminColors.success,
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
        backgroundColor: AdminColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Users Management',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AdminColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminColors.textWhite),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: AdminColors.textWhite,
            ),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AdminColors.textWhite),
            tooltip: 'Filter Users',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            color: Colors.white,
            onSelected: (value) {
              if (value == 'reset') {
                _resetSort();
              } else {
                _applySort(value);
              }
            },
            itemBuilder: (BuildContext context) => [
              // Header
              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Sort Users By',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              const PopupMenuDivider(),

              // SALES Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 16, color: AdminColors.primaryGreen),
                    SizedBox(width: 8),
                    Text('Sales',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sales_high',
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Highest Sales First')),
                    if (_selectedSortOption == 'sales_high')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sales_low',
                child: Row(
                  children: [
                    const Icon(Icons.trending_down,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Lowest Sales First')),
                    if (_selectedSortOption == 'sales_low')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // PURCHASES Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        size: 16, color: AdminColors.accentBlue),
                    SizedBox(width: 8),
                    Text('Purchases',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'purchases_high',
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Highest Purchases First')),
                    if (_selectedSortOption == 'purchases_high')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'purchases_low',
                child: Row(
                  children: [
                    const Icon(Icons.trending_down,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Lowest Purchases First')),
                    if (_selectedSortOption == 'purchases_low')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // DATE Section
              const PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AdminColors.accentPurple),
                    SizedBox(width: 8),
                    Text('Join Date',
                        style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'newest',
                child: Row(
                  children: [
                    const Icon(Icons.new_releases, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Newest Members First')),
                    if (_selectedSortOption == 'newest')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'oldest',
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Oldest Members First')),
                    if (_selectedSortOption == 'oldest')
                      const Icon(Icons.check,
                          color: AdminColors.success, size: 20),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              // RESET Option
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AdminColors.error, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Clear Filter',
                      style: TextStyle(
                        color: AdminColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AdminColors.cardBackground,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {}); // Refresh to apply filter
              },
              labelColor: AdminColors.primaryGreen,
              unselectedLabelColor: AdminColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              indicatorColor: AdminColors.primaryGreen,
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
              color: AdminColors.cardBackground,
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
                  hintStyle: const TextStyle(
                    color: AdminColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AdminColors.primaryGreen,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AdminColors.textLight,
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
                  fillColor: AdminColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.primaryGreen,
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
            color: AdminColors.surfaceLight,
            child: Text(
              '${filteredUsers.length} ${filteredUsers.length == 1 ? 'User' : 'Users'} Found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.textSecondary,
              ),
            ),
          ),

          // Filter Indicator Banner
          if (_selectedSortOption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withOpacity(0.1),
                border: const Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt,
                      size: 18, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sorted by: ${_getFilterLabel(_selectedSortOption)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AdminColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetSort,
                    icon: const Icon(Icons.close, size: 16, color: AdminColors.error),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: AdminColors.error, fontSize: 13),
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
            child: filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AdminColors.primaryGreen,
        icon: const Icon(Icons.person_add, color: AdminColors.textWhite),
        label: const Text(
          'Add User',
          style: TextStyle(
            color: AdminColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isSuspended = user['isSuspended'] ?? false;
    final typeColor = _getUserTypeColor(user['type']);

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSuspended
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
              : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: ModernColors.softShadow,
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
                      colors: [typeColor, typeColor.withOpacity(0.6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red, width: 1),
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
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    const SizedBox(height: 4),
                    Text(
                      user['email'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 12,
                          color: AdminColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user['contact'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminColors.textLight,
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

          // Stats Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales',
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCurrency(user['sales'])} PKR',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.success,
                        ),
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
                    color: AdminColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Purchases',
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCurrency(user['purchases'])} PKR',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.accentBlue,
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
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AdminColors.primaryGreen.withOpacity(0.3),
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
                          userId: user['email'],
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
        color: _getUserTypeColor(type).withOpacity(0.15),
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
        return AdminColors.success;
      case 'Warehouse':
        return AdminColors.accentOrange;
      case 'Company':
        return AdminColors.accentPurple;
      default:
        return AdminColors.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 80,
            color: AdminColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Users Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value is int) {
      return NumberFormat('#,###').format(value);
    }
    return value.toString();
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final contactController = TextEditingController();
    final addressController = TextEditingController();
    final salesController = TextEditingController(text: '0');
    final purchasesController = TextEditingController(text: '0');
    String selectedType = 'Individual';

    bool isNameValid = false;
    bool isEmailValid = false;
    bool isContactValid = false;
    bool isAddressValid = false;

    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }

      // Remove spaces and convert to lowercase
      value = value.trim().toLowerCase();

      // Check if contains @
      if (!value.contains('@')) {
        return 'Email must contain @ symbol';
      }

      // Check for spaces
      if (value.contains(' ')) {
        return 'Email cannot contain spaces';
      }

      // Split by @
      final parts = value.split('@');

      // Check if has text before @
      if (parts[0].isEmpty) {
        return 'Email must have characters before @';
      }

      // Check if more than one @
      if (parts.length != 2) {
        return 'Email must contain exactly one @ symbol';
      }

      // Check if has domain after @
      if (parts[1].isEmpty) {
        return 'Email must have a domain (e.g., @gmail.com)';
      }

      // Check if domain has a dot
      if (!parts[1].contains('.')) {
        return 'Email domain must include a dot (e.g., gmail.com)';
      }

      // Check if domain extension exists
      final domainParts = parts[1].split('.');
      if (domainParts.last.length < 2) {
        return 'Invalid email domain extension';
      }

      // Email regex pattern for complete validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }

      // Check for duplicate email
      final lowercaseEmail = value.toLowerCase();
      final emailExists = _allUsers.any(
        (user) {
          final userEmail = user['email'];
          if (userEmail == null) return false;
          return userEmail.toString().toLowerCase() == lowercaseEmail;
        },
      );

      if (emailExists) {
        return 'This email is already registered';
      }

      return null; // Valid email
    }

    String? validateName(String? value) {
      if (value == null || value.isEmpty) {
        return 'Name is required';
      }

      if (value.length < 3) {
        return 'Name must be at least 3 characters';
      }

      if (value.length > 50) {
        return 'Name must not exceed 50 characters';
      }

      // Check for numbers and special characters (allow spaces)
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        return 'Name must contain only letters and spaces';
      }

      return null;
    }

    String? validateContact(String? value) {
      if (value == null || value.isEmpty) {
        return 'Contact number is required';
      }

      // Remove spaces and dashes for validation
      final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');

      // Check if it's a Pakistani number
      if (cleaned.startsWith('+92')) {
        // Format: +92-3XX-XXXXXXX (total 13 chars with +92)
        if (cleaned.length != 13) {
          return 'Pakistani number must be in format: +92-3XX-XXXXXXX';
        }
      } else if (cleaned.startsWith('0')) {
        // Format: 03XXXXXXXXX (11 digits)
        if (cleaned.length != 11) {
          return 'Number must be 11 digits starting with 0';
        }
      } else if (cleaned.startsWith('3')) {
        // Format: 3XXXXXXXXXX (10 digits without 0)
        if (cleaned.length != 10) {
          return 'Number must be 10 digits';
        }
      } else {
        return 'Enter valid Pakistani phone number (+92-XXX-XXXXXXX or 03XXXXXXXXX)';
      }

      // Check if only contains valid characters
      if (!RegExp(r'^[\d\+\-\s]+$').hasMatch(value)) {
        return 'Contact can only contain numbers, +, and -';
      }

      return null;
    }

    String? validateAddress(String? value) {
      if (value == null || value.isEmpty) {
        return 'Address is required';
      }

      if (value.length < 10) {
        return 'Address must be at least 10 characters';
      }

      if (value.length > 200) {
        return 'Address must not exceed 200 characters';
      }

      return null;
    }

    String? validateAmount(String? value) {
      if (value == null || value.isEmpty) {
        return null; // Optional field
      }

      final amount = int.tryParse(value);
      if (amount == null) {
        return 'Please enter a valid number';
      }

      if (amount < 0) {
        return 'Amount cannot be negative';
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add New User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'Ahmed Khan',
                          helperText: 'Letters and spaces only (3-50 characters)',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: isNameValid
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isNameValid ? Colors.green : AdminColors.border,
                              width: isNameValid ? 2 : 1,
                            ),
                          ),
                        ),
                        validator: validateName,
                        onChanged: (value) {
                          setDialogState(() {
                            isNameValid = validateName(value) == null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'example@gmail.com',
                          helperText: 'e.g., @gmail.com, @yahoo.com, @outlook.com',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.email),
                          suffixIcon: isEmailValid
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isEmailValid ? Colors.green : AdminColors.border,
                              width: isEmailValid ? 2 : 1,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        onChanged: (value) {
                          // Auto-convert to lowercase
                          final cursorPos = emailController.selection.start;
                          emailController.value = emailController.value.copyWith(
                            text: value.toLowerCase(),
                            selection: TextSelection.collapsed(offset: cursorPos),
                          );
                          setDialogState(() {
                            isEmailValid = validateEmail(value.toLowerCase()) == null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Contact Field
                      TextFormField(
                        controller: contactController,
                        decoration: InputDecoration(
                          labelText: 'Contact Number *',
                          hintText: '+92-300-1234567',
                          helperText: 'Pakistani phone number',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.phone),
                          suffixIcon: isContactValid
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isContactValid ? Colors.green : AdminColors.border,
                              width: isContactValid ? 2 : 1,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: validateContact,
                        onChanged: (value) {
                          setDialogState(() {
                            isContactValid = validateContact(value) == null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Address Field
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Address *',
                          hintText: 'Street, Block, Area, City',
                          helperText: 'Complete address (10-200 characters)',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: isAddressValid
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isAddressValid ? Colors.green : AdminColors.border,
                              width: isAddressValid ? 2 : 1,
                            ),
                          ),
                        ),
                        maxLines: 2,
                        validator: validateAddress,
                        onChanged: (value) {
                          setDialogState(() {
                            isAddressValid = validateAddress(value) == null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // User Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'User Type *',
                          helperText: 'Select user category',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['Individual', 'Warehouse', 'Company']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Sales Amount Field
                      TextFormField(
                        controller: salesController,
                        decoration: InputDecoration(
                          labelText: 'Sales Amount (PKR)',
                          hintText: '0',
                          helperText: 'Total sales (optional, must be ≥ 0)',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: validateAmount,
                      ),
                      const SizedBox(height: 12),
                      // Purchases Amount Field
                      TextFormField(
                        controller: purchasesController,
                        decoration: InputDecoration(
                          labelText: 'Purchases Amount (PKR)',
                          hintText: '0',
                          helperText: 'Total purchases (optional, must be ≥ 0)',
                          helperStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: validateAmount,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AdminColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Generate initials
                      final nameParts = nameController.text.trim().split(' ');
                      final initials = nameParts.length >= 2
                          ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                          : nameController.text[0].toUpperCase();

                      // Create new user with validated data
                      final newUser = {
                        'name': nameController.text.trim(),
                        'email': emailController.text.trim().toLowerCase(),
                        'contact': contactController.text.trim(),
                        'type': selectedType,
                        'sales': int.tryParse(salesController.text) ?? 0,
                        'purchases': int.tryParse(purchasesController.text) ?? 0,
                        'initials': initials,
                        'isSuspended': false,
                        'joinedDate': DateTime.now(),
                      };

                      setState(() {
                        _allUsers.insert(0, newUser); // Add at beginning
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${nameController.text} added successfully!',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      // Show error snackbar if validation fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Please fix all errors before submitting',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Add User',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
