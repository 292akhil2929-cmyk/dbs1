import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Your Cart',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: AppTheme.border.withValues(alpha: 0.4)),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.items.isEmpty) {
            return _EmptyCart(
              onBrowse: () => Navigator.pushNamed(ctx, '/shop'),
            );
          }
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _CartItemsList(cart: cart),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _OrderSummary(cart: cart),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(child: _CartItemsList(cart: cart)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _OrderSummary(cart: cart),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some luxury items to get started.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Browse Products',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList({required this.cart});
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _CartRow(item: cart.items[i], cart: cart),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.cart});
  final CartItem item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.border.withValues(alpha: 0.8), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.surface2,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.muted, size: 24)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  p.categoryName,
                  style: GoogleFonts.inter(
                      fontSize: 11.5, color: AppTheme.muted),
                ),
                const SizedBox(height: 8),
                Text(
                  'AED ${p.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () =>
                    cart.removeItem(p.productId),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 16, color: const Color(0xFFEF4444)),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.7), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SmallQtyBtn(
                      icon: Icons.remove_rounded,
                      onTap: () =>
                          cart.updateQty(p.productId, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 28,
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    _SmallQtyBtn(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          cart.updateQty(p.productId, item.quantity + 1),
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
}

class _SmallQtyBtn extends StatefulWidget {
  const _SmallQtyBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SmallQtyBtn> createState() => _SmallQtyBtnState();
}

class _SmallQtyBtnState extends State<_SmallQtyBtn> {
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hover
                ? AppTheme.accentBlue.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 14, color: AppTheme.text),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppTheme.border.withValues(alpha: 0.85), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
              label: 'Subtotal (${cart.itemCount} items)',
              value: 'AED ${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'Shipping',
              value: cart.shipping == 0
                  ? 'Free'
                  : 'AED ${cart.shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'VAT (5%)',
              value: 'AED ${cart.vat.toStringAsFixed(2)}'),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                'AED ${cart.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _CheckoutButton(
              onTap: () => Navigator.pushNamed(context, '/checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                GoogleFonts.inter(fontSize: 13, color: AppTheme.muted)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.text)),
      ],
    );
  }
}

class _CheckoutButton extends StatefulWidget {
  const _CheckoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _hover ? AppTheme.accentBlue : AppTheme.accentBlue.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              'Proceed to Checkout →',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
