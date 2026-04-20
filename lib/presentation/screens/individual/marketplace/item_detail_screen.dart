import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/listing_model.dart';
import '../../../../core/services/auth_service.dart';
import 'checkout_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Listing item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;

  Color _materialColor() {
    switch (widget.item.materialType.toLowerCase()) {
      case 'plastic':
        return const Color(0xFFFF7043);
      case 'metal':
        return const Color(0xFF546E7A);
      case 'paper':
        return const Color(0xFF1565C0);
      case 'e-waste':
        return const Color(0xFF6A1B9A);
      case 'glass':
        return const Color(0xFF00838F);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: _materialColor().withOpacity(isDark ? 0.15 : 0.08),
      child: Center(
        child: Icon(
          Icons.recycling_rounded,
          size: 72,
          color: _materialColor().withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final hasImages = widget.item.hasNetworkImages || widget.item.decodedImages.isNotEmpty;
    if (!hasImages) return _buildImagePlaceholder(isDark);

    final imageCount = widget.item.hasNetworkImages
        ? widget.item.imageUrls.length
        : widget.item.decodedImages.length;

    return Stack(
      children: [
        PageView.builder(
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemCount: imageCount,
          itemBuilder: (context, index) {
            if (widget.item.hasNetworkImages) {
              return Image.network(
                widget.item.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildImagePlaceholder(isDark);
                },
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(isDark),
              );
            } else {
              return Image.memory(
                widget.item.decodedImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
          },
        ),
        if (imageCount > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageCount, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 10 : 7,
                  height: _currentImageIndex == index ? 10 : 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _sectionCard({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow({required String label, required String value, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _featurePill(IconData icon, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A3A2A) : const Color(0xFFF0FBF0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFBBE5BB),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5FAF5);
    final primaryGreen = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFF4CAF50);
    final totalPrice = (widget.item.estimatedWeight * 20).toStringAsFixed(0);
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Image ──────────────────────────────────
                    Stack(
                      children: [
                        Container(
                          height: size.height * 0.40,
                          width: double.infinity,
                          color: isDark ? const Color(0xFF1A2A1A) : const Color(0xFFE8F5E9),
                          child: _buildImage(isDark),
                        ),
                        // Gradient overlay at bottom of image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [bgColor, bgColor.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Main Content ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Category Badge ──────────────────────────
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _materialColor().withOpacity(isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _materialColor().withOpacity(isDark ? 0.4 : 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.item.materialTypeDisplay.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? _materialColor().withOpacity(0.9)
                                        : _materialColor(),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Item Details Card ───────────────────────
                          _sectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.displayTitle,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoRow(
                                      label: 'Weight',
                                      value: '${widget.item.estimatedWeight} kg',
                                      isDark: isDark,
                                    ),
                                    _infoRow(
                                      label: 'Posted On',
                                      value: DateFormat('MMM dd, yyyy').format(widget.item.createdAt),
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Seller Profile Card ───────────────────────
                          _sectionCard(
                            isDark: isDark,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isDark ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                                  child: Icon(Icons.person, color: isDark ? Colors.white : const Color(0xFF2E7D32), size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.item.user?.name ?? 'Verified Seller',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.item.user?.createdAt != null 
                                          ? 'Member since ${DateFormat('MMM yyyy').format(widget.item.user!.createdAt!)}' 
                                          : 'Active Member',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black26),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Logistics & Notes Card ───────────────────────
                          _sectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(
                                  label: 'Pickup Location',
                                  value: widget.item.pickupAddress.isNotEmpty
                                      ? widget.item.pickupAddress
                                      : 'Location shared after purchase',
                                  isDark: isDark,
                                ),
                                if (widget.item.notes != null &&
                                    widget.item.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Divider(color: isDark ? Colors.white12 : Colors.black12),
                                  const SizedBox(height: 8),
                                  _infoRow(
                                    label: 'Seller Notes',
                                    value: widget.item.notes!,
                                    isDark: isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Price Card ──────────────────────────────
                          _sectionCard(
                            isDark: isDark,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Price',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rs $totalPrice',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? lightGreen : primaryGreen,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '/ negotiable',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white38 : const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Eco points pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.eco_rounded, color: lightGreen, size: 20),
                                      const SizedBox(height: 2),
                                      Text(
                                        '+${(widget.item.estimatedWeight * 10).toInt()} pts',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? lightGreen : primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Feature Pills ───────────────────────────
                          _sectionCard(
                            isDark: isDark,
                            child: Row(
                              children: [
                                _featurePill(Icons.recycling_rounded, 'Eco Impact', isDark),
                                const SizedBox(width: 8),
                                _featurePill(Icons.local_shipping_rounded, 'Pickup', isDark),
                                const SizedBox(width: 8),
                                _featurePill(Icons.verified_rounded, 'Verified', isDark),
                              ],
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Sticky Bottom Button ──────────────────────────────────────
        bottomSheet: Builder(builder: (context) {
          final authService = Provider.of<AuthService>(context, listen: false);
          final currentUserId = authService.userId;
          final isOwnListing =
              currentUserId != null && widget.item.userId == currentUserId;

          return Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: isOwnListing
                  ? Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18,
                              color: isDark ? Colors.white38 : Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Text(
                            'This is your listing',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(item: widget.item),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                            'Confirm Purchase',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
