import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/rewards_service.dart';
import '../../../core/services/auth_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _radialController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _radialProgressAnimation;

  String _leaderboardCategory = 'individuals';
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _radialProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radialController, curve: Curves.fastOutSlowIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _radialController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    final rewardsService = context.read<RewardsService>();
    
    // Load rewards status
    final statusResult = await rewardsService.fetchRewardsStatus();
    if (statusResult['success'] == true && mounted) {
      final nextLevelInfo = rewardsService.rewardsStatus?['nextLevelInfo'];
      final progressPercent = (nextLevelInfo?['progressPercent'] as num?)?.toDouble() ?? 0.0;
      
      _radialProgressAnimation = Tween<double>(begin: 0.0, end: progressPercent).animate(
        CurvedAnimation(parent: _radialController, curve: Curves.fastOutSlowIn),
      );
      _radialController.forward(from: 0.0);
    }

    // Load other tabs data
    rewardsService.fetchHistory();
    rewardsService.fetchLeaderboard(_leaderboardCategory);
    rewardsService.fetchChallenges();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _leaderboardCategory = category;
    });
    context.read<RewardsService>().fetchLeaderboard(category);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rewardsService = context.watch<RewardsService>();
    final status = rewardsService.rewardsStatus;
    final isLoading = rewardsService.isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'RecyConnect Rewards',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Holographic glowing backgrounds
          _buildHolographicBackground(isDark),

          SafeArea(
            child: Column(
              children: [
                // Top Scrollable Tab Bar
                _buildTabBar(isDark),

                // Main Views
                Expanded(
                  child: isLoading && status == null
                      ? Center(
                          child: CircularProgressIndicator(
                            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDashboardTab(status, isDark, rewardsService),
                            _buildStreaksTab(status, isDark, rewardsService),
                            _buildLeaderboardTab(rewardsService, isDark),
                            _buildBadgesTab(status, isDark),
                            _buildChallengesTab(rewardsService, isDark),
                            _buildHistoryTab(rewardsService, isDark),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF070B19), // Extra deep space navy
                  const Color(0xFF0F1A30), // Deep blue-indigo
                  const Color(0xFF0A2240), // Dark neon cyan hue
                  const Color(0xFF060914), // Outer space black
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF0FDF4), // Super soft green
                  const Color(0xFFECFDF5), // Light emerald/mint
                  const Color(0xFFF5F5F7), // Neutral gray
                ],
        ),
      ),
      child: isDark
          ? Stack(
              children: [
                // Top-right cyan aura
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      filters: [
                        ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                      ],
                    ),
                  ),
                ),
                // Bottom-left green/emerald aura
                Positioned(
                  bottom: -150,
                  left: -150,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonGreen.withValues(alpha: 0.12),
                      filters: [
                        ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
            indicatorColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Streaks'),
              Tab(text: 'Leaderboard'),
              Tab(text: 'Badges'),
              Tab(text: 'Challenges'),
              Tab(text: 'History'),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DASHBOARD TAB
  // ==========================================
  Widget _buildDashboardTab(Map<String, dynamic>? status, bool isDark, RewardsService service) {
    if (status == null) return const SizedBox.shrink();

    final int points = (status['ecoPoints'] as num?)?.toInt() ?? 0;
    final String level = status['currentLevel'] as String? ?? 'Beginner Recycler';
    final int streak = (status['dailyStreak'] as num?)?.toInt() ?? 0;
    final nextLevelInfo = status['nextLevelInfo'] as Map<String, dynamic>?;
    final String nextLevel = nextLevelInfo?['nextLevel'] ?? 'Max Level';
    final int pointsNeeded = (nextLevelInfo?['pointsNeeded'] as num?)?.toInt() ?? 0;
    final bool claimedToday = _hasCheckedInToday(status['lastLoginDate'] as String?);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Points circular progress card
          _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.neonCyan.withValues(alpha: 0.1) : AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active Rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Custom Radial Point Gauge
                AnimatedBuilder(
                  animation: _radialProgressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 190,
                      height: 190,
                      child: CustomPaint(
                        painter: RadialProgressPainter(
                          progressPercent: _radialProgressAnimation.value,
                          trackColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          progressColors: isDark 
                              ? [AppColors.neonCyan, AppColors.neonGreen]
                              : [AppColors.primaryGreen, AppColors.ecoTeal],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$points',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.black,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'ECO POINTS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Next Level Status Description
                if (nextLevel != "Max Level Reached") ...[
                  Text(
                    '$pointsNeeded pts needed for $nextLevel',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 8,
                      width: double.infinity,
                      child: LinearProgressIndicator(
                        value: _radialProgressAnimation.value,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    '🏆 Max level reached! Outstanding contribution.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Streak Check-in Quick Card
          _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Glowing streak flame badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak-Day Streak!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        claimedToday ? 'Checked in for today' : 'Unlock points now',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCheckInButton(claimedToday, isDark, service),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Platform Contribution Stats
          _buildQuickOverviewStats(status, isDark),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(bool claimedToday, bool isDark, RewardsService service) {
    if (claimedToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: isDark ? AppColors.neonGreen : AppColors.primaryGreen),
            const SizedBox(width: 4),
            Text(
              'Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: ElevatedButton(
            onPressed: () => _performCheckIn(service),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
              elevation: isDark ? 8 : 4,
              shadowColor: (isDark ? AppColors.neonGreen : AppColors.primaryGreen).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Check In',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF070B19) : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _performCheckIn(RewardsService service) async {
    final result = await service.checkIn();
    if (!mounted) return;
    
    if (result['success'] == true) {
      // Re-trigger level progress animation
      final nextLevelInfo = service.rewardsStatus?['nextLevelInfo'];
      final progressPercent = (nextLevelInfo?['progressPercent'] as num?)?.toDouble() ?? 0.0;
      
      _radialProgressAnimation = Tween<double>(begin: 0.0, end: progressPercent).animate(
        CurvedAnimation(parent: _radialController, curve: Curves.fastOutSlowIn),
      );
      _radialController.forward(from: 0.0);

      _showSuccessDialog(
        context,
        'Daily Streak Check-In',
        result['message'] ?? 'Successfully checked in!',
        result['data']?['pointsEarned'] ?? 5,
        service.rewardsStatus?['dailyStreak'] ?? 1,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Check-in failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(
    BuildContext context,
    String title,
    String message,
    int pointsEarned,
    int newStreak,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF131C33) : Colors.white,
          title: Center(
            child: Column(
              children: [
                // Big glowing flame/star
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Streak Active!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black60,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPopMetric('+$pointsEarned', 'Points Gained', isDark),
                  _buildPopMetric('$newStreak Days', 'Streak Level', isDark),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Awesome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF070B19) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopMetric(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.black,
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOverviewStats(Map<String, dynamic> status, bool isDark) {
    final int badgesCount = (status['badges'] as List?)?.length ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatBox('Badges Unlocked', '$badgesCount / 5', Icons.workspace_premium, Colors.amber, isDark),
        _buildStatBox('Tier Boost', 'x1.2 Multiplier', Icons.bolt, AppColors.neonCyan, isDark),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, bool isDark) {
    return _GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STREAKS TAB
  // ==========================================
  Widget _buildStreaksTab(Map<String, dynamic>? status, bool isDark, RewardsService service) {
    if (status == null) return const SizedBox.shrink();

    final int streak = (status['dailyStreak'] as num?)?.toInt() ?? 0;
    final bool claimedToday = _hasCheckedInToday(status['lastLoginDate'] as String?);

    // Days milestone tracker configurations
    final milestones = [
      {'day': 1, 'bonus': 0, 'points': 5},
      {'day': 2, 'bonus': 0, 'points': 5},
      {'day': 3, 'bonus': 20, 'points': 25},
      {'day': 4, 'bonus': 0, 'points': 5},
      {'day': 5, 'bonus': 0, 'points': 5},
      {'day': 6, 'bonus': 0, 'points': 5},
      {'day': 7, 'bonus': 50, 'points': 55},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Glass card
          _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 58),
                const SizedBox(height: 12),
                Text(
                  '$streak Days Active',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  claimedToday
                      ? 'Awesome! You have secured today\'s streak.'
                      : 'Keep your streak alive. Check in now!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Horizontal weekly timeline
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: milestones.map((m) {
                      final dayNum = m['day'] as int;
                      final bonus = m['bonus'] as int;
                      final isCompleted = dayNum <= streak;
                      final isCurrentTarget = dayNum == (claimedToday ? streak : streak + 1);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 52,
                        child: Column(
                          children: [
                            // Day bubble
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : (isCurrentTarget
                                        ? (isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.primaryGreen.withValues(alpha: 0.1))
                                        : Colors.transparent),
                                border: Border.all(
                                  color: isCompleted
                                      ? Colors.orange
                                      : (isCurrentTarget
                                          ? (isDark ? AppColors.neonCyan : AppColors.primaryGreen)
                                          : (isDark ? Colors.white12 : Colors.black12)),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 24)
                                    : (isCurrentTarget
                                        ? Text(
                                            'Tgt',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                                            ),
                                          )
                                        : Text(
                                            'D$dayNum',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white54 : Colors.black54,
                                            ),
                                          )),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Label with points/bonuses
                            Text(
                              bonus > 0 ? '+$bonus' : '+5',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: bonus > 0 ? FontWeight.bold : FontWeight.normal,
                                color: bonus > 0
                                    ? Colors.amber.shade700
                                    : (isDark ? Colors.white54 : Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Big Claim Button Card
          if (!claimedToday) ...[
            GestureDetector(
              onTap: () => _performCheckIn(service),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.neonGreen, AppColors.neonTeal]
                        : [AppColors.primaryGreen, const Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.neonGreen : AppColors.primaryGreen).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department, color: isDark ? const Color(0xFF070B19) : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Claim Today\'s Check-In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF070B19) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: isDark ? AppColors.neonGreen : AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Successfully Checked In Today',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Milestone bonus descriptions card
          _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milestone Bonuses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMilestoneRow('3-Day Streak Bonus', '+20 Eco Points', isDark),
                const SizedBox(height: 12),
                _buildMilestoneRow('7-Day Streak Bonus', '+50 Eco Points', isDark),
                const SizedBox(height: 12),
                _buildMilestoneRow('15-Day Streak Bonus', '+120 Eco Points', isDark),
                const SizedBox(height: 12),
                _buildMilestoneRow('30-Day Streak Bonus', '+300 Eco Points', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(String title, String bonus, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            bonus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LEADERBOARD TAB
  // ==========================================
  Widget _buildLeaderboardTab(RewardsService service, bool isDark) {
    final list = service.leaderboard;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: _buildCategorySelector(_leaderboardCategory, _onCategoryChanged),
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await service.fetchLeaderboard(_leaderboardCategory);
            },
            color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
            child: list.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          'No leaders in this category yet. Be the first!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index] as Map<String, dynamic>;
                      final int rank = item['rank'] ?? (index + 1);
                      final String name = item['displayName'] ?? 'Anonymous';
                      final int points = (item['ecoPoints'] as num?)?.toInt() ?? 0;
                      final String level = item['currentLevel'] ?? 'Recycler';
                      final String? city = item['city'];
                      final String? area = item['area'];

                      // Render Podium visual decoration for top 3
                      bool isPodium = rank <= 3;
                      Color? ringColor;
                      IconData? rankIcon;

                      if (rank == 1) {
                        ringColor = Colors.amber.shade600;
                        rankIcon = Icons.workspace_premium;
                      } else if (rank == 2) {
                        ringColor = Colors.grey.shade400;
                        rankIcon = Icons.emoji_events_outlined;
                      } else if (rank == 3) {
                        ringColor = Colors.brown.shade400;
                        rankIcon = Icons.emoji_events_outlined;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPodium
                              ? (isDark
                                  ? ringColor!.withValues(alpha: 0.1)
                                  : ringColor!.withValues(alpha: 0.05))
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPodium
                                ? ringColor!
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03)),
                            width: isPodium ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Rank Number/Medal
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPodium
                                    ? ringColor.withValues(alpha: 0.2)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: isPodium
                                    ? Icon(rankIcon, color: ringColor, size: 20)
                                    : Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white60 : Colors.black54,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // User Profile Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isPodium ? Border.all(color: ringColor, width: 2) : null,
                                color: isDark ? Colors.white10 : Colors.grey.shade300,
                              ),
                              child: ClipOval(
                                child: item['profileImage'] != null
                                    ? Image.network(
                                        item['profileImage'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(name, isDark),
                                      )
                                    : _buildAvatarPlaceholder(name, isDark),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Display details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    city != null ? '$area, $city' : level,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Points Counter
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$points PTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(String displayName, bool isDark) {
    return Center(
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(String selectedCategory, Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['individuals', 'warehouses', 'companies'];
    final displayNames = {
      'individuals': 'Individuals',
      'warehouses': 'Warehouses',
      'companies': 'Companies'
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? (isDark ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.primaryGreen)
                      : Colors.transparent,
                  border: isSelected && isDark
                      ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  displayNames[cat]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? AppColors.neonCyan : Colors.white)
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // BADGES TAB
  // ==========================================
  Widget _buildBadgesTab(Map<String, dynamic>? status, bool isDark) {
    if (status == null) return const SizedBox.shrink();

    final userBadges = status['badges'] as List? ?? [];
    
    // System badges database configurations
    final systemBadges = [
      _BadgeConfig(
        name: 'First Sale Badge',
        description: 'Complete your first successful recyclable waste materials sale.',
        icon: Icons.local_mall,
        color: Colors.orange,
      ),
      _BadgeConfig(
        name: 'Green Contributor',
        description: 'Stay active and complete transactions this calendar month.',
        icon: Icons.eco,
        color: Colors.green,
      ),
      _BadgeConfig(
        name: 'Eco Hero',
        description: 'Achieve an outstanding lifetime score of 1,000+ Eco Points.',
        icon: Icons.emoji_events,
        color: Colors.amber,
      ),
      _BadgeConfig(
        name: 'Trusted Seller',
        description: 'Demonstrate top tier reliability with 100+ completed marketplace orders.',
        icon: Icons.verified_user,
        color: Colors.deepPurple,
      ),
      _BadgeConfig(
        name: 'Recycling Master',
        description: 'Master the circular economy with 500+ total reward activity events.',
        icon: Icons.workspace_premium,
        color: Colors.teal,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: systemBadges.length,
      itemBuilder: (context, index) {
        final b = systemBadges[index];
        final isEarned = userBadges.any((element) => element['badgeName'] == b.name);
        
        return GestureDetector(
          onTap: () => _showBadgeDetailSheet(context, b, isEarned, isDark),
          child: _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Badge Avatar Shape
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? b.color.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isEarned
                          ? b.color
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    b.icon,
                    size: 38,
                    color: isEarned
                        ? b.color
                        : (isDark ? Colors.white30 : Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isEarned 
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white30 : Colors.grey.shade500),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Lock/Unlock Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEarned ? Icons.check_circle : Icons.lock_outline,
                        size: 12,
                        color: isEarned 
                            ? (isDark ? AppColors.neonGreen : AppColors.success)
                            : (isDark ? Colors.white30 : Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEarned ? 'Unlocked' : 'Locked',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isEarned 
                              ? (isDark ? AppColors.neonGreen : AppColors.success)
                              : (isDark ? Colors.white30 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetailSheet(BuildContext context, _BadgeConfig badge, bool isEarned, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C33) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull-down handle bar
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Large Badge Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned
                      ? badge.color.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isEarned
                        ? badge.color
                        : (isDark ? Colors.white12 : Colors.black12),
                    width: 3,
                  ),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  badge.icon,
                  size: 58,
                  color: isEarned
                      ? badge.color
                      : (isDark ? Colors.white30 : Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 20),

              // Badge Name
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEarned
                        ? (isDark ? AppColors.neonGreen : AppColors.primaryGreen)
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEarned ? 'Collector Verified!' : 'Dismiss',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEarned 
                          ? (isDark ? const Color(0xFF070B19) : Colors.white)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CHALLENGES TAB
  // ==========================================
  Widget _buildChallengesTab(RewardsService service, bool isDark) {
    final challengesList = service.challenges;

    if (challengesList.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => service.fetchChallenges(),
        color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'No active challenges. Check back later!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => service.fetchChallenges(),
      color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: challengesList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final ch = challengesList[index] as Map<String, dynamic>;
          final String title = ch['title'] ?? 'Challenge';
          final String description = ch['description'] ?? '';
          final int current = (ch['current'] as num?)?.toInt() ?? 0;
          final int target = (ch['target'] as num?)?.toInt() ?? 1;
          final int rewardPoints = (ch['points'] as num?)?.toInt() ?? 0;

          final double progress = (current / target).clamp(0.0, 1.0);
          final bool isComplete = current >= target;

          return _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    // Points reward badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+$rewardPoints PTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),

                // Progress Bar with current/target text
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete 
                                  ? (isDark ? AppColors.neonGreen : AppColors.success)
                                  : (isDark ? AppColors.neonCyan : AppColors.primaryGreen),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '$current/$target',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                
                // Completion label
                if (isComplete) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: isDark ? AppColors.neonGreen : AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Challenge Completed!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.neonGreen : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // HISTORY TAB
  // ==========================================
  Widget _buildHistoryTab(RewardsService service, bool isDark) {
    final historyList = service.history;

    if (historyList.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => service.fetchHistory(),
        color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'No points history yet. Earn points to view timeline!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => service.fetchHistory(),
      color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: historyList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyList[index] as Map<String, dynamic>;
          final int pts = (item['points'] as num?)?.toInt() ?? 0;
          final String activity = item['activityType'] as String? ?? 'POINTS_AWARDED';
          final String dateStr = item['createdAt'] as String? ?? '';
          
          // Activity Clean Title & Icons
          String title = activity.replaceAll('_', ' ');
          title = title[0].toUpperCase() + title.substring(1).toLowerCase();

          IconData icon = Icons.emoji_events_outlined;
          Color color = Colors.amber;

          switch (activity) {
            case 'DAILY_STREAK':
              icon = Icons.local_fire_department;
              color = Colors.orange;
              break;
            case 'LISTING_UPLOAD':
            case 'AI_CLASSIFICATION':
              icon = Icons.cloud_upload_outlined;
              color = AppColors.neonCyan;
              break;
            case 'SUCCESSFUL_SALE':
              icon = Icons.sell_outlined;
              color = Colors.green;
              break;
            case 'PURCHASE':
              icon = Icons.shopping_bag_outlined;
              color = Colors.blue;
              break;
            case 'REFERRAL':
              icon = Icons.person_add_alt_1_outlined;
              color = Colors.pink;
              break;
          }

          // Format Date
          String dateFormatted = '';
          if (dateStr.isNotEmpty) {
            try {
              final parsed = DateTime.parse(dateStr).toLocal();
              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              dateFormatted = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
            } catch (_) {}
          }

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              ),
            ),
            child: Row(
              children: [
                // Glowing Circular Icon Badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),

                // Details Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Points Gained count
                Text(
                  '+$pts PTS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.black,
                    color: isDark ? AppColors.neonGreen : AppColors.success,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hasCheckedInToday(String? lastLoginDateStr) {
    if (lastLoginDateStr == null) return false;
    try {
      final lastLogin = DateTime.parse(lastLoginDateStr).toLocal();
      final now = DateTime.now();
      return lastLogin.year == now.year &&
          lastLogin.month == now.month &&
          lastLogin.day == now.day;
    } catch (e) {
      return false;
    }
  }
}

// ==========================================
// CUSTOM GLASS CARD COMPONENT
// ==========================================
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({
    required this.child,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.60),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ==========================================
// RADIAL PROGRESS GAUGE PAINTER
// ==========================================
class RadialProgressPainter extends CustomPainter {
  final double progressPercent;
  final Color trackColor;
  final List<Color> progressColors;

  RadialProgressPainter({
    required this.progressPercent,
    required this.trackColor,
    required this.progressColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 12.0;

    // 1. Draw background track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress sweeping arc
    if (progressPercent > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: progressColors,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw progress arc starting from top (-90 degrees / -pi/2)
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progressPercent,
        false,
        progressPaint,
      );

      // 3. Draw neon glowing dot at the end of the arc
      final endAngle = -math.pi / 2 + 2 * math.pi * progressPercent;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      final dotPaint = Paint()
        ..color = progressColors.last
        ..style = PaintingStyle.fill;

      // Outer blur glow
      final glowPaint = Paint()
        ..color = progressColors.last.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(dotX, dotY), 10, glowPaint);
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadialProgressPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColors != progressColors;
  }
}

// ==========================================
// BADGE CONFIGURATION DATA HOLDER
// ==========================================
class _BadgeConfig {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  _BadgeConfig({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}