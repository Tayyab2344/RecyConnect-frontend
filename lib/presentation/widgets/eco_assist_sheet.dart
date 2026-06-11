import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/eco_assist_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/rewards_service.dart';
import '../../core/theme/marketplace_theme.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/marketplace/glass_card.dart';
import '../screens/individual/create_listing_screen.dart';
import '../screens/individual/browse_marketplace_screen.dart';
import '../screens/rewards/rewards_screen.dart';
import '../screens/individual/my_orders_screen.dart';

class EcoAssistSheet extends StatefulWidget {
  const EcoAssistSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const EcoAssistSheet(),
    );
  }

  @override
  State<EcoAssistSheet> createState() => _EcoAssistSheetState();
}

class _EcoAssistSheetState extends State<EcoAssistSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  
  bool _isListening = false;
  String _listeningStatus = '';
  List<String> _suggestions = [
    'I want to sell plastic bottles',
    'Show cardboard near me',
    'Mujhe kabaria bulana hai',
    'Mere eco points kitne hain?'
  ];

  @override
  void initState() {
    super.initState();
    // Add welcome message from EcoAssist
    _messages.add({
      'sender': 'assistant',
      'text': 'Hi! I am EcoAssist, your AI recycling companion. How can I help you save the environment today? (I understand English, Urdu & Roman Urdu!)',
      'time': DateTime.now(),
    });
    
    // Customize suggestions based on user role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final role = authService.userRole?.toLowerCase() ?? 'individual';
      setState(() {
        if (role == 'warehouse') {
          _suggestions = [
            'Show inventory status',
            'Find nearby suppliers',
            'Check daily sales overview',
            'Check eco constraints'
          ];
        } else if (role == 'company') {
          _suggestions = [
            'Find highest paying buyer nearby',
            'Analyze plastic sourcing',
            'Show warehouse capacity info',
            'Check carbon credit estimation'
          ];
        } else if (role == 'collector') {
          _suggestions = [
            'Show assigned requests',
            'Open pickup route',
            'My daily earnings',
            'Report a blocked route'
          ];
        }
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _inputController.clear();
    
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();

    final ecoService = Provider.of<EcoAssistService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Call service API
    final response = await ecoService.sendQuery(
      text,
      location: {
        'city': authService.currentUser?['city'],
        'area': authService.currentUser?['area']
      }
    );

    if (!mounted) return;

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final reply = data['reply'] as String? ?? 'No response text received.';
      final intent = data['intent'] as Map<String, dynamic>?;
      final serverSuggestions = data['suggestions'] as List<dynamic>?;

      setState(() {
        _messages.add({
          'sender': 'assistant',
          'text': reply,
          'time': DateTime.now(),
          'intent': intent,
        });
        
        if (serverSuggestions != null && serverSuggestions.isNotEmpty) {
          _suggestions = List<String>.from(serverSuggestions);
        }
      });
      _scrollToBottom();

      // Trigger Intent-Based Navigation after a short delay
      if (intent != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _executeNavigationIntent(intent, text);
        });
      }
    } else {
      setState(() {
        _messages.add({
          'sender': 'assistant',
          'text': 'Sorry, I encountered an error: ${response['message']}',
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  void _executeNavigationIntent(Map<String, dynamic> intent, String queryText) {
    final action = intent['action'] as String?;
    final params = intent['params'] as Map<String, dynamic>? ?? {};
    final category = params['category'] as String?;
    
    if (action == 'NAVIGATE_SELL_ITEM') {
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateListingScreen(
            initialMaterial: category,
            triggerCamera: params['triggerCamera'] == true,
            requestCollector: params['autofill'] == true,
          ),
        ),
      );
    } else if (action == 'NAVIGATE_MARKETPLACE') {
      Navigator.pop(context); // close sheet
      
      // Map maxDistance integer to radius option string
      String radius = 'Within 10 km';
      final dist = params['maxDistance'];
      if (dist == 5) radius = 'Within 5 km';
      if (dist == 25) radius = 'Within 25 km';

      // Check if user specifically requested a map view
      final lowercaseQuery = queryText.toLowerCase();
      final wantsMap = params['mapView'] == true || 
                       params['showMap'] == true ||
                       lowercaseQuery.contains('map') ||
                       lowercaseQuery.contains('map view') ||
                       lowercaseQuery.contains('naqsha') ||
                       lowercaseQuery.contains('naqshay') ||
                       lowercaseQuery.contains('location') ||
                       lowercaseQuery.contains('kahan') ||
                       lowercaseQuery.contains('kidhar');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrowseMarketplaceScreen(
            initialMaterial: category,
            initialRadius: radius,
            initialSort: params['sortBy'] ?? 'Nearest First',
            initialMapView: wantsMap,
          ),
        ),
      );
    } else if (action == 'REQUEST_COLLECTOR') {
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateListingScreen(
            requestCollector: true,
          ),
        ),
      );
    } else if (action == 'OPEN_REWARDS') {
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RewardsScreen(),
        ),
      );
    } else if (action == 'OPEN_ORDERS') {
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyOrdersScreen(),
        ),
      );
    } else if (action == 'SCAN_ITEM') {
      Navigator.pop(context); // close sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateListingScreen(
            triggerCamera: true,
          ),
        ),
      );
    }
  }

  /// Simulate Speech to Text (Urdu & English Auto detection)
  void _startSimulatedListening() {
    if (_isListening) return;
    
    setState(() {
      _isListening = true;
      _listeningStatus = 'Listening... (Speak naturally)';
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final role = authService.userRole?.toLowerCase() ?? 'individual';

    // Mock statements based on role
    final individualQueries = [
      'I want to sell plastic bottles',
      'Show cardboard near me',
      'Mujhe kabaria bulana hai',
      'Mere eco points kitne hain?'
    ];
    final otherQueries = [
      'Show inventory status',
      'Find highest paying buyer nearby',
      'Show assigned requests',
      'Report a blocked route'
    ];
    final selectedPool = role == 'individual' ? individualQueries : otherQueries;
    final randomQuery = selectedPool[math.Random().nextInt(selectedPool.length)];

    // Detect language for status visualizer
    String langDetection = 'Auto-detecting language...';
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          langDetection = randomQuery.contains('Mujhe') || randomQuery.contains('kabaria')
              ? 'Urdu/Roman Urdu detected'
              : 'English detected';
          _listeningStatus = langDetection;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _listeningStatus = '';
        });
        _handleSubmitted(randomQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: size.height * 0.72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.black12,
              blurRadius: 24,
              offset: const Offset(0, -4),
            )
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF00E5FF).withOpacity(0.4) : Colors.green.shade200,
            width: 1.5,
          )
        ),
        child: Column(
          children: [
            // Top Notch indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFF00E5FF) : const Color(0xFF4CAF50)).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology_outlined,
                          color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EcoAssist',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'AI Recycling Companion',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white60 : Colors.black45),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Message Feed
            Expanded(
              child: Consumer<EcoAssistService>(
                builder: (context, ecoService, child) {
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['sender'] == 'user';
                          
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(
                                maxWidth: size.width * 0.76,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? (isDark ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF4CAF50).withOpacity(0.12))
                                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: isUser
                                      ? (isDark ? const Color(0xFF00E5FF).withOpacity(0.4) : const Color(0xFF4CAF50).withOpacity(0.3))
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['text'],
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      color: isDark ? Colors.white : Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (msg['intent'] != null && msg['intent']['action'] != 'GENERAL_CHAT') ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome, color: Colors.green, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Auto-Redirecting...',
                                            style: GoogleFonts.outfit(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Loading Indicator Overlay
                      if (ecoService.isLoading)
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'EcoAssist is thinking...',
                                  style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      // Voice Listening Overlay
                      if (_isListening)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.65),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  VoiceEqualizer(isListening: _isListening),
                                  const SizedBox(height: 16),
                                  Text(
                                    _listeningStatus,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Roman Urdu & English supported',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            
            // Smart Suggestions row
            if (_suggestions.isNotEmpty && !_isListening) ...[
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          _suggestions[index],
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                        onPressed: () => _handleSubmitted(_suggestions[index]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],
            
            // Input Text Field Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  // Mic button (Speech simulation)
                  GestureDetector(
                    onTap: _startSimulatedListening,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF00E5FF).withOpacity(0.12) : const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF2E7D32),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: GoogleFonts.outfit(fontSize: 14.5, color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Type or tap voice...',
                          hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Send button
                  GestureDetector(
                    onTap: () => _handleSubmitted(_inputController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceEqualizer extends StatefulWidget {
  final bool isListening;
  const VoiceEqualizer({Key? key, required this.isListening}) : super(key: key);

  @override
  State<VoiceEqualizer> createState() => _VoiceEqualizerState();
}

class _VoiceEqualizerState extends State<VoiceEqualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isListening) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final double phase = (index * 0.2);
            final double value = (phase + _controller.value) % 1.0;
            final double height = 8 + 36 * (0.5 + 0.5 * math.sin(value * 2 * math.pi));
            return Container(
              width: 5,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
