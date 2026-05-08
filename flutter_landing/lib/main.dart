import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/auth_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/landing_page.dart';
import 'pages/orders_page.dart';
import 'pages/shop_page.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'theme/app_theme.dart';
import 'ui/smooth_scroll_behavior.dart';

void main() {
  runApp(const ShopSphereApp());
}

class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const SmoothScrollBehavior(),
        theme: AppTheme.dark(),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const Scaffold(
                body: SafeArea(bottom: false, child: LandingPage()),
              ),
          '/shop': (ctx) => const ShopPage(),
          '/cart': (ctx) => const CartPage(),
          '/auth': (ctx) => const AuthPage(),
          '/checkout': (ctx) => const CheckoutPage(),
          '/orders': (ctx) => const OrdersPage(),
        },
      ),
    );
  }
}
