import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.75), width: 1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (r) => false),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'ShopSphere',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (isWide) ...[
                _NavItem(
                  label: 'Collection',
                  onTap: () => Navigator.pushNamed(context, '/shop'),
                ),
                const SizedBox(width: 14),
                Consumer<AuthProvider>(
                  builder: (ctx, auth, _) => _NavItem(
                    label: 'Orders',
                    onTap: () => Navigator.pushNamed(ctx, '/orders'),
                  ),
                ),
                const SizedBox(width: 14),
                const _NavItem(label: 'Craft'),
                const SizedBox(width: 18),
              ],
              // Cart icon with badge
              Consumer<CartProvider>(
                builder: (ctx, cart, _) => GestureDetector(
                  onTap: () => Navigator.pushNamed(ctx, '/cart'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.border.withValues(alpha: 0.7),
                                width: 1),
                          ),
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 16, color: AppTheme.text),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.bg, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  cart.itemCount > 9
                                      ? '9+'
                                      : '${cart.itemCount}',
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
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
              const SizedBox(width: 8),
              // User icon
              Consumer<AuthProvider>(
                builder: (ctx, auth, _) => GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      ctx, auth.isLoggedIn ? '/orders' : '/auth'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: auth.isLoggedIn
                            ? AppTheme.accentBlue.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: auth.isLoggedIn
                              ? AppTheme.accentBlue.withValues(alpha: 0.4)
                              : AppTheme.border.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        auth.isLoggedIn
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        size: 16,
                        color: auth.isLoggedIn
                            ? AppTheme.accentBlue
                            : AppTheme.text,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Consumer<AuthProvider>(
                builder: (ctx, auth, _) => auth.isLoggedIn
                    ? const SizedBox.shrink()
                    : _PillButton(
                        label: 'Sign in',
                        onPressed: () => Navigator.pushNamed(ctx, '/auth'),
                      ),
              ),
              const SizedBox(width: 10),
              _PillButton(
                label: 'Shop',
                primary: true,
                onPressed: () => Navigator.pushNamed(context, '/shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _hover ? AppTheme.text : AppTheme.muted,
            letterSpacing: 0.2,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? AppTheme.accentBlue.withValues(alpha: _hover ? 0.9 : 0.75)
        : Colors.white.withValues(alpha: _hover ? 0.08 : 0.06);
    final fg =
        widget.primary ? AppTheme.text : AppTheme.text.withValues(alpha: 0.9);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.primary
                  ? AppTheme.accentBlue.withValues(alpha: 0.55)
                  : AppTheme.border.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
