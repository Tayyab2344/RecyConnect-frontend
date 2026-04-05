import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/listing_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/reservation_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/marketplace/neon_button.dart';

class CheckoutScreen extends StatefulWidget {
  final Listing item;

  const CheckoutScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ReservationService _reservationService = ReservationService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.fetchProfile();
      if (response['success'] == true) {
        final data = response['data']['data'];
        final addressParts = <String>[];
        if (data['address'] != null) addressParts.add(data['address']);
        if (data['city'] != null) addressParts.add(data['city']);
        
        if (addressParts.isNotEmpty) {
          if (mounted) {
            setState(() {
              _addressController.text = addressParts.join(', ');
            });
          }
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

    setState(() => _isLoading = true);

    int? reservationId;

    try {
      // 1. Reserve 1 unit of the listing (idempotent - safe to retry)
      final reservationResult = await _reservationService.reserveListing(widget.item.id, 1.0);
      reservationId = reservationResult['data']?['reservation']?['id'] as int?;

      // 2. Create Order
      final order = Order(
        id: 0,
        buyerId: 0,
        sellerId: widget.item.userId,
        materialType: widget.item.materialType,
        weight: widget.item.estimatedWeight,
        pickupAddress: _addressController.text,
        paymentMethod: _paymentMethod,
        status: 'PENDING',
        reservationId: reservationId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final createdOrder = await _orderService.createOrder(order);

      // 3. Handle Payment
      if (_paymentMethod == 'COD') {
        await _paymentService.createCodPayment(createdOrder.id);
      } else {
        await _paymentService.createPaymentIntent(createdOrder.id);
        final paymentsResult = await _paymentService.getPaymentMethods(createdOrder.id);
        if (paymentsResult['success'] == true && (paymentsResult['data'] as List).isNotEmpty) {
          final paymentId = paymentsResult['data'][0]['id'] as int;
          await _paymentService.authorizePayment(paymentId);
          await _paymentService.capturePayment(paymentId);
        }
      }

      if (!mounted) return;

      // 4. Show Success
      _showSuccessDialog();

    } catch (e) {
      // Release the reservation so the user can retry
      if (reservationId != null) {
        try {
          await _reservationService.releaseReservation(reservationId);
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: ${e.toString().replaceAll("Exception: ", "")}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: MarketplaceTheme.lightAccent, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your payment/order has been successfully processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              NeonButton(
                text: 'CONTINUE SHOPPING',
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  int count = 0;
                  Navigator.of(context).popUntil((route) {
                    return count++ == 2; // Pop checkout and item detail
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    // Mock rate calculation as before, typical values
    final rate = 20.0; 
    final total = item.estimatedWeight * rate;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(
            color: isDark ? MarketplaceTheme.darkTextPrimary : MarketplaceTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? MarketplaceTheme.darkTextPrimary : MarketplaceTheme.lightTextPrimary),
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
                      // Order Summary
                      Text(
                        'ORDER SUMMARY',
                        style: TextStyle(
                          color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.estimatedWeight} kg of ${item.materialType}',
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                                Text('Rs ${total.toStringAsFixed(0)}',
                                  style: TextStyle(color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Fee', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                                Text('Free', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('Rs ${total.toStringAsFixed(0)}',
                                  style: TextStyle(color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Address
                      Text(
                        'DELIVERY ADDRESS',
                        style: TextStyle(
                          color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: _addressController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter full delivery address',
                            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black12),
                            icon: Icon(Icons.location_on_outlined, color: isDark ? Colors.white54 : Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method
                      Text(
                        'PAYMENT METHOD',
                        style: TextStyle(
                          color: isDark ? MarketplaceTheme.darkAccentCyan : MarketplaceTheme.lightAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Cash on Delivery (COD)', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              value: 'COD',
                              groupValue: _paymentMethod,
                              activeColor: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
                              onChanged: (val) => setState(() => _paymentMethod = val!),
                            ),
                            RadioListTile<String>(
                              title: Text('Pay via Stripe', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              value: 'STRIPE',
                              groupValue: _paymentMethod,
                              activeColor: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
                              onChanged: (val) => setState(() => _paymentMethod = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                  boxShadow: [
                    BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 10,
                       offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'CONFIRM ORDER',
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
}
