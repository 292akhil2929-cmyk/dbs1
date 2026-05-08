class Product {
  final int productId;
  final String name;
  final String categoryName;
  final double price;
  final double? comparePrice;
  final double? discountPct;
  final int stockQty;
  final double avgRating;
  final int reviewCount;
  final String? brandName;
  final String? primaryImage;
  final String? description;

  const Product({
    required this.productId,
    required this.name,
    required this.categoryName,
    required this.price,
    this.comparePrice,
    this.discountPct,
    required this.stockQty,
    required this.avgRating,
    required this.reviewCount,
    this.brandName,
    this.primaryImage,
    this.description,
  });

  String get imageUrl =>
      (primaryImage != null && primaryImage!.isNotEmpty)
          ? primaryImage!
          : 'https://picsum.photos/seed/$productId/400/400';

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      productId: (j['product_id'] as num?)?.toInt() ?? 0,
      name: j['name'] as String? ?? '',
      categoryName: j['category_name'] as String? ?? 'General',
      price: (j['price'] as num?)?.toDouble() ?? 0.0,
      comparePrice: (j['compare_price'] as num?)?.toDouble(),
      discountPct: (j['discount_pct'] as num?)?.toDouble(),
      stockQty: (j['stock_qty'] as num?)?.toInt() ?? 0,
      avgRating: (j['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (j['review_count'] as num?)?.toInt() ?? 0,
      brandName: j['brand_name'] as String?,
      primaryImage: j['primary_image'] as String?,
      description: j['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'category_name': categoryName,
        'price': price,
        'compare_price': comparePrice,
        'discount_pct': discountPct,
        'stock_qty': stockQty,
        'avg_rating': avgRating,
        'review_count': reviewCount,
        'brand_name': brandName,
        'primary_image': primaryImage,
        'description': description,
      };

  static List<Product> mockList() => [
        const Product(
          productId: 1,
          name: 'AirPods Pro Max',
          categoryName: 'Electronics',
          price: 1099.00,
          comparePrice: 1299.00,
          discountPct: 15.4,
          stockQty: 24,
          avgRating: 4.8,
          reviewCount: 312,
          brandName: 'SoundElite',
          primaryImage:
              'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
          description:
              'Premium wireless headphones with active noise cancellation, spatial audio, and 30-hour battery life.',
        ),
        const Product(
          productId: 2,
          name: 'Obsidian Chrono Watch',
          categoryName: 'Electronics',
          price: 2199.00,
          comparePrice: 2599.00,
          discountPct: 15.4,
          stockQty: 8,
          avgRating: 4.9,
          reviewCount: 187,
          brandName: 'AurumTime',
          primaryImage:
              'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
          description:
              'Swiss movement automatic watch with ceramic bezel, sapphire crystal and 100m water resistance.',
        ),
        const Product(
          productId: 3,
          name: 'Carbon Velocity Runners',
          categoryName: 'Sports',
          price: 649.00,
          comparePrice: 799.00,
          discountPct: 18.8,
          stockQty: 42,
          avgRating: 4.7,
          reviewCount: 523,
          brandName: 'ApexStride',
          primaryImage:
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
          description:
              'Ultra-lightweight carbon-fiber plate running shoes with responsive foam and breathable mesh upper.',
        ),
        const Product(
          productId: 4,
          name: 'Midnight Denim Jacket',
          categoryName: 'Clothing',
          price: 449.00,
          comparePrice: 549.00,
          discountPct: 18.2,
          stockQty: 18,
          avgRating: 4.6,
          reviewCount: 94,
          brandName: 'NordForm',
          primaryImage:
              'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&h=400&fit=crop',
          description:
              'Premium heavyweight Japanese selvedge denim jacket with contrast stitching and custom hardware.',
        ),
        const Product(
          productId: 5,
          name: 'Atlas Coffee Maker',
          categoryName: 'Home & Garden',
          price: 879.00,
          comparePrice: null,
          discountPct: null,
          stockQty: 15,
          avgRating: 4.8,
          reviewCount: 211,
          brandName: 'BrewCraft',
          primaryImage:
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=400&fit=crop',
          description:
              'Precision temperature-controlled pour-over coffee maker with built-in grinder and smart scheduling.',
        ),
        const Product(
          productId: 6,
          name: 'Sable Commuter Backpack',
          categoryName: 'Clothing',
          price: 599.00,
          comparePrice: 699.00,
          discountPct: 14.3,
          stockQty: 31,
          avgRating: 4.7,
          reviewCount: 276,
          brandName: 'TrailForm',
          primaryImage:
              'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
          description:
              'Structured 28L commuter backpack with TSA-friendly laptop compartment and water-resistant exterior.',
        ),
        const Product(
          productId: 7,
          name: 'Noir Shield Sunglasses',
          categoryName: 'Clothing',
          price: 349.00,
          comparePrice: 429.00,
          discountPct: 18.6,
          stockQty: 55,
          avgRating: 4.5,
          reviewCount: 143,
          brandName: 'LuxOptics',
          primaryImage:
              'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=400&fit=crop',
          description:
              'Polarised UV400 shield sunglasses with titanium frame, acetate nose pads and anti-reflective coating.',
        ),
        const Product(
          productId: 8,
          name: 'Artisan Plant Pot Set',
          categoryName: 'Home & Garden',
          price: 229.00,
          comparePrice: null,
          discountPct: null,
          stockQty: 62,
          avgRating: 4.6,
          reviewCount: 88,
          brandName: 'TerraForm',
          primaryImage:
              'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&h=400&fit=crop',
          description:
              'Set of 3 hand-thrown terracotta pots with drainage holes, saucers and natural mineral glaze finish.',
        ),
        const Product(
          productId: 9,
          name: 'Obsidian BT Speaker',
          categoryName: 'Electronics',
          price: 749.00,
          comparePrice: 899.00,
          discountPct: 16.7,
          stockQty: 27,
          avgRating: 4.9,
          reviewCount: 402,
          brandName: 'SoundElite',
          primaryImage:
              'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
          description:
              '360-degree Bluetooth 5.3 speaker with IPX7 waterproofing, 24-hour playtime and lossless audio.',
        ),
        const Product(
          productId: 10,
          name: 'Altitude Yoga Mat',
          categoryName: 'Sports',
          price: 289.00,
          comparePrice: 349.00,
          discountPct: 17.2,
          stockQty: 48,
          avgRating: 4.7,
          reviewCount: 319,
          brandName: 'ZenCore',
          primaryImage:
              'https://images.unsplash.com/photo-1601925228335-74d6e41a892e?w=400&h=400&fit=crop',
          description:
              'Natural rubber 6mm yoga mat with alignment lines, moisture-wicking surface and carry strap.',
        ),
        const Product(
          productId: 11,
          name: 'Arc Desk Lamp',
          categoryName: 'Home & Garden',
          price: 469.00,
          comparePrice: 549.00,
          discountPct: 14.6,
          stockQty: 19,
          avgRating: 4.8,
          reviewCount: 156,
          brandName: 'LumiCraft',
          primaryImage:
              'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&h=400&fit=crop',
          description:
              'Articulated LED desk lamp with wireless charging pad, USB-C port and 5-step dimmer control.',
        ),
        const Product(
          productId: 12,
          name: 'Minimal Polo Shirt',
          categoryName: 'Clothing',
          price: 199.00,
          comparePrice: 249.00,
          discountPct: 20.1,
          stockQty: 86,
          avgRating: 4.5,
          reviewCount: 231,
          brandName: 'NordForm',
          primaryImage:
              'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=400&h=400&fit=crop',
          description:
              'Premium pima cotton polo with mother-of-pearl buttons, stretch comfort weave and reinforced collar.',
        ),
      ];
}
