import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/cart_icon.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import 'product_details_view.dart';

class CategoryProductsView extends StatefulWidget {
  final String categoryName;
  final String? categoryId;
  final String? searchQuery;

  const CategoryProductsView({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.searchQuery,
  });

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView> {
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Filter options
  String selectedSort = 'name_asc';
  double? minPrice;
  double? maxPrice;
  bool inStockOnly = false;
  
  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      searchController.text = widget.searchQuery!;
    }
    _loadProducts();
    CartService.setCartChangeCallback(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        errorMessage = null;
        currentPage = 1;
      });
    }

    try {
      Map<String, dynamic> result;
      
      if (widget.searchQuery != null || searchController.text.isNotEmpty) {
        // Search products
        final query = widget.searchQuery ?? searchController.text;
        final filters = ProductFilters(
          category: widget.categoryId,
          sortBy: selectedSort,
          minPrice: minPrice,
          maxPrice: maxPrice,
          inStockOnly: inStockOnly,
        );
        
        result = await ProductService.searchProducts(
          query: query,
          filters: filters,
          page: loadMore ? currentPage + 1 : 1,
          limit: 20,
        );
      } else if (widget.categoryId != null) {
        // Get products by category
        result = await ProductService.getProductsByCategory(
          category: widget.categoryId!,
          page: loadMore ? currentPage + 1 : 1,
          limit: 20,
          sortBy: selectedSort,
        );
      } else {
        // Get all products
        final filters = ProductFilters(
          sortBy: selectedSort,
          minPrice: minPrice,
          maxPrice: maxPrice,
          inStockOnly: inStockOnly,
        );
        
        result = await ProductService.getProducts(
          filters: filters,
          page: loadMore ? currentPage + 1 : 1,
          limit: 20,
        );
      }

      if (result['success'] == true) {
        List<ProductModel> newProducts = result['products'] as List<ProductModel>;
        
        setState(() {
          if (loadMore) {
            products.addAll(newProducts);
            currentPage++;
            isLoadingMore = false;
          } else {
            products = newProducts;
            isLoading = false;
          }
          totalPages = result['totalPages'] ?? 1;
          _applyFilters();
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load products';
          isLoading = false;
          isLoadingMore = false;
        });
        
        // Use mock data as fallback
        if (!loadMore) {
          setState(() {
            products = MockProductService.getMockProducts();
            _applyFilters();
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
        isLoadingMore = false;
      });
      
      // Use mock data as fallback
      if (!loadMore) {
        setState(() {
          products = MockProductService.getMockProducts();
          _applyFilters();
        });
      }
    }
  }

  void _applyFilters() {
    filteredProducts = products.where((product) {
      // Apply local filters if needed
      if (inStockOnly && !product.inStock) return false;
      if (minPrice != null && product.price < minPrice!) return false;
      if (maxPrice != null && product.price > maxPrice!) return false;
      
      return true;
    }).toList();
    
    // Apply sorting
    switch (selectedSort) {
      case 'price_asc':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name_desc':
        filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'rating_desc':
        filteredProducts.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'name_asc':
      default:
        filteredProducts.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _onSearchSubmitted(String query) {
    _loadProducts();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 46, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: TColor.primaryText),
                ),
                Expanded(
                  child: Text(
                    widget.categoryName,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const CartIcon(),
              ],
            ),
          ),

          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: RoundTextfield(
                    hintText: "Search products...",
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
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterDialog,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: TColor.primary),
                    ),
                    child: Icon(Icons.tune, color: TColor.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Products List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  onPressed: _loadProducts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No products found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Try adjusting your search or filters",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filteredProducts.length + (isLoadingMore ? 2 : 0),
                              itemBuilder: (context, index) {
                                if (index >= filteredProducts.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final product = filteredProducts[index];
                                
                                // Load more when reaching near end
                                if (index == filteredProducts.length - 4 && 
                                    currentPage < totalPages && 
                                    !isLoadingMore) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _loadProducts(loadMore: true);
                                  });
                                }

                                return _buildProductCard(product);
                              },
                            ),
            ),
          ),
        ],
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

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Sort',
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          // Sort Options
          Text(
            'Sort By',
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSort,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
              DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
              DropdownMenuItem(value: 'price_asc', child: Text('Price (Low to High)')),
              DropdownMenuItem(value: 'price_desc', child: Text('Price (High to Low)')),
              DropdownMenuItem(value: 'rating_desc', child: Text('Highest Rated')),
            ],
            onChanged: (value) {
              setState(() {
                selectedSort = value!;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Stock Filter
          CheckboxListTile(
            title: const Text('In Stock Only'),
            value: inStockOnly,
            onChanged: (value) {
              setState(() {
                inStockOnly = value!;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadProducts();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
