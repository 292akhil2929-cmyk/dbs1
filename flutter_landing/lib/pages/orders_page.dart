import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> _orders = [];
  bool _loading = true;
  int? _expanded;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final orders =
          await ApiService.instance.fetchOrders(auth.user!.token);
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      if (mounted) setState(() => _orders = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
          'My Orders',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text),
        ),
        actions: [
          GestureDetector(
            onTap: _fetchOrders,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.8), width: 1),
              ),
              child: Icon(Icons.refresh_rounded,
                  size: 18, color: AppTheme.muted),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: AppTheme.border.withValues(alpha: 0.4)),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          if (!auth.isLoggedIn) {
            return _LockScreen(
              onSignIn: () => Navigator.pushNamed(ctx, '/auth'),
            );
          }
          if (_loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentBlue.withValues(alpha: 0.6)),
              ),
            );
          }
          if (_orders.isEmpty) {
            return _EmptyOrders(
              onShop: () => Navigator.pushNamed(ctx, '/shop'),
            );
          }
          return SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (c, i) {
                final o = _orders[i];
                return _OrderCard(
                  order: o,
                  expanded: _expanded == i,
                  onTap: () =>
                      setState(() => _expanded = _expanded == i ? null : i),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onSignIn});
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.8), width: 1),
            ),
            child: Icon(Icons.lock_outline_rounded,
                size: 34, color: AppTheme.muted),
          ),
          const SizedBox(height: 20),
          Text(
            'Sign in to view orders',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onSignIn,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Sign In',
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

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.onShop});
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📦', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onShop,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Start Shopping',
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.expanded,
    required this.onTap,
  });

  final Order order;
  final bool expanded;
  final VoidCallback onTap;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'processing':
      case 'shipped':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.muted;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expanded
                ? AppTheme.accentBlue.withValues(alpha: 0.4)
                : AppTheme.border.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(order.orderedAt),
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.35), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(
                        _capitalize(order.status),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                      fontSize: 12.5, color: AppTheme.muted),
                ),
                Text(
                  'AED ${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
            // Expanded details
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Container(
                      height: 1,
                      color: AppTheme.border.withValues(alpha: 0.6)),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: 'Payment',
                      value: order.paymentMethod),
                  const SizedBox(height: 6),
                  if (order.street.isNotEmpty)
                    _DetailRow(
                        label: 'Delivery',
                        value:
                            '${order.street}, ${order.city}'),
                ],
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppTheme.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.text),
          ),
        ),
      ],
    );
  }
}
