import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/cart_icon.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

class CategoryProductsView extends StatefulWidget {
  final String? category;
  final String categoryName;
  final String? categoryId;
  final String? searchQuery;

  const CategoryProductsView({
    super.key,
    this.category,
    required this.categoryName,
    this.categoryId,
    this.searchQuery,
  });

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView> {
  TextEditingController txtSearch = TextEditingController();
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
    
    // If there's a search query, set it in the text field
    if (widget.searchQuery != null) {
      txtSearch.text = widget.searchQuery!;
    }
    
    _loadCategoryProducts();
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> result;
      
      // Determine which category to load
      String? categoryToLoad = widget.category ?? widget.categoryId;
      
      if (categoryToLoad != null && categoryToLoad.isNotEmpty) {
        // Load specific category
        result = await ProductService.getProductsByCategory(
          category: categoryToLoad,
          limit: 50,
        );
      } else {
        // Load all products
        result = await ProductService.getProducts(limit: 50);
      }

      if (result['success'] == true) {
        setState(() {
          allProducts = result['products'] as List<ProductModel>;
          
          // If there's a search query, filter immediately
          if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
            _performSearch(widget.searchQuery!);
          } else {
            filteredProducts = allProducts;
          }
          
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError(result['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error loading products: ${e.toString()}');
    }
  }

  void _onSearchChanged() {
    String query = txtSearch.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredProducts = allProducts;
      });
      return;
    }

    _performSearch(query);
  }

  void _performSearch(String query) {
    setState(() {
      isSearching = true;
      filteredProducts = allProducts.where((product) {
        String name = product.name.toLowerCase();
        String description = product.description.toLowerCase();
        String brand = (product.brand ?? "").toLowerCase();
        String activeIngredient = (product.activeIngredient ?? "").toLowerCase();

        return name.contains(query.toLowerCase()) ||
               description.contains(query.toLowerCase()) ||
               brand.contains(query.toLowerCase()) ||
               activeIngredient.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _clearSearch() {
    txtSearch.clear();
    setState(() {
      isSearching = false;
      filteredProducts = allProducts;
    });
  }

  Future<void> _addToCart(ProductModel product) async {
    final success = await CartService.addToCart(product);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 2),
          backgroundColor: TColor.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add ${product.name} to cart'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getCategoryColor() {
    String? categoryToCheck = widget.category ?? widget.categoryId;
    switch (categoryToCheck) {
      case 'medicines':
        return Colors.blue;
      case 'vitamins':
        return Colors.green;
      case 'first_aid':
        return Colors.red;
      case 'prescription_drugs':
        return Colors.orange;
      default:
        return TColor.primary;
    }
  }

  IconData _getCategoryIcon() {
    String? categoryToCheck = widget.category ?? widget.categoryId;
    switch (categoryToCheck) {
      case 'medicines':
        return Icons.medication;
      case 'vitamins':
        return Icons.health_and_safety;
      case 'first_aid':
        return Icons.medical_services;
      case 'prescription_drugs':
        return Icons.local_pharmacy;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Column(
        children: [
          const SizedBox(height: 46),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
                ),
                const SizedBox(width: 8),
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
                const CartIcon(size: 25),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category Info Card (only show if not search results)
          if (widget.searchQuery == null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _getCategoryColor().withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "${filteredProducts.length} products available",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoundTextfield(
              hintText: widget.searchQuery != null 
                  ? "Search results for '${widget.searchQuery}'"
                  : "Search in ${widget.categoryName.toLowerCase()}...",
              controller: txtSearch,
              left: Container(
                alignment: Alignment.center,
                width: 30,
                child: Image.asset("assets/img/search.png", width: 20, height: 20),
              ),
              right: txtSearch.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(Icons.clear, size: 20, color: TColor.secondaryText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCategoryProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.searchQuery != null ? Icons.search_off : _getCategoryIcon(),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            widget.searchQuery != null 
                ? "No results found for '${widget.searchQuery}'"
                : isSearching 
                    ? "No products found" 
                    : "No products available",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.searchQuery != null || isSearching 
                ? "Try searching with different keywords"
                : "Products will appear here when available",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.searchQuery == null && !isSearching) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadCategoryProducts,
              child: const Text("Refresh"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.image ?? "assets/img/placeholder.png",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: _getCategoryColor().withValues(alpha: 0.1),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getCategoryColor(),
                    size: 30,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                
                if (product.brand != null) ...[
                  Text(
                    "by ${product.brand}",
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                Text(
                  product.description,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(width: 10),
                    
                    if (product.rating != null) ...[
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    
                    if (product.requiresPrescription) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rx Required",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Add to Cart Button
          Column(
            children: [
              ElevatedButton(
                onPressed: product.inStock ? () => _addToCart(product) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.inStock ? _getCategoryColor() : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  product.inStock ? "Add to Cart" : "Out of Stock",
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                "Stock: ${product.stockQuantity}",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}