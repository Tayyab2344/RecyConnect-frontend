import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/listing_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/marketplace_theme.dart';
import '../../../widgets/marketplace/glass_card.dart';
import '../../../widgets/marketplace/neon_button.dart';

class CheckoutScreen extends StatefulWidget {
  final Listing item;

  const CheckoutScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  // 'cod' = Cash on Delivery, 'stripe' = Stripe online payment
  String _selectedPaymentMethod = 'cod';

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
        if (addressParts.isNotEmpty && mounted) {
          setState(() => _addressController.text = addressParts.join(', '));
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

    const rate = 20.0; // Standard rate used in UI
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

    try {
      // Step 1: Create the order
      final Order order = await _orderService.createOrder(
        widget.item.id,
        widget.item.estimatedWeight,
        paymentMethod: _selectedPaymentMethod,
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
        _showSuccessDialog(isCod: true);
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
      if (mounted) _showSuccessDialog(isCod: false);
    } on StripeException catch (e) {
      if (!mounted) return;
      // Cancel the order since payment was not completed
      await _orderService.cancelOrder(order.id, reason: 'Stripe payment cancelled/failed');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.isNotEmpty ? errorMsg : 'Payment setup failed. Please try again.'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessDialog({required bool isCod}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? MarketplaceTheme.darkAccentGreen
        : MarketplaceTheme.lightAccent;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2D40) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? accentColor.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? accentColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
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
                  color: accentColor.withOpacity(0.1),
                  border: Border.all(
                    color: accentColor.withOpacity(0.4),
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
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'RETURN TO MARKETPLACE',
                  onPressed: () {
                    // Close the success dialog first
                    Navigator.of(ctx).pop();
                    // Pop the CheckoutScreen and signal success (true) so that
                    // ItemDetailScreen can pop itself and return to the marketplace.
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
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
    const rate = 20.0; // Rs/kg fallback rate
    final total = item.estimatedWeight * rate;

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
                                Text('Free',
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
                            color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                      ? const Color(0xFF0F172A).withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  border: Border(
                      top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12)),
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
              ? accentColor.withOpacity(isDark ? 0.10 : 0.06)
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.75)),
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
                      ? accentColor.withOpacity(0.15)
                      : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
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
                              color: const Color(0xFF635BFF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF635BFF).withOpacity(0.4)),
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
}
