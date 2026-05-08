import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Product> _products = [];
  bool _loading = true;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _category = 'All';
  String _sort = 'Newest';
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  static const _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Sports',
    'Home & Garden',
  ];
  static const _sorts = ['Newest', 'Price ↑', 'Price ↓', 'Rating'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  String _sortKey() {
    switch (_sort) {
      case 'Price ↑':
        return 'price_asc';
      case 'Price ↓':
        return 'price_desc';
      case 'Rating':
        return 'rating';
      default:
        return 'newest';
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _loading = true);
    try {
      final api = ApiService.instance;
      final double? minP = double.tryParse(_minPriceCtrl.text);
      final double? maxP = double.tryParse(_maxPriceCtrl.text);
      final prods = await api.fetchProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sort: _sortKey(),
        minPrice: minP,
        maxPrice: maxP,
      );

      List<Product> filtered = prods;
      if (_category != 'All') {
        filtered = prods
            .where((p) =>
                p.categoryName.toLowerCase() == _category.toLowerCase())
            .toList();
      }

      if (mounted) setState(() => _products = filtered);
    } catch (_) {
      if (mounted) setState(() => _products = Product.mockList());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppTheme.border.withValues(alpha: 0.8),
                                  width: 1),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 14, color: AppTheme.muted),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Shop',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.border.withValues(alpha: 0.8),
                                width: 1),
                          ),
                          child: Text(
                            '${_products.length} items',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppTheme.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.8),
                            width: 1),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppTheme.text),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 14, color: AppTheme.muted),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppTheme.muted, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded,
                                      size: 18, color: AppTheme.muted),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                    _fetchProducts();
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (v) {
                          setState(() => _searchQuery = v.trim());
                          _fetchProducts();
                        },
                        onChanged: (v) {
                          if (v.isEmpty) {
                            setState(() => _searchQuery = '');
                            _fetchProducts();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Filter row
                    _FilterRow(
                      categories: _categories,
                      sorts: _sorts,
                      selectedCategory: _category,
                      selectedSort: _sort,
                      minPriceCtrl: _minPriceCtrl,
                      maxPriceCtrl: _maxPriceCtrl,
                      onCategoryChanged: (v) {
                        setState(() => _category = v);
                        _fetchProducts();
                      },
                      onSortChanged: (v) {
                        setState(() => _sort = v);
                        _fetchProducts();
                      },
                      onPriceApplied: _fetchProducts,
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
            // Product grid
            _loading
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ShimmerCard(),
                        childCount: 6,
                      ),
                      gridDelegate: _gridDelegate(
                          MediaQuery.sizeOf(context).width - 48),
                    ),
                  )
                : _products.isEmpty
                    ? SliverFillRemaining(
                        child: _EmptyState(
                          onBrowse: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                              _category = 'All';
                            });
                            _fetchProducts();
                          },
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final p = _products[i];
                              return ProductCard(
                                product: p,
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailPage(product: p),
                                  ),
                                ),
                              );
                            },
                            childCount: _products.length,
                          ),
                          gridDelegate: _gridDelegate(
                              MediaQuery.sizeOf(context).width - 48),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate(double width) {
    final cols = width >= 1052 ? 3 : width >= 552 ? 2 : 1;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.72,
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.categories,
    required this.sorts,
    required this.selectedCategory,
    required this.selectedSort,
    required this.minPriceCtrl,
    required this.maxPriceCtrl,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onPriceApplied,
  });

  final List<String> categories;
  final List<String> sorts;
  final String selectedCategory;
  final String selectedSort;
  final TextEditingController minPriceCtrl;
  final TextEditingController maxPriceCtrl;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onPriceApplied;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DropdownFilter<String>(
          label: 'Category',
          value: selectedCategory,
          items: categories,
          onChanged: onCategoryChanged,
        ),
        _DropdownFilter<String>(
          label: 'Sort',
          value: selectedSort,
          items: sorts,
          onChanged: onSortChanged,
        ),
        SizedBox(
          width: 110,
          child: _PriceField(
              controller: minPriceCtrl,
              hint: 'Min AED',
              onSubmit: onPriceApplied),
        ),
        SizedBox(
          width: 110,
          child: _PriceField(
              controller: maxPriceCtrl,
              hint: 'Max AED',
              onSubmit: onPriceApplied),
        ),
        GestureDetector(
          onTap: onPriceApplied,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.4), width: 1),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.border.withValues(alpha: 0.8), width: 1),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: AppTheme.surface2,
        style:
            GoogleFonts.inter(fontSize: 13, color: AppTheme.text),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            size: 16, color: AppTheme.muted),
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(e.toString()),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.hint,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.border.withValues(alpha: 0.8), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.muted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        ),
        onSubmitted: (_) => onSubmit(),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  color: Color.lerp(AppTheme.surface, AppTheme.surface2,
                      _ctrl.value),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.lerp(AppTheme.surface2, AppTheme.border,
                            _ctrl.value),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Color.lerp(AppTheme.surface2, AppTheme.border,
                            _ctrl.value),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 16,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Color.lerp(AppTheme.surface2, AppTheme.border,
                            _ctrl.value),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔍', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.muted),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.4),
                    width: 1),
              ),
              child: Text(
                'Browse All Products',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
