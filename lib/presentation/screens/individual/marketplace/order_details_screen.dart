import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/marketplace/neon_button.dart';
import '../../../widgets/recycle_loader.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order? order;
  final int? orderId;

  const OrderDetailsScreen({
    Key? key,
    this.order,
    this.orderId,
  })  : assert(order != null || orderId != null, 'Either order or orderId must be provided'),
        super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Order? _order;
  bool _isLoadingOrder = true;
  String? _orderError;

  // Chat variables
  List<dynamic> _conversations = [];
  dynamic _selectedConversation;
  List<dynamic> _messages = [];
  bool _isLoadingChat = false;
  bool _isSendingMessage = false;
  String? _chatError;
  Timer? _chatPollingTimer;
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _currentUserId = Provider.of<AuthService>(context, listen: false).userId ?? 0;

    _order = widget.order;
    if (_order != null) {
      _isLoadingOrder = false;
      _loadChats();
    } else {
      _loadOrderDetails();
    }
  }

  @override
  void dispose() {
    _chatPollingTimer?.cancel();
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index == 1) {
      // Switched to Chat tab
      _loadChats();
      _startChatPolling();
    } else {
      _chatPollingTimer?.cancel();
    }
  }

  void _startChatPolling() {
    _chatPollingTimer?.cancel();
    _chatPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_selectedConversation != null) {
        _fetchMessages(silent: true);
      }
    });
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoadingOrder = true;
      _orderError = null;
    });

    try {
      final orderId = widget.orderId ?? _order!.id;
      final order = await _orderService.getOrderById(orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoadingOrder = false;
        });
        _loadChats();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _orderError = e.toString().replaceAll('Exception: ', '');
          _isLoadingOrder = false;
        });
      }
    }
  }

  Future<void> _loadChats() async {
    if (_order == null) return;

    if (_conversations.isEmpty) {
      setState(() {
        _isLoadingChat = true;
        _chatError = null;
      });
    }

    try {
      final list = await _chatService.getOrderChats(_order!.id);
      if (mounted) {
        setState(() {
          _conversations = list;
          _isLoadingChat = false;

          // Default selection: BUYER_SELLER conversation
          if (_selectedConversation == null && list.isNotEmpty) {
            _selectedConversation = list.firstWhere(
              (c) => c['type'] == 'BUYER_SELLER',
              orElse: () => list.first,
            );
          }
        });

        if (_selectedConversation != null) {
          _fetchMessages(scroll: _messages.isEmpty);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatError = 'Failed to load chats: $e';
          _isLoadingChat = false;
        });
      }
    }
  }

  Future<void> _fetchMessages({bool silent = false, bool scroll = false}) async {
    if (_selectedConversation == null) return;
    final convId = _selectedConversation['id'] as int;

    try {
      final list = await _chatService.getMessages(convId);
      if (mounted) {
        setState(() {
          _messages = list;
        });
        if (scroll) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Failed to poll messages: $e');
    }
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSendingMessage || _selectedConversation == null) return;

    _messageController.clear();
    setState(() => _isSendingMessage = true);

    try {
      final convId = _selectedConversation['id'] as int;
      await _chatService.sendMessage(
        conversationId: convId,
        content: text,
      );
      _fetchMessages(silent: true, scroll: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  Future<void> _shareLocation() async {
    if (_selectedConversation == null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    setState(() => _isSendingMessage = true);

    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationContent = 'LOCATION_SHARE:${pos.latitude},${pos.longitude}';
      final convId = _selectedConversation['id'] as int;
      
      await _chatService.sendMessage(
        conversationId: convId,
        content: locationContent,
        messageType: 'LOCATION',
      );
      _fetchMessages(silent: true, scroll: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share location: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  void _openSharedLocation(String content) async {
    final parts = content.replaceFirst('LOCATION_SHARE:', '').split(',');
    if (parts.length == 2) {
      final double? lat = double.tryParse(parts[0]);
      final double? lon = double.tryParse(parts[1]);
      if (lat != null && lon != null) {
        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  // Seller Action: Accept Order
  Future<void> _acceptOrder() async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Accept Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to accept this order? This will lock the reservation and prepare delivery.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: RecycleLoader()),
    );

    try {
      final updatedOrder = await _orderService.confirmOrder(_order!.id);
      Navigator.pop(context); // Pop loading

      setState(() {
        _order = updatedOrder;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted successfully!'), backgroundColor: Colors.green),
      );
      _loadChats(); // Reload chats for new system message
    } catch (e) {
      Navigator.pop(context); // Pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept order: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Seller Action: Reject Order
  Future<void> _rejectOrder() async {
    if (_order == null) return;

    final TextEditingController reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reject Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejecting this order:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejection reason is required.'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: RecycleLoader()),
    );

    try {
      await _orderService.cancelOrder(_order!.id, reason: reason);
      Navigator.pop(context); // Pop loading

      // Reload order details to show CANCELLED status
      _loadOrderDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order rejected/cancelled successfully.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      Navigator.pop(context); // Pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject order: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _order != null ? 'Order #ORDER0${_order!.id}' : 'Order Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_order != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadOrderDetails,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          labelColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'ORDER INFO'),
            Tab(text: 'CHAT'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: MarketplaceTheme.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: _isLoadingOrder
              ? const Center(child: RecycleLoader())
              : _orderError != null
                  ? _buildErrorState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderInfoTab(isDark),
                        _buildChatTab(isDark),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _orderError ?? 'Failed to load order',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── ORDER INFO TAB ──────────────────────────────────────────────
  Widget _buildOrderInfoTab(bool isDark) {
    final order = _order!;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticky Status Header Card
          _buildStatusHeaderCard(isDark),
          const SizedBox(height: 16),

          // Handshake OTP Verification Card (if active)
          if (order.handshakeOtp != null && 
              order.status != 'COMPLETED' && 
              order.status != 'CANCELLED' &&
              order.buyerId == _currentUserId)
            _buildHandshakeOtpCard(isDark),

          const SizedBox(height: 16),

          // Progress timeline
          _buildTimelineCard(isDark),
          const SizedBox(height: 16),

          // Items summary
          _buildItemsCard(isDark),
          const SizedBox(height: 16),

          // Counterpart info card
          _buildCounterpartCard(isDark),
          const SizedBox(height: 16),

          // Delivery info card
          _buildDeliveryMethodCard(isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusHeaderCard(bool isDark) {
    final order = _order!;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusDisplay,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed on ${DateFormat('MMM dd, yyyy hh:mm a').format(order.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandshakeOtpCard(bool isDark) {
    final order = _order!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F2D1A), const Color(0xFF071F10)]
              : [Colors.green.shade50, Colors.green.shade100],
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.08),
                  blurRadius: 15,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'DELIVERY CONFIRMATION PIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.handshakeOtp!,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: isDark ? Colors.white : Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this PIN with the collector or seller once they deliver your items to confirm delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(bool isDark) {
    final order = _order!;
    final List<String> states = ['CREATED', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'COMPLETED'];
    final currentIdx = states.indexOf(order.status.trim().toUpperCase());

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER TIMELINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(states.length, (index) {
            final state = states[index];
            final bool isDone = order.status.trim().toUpperCase() == 'CANCELLED'
                ? false
                : currentIdx >= index;
            final bool isActive = order.status.trim().toUpperCase() == 'CANCELLED'
                ? false
                : currentIdx == index;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? Colors.green
                            : (isDark ? Colors.white10 : Colors.grey.shade300),
                        border: isActive
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    if (index < states.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: isDone && currentIdx > index
                            ? Colors.green
                            : (isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimelineStateText(state),
                      style: TextStyle(
                        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                        color: isDone
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTimelineStateSubtitle(state, isDone),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ],
            );
          }),
          if (order.status.trim().toUpperCase() == 'CANCELLED') ...[
            const Divider(),
            Row(
              children: const [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Order Cancelled',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(bool isDark) {
    final order = _order!;
    final rate = 20.0; // fallback standard rate

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ITEMS SUMMARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items?.length ?? 0,
            itemBuilder: (context, idx) {
              final item = order.items![idx];
              final itemTitle = item.listing?['title'] as String? ?? order.materialTypeDisplay;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} kg x Rs ${item.price.toStringAsFixed(0)}/kg',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      'Rs ${(item.quantity * item.price).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Rs ${order.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterpartCard(bool isDark) {
    final order = _order!;
    final isBuyer = order.buyerId == _currentUserId;
    final counterpartName = isBuyer ? order.sellerName : order.buyerName;
    final counterpart = isBuyer ? order.seller : order.buyer;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBuyer ? 'SELLER INFORMATION' : 'BUYER INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                child: Text(
                  counterpartName.isNotEmpty ? counterpartName[0] : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counterpartName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (counterpart?.contactNo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${counterpart!.contactNo}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    if (counterpart?.address != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Address: ${counterpart!.address}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodCard(bool isDark) {
    final order = _order!;
    final isCollector = order.deliveryMethod == DeliveryMethod.WAREHOUSE_COLLECTOR_SERVICE ||
        order.deliveryMethod.toString().contains('COLLECTOR');

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isCollector ? Icons.local_shipping_outlined : Icons.directions_walk_outlined,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCollector ? 'Warehouse Collector Service' : 'Self Transportation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCollector
                          ? 'A warehouse collector is assigned to pick up the recyclables.'
                          : 'Buyer handles transporting items directly to/from seller.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CHAT TAB ────────────────────────────────────────────────────
  Widget _buildChatTab(bool isDark) {
    if (_isLoadingChat && _conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No active chat room found',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Conversation scope selector (if more than one conversation exists)
        if (_conversations.length > 1) _buildConversationSelector(isDark),

        // Live messages feed
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyChatState(isDark)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final int senderId = msg['senderId'] as int;
                    final bool isMe = senderId == _currentUserId;
                    final String content = msg['content'] ?? '';
                    final String messageType = msg['messageType'] ?? 'TEXT';
                    final DateTime date = msg['createdAt'] != null
                        ? DateTime.parse(msg['createdAt'])
                        : DateTime.now();
                    final String timeStr = DateFormat('hh:mm a').format(date);

                    return _buildChatBubble(isMe, content, messageType, timeStr, isDark);
                  },
                ),
        ),

        // Seller Accept/Reject Row above input text box (visible only when order is CREATED/PENDING and user is seller)
        if (_order!.sellerId == _currentUserId && 
            (_order!.status == 'CREATED' || _order!.status == 'PENDING'))
          _buildSellerActionButtons(isDark),

        // Message input bar
        _buildMessageInputBar(isDark),
      ],
    );
  }

  Widget _buildConversationSelector(bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conv = _conversations[index];
          final bool isSelected = _selectedConversation?['id'] == conv['id'];
          final String title = conv['type'] == 'BUYER_SELLER'
              ? (_order!.buyerId == _currentUserId ? 'Chat with Seller' : 'Chat with Buyer')
              : 'Chat with Collector';

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedConversation = conv;
                _messages = [];
              });
              _fetchMessages(scroll: true);
              _startChatPolling();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.neonCyan : AppColors.primaryGreen)
                      : (isDark ? Colors.white24 : Colors.black12),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected
                        ? (isDark ? AppColors.neonCyan : AppColors.primaryGreen)
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          const Text('No messages yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String content, String messageType, String timeStr, bool isDark) {
    final bool isSystem = messageType == 'SYSTEM';
    final bool isLocation = messageType == 'LOCATION' || content.startsWith('LOCATION_SHARE:');

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    Widget body;
    if (isLocation) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Shared Location',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openSharedLocation(content),
            icon: const Icon(Icons.map, size: 14),
            label: const Text('Open in Google Maps', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: Colors.orange),
              elevation: 0,
            ),
          ),
        ],
      );
    } else {
      body = Text(
        content,
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontSize: 14,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isLocation
                  ? Colors.orange.shade50
                  : isMe
                      ? (isDark ? AppColors.neonGreen.withOpacity(0.8) : AppColors.primaryGreen)
                      : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: isLocation ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
            ),
            child: body,
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: const TextStyle(color: Colors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _rejectOrder,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('REJECT ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _acceptOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.neonGreen : AppColors.primaryGreen,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('ACCEPT ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Share location button
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.orange),
              onPressed: _isSendingMessage ? null : _shareLocation,
            ),
            const SizedBox(width: 8),

            // Message text field
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                radius: 20,
                child: _isSendingMessage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(Icons.send, color: isDark ? Colors.black : Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Status icons
  IconData _getStatusIcon(String status) {
    switch (status.trim().toUpperCase()) {
      case 'CREATED':
      case 'PENDING':
        return Icons.hourglass_empty_rounded;
      case 'CONFIRMED':
        return Icons.check_circle_outline_rounded;
      case 'PROCESSING':
        return Icons.settings_suggest_rounded;
      case 'SHIPPED':
      case 'COLLECTED':
        return Icons.local_shipping_rounded;
      case 'DELIVERED':
        return Icons.mark_chat_read_rounded;
      case 'COMPLETED':
        return Icons.verified_rounded;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // Helper: Timeline mapping
  String _getTimelineStateText(String state) {
    switch (state) {
      case 'CREATED':
        return 'Order Placed';
      case 'CONFIRMED':
        return 'Seller Confirmed';
      case 'SHIPPED':
        return 'Dispatched / Collected';
      case 'DELIVERED':
        return 'Delivered';
      case 'COMPLETED':
        return 'Completed';
      default:
        return state;
    }
  }

  String _getTimelineStateSubtitle(String state, bool isDone) {
    if (!isDone) return 'Awaiting progression';
    switch (state) {
      case 'CREATED':
        return 'Your order is recorded.';
      case 'CONFIRMED':
        return 'Seller accepted the trade.';
      case 'SHIPPED':
        return 'Collector is moving order.';
      case 'DELIVERED':
        return 'Order arrived at destination.';
      case 'COMPLETED':
        return 'Trade successfully resolved.';
      default:
        return '';
    }
  }
}
