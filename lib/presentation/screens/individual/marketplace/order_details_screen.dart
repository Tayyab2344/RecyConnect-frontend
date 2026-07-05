import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/recycle_loader.dart';
import '../../../widgets/chat/voice_note_bubble.dart';
import '../../../widgets/ratings_reviews_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order? order;
  final int? orderId;

  const OrderDetailsScreen({
    super.key,
    this.order,
    this.orderId,
  })  : assert(order != null || orderId != null, 'Either order or orderId must be provided');

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
  bool _hasReviewed = false;

  // Self Exchange Route Map variables
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  double? _routeDistanceKm;
  double? _routeDurationMins;

  // Resolved exchange coordinates
  double? _resolvedSellerLat;
  double? _resolvedSellerLng;
  double? _resolvedBuyerLat;
  double? _resolvedBuyerLng;

  // Chat variables
  List<dynamic> _conversations = [];
  dynamic _selectedConversation;
  List<dynamic> _messages = [];
  bool _isLoadingChat = false;
  bool _isSendingMessage = false;
  Timer? _chatPollingTimer;
  late int _currentUserId;

  // Recording variables
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

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
      final isSelf = _order!.deliveryMethod == null || 
                     _order!.deliveryMethod.toString().contains('SELF') || 
                     _order!.deliveryMethod.toString().contains('BUYER');
      if (isSelf) {
        _fetchSelfExchangeRoute();
      }
    } else {
      _loadOrderDetails();
    }
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'RecyConnectApp/1.0',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse('${data[0]['lat']}');
          final lon = double.tryParse('${data[0]['lon']}');
          if (lat != null && lon != null) {
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  Future<void> _fetchSelfExchangeRoute() async {
    if (_order == null) return;
    final order = _order!;
    
    setState(() {
      _isLoadingRoute = true;
    });

    double? sellerLat = order.seller?.latitude;
    double? sellerLng = order.seller?.longitude;

    // Fallback to listing coordinates for seller
    final listing = (order.items != null && order.items!.isNotEmpty) 
        ? order.items!.first.listing 
        : null;
    if (sellerLat == null || sellerLng == null) {
      if (listing != null) {
        sellerLat = listing['latitude'] as double?;
        sellerLng = listing['longitude'] as double?;
      }
    }

    // Geocode seller address if still null
    if ((sellerLat == null || sellerLng == null) && order.seller?.address != null && order.seller!.address!.isNotEmpty) {
      final geocoded = await _geocodeAddress(order.seller!.address!);
      if (geocoded != null) {
        sellerLat = geocoded.latitude;
        sellerLng = geocoded.longitude;
      }
    }

    double? buyerLat = order.buyer?.latitude;
    double? buyerLng = order.buyer?.longitude;

    // Fallback for buyer coordinates:
    if (buyerLat == null || buyerLng == null) {
      if (order.buyerId == _currentUserId) {
        // Current user is the buyer, try to get live location
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          buyerLat = position.latitude;
          buyerLng = position.longitude;
        } catch (e) {
          debugPrint('Error getting buyer live location: $e');
        }
      }

      // If still null, try to geocode the address
      if ((buyerLat == null || buyerLng == null) && order.buyer?.address != null && order.buyer!.address!.isNotEmpty) {
        final geocoded = await _geocodeAddress(order.buyer!.address!);
        if (geocoded != null) {
          buyerLat = geocoded.latitude;
          buyerLng = geocoded.longitude;
        }
      }
    }

    if (sellerLat == null || sellerLng == null || buyerLat == null || buyerLng == null) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
      return;
    }

    _resolvedSellerLat = sellerLat;
    _resolvedSellerLng = sellerLng;
    _resolvedBuyerLat = buyerLat;
    _resolvedBuyerLng = buyerLng;

    try {
      final String url = 'https://router.project-osrm.org/route/v1/driving/'
          '$sellerLng,$sellerLat;$buyerLng,$buyerLat'
          '?overview=full&geometries=geojson';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
          final List<LatLng> points = coordinates.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
          final distanceMeters = data['routes'][0]['distance'] as num? ?? 0;
          final durationSeconds = data['routes'][0]['duration'] as num? ?? 0;
          
          if (mounted) {
            setState(() {
              _routePoints = points;
              _routeDistanceKm = distanceMeters / 1000.0;
              _routeDurationMins = durationSeconds / 60.0;
              _isLoadingRoute = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _routePoints = [LatLng(sellerLat!, sellerLng!), LatLng(buyerLat!, buyerLng!)];
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching self-exchange route: $e');
      if (mounted) {
        setState(() {
          _routePoints = [LatLng(sellerLat!, sellerLng!), LatLng(buyerLat!, buyerLng!)];
          _isLoadingRoute = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chatPollingTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record voice notes.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  Future<void> _stopAndSendVoiceNote() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
        _isSendingMessage = true;
      });

      if (path != null && _selectedConversation != null) {
        final result = await _chatService.uploadVoiceNote(path);
        final voiceUrl = result['voiceUrl'] as String?;

        if (voiceUrl != null) {
          final convId = _selectedConversation['id'] as int;
          await _chatService.sendMessage(
            conversationId: convId,
            content: '',
            voiceUrl: voiceUrl,
            messageType: 'VOICE_NOTE',
          );
          _fetchMessages(silent: true, scroll: true);
        } else {
          throw Exception('Failed to get voice url from upload');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send voice note: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.index == 1) {
      // Switched to Chat tab
      _loadChats();
      _startChatPolling();
    } else {
      _chatPollingTimer?.cancel();
    }
    if (mounted) {
      setState(() {});
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
        final isSelf = order.deliveryMethod == null || 
                       order.deliveryMethod.toString().contains('SELF') || 
                       order.deliveryMethod.toString().contains('BUYER');
        if (isSelf) {
          _fetchSelfExchangeRoute();
        }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    setState(() => _isSendingMessage = true);

    try {
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
      if (!mounted) return;
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

  Future<void> _updateOrderStatus(String newStatus) async {
    if (_order == null) return;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Update Order Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Change order status to ${_getStatusDisplayText(newStatus)}?', style: const TextStyle(color: Colors.white70)),
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

      if (confirmed == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: RecycleLoader()),
        );

        final updatedOrder = await _orderService.updateOrderStatus(_order!.id, newStatus);
        
        if (mounted) Navigator.pop(context); // Close loading

        setState(() {
          _order = updatedOrder;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED': return 'Created';
      case 'PENDING': return 'Pending';
      case 'CONFIRMED': return 'Confirmed';
      case 'COLLECTED': return 'Collected';
      case 'COMPLETED': return 'Completed';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }

  Widget? _buildOrderInfoBottomBar(bool isDark) {
    if (_order == null) return null;
    final order = _order!;
    final isSeller = order.sellerId == _currentUserId;
    final isBuyer = order.buyerId == _currentUserId;
    final status = order.status.trim().toUpperCase();
    
    final isSelf = order.deliveryMethod == null || 
                   order.deliveryMethod.toString().contains('SELF') || 
                   order.deliveryMethod.toString().contains('BUYER');

    // Only allow manual status changes if it is a self trade/direct trade
    // If it's a collector dispatch, logistics are automated, so only CREATED acceptance is manual for seller
    if (!isSelf && !isSeller) return null;

    if (status == 'CREATED') {
      if (!isSeller) return null; // Only seller can accept/reject new orders
      return Container(
        padding: const EdgeInsets.all(16),
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                child: const Text('REJECT ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _acceptOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ACCEPT ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    if (isSelf) {
      if (status == 'CONFIRMED') {
        if (isSeller) {
          // Seller is giving the item
          final buttonText = order.deliveryMethod == 'BUYER_PICKUP' ? 'GIVE ITEMS' : 'DISPATCH DELIVERY';
          return Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus('CANCELLED'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus('PROCESSING'), // Transitions to Direct Exchange state
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        } else if (isBuyer) {
          // Buyer can receive or cancel
          return Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus('CANCELLED'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus('COMPLETED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CONFIRM RECEIPT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }
      }
      
      if (status == 'PROCESSING' || status == 'SHIPPED') {
        if (isBuyer) {
          // Buyer has received and completes
          return Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus('COMPLETED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('RECEIVE & COMPLETE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        } else if (isSeller) {
          // Seller is waiting for Buyer to receive, but has a cancel option
          return Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: const Center(
              child: Text(
                'Waiting for Buyer to confirm receipt...',
                style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
          );
        }
      }
    } else {
      // Legacy seller dashboard action updates for collector routes
      if (status == 'PENDING') {
        return Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateOrderStatus('CANCELLED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus('COLLECTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('MARK COLLECTED', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      } else if (status == 'COLLECTED') {
        return Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateOrderStatus('CANCELLED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus('COMPLETED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('MARK COMPLETED', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
    }
    
    return null;
  }

  Widget _buildSelfExchangeMapCard(bool isDark) {
    final order = _order!;
    final sellerLat = _resolvedSellerLat;
    final sellerLng = _resolvedSellerLng;
    final buyerLat = _resolvedBuyerLat;
    final buyerLng = _resolvedBuyerLng;
    
    if (sellerLat == null || sellerLng == null || buyerLat == null || buyerLng == null) {
      return const SizedBox.shrink();
    }
    
    final sellerPos = LatLng(sellerLat, sellerLng);
    final buyerPos = LatLng(buyerLat, buyerLng);
    
    // Determine center of the two points
    final centerLat = (sellerLat + buyerLat) / 2;
    final centerLng = (sellerLng + buyerLng) / 2;
    final center = LatLng(centerLat, centerLng);
    
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    order.deliveryMethod == 'BUYER_PICKUP' ? 'BUYER PICKUP ROUTE' : 'SELF DELIVERY ROUTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (_routeDistanceKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_routeDistanceKm!.toStringAsFixed(1)} km (${_routeDurationMins!.toStringAsFixed(0)} mins)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 13.0,
                      maxZoom: 18,
                      minZoom: 8,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: isDark
                            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.recyconnect.app',
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: const Color(0xFF1D9E75),
                              strokeWidth: 4.5,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: sellerPos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.store,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                          Marker(
                            point: buyerPos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Float Google Maps Navigation Button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'nav_btn_${order.id}',
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        final travelerIsBuyer = order.deliveryMethod == 'BUYER_PICKUP';
                        final double targetLat = travelerIsBuyer ? sellerLat : buyerLat;
                        final double targetLng = travelerIsBuyer ? sellerLng : buyerLng;
                        
                        final uri = Uri.parse('google.navigation:q=$targetLat,$targetLng');
                        final appleUri = Uri.parse('https://maps.apple.com/?daddr=$targetLat,$targetLng');
                        
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else if (await canLaunchUrl(appleUri)) {
                            await launchUrl(appleUri);
                          } else {
                            final fallbackUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$targetLat,$targetLng');
                            await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
                          }
                        } catch (e) {
                          debugPrint('Error launching navigation maps: $e');
                        }
                      },
                      child: const Icon(Icons.navigation, size: 18),
                    ),
                  ),
                  if (_isLoadingRoute)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black38,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.deliveryMethod == 'BUYER_PICKUP'
                ? 'Buyer (${order.buyerName}) is traveling to Seller (${order.sellerName}) location for self-pickup.'
                : 'Seller (${order.sellerName}) is delivering directly to Buyer (${order.buyerName}) address.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
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
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: RecycleLoader()),
    );

    try {
      final updatedOrder = await _orderService.confirmOrder(_order!.id);
      if (!mounted) return;
      Navigator.pop(context); // Pop loading

      setState(() {
        _order = updatedOrder;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted successfully!'), backgroundColor: Colors.green),
      );
      _loadChats(); // Reload chats for new system message
    } catch (e) {
      if (!mounted) return;
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
    if (!mounted) return;
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
      if (!mounted) return;
      Navigator.pop(context); // Pop loading

      // Reload order details to show CANCELLED status
      _loadOrderDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order rejected/cancelled successfully.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
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
      bottomNavigationBar: _isLoadingOrder || _orderError != null || _order == null
          ? null
          : _tabController.index == 0
              ? _buildOrderInfoBottomBar(isDark)
              : null,
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
    final isSelf = order.deliveryMethod == null || 
                   order.deliveryMethod.toString().contains('SELF') || 
                   order.deliveryMethod.toString().contains('BUYER');


    Map<String, dynamic>? verificationTask;
    if (order.collectorTasks != null) {
      for (final t in order.collectorTasks!) {
        if (t is Map && t['verification'] != null) {
          verificationTask = Map<String, dynamic>.from(t);
          break;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticky Status Header Card
          _buildStatusHeaderCard(isDark),
          const SizedBox(height: 16),

          // Collector Verification Card (Real Data Proofs)
          if (verificationTask != null) ...[
            _buildCollectorVerificationCard(verificationTask, isDark),
            const SizedBox(height: 16),
          ],

          // Rate Order Prompt Card (if completed, buyer is current user, and not reviewed)
          if (order.status.trim().toUpperCase() == 'COMPLETED' &&
              order.buyerId == _currentUserId &&
              order.review == null &&
              !_hasReviewed) ...[
            _buildRateOrderCard(isDark),
            const SizedBox(height: 16),
          ],

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

          // Map Card for Self Delivery / Buyer Pickup
          if (isSelf && 
              order.status.trim().toUpperCase() != 'COMPLETED' && 
              order.status.trim().toUpperCase() != 'CANCELLED' && 
              _resolvedSellerLat != null && 
              _resolvedBuyerLat != null) ...[
            _buildSelfExchangeMapCard(isDark),
            const SizedBox(height: 16),
          ],

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

  Widget _buildCollectorVerificationCard(Map<String, dynamic> task, bool isDark) {
    final verification = task['verification'] as Map<String, dynamic>?;
    if (verification == null) return const SizedBox.shrink();

    final collector = task['collector'] as Map<String, dynamic>?;
    final collectorName = collector?['name']?.toString() ?? 'Collector';
    final collectorPhone = collector?['contactNo']?.toString() ?? '';

    final verifiedWeight = verification['verifiedWeight']?.toString() ?? '0';
    final verifiedCategory = verification['verifiedCategory']?.toString() ?? '-';
    final verifiedMaterial = verification['verifiedMaterial']?.toString() ?? '';
    final notes = verification['notes']?.toString() ?? '';
    final List<dynamic> proofImages = verification['proofImages'] as List<dynamic>? ?? [];

    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'COLLECTOR VERIFICATION PROOF',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Side-by-side stats for Weight and Category
          Row(
            children: [
              Expanded(
                child: _buildVerificationStatTile(
                  'Verified Weight',
                  '$verifiedWeight kg',
                  Icons.scale_outlined,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVerificationStatTile(
                  'Verified Category',
                  verifiedCategory,
                  Icons.category_outlined,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (verifiedMaterial.isNotEmpty) ...[
            _buildVerificationStatTile(
              'Material Type',
              verifiedMaterial,
              Icons.recycling_outlined,
              isDark,
              isWide: true,
            ),
            const SizedBox(height: 12),
          ],

          if (notes.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes from Collector',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Proof images
          if (proofImages.isNotEmpty) ...[
            const Text(
              'PROOF IMAGES',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: proofImages.length,
                itemBuilder: (context, idx) {
                  final imgUrl = proofImages[idx].toString();
                  return GestureDetector(
                    onTap: () => _showFullImageDialog(imgUrl),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(),
          const SizedBox(height: 6),

          // Collector details
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                child: Icon(Icons.person_outline, size: 18, color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collectorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Text(
                      'Assigned Waste Collector',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (collectorPhone.isNotEmpty)
                IconButton.filledTonal(
                  onPressed: () => launchUrl(Uri.parse('tel:$collectorPhone')),
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatTile(String label, String value, IconData icon, bool isDark, {bool isWide = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppColors.neonCyan : AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(String imgUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.network(imgUrl, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
              color: accentColor.withValues(alpha: 0.15),
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
        border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F2D1A), const Color(0xFF071F10)]
              : [Colors.green.shade50, Colors.green.shade100],
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.08),
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
    final isSelf = order.deliveryMethod == null || 
                   order.deliveryMethod.toString().contains('SELF') || 
                   order.deliveryMethod.toString().contains('BUYER');

    final task = (order.collectorTasks != null && order.collectorTasks!.isNotEmpty)
        ? order.collectorTasks!.first as Map<String, dynamic>
        : null;

    final List<Map<String, dynamic>> steps;

    if (isSelf) {
      steps = [
        {
          'title': 'Order Placed',
          'subtitle': 'Your order has been recorded.',
          'isDone': true,
          'isActive': order.status.trim().toUpperCase() == 'CREATED',
        },
        {
          'title': 'Confirmed',
          'subtitle': 'Seller accepted the trade.',
          'isDone': ['CONFIRMED', 'SHIPPED', 'DELIVERED', 'COMPLETED'].contains(order.status.trim().toUpperCase()),
          'isActive': order.status.trim().toUpperCase() == 'CONFIRMED',
        },
        {
          'title': 'Self Exchange',
          'subtitle': 'Buyer and seller exchanging directly.',
          'isDone': ['SHIPPED', 'DELIVERED', 'COMPLETED'].contains(order.status.trim().toUpperCase()),
          'isActive': ['SHIPPED', 'DELIVERED'].contains(order.status.trim().toUpperCase()),
        },
        {
          'title': 'Completed',
          'subtitle': 'Trade successfully resolved.',
          'isDone': order.status.trim().toUpperCase() == 'COMPLETED',
          'isActive': order.status.trim().toUpperCase() == 'COMPLETED',
        },
      ];
    } else {
      steps = [
        {
          'title': 'Order Placed',
          'subtitle': 'Waiting for collector dispatch.',
          'isDone': true,
          'isActive': task == null || task['status'] == 'ASSIGNED',
        },
        {
          'title': 'Collector Assigned',
          'subtitle': task != null && task['collector'] != null
              ? 'Rider ${task['collector']['name']} accepted the task.'
              : 'Awaiting a rider to claim the job.',
          'isDone': task != null && ['ACCEPTED', 'EN_ROUTE_TO_PICKUP', 'ARRIVED_AT_SOURCE', 'VERIFIED', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'DELIVERED', 'COMPLETED'].contains(task['status']),
          'isActive': task != null && ['ACCEPTED', 'EN_ROUTE_TO_PICKUP', 'ARRIVED_AT_SOURCE'].contains(task['status']),
        },
        {
          'title': 'Picked Up & Verified',
          'subtitle': 'Collector verified quality and loaded materials.',
          'isDone': task != null && ['VERIFIED', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'DELIVERED', 'COMPLETED'].contains(task['status']),
          'isActive': task != null && ['VERIFIED', 'PICKED_UP'].contains(task['status']),
        },
        {
          'title': 'In Transit',
          'subtitle': 'Rider is carrying the shipment to you.',
          'isDone': task != null && ['IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'DELIVERED', 'COMPLETED'].contains(task['status']),
          'isActive': task != null && ['IN_TRANSIT', 'ARRIVED_AT_DESTINATION', 'DELIVERED'].contains(task['status']),
        },
        {
          'title': 'Completed',
          'subtitle': 'Shipment delivered successfully.',
          'isDone': order.status.trim().toUpperCase() == 'COMPLETED' || (task != null && task['status'] == 'COMPLETED'),
          'isActive': order.status.trim().toUpperCase() == 'COMPLETED' || (task != null && task['status'] == 'COMPLETED'),
        },
      ];
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSelf ? 'DIRECT TRADE TIMELINE' : 'SHIPMENT LOGISTICS TRACKING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final bool isDone = order.status.trim().toUpperCase() == 'CANCELLED' ? false : step['isDone'] == true;
            final bool isActive = order.status.trim().toUpperCase() == 'CANCELLED' ? false : step['isActive'] == true;

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
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: isDone && steps[index + 1]['isDone'] == true
                            ? Colors.green
                            : (isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'],
                        style: TextStyle(
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step['subtitle'],
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            );
          }),
          if (order.status.trim().toUpperCase() == 'CANCELLED' || (task != null && task['status'] == 'CANCELLED')) ...[
            const Divider(),
            Row(
              children: const [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Order/Shipment Cancelled',
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
    final isCollector = order.deliveryMethod != null &&
        (order.deliveryMethod == 'WAREHOUSE_COLLECTOR_SERVICE' ||
        order.deliveryMethod.toString().contains('COLLECTOR'));

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
                    final String voiceUrl = msg['voiceUrl'] ?? '';
                    final DateTime date = msg['createdAt'] != null
                        ? DateTime.parse(msg['createdAt'])
                        : DateTime.now();
                    final String timeStr = DateFormat('hh:mm a').format(date);

                    return _buildChatBubble(isMe, content, messageType, timeStr, isDark, voiceUrl: voiceUrl);
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
                    ? (isDark ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.primaryGreen.withValues(alpha: 0.1))
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

  Widget _buildChatBubble(bool isMe, String content, String messageType, String timeStr, bool isDark, {String? voiceUrl}) {
    final bool isSystem = messageType == 'SYSTEM';
    final bool isLocation = messageType == 'LOCATION' || content.startsWith('LOCATION_SHARE:');
    final bool isVoice = messageType == 'VOICE_NOTE' || (voiceUrl != null && voiceUrl.isNotEmpty);

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
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
    } else if (isVoice) {
      body = VoiceNoteBubble(
        voiceUrl: voiceUrl ?? '',
        isMe: isMe,
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
                      ? (isDark ? AppColors.neonGreen.withValues(alpha: 0.8) : AppColors.primaryGreen)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: isLocation ? Border.all(color: Colors.orange.withValues(alpha: 0.5)) : null,
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
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
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
    final orderStatus = _order?.status.trim().toUpperCase() ?? '';
    final isClosed = orderStatus == 'COMPLETED' || 
                     orderStatus == 'CANCELLED' || 
                     _selectedConversation?['status'] == 'ARCHIVED';

    if (isClosed) {
      return Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                orderStatus == 'COMPLETED' ? Icons.check_circle_outline : Icons.lock_outline,
                color: orderStatus == 'COMPLETED' ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                orderStatus == 'COMPLETED'
                    ? 'This chat is closed because the order is completed.'
                    : orderStatus == 'CANCELLED'
                        ? 'This chat is closed because the order is cancelled.'
                        : 'This chat is closed.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const Icon(Icons.mic, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Recording... ${_recordingDuration}s',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _cancelRecording,
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _stopAndSendVoiceNote,
              ),
            ],
          ),
        ),
      );
    }

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
                onChanged: (text) {
                  setState(() {});
                },
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

            // Send or Record button
            GestureDetector(
              onTap: _messageController.text.trim().isEmpty
                  ? _startRecording
                  : _sendMessage,
              child: CircleAvatar(
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                radius: 20,
                child: _isSendingMessage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(
                        _messageController.text.trim().isEmpty ? Icons.mic : Icons.send,
                        color: isDark ? Colors.black : Colors.white,
                        size: 16,
                      ),
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



  Widget _buildRateOrderCard(bool isDark) {
    final accentColor = isDark ? AppColors.neonCyan : AppColors.primaryGreen;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F1E2E), const Color(0xFF0A1420)]
              : [Colors.green.shade50, Colors.green.shade100],
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.05),
                  blurRadius: 15,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFFFFA726),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rate Your Transaction!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your feedback helps maintain a trustworthy community. Submit a review of ${_order!.sellerName} and earn +5 Eco Points!',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => RatingsReviewsDialog(
                    orderId: _order!.id,
                    sellerName: _order!.sellerName,
                  ),
                );
                if (result == true) {
                  setState(() {
                    _hasReviewed = true;
                  });
                }
              },
              icon: const Icon(Icons.rate_review_rounded, size: 18),
              label: const Text(
                'Rate Order',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.primaryGreen,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
