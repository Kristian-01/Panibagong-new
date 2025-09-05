import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/cart_icon.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import 'product_details_view.dart';
import 'category_products_view.dart';

class ProductCatalogView extends StatefulWidget {
  const ProductCatalogView({super.key});

  @override
  State<ProductCatalogView> createState() => _ProductCatalogViewState();
}

class _ProductCatalogViewState extends State<ProductCatalogView> {
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> featuredProducts = [];
  List<ProductCategory> categories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    CartService.setCartChangeCallback(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load featured products and categories
      final futures = await Future.wait([
        ProductService.getFeaturedProducts(limit: 6),
        ProductService.getCategories(),
      ]);

      final featuredResult = futures[0];
      final categoriesResult = futures[1];

      setState(() {
        if (featuredResult['success'] == true) {
          featuredProducts = featuredResult['products'] as List<ProductModel>;
        }
        
        if (categoriesResult['success'] == true) {
          categories = categoriesResult['categories'] as List<ProductCategory>;
        } else {
          // Use mock categories if API fails
          categories = MockProductService.getMockCategories();
        }
        
        isLoading = false;
      });

      // If API fails, use mock data
      if (featuredResult['success'] != true) {
        setState(() {
          featuredProducts = MockProductService.getMockProducts().take(6).toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load products: ${e.toString()}';
        isLoading = false;
        // Use mock data as fallback
        featuredProducts = MockProductService.getMockProducts().take(6).toList();
        categories = MockProductService.getMockCategories();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryProductsView(
            categoryName: 'Search Results',
            searchQuery: query.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(top: 46, left: 20, right: 20, bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Nine27 Pharmacy",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const CartIcon(),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RoundTextfield(
                    hintText: "Search medicines, vitamins, health products...",
                    controller: searchController,
                    onSubmitted: _onSearchSubmitted,
                    left: Container(
                      alignment: Alignment.center,
                      width: 30,
                      child: Image.asset(
                        "assets/img/search.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Shop by Category",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Categories Grid
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryCard(category);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Featured Products Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Featured Products",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoryProductsView(
                                  categoryName: 'All Products',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Featured Products Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ProductCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsView(
              categoryName: category.displayName,
              categoryId: category.name,
            ),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: TColor.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: category.icon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        category.icon!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.medical_services, color: TColor.primary, size: 30),
                      ),
                    )
                  : Icon(Icons.medical_services, color: TColor.primary, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isInCart = CartService.isInCart(product.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsView(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.image != null
                      ? Image.asset(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.medical_services,
                                  color: TColor.primary,
                                  size: 40,
                                ),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.medical_services,
                            color: TColor.primary,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.stockStatus,
                            style: TextStyle(
                              color: product.inStock ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (product.inStock) {
                              final success = await CartService.addToCart(product);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isInCart ? TColor.primary : TColor.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              isInCart ? Icons.check : Icons.add,
                              color: isInCart ? Colors.white : TColor.primary,
                              size: 16,
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
    );
  }
}
