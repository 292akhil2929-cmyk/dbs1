import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'UAE');

  String _shippingMethod = 'Standard';
  String _paymentMethod = 'Cash on Delivery';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  double get _shippingCost =>
      _shippingMethod == 'Express' ? 20.0 : 10.0;

  Future<void> _placeOrder() async {
    final street = _streetCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    if (street.isEmpty || city.isEmpty || _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all delivery details.',
              style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final subtotal = cart.subtotal;
    final vat = (subtotal + _shippingCost) * 0.05;
    final total = subtotal + _shippingCost + vat;

    setState(() => _loading = true);
    try {
      final result = await ApiService.instance.placeOrder(
        address: street,
        paymentMethod: _paymentMethod,
        cartItems: cart.items.toList(),
        total: total,
        city: city,
      );

      cart.clear();

      if (mounted) _showSuccessDialog(result['order_id']?.toString() ?? 'SS-000');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placement failed. Please try again.',
                style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                      width: 1),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 32, color: Color(0xFF22C55E)),
              ),
              const SizedBox(height: 18),
              Text(
                'Order Placed!',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order $orderId has been confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.muted, height: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                'Expected delivery: ${_shippingMethod == "Express" ? "1-2" : "3-5"} business days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.muted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/orders', (r) => r.settings.name == '/');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'View My Orders',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
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
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
      return const Scaffold(backgroundColor: AppTheme.bg);
    }

    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final vat = (subtotal + _shippingCost) * 0.05;
    final total = subtotal + _shippingCost + vat;

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
          'Checkout',
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final form = _CheckoutForm(
              nameCtrl: _nameCtrl,
              streetCtrl: _streetCtrl,
              cityCtrl: _cityCtrl,
              countryCtrl: _countryCtrl,
              shippingMethod: _shippingMethod,
              paymentMethod: _paymentMethod,
              onShippingChanged: (v) => setState(() => _shippingMethod = v),
              onPaymentChanged: (v) => setState(() => _paymentMethod = v),
            );
            final summary = _CheckoutSummary(
              cart: cart,
              shippingCost: _shippingCost,
              subtotal: subtotal,
              vat: vat,
              total: total,
              loading: _loading,
              onPlaceOrder: _placeOrder,
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: form,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: summary,
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [form, const SizedBox(height: 20), summary],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckoutForm extends StatelessWidget {
  const _CheckoutForm({
    required this.nameCtrl,
    required this.streetCtrl,
    required this.cityCtrl,
    required this.countryCtrl,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.onShippingChanged,
    required this.onPaymentChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController countryCtrl;
  final String shippingMethod;
  final String paymentMethod;
  final ValueChanged<String> onShippingChanged;
  final ValueChanged<String> onPaymentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Delivery Details'),
        const SizedBox(height: 14),
        _CheckoutField(controller: nameCtrl, hint: 'Full Name', icon: Icons.person_outline_rounded),
        const SizedBox(height: 10),
        _CheckoutField(controller: streetCtrl, hint: 'Street Address', icon: Icons.location_on_outlined),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CheckoutField(
                  controller: cityCtrl,
                  hint: 'City',
                  icon: Icons.apartment_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CheckoutField(
                  controller: countryCtrl,
                  hint: 'Country',
                  icon: Icons.flag_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Shipping Method'),
        const SizedBox(height: 12),
        _RadioTile(
          title: 'Standard Shipping',
          subtitle: 'AED 10.00 — 3-5 business days',
          value: 'Standard',
          groupValue: shippingMethod,
          onChanged: onShippingChanged,
        ),
        const SizedBox(height: 8),
        _RadioTile(
          title: 'Express Shipping',
          subtitle: 'AED 20.00 — 1-2 business days',
          value: 'Express',
          groupValue: shippingMethod,
          onChanged: onShippingChanged,
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Payment Method'),
        const SizedBox(height: 12),
        _RadioTile(
          title: 'Cash on Delivery',
          subtitle: 'Pay when your order arrives',
          value: 'Cash on Delivery',
          groupValue: paymentMethod,
          onChanged: onPaymentChanged,
          icon: Icons.money_rounded,
        ),
        const SizedBox(height: 8),
        _RadioTile(
          title: 'Credit Card',
          subtitle: 'Visa, Mastercard, Amex',
          value: 'Credit Card',
          groupValue: paymentMethod,
          onChanged: onPaymentChanged,
          icon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 8),
        _RadioTile(
          title: 'Apple Pay',
          subtitle: 'Fast and secure',
          value: 'Apple Pay',
          groupValue: paymentMethod,
          onChanged: onPaymentChanged,
          icon: Icons.apple_rounded,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.text,
          letterSpacing: -0.2),
    );
  }
}

class _CheckoutField extends StatefulWidget {
  const _CheckoutField({
    required this.controller,
    required this.hint,
    required this.icon,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  State<_CheckoutField> createState() => _CheckoutFieldState();
}

class _CheckoutFieldState extends State<_CheckoutField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? AppTheme.accentBlue.withValues(alpha: 0.6)
              : AppTheme.border.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
            prefixIcon:
                Icon(widget.icon, size: 18, color: AppTheme.muted),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentBlue.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.accentBlue.withValues(alpha: 0.5)
                : AppTheme.border.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon!,
                  size: 20,
                  color: selected ? AppTheme.accentBlue : AppTheme.muted),
            if (icon != null) const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppTheme.text : AppTheme.text,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppTheme.accentBlue
                      : AppTheme.border.withValues(alpha: 0.8),
                  width: 2,
                ),
                color: selected ? AppTheme.accentBlue : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.cart,
    required this.shippingCost,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.loading,
    required this.onPlaceOrder,
  });

  final CartProvider cart;
  final double shippingCost;
  final double subtotal;
  final double vat;
  final double total;
  final bool loading;
  final VoidCallback onPlaceOrder;

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
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
          const SizedBox(height: 14),
          // Items list
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.quantity}',
                        style: GoogleFonts.inter(
                            fontSize: 12.5, color: AppTheme.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'AED ${item.lineTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          _Row(label: 'Subtotal', value: 'AED ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _Row(
              label: 'Shipping',
              value: 'AED ${shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _Row(label: 'VAT (5%)', value: 'AED ${vat.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              Text(
                'AED ${total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentBlue),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _PlaceOrderBtn(loading: loading, onTap: onPlaceOrder),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.muted)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.text)),
      ],
    );
  }
}

class _PlaceOrderBtn extends StatefulWidget {
  const _PlaceOrderBtn({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_PlaceOrderBtn> createState() => _PlaceOrderBtnState();
}

class _PlaceOrderBtnState extends State<_PlaceOrderBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _hover ? AppTheme.accentBlue : AppTheme.accentBlue.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text(
                    'Place Order',
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
