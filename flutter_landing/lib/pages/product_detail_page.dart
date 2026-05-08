import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;

  Product get p => widget.product;

  String get _stockLabel {
    if (p.stockQty == 0) return 'Out of Stock';
    if (p.stockQty <= 5) return 'Only ${p.stockQty} left';
    return 'In Stock';
  }

  Color get _stockColor {
    if (p.stockQty == 0) return const Color(0xFFEF4444);
    if (p.stockQty <= 5) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(p, qty: _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${p.name} added to cart',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppTheme.accentBlue,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.8), width: 1),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppTheme.muted),
          ),
        ),
        title: Text(
          p.name,
          style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.text),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cart, _) => GestureDetector(
              onTap: () => Navigator.pushNamed(ctx, '/cart'),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.8), width: 1),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 18, color: AppTheme.text),
                    if (cart.itemCount > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.itemCount}',
                              style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.border.withValues(alpha: 0.4),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ImageSection(p: p)),
                        const SizedBox(width: 36),
                        Expanded(
                          child: _InfoSection(
                            p: p,
                            qty: _qty,
                            stockLabel: _stockLabel,
                            stockColor: _stockColor,
                            onQtyChanged: (v) => setState(() => _qty = v),
                            onAddToCart: _addToCart,
                            onContinue: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _ImageSection(p: p),
                        const SizedBox(height: 24),
                        _InfoSection(
                          p: p,
                          qty: _qty,
                          stockLabel: _stockLabel,
                          stockColor: _stockColor,
                          onQtyChanged: (v) => setState(() => _qty = v),
                          onAddToCart: _addToCart,
                          onContinue: () => Navigator.pop(context),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.p});
  final Product p;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Hero(
        tag: 'product_image_${p.productId}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.8), width: 1),
            ),
            child: Image.network(
              p.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.surface2,
                child: Icon(Icons.image_not_supported_outlined,
                    color: AppTheme.muted, size: 48),
              ),
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppTheme.surface2,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentBlue.withValues(alpha: 0.5)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.p,
    required this.qty,
    required this.stockLabel,
    required this.stockColor,
    required this.onQtyChanged,
    required this.onAddToCart,
    required this.onContinue,
  });

  final Product p;
  final int qty;
  final String stockLabel;
  final Color stockColor;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand + category
        Row(
          children: [
            if (p.brandName != null) ...[
              Text(
                p.brandName!.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.8), width: 1),
              ),
              child: Text(
                p.categoryName,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          p.name,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        // Stars
        Row(
          children: [
            ...List.generate(5, (i) {
              final filled = i < p.avgRating.floor();
              final half =
                  !filled && i < p.avgRating && (p.avgRating - i) >= 0.5;
              return Icon(
                half
                    ? Icons.star_half_rounded
                    : filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                size: 16,
                color: filled || half
                    ? const Color(0xFFFFB800)
                    : AppTheme.muted.withValues(alpha: 0.4),
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${p.avgRating.toStringAsFixed(1)} (${p.reviewCount} reviews)',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'AED ${p.price.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.accentBlue,
              ),
            ),
            if (p.comparePrice != null) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'AED ${p.comparePrice!.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
            if (p.discountPct != null) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${p.discountPct!.round()}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        // Stock badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: stockColor.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: stockColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                stockLabel,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: stockColor),
              ),
            ],
          ),
        ),
        if (p.description != null && p.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.7), width: 1),
            ),
            child: Text(
              p.description!,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.muted, height: 1.6),
            ),
          ),
        ],
        const SizedBox(height: 24),
        // Qty selector
        Row(
          children: [
            Text(
              'Quantity',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.8), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (qty > 1) onQtyChanged(qty - 1);
                    },
                  ),
                  SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        '$qty',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      if (p.stockQty == 0 || qty < p.stockQty) {
                        onQtyChanged(qty + 1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // Buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label:
                    p.stockQty == 0 ? 'Out of Stock' : 'Add to Cart',
                primary: true,
                disabled: p.stockQty == 0,
                onTap: p.stockQty == 0 ? null : onAddToCart,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'Continue Shopping',
                primary: false,
                onTap: onContinue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyButton extends StatefulWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _hover
                ? AppTheme.accentBlue.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 16, color: AppTheme.text),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.primary,
    this.onTap,
    this.disabled = false,
  });
  final String label;
  final bool primary;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.disabled
        ? AppTheme.surface
        : widget.primary
            ? AppTheme.accentBlue
                .withValues(alpha: _hover ? 1.0 : 0.88)
            : Colors.white.withValues(alpha: _hover ? 0.08 : 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.primary
                  ? AppTheme.accentBlue.withValues(alpha: 0.5)
                  : AppTheme.border.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.disabled ? AppTheme.muted : AppTheme.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
