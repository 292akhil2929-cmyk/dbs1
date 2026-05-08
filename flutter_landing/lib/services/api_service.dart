import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String baseUrl = 'https://shopsphere-bits.up.railway.app/api';

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------
  Future<List<Product>> fetchProducts({
    String? search,
    int? categoryId,
    String? sort,
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (sort != null) 'sort': sort,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
      };

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list =
            data is List ? data : (data['products'] ?? data['data'] ?? []);
        return list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Status ${response.statusCode}');
    } catch (_) {
      return _filterMock(
        Product.mockList(),
        search: search,
        sort: sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    }
  }

  List<Product> _filterMock(
    List<Product> all, {
    String? search,
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) {
    var result = all.where((p) {
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.categoryName.toLowerCase().contains(q) &&
            !(p.brandName?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      if (minPrice != null && p.price < minPrice) return false;
      if (maxPrice != null && p.price > maxPrice) return false;
      return true;
    }).toList();

    switch (sort) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        result.sort((a, b) => b.avgRating.compareTo(a.avgRating));
        break;
      default:
        break;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  Future<AppUser> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        userMap['token'] = data['token'] as String? ?? 'mock_token';
        return AppUser.fromJson(userMap);
      }
      throw Exception('Status ${response.statusCode}');
    } catch (_) {
      final name = email.split('@').first;
      return AppUser(
        userId: 1001,
        fullName: _capitalize(name),
        email: email,
        token: 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
        role: 'customer',
      );
    }
  }

  Future<AppUser> register(
      String name, String email, String password, String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': name,
              'email': email,
              'password': password,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        userMap['token'] = data['token'] as String? ?? 'mock_token';
        userMap['full_name'] ??= name;
        return AppUser.fromJson(userMap);
      }
      throw Exception('Status ${response.statusCode}');
    } catch (_) {
      return AppUser(
        userId: 1000 + Random().nextInt(9000),
        fullName: name,
        email: email,
        token: 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
        role: 'customer',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> placeOrder({
    required String address,
    required String paymentMethod,
    required List<CartItem> cartItems,
    required double total,
    String city = 'Dubai',
  }) async {
    try {
      final body = jsonEncode({
        'address': address,
        'city': city,
        'payment_method': paymentMethod,
        'total': total,
        'items': cartItems
            .map((i) => {
                  'product_id': i.product.productId,
                  'quantity': i.quantity,
                  'price': i.product.price,
                })
            .toList(),
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Status ${response.statusCode}');
    } catch (_) {
      final orderId =
          'SS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      return {
        'order_id': orderId,
        'status': 'confirmed',
        'total_amount': total,
        'ordered_at': DateTime.now().toIso8601String(),
        'item_count': cartItems.length,
        'payment_method': paymentMethod,
        'street': address,
        'city': city,
      };
    }
  }

  Future<List<Order>> fetchOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list =
            data is List ? data : (data['orders'] ?? data['data'] ?? []);
        return list
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Status ${response.statusCode}');
    } catch (_) {
      return [];
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
