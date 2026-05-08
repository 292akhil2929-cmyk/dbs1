import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _addFlash = false;

  late final AnimationController _flashCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _flashCtrl.reverse();
      }
    });

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  void _handleAdd(BuildContext ctx) {
    context.read<CartProvider>().addItem(widget.product);
    setState(() => _addFlash = true);
    _flashCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _addFlash = false);
    });
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} added to cart',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.identity()
            ..scale(_hover ? 1.03 : 1.0, _hover ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hover
                  ? AppTheme.accentBlue.withValues(alpha: 0.35)
                  : AppTheme.border.withValues(alpha: 0.85),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: _hover ? 28 : 12,
                spreadRadius: -8,
                offset: Offset(0, _hover ? 16 : 8),
                color: Colors.black.withValues(alpha: _hover ? 0.55 : 0.35),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surface2,
                          child: Icon(Icons.image_not_supported_outlined,
                              color: AppTheme.muted, size: 36),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppTheme.surface2,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentBlue.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Category chip overlay
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.border.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            p.categoryName,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.muted,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      // Discount badge
                      if (p.discountPct != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '-${p.discountPct!.round()}%',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Stars
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final filled = i < p.avgRating.floor();
                            final half = !filled &&
                                i < p.avgRating &&
                                (p.avgRating - i) >= 0.5;
                            return Icon(
                              half
                                  ? Icons.star_half_rounded
                                  : filled
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                              size: 13,
                              color: filled || half
                                  ? const Color(0xFFFFB800)
                                  : AppTheme.muted.withValues(alpha: 0.4),
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '(${p.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p.comparePrice != null)
                                Text(
                                  'AED ${p.comparePrice!.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.muted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'AED ${p.price.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.text,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          AnimatedBuilder(
                            animation: _flashCtrl,
                            builder: (ctx, _) => GestureDetector(
                              onTap: () => _handleAdd(ctx),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _addFlash
                                      ? AppTheme.accentBlue
                                      : _hover
                                          ? AppTheme.accentBlue
                                              .withValues(alpha: 0.85)
                                          : AppTheme.accentBlue
                                              .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.accentBlue
                                        .withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _addFlash
                                          ? Icons.check_rounded
                                          : Icons.add_shopping_cart_rounded,
                                      size: 14,
                                      color: _addFlash || _hover
                                          ? Colors.white
                                          : AppTheme.accentBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
