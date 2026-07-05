import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/listing_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/marketplace/neon_button.dart';
import '../../marketplace/location_selection_screen.dart';
import 'order_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Listing item;

  const CheckoutScreen({super.key, required this.item});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final ApiService _apiService = ApiService();

  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  // 'cod' = Cash on Delivery, 'stripe' = Stripe online payment
  String _selectedPaymentMethod = 'cod';
  String _selectedDeliveryMethod = 'RECYCONNECT_PICKUP';

  List<dynamic> _nearbyWarehouses = [];
  bool _loadingWarehouses = false;
  int? _selectedWarehouseId;
  String _assignmentType = 'automatic'; // 'automatic' or 'manual'

  Future<void> _loadNearbyWarehouses() async {
    if (_latitude == null || _longitude == null) return;
    setState(() {
      _loadingWarehouses = true;
    });
    try {
      final response = await _apiService.get(
        '/dispatch/nearby-warehouses',
        query: {
          'latitude': _latitude,
          'longitude': _longitude,
        },
      );
      if (response['success'] == true) {
        setState(() {
          _nearbyWarehouses = response['data'] as List<dynamic>;
          _loadingWarehouses = false;
        });
      } else {
        setState(() {
          _loadingWarehouses = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading nearby warehouses: $e');
      setState(() {
        _loadingWarehouses = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final pickupRequired = widget.item.metadata?['pickupRequired'] ?? true;
    _selectedDeliveryMethod = pickupRequired ? 'RECYCONNECT_PICKUP' : 'SELF_DELIVERY';
    _loadUserLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      final locationService = LocationService();
      // Prompt for location permissions on page initialization
      await locationService.requestLocationPermission();

      double? lat;
      double? lng;
      String? addressText;

      // Always try to fetch current GPS coordinates first
      final gpsData = await locationService.getCurrentLocationWithTimeout(
        timeout: const Duration(seconds: 4),
      );
      if (gpsData != null) {
        lat = gpsData['latitude'];
        lng = gpsData['longitude'];
        if (lat != null && lng != null) {
          final addressData = await locationService.getAddressFromCoordinates(lat, lng);
          if (addressData != null) {
            final street = addressData['street'] ?? '';
            final subLocality = addressData['subLocality'] ?? '';
            final locality = addressData['locality'] ?? '';
            final province = addressData['administrativeArea'] ?? '';
            final List<String> parts = [
              if (street.isNotEmpty) street,
              if (subLocality.isNotEmpty) subLocality,
              if (locality.isNotEmpty) locality,
              if (province.isNotEmpty) province,
            ];
            if (parts.isNotEmpty) {
              addressText = parts.join(', ');
            }
          }
        }
      }

      // If GPS failed or is null, fallback to profile location
      if (lat == null || lng == null) {
        if (!mounted) return;
        final authService = Provider.of<AuthService>(context, listen: false);
        final response = await authService.fetchProfile();
        if (response['success'] == true) {
          final data = response['data'] as Map<String, dynamic>;
          final addressParts = <String>[];
          final address = data['address']?.toString().trim();
          final area = data['area']?.toString().trim();
          final city = data['city']?.toString().trim();
          if (address != null && address.isNotEmpty) addressParts.add(address);
          if (area != null && area.isNotEmpty && !addressParts.contains(area)) {
            addressParts.add(area);
          }
          if (city != null && city.isNotEmpty && !addressParts.contains(city)) {
            addressParts.add(city);
          }

          if (addressParts.isNotEmpty) {
            addressText = addressParts.join(', ');
          }
          if (data['latitude'] != null) {
            lat = data['latitude'] is String ? double.tryParse(data['latitude']) : (data['latitude'] as num).toDouble();
          }
          if (data['longitude'] != null) {
            lng = data['longitude'] is String ? double.tryParse(data['longitude']) : (data['longitude'] as num).toDouble();
          }
        }
      }

      if (mounted) {
        setState(() {
          if (addressText != null) {
            _addressController.text = addressText;
          }
          _latitude = lat;
          _longitude = lng;
        });

        // Load nearby warehouses once we have coordinates
        if (_latitude != null && _longitude != null) {
          _loadNearbyWarehouses();
        }
      }
    } catch (_) {}
  }

  Future<void> _processCheckout() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    final rate = widget.item.price > 0 ? widget.item.price : 20.0;
    final total = widget.item.estimatedWeight * rate;
    if (_selectedPaymentMethod == 'stripe' && total < 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Minimum order amount for online payment is Rs 150. Please use Cash on Delivery (COD).'),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    double? lat = _latitude;
    double? lng = _longitude;
    String? city;

    if (lat == null || lng == null) {
      try {
        final locationService = LocationService();
        final gpsData = await locationService.getCurrentLocationWithTimeout(
          timeout: const Duration(seconds: 4),
        );
        if (gpsData != null) {
          lat = gpsData['latitude'];
          lng = gpsData['longitude'];
        }
      } catch (e) {
        debugPrint('Error fetching GPS for checkout fallback: $e');
      }
    }

    if (lat != null && lng != null) {
      try {
        final locationService = LocationService();
        final addressData = await locationService.getAddressFromCoordinates(lat, lng);
        if (addressData != null) {
          city = addressData['locality']?.isNotEmpty == true ? addressData['locality'] : null;
        }
      } catch (e) {
        debugPrint('Error geocoding address for checkout: $e');
      }
    }

    try {
      // Update buyer's location on their profile so the backend has updated coordinates
      final Map<String, dynamic> updateData = {
        'address': _addressController.text.trim(),
      };
      if (lat != null && lng != null) {
        updateData['latitude'] = lat;
        updateData['longitude'] = lng;
      }
      if (city != null) {
        updateData['city'] = city;
      }
      // Update profile
      await authService.updateProfile(updateData, null);
    } catch (e) {
      debugPrint('Error updating profile with delivery coordinates: $e');
    }

    try {
      // Step 1: Create the order
      final Order order = await _orderService.createOrder(
        widget.item.id,
        widget.item.estimatedWeight,
        paymentMethod: _selectedPaymentMethod,
        deliveryMethod: _selectedDeliveryMethod,
        buyerLatitude: lat,
        buyerLongitude: lng,
        chosenWarehouseId: _selectedDeliveryMethod == 'RECYCONNECT_PICKUP' && _assignmentType == 'manual'
            ? _selectedWarehouseId
            : null,
      );

      if (!mounted) return;

      // Step 2: If Stripe selected, launch Stripe Payment Sheet
      if (_selectedPaymentMethod == 'stripe') {
        await _launchStripePayment(order);
      } else {
        // COD: create the COD payment record in the backend, then show success
        try {
          await _paymentService.createCodPayment(order.id);
        } catch (e) {
          // Log but don't block — order is already created
          debugPrint('COD payment record creation failed: $e');
        }
        _showSuccessDialog(order, isCod: true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
                .replaceAll('Exception: ', '')
                .replaceAll('Error creating order: Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchStripePayment(Order order) async {
    try {
      // Step 3: Get PaymentIntent clientSecret from backend
      final intentData = await _paymentService.createPaymentIntent(order.id);
      final clientSecret = intentData['data']?['clientSecret'] as String?;

      if (clientSecret == null) {
        // Cancel the order since payment can't proceed
        await _orderService.cancelOrder(order.id, reason: 'Payment setup failed');
        throw Exception('Payment setup failed — no client secret returned.');
      }

      // Step 4: Init Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'RecyConnect',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF00E676),
              background: Color(0xFF0D1B2A),
              componentBackground: Color(0xFF1A2D40),
              componentText: Colors.white,
              primaryText: Colors.white,
              secondaryText: Color(0xFFB0C4DE),
              placeholderText: Color(0xFF6B8FAB),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 14,
            ),
          ),
        ),
      );

      // Step 5: Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      if (mounted) _showSuccessDialog(order, isCod: false);
    } on StripeException catch (e) {
      if (!mounted) return;
      // Cancel the order since payment was not completed
      await _orderService.cancelOrder(order.id, reason: 'Stripe payment cancelled/failed');
      if (!mounted) return;
      if (e.error.code == FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage ?? e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      // Catch backend/network errors (e.g., 400 from create-intent)
      if (!mounted) return;
      final errorMsg = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('Error creating order: Exception: ', '');
      debugPrint('Stripe payment setup error: $e');
      // Cancel the order since payment setup failed
      await _orderService.cancelOrder(order.id, reason: 'Payment setup failed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.isNotEmpty ? errorMsg : 'Payment setup failed. Please try again.'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessDialog(Order order, {required bool isCod}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? MarketplaceTheme.darkAccentGreen
        : MarketplaceTheme.lightAccent;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Automatically close dialog and redirect after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) {
            Navigator.of(ctx).pop(); // Close success dialog
          }
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(order: order),
              ),
            );
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2D40) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? accentColor.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? accentColor.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animated circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCod
                        ? Icons.check_circle_outline_rounded
                        : Icons.verified_rounded,
                    color: accentColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isCod ? 'Order Placed!' : 'Payment Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isCod
                      ? 'Your order is placed. Cash payment will be collected on delivery after the seller confirms.'
                      : 'Your payment was processed successfully via Stripe. The seller will confirm your order shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 10),
                Text(
                  'Redirecting to order details...',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final authService = Provider.of<AuthService>(context);
    final userRole = authService.userRole;
    final rate = item.price > 0 ? item.price : 20.0;
    final deliveryFee = 0.0; // Collector fee removed for all users
    final total = item.estimatedWeight * rate + deliveryFee;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(
            color: isDark
                ? MarketplaceTheme.darkTextPrimary
                : MarketplaceTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? MarketplaceTheme.darkTextPrimary
                : MarketplaceTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: MarketplaceTheme.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ORDER SUMMARY ──────────────────────────────
                      _sectionLabel('ORDER SUMMARY', isDark),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.displayTitle,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rs ${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: isDark
                                        ? MarketplaceTheme.darkAccentGreen
                                        : MarketplaceTheme.lightAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Fee',
                                    style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54)),
                                Text(deliveryFee > 0 ? 'Rs ${deliveryFee.toStringAsFixed(0)}' : 'Free',
                                    style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('Rs ${total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: isDark
                                            ? MarketplaceTheme.darkAccentGreen
                                            : MarketplaceTheme.lightAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── DELIVERY ADDRESS ───────────────────────────
                      _sectionLabel('DELIVERY ADDRESS', isDark),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: _addressController,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter full delivery address',
                            hintStyle: TextStyle(
                                color: isDark ? Colors.white24 : Colors.black12),
                            icon: Icon(Icons.location_on_outlined,
                                color: isDark ? Colors.white54 : Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_latitude != null && _longitude != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: FlutterMap(
                              key: ValueKey('$_latitude,$_longitude'),
                              options: MapOptions(
                                initialCenter: LatLng(_latitude!, _longitude!),
                                initialZoom: 14.5,
                                maxZoom: 18,
                                minZoom: 8,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.recyconnect.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_latitude!, _longitude!),
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.location_on,
                                        color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('CONFIRM LOCATION'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                            side: BorderSide(
                              color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationSelectionScreen(
                                  initialLocation: LatLng(_latitude ?? 33.7687, _longitude ?? 72.3618),
                                  initialAddress: _addressController.text,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _latitude = result['latitude'];
                                _longitude = result['longitude'];
                                _addressController.text = result['address'];
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── DELIVERY METHOD ─────────────────────────────
                      _sectionLabel('DELIVERY METHOD', isDark),
                      const SizedBox(height: 12),
                      _buildDeliveryMethodOption(
                        isDark: isDark,
                        value: 'SELF_DELIVERY',
                        icon: Icons.directions_car_rounded,
                        title: 'Self Delivery',
                        subtitle: 'Seller will self-deliver the materials to you directly.',
                      ),
                      const SizedBox(height: 10),
                      _buildDeliveryMethodOption(
                        isDark: isDark,
                        value: 'BUYER_PICKUP',
                        icon: Icons.store_rounded,
                        title: 'Buyer Pickup',
                        subtitle: 'Go to the seller’s location to pick up materials yourself.',
                      ),
                      if (widget.item.metadata?['pickupRequired'] ?? true) ...[
                        const SizedBox(height: 10),
                        _buildDeliveryMethodOption(
                          isDark: isDark,
                          value: 'RECYCONNECT_PICKUP',
                          icon: Icons.local_shipping_rounded,
                          title: 'RecyConnect Pickup',
                          subtitle: 'RecyConnect logistics warehouse collector picks up and delivers. Free delivery.',
                          badge: 'RECOMMENDED',
                        ),
                      ],
                      if (_selectedDeliveryMethod == 'RECYCONNECT_PICKUP' && userRole != 'warehouse') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logistics Assignment Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAssignmentTypeBtn(
                                      title: 'Auto-Assign',
                                      value: 'automatic',
                                      isSelected: _assignmentType == 'automatic',
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAssignmentTypeBtn(
                                      title: 'Choose Warehouse',
                                      value: 'manual',
                                      isSelected: _assignmentType == 'manual',
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              if (_assignmentType == 'manual') ...[
                                const SizedBox(height: 16),
                                if (_loadingWarehouses)
                                  const Center(child: CircularProgressIndicator())
                                else if (_nearbyWarehouses.isEmpty)
                                  Text(
                                    'No nearby logistics providers found within range.',
                                    style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                                  )
                                else ...[
                                  Text(
                                    'Select Nearby Warehouse Provider:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _nearbyWarehouses.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final wh = _nearbyWarehouses[index];
                                      final isWhSelected = _selectedWarehouseId == wh['id'];
                                      final whAccentColor = isDark
                                          ? MarketplaceTheme.darkAccentGreen
                                          : MarketplaceTheme.lightAccent;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedWarehouseId = wh['id'];
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isWhSelected
                                                ? whAccentColor.withValues(alpha: isDark ? 0.15 : 0.08)
                                                : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
                                            border: Border.all(
                                              color: isWhSelected
                                                  ? whAccentColor
                                                  : (isDark ? Colors.white12 : Colors.black12),
                                              width: isWhSelected ? 1.5 : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      wh['name'] ?? 'Warehouse',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                        color: isDark ? Colors.white : Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.location_on, size: 12, color: Colors.grey),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${wh['distance']} km away',
                                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Icon(Icons.star, size: 12, color: Colors.amber),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${wh['rating']}',
                                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Delivery: Rs 0',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: wh['collectorAvailability'] == 'AVAILABLE'
                                                          ? Colors.green.withValues(alpha: 0.15)
                                                          : Colors.orange.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      wh['collectorAvailability'] ?? 'UNAVAILABLE',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                        color: wh['collectorAvailability'] == 'AVAILABLE'
                                                            ? Colors.green
                                                            : Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── PAYMENT METHOD ─────────────────────────────
                      _sectionLabel('PAYMENT METHOD', isDark),
                      const SizedBox(height: 12),

                      // Cash on Delivery
                      _buildPaymentOption(
                        isDark: isDark,
                        value: 'cod',
                        icon: Icons.payments_outlined,
                        title: 'Cash on Delivery',
                        subtitle:
                            'Pay cash when your order is delivered, arranged with the seller after confirmation.',
                      ),
                      const SizedBox(height: 10),

                      // Stripe
                      if (total >= 160)
                        _buildPaymentOption(
                          isDark: isDark,
                          value: 'stripe',
                          icon: Icons.credit_card_rounded,
                          title: 'Pay with Stripe',
                          subtitle:
                              'Secure card payment powered by Stripe. You\'ll be prompted to enter your card details.',
                          badge: 'SECURE',
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Online payment via Stripe is only available for orders of Rs 160 or more.',
                                  style: TextStyle(
                                    color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── CONFIRM BUTTON ─────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  border: Border(
                      top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: _selectedPaymentMethod == 'stripe'
                        ? 'PAY WITH STRIPE'
                        : 'CONFIRM ORDER',
                    isLoading: _isLoading,
                    onPressed: _processCheckout,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          color: isDark
              ? MarketplaceTheme.darkAccentCyan
              : MarketplaceTheme.lightAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      );

  Widget _buildPaymentOption({
    required bool isDark,
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    final accentColor = isDark
        ? MarketplaceTheme.darkAccentGreen
        : MarketplaceTheme.lightAccent;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.10 : 0.06)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.75)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? accentColor
                      : (isDark ? Colors.white54 : Colors.black38),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Text + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF635BFF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF635BFF).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF635BFF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark ? Colors.white30 : Colors.black26),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                           width: 10,
                           height: 10,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             color: accentColor,
                           ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodOption({
    required bool isDark,
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedDeliveryMethod == value;
    final accentColor = isDark
        ? MarketplaceTheme.darkAccentGreen
        : MarketplaceTheme.lightAccent;

    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.10 : 0.06)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.75)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? accentColor
                      : (isDark ? Colors.white54 : Colors.black38),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Text + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF635BFF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF635BFF).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF635BFF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark ? Colors.white30 : Colors.black26),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                           width: 10,
                           height: 10,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             color: accentColor,
                           ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentTypeBtn({
    required String title,
    required String value,
    required bool isSelected,
    required bool isDark,
  }) {
    final accentColor = isDark
        ? MarketplaceTheme.darkAccentGreen
        : MarketplaceTheme.lightAccent;

    return GestureDetector(
      onTap: () {
        setState(() {
          _assignmentType = value;
          if (value == 'manual') {
            _loadNearbyWarehouses();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white24 : Colors.black26),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

