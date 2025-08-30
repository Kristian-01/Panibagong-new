import 'package:flutter/material.dart';
import '/common/color_extension.dart';
import '/common_widget/round_textfield.dart';

import '../../common/globs.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../../common_widget/cart_icon.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../products/category_products_view.dart';
import '../products/product_catalog_view.dart';
import 'location_selection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;
  List<ProductModel> searchResults = [];
  List<ProductModel> allProducts = [];
  List<ProductModel> featuredMedicines = [];
  List<ProductModel> groceriesHighlights = [];
  List<ProductModel> specialOffers = [];
  String currentAddress = "Current Location";

  // Pharmacy categories with proper images
  List catArr = [
    {
      "image": "assets/img/med.png", 
      "name": "Pain Relief", 
      "category": "medicines",
      "description": "Headache & Fever",
      "color": Colors.blue[100]
    },
    {
      "image": "assets/img/vitamins.png", 
      "name": "Vitamins", 
      "category": "vitamins",
      "description": "Health Supplements",
      "color": Colors.green[100]
    },
    {
      "image": "assets/img/first aid.png", 
      "name": "First Aid", 
      "category": "first_aid",
      "description": "Wound Care & Safety",
      "color": Colors.red[100]
    },
    {
      "image": "assets/img/med.png", 
      "name": "Prescription", 
      "category": "prescription_drugs",
      "description": "Doctor Required",
      "color": Colors.orange[100]
    },
  ];

  // Quick Links for pharmacy
  List quickLinks = [];

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
    
    // Initialize quick links
    quickLinks = [
      {
        "icon": Icons.medication,
        "title": "Order Prescription",
        "subtitle": "Upload your prescription",
        "color": Colors.blue[600]!,
        "onTap": () => _navigateToProducts('prescription_drugs', 'Prescription Medicines')
      },
      {
        "icon": Icons.medical_services,
        "title": "First Aid Kit",
        "subtitle": "Emergency supplies",
        "color": Colors.red[600]!,
        "onTap": () => _navigateToProducts('first_aid', 'First Aid & Wound Care')
      },
      {
        "icon": Icons.health_and_safety,
        "title": "Health Check",
        "subtitle": "Monitoring devices",
        "color": Colors.green[600]!,
        "onTap": () => _navigateToProducts('health_devices', 'Health Monitoring')
      },
      {
        "icon": Icons.local_pharmacy,
        "title": "Consultation",
        "subtitle": "Talk to pharmacist",
        "color": Colors.purple[600]!,
        "onTap": () => _showConsultationInfo()
      },
    ];
    
    _loadHomeData();
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    super.dispose();
  }

  /// Load all data for the home screen from MySQL API
  Future<void> _loadHomeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get all products from API
      final productsResponse = await ProductService.getProducts(limit: 50);
      
      if (productsResponse['success'] == true) {
        final products = productsResponse['products'] as List<ProductModel>;
        
        setState(() {
          allProducts = products;
          
          // Featured Medicines - best sellers and high-rated medicines
          featuredMedicines = products
              .where((p) => (p.category == 'medicines' || p.category == 'vitamins') && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          featuredMedicines = featuredMedicines.take(6).toList();
          
          // Groceries Highlights - snacks, drinks, baby essentials
          groceriesHighlights = products
              .where((p) => (p.category == 'groceries' || p.category == 'snacks' || p.category == 'baby_care') && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          groceriesHighlights = groceriesHighlights.take(4).toList();
          
          // Special Offers - products with high ratings or low stock (as special offers)
          specialOffers = products
              .where((p) => p.isAvailable && (p.rating ?? 0) >= 4.0)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          specialOffers = specialOffers.take(4).toList();
          
          isLoading = false;
        });
      } else {
        // Handle API error
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load products: ${productsResponse['message']}');
      }
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        isLoading = false;
      });
      _showError('Network error: Please check your connection and ensure the server is running.');
    }
  }

  void _onSearchChanged() {
    String query = txtSearch.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    // Search via API for better results
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final response = await ProductService.searchProducts(query: query, limit: 20);
      
      if (response['success'] == true) {
        setState(() {
          isSearching = true;
          searchResults = response['products'] as List<ProductModel>;
        });
      }
    } catch (e) {
      print('Search error: $e');
      // Fallback to local search if API fails
      _performLocalSearch(query);
    }
  }

  void _performLocalSearch(String query) {
    // Filter products based on search query (fallback)
    List<ProductModel> filtered = allProducts.where((product) {
      String name = product.name.toLowerCase();
      String description = product.description.toLowerCase();
      String category = product.categoryDisplayName.toLowerCase();
      String brand = (product.brand ?? "").toLowerCase();
      String activeIngredient = (product.activeIngredient ?? "").toLowerCase();

      return name.contains(query) ||
             description.contains(query) ||
             category.contains(query) ||
             brand.contains(query) ||
             activeIngredient.contains(query);
    }).toList();

    setState(() {
      isSearching = true;
      searchResults = filtered;
    });
  }

  void _clearSearch() {
    txtSearch.clear();
    setState(() {
      isSearching = false;
      searchResults.clear();
    });
  }

  /// Add product to cart
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
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadHomeData,
        ),
      ),
    );
  }

  void _showConsultationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pharmacist Consultation", style: TextStyle(color: TColor.primaryText)),
        content: Text("Our licensed pharmacists are available for consultation. Please visit our store or call us for personalized advice."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: TColor.primary)),
          ),
        ],
      ),
    );
  }

  void _navigateToProducts(String category, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsView(
          category: category,
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHomeData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 46),
                
                // Header with title and cart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nine27 Pharmacy",
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "Your health, our priority",
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),



                      const SizedBox(width: 10),
                      const CartIcon(size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Location
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Delivering to",
                          style: TextStyle(
                              color: TColor.secondaryText, fontSize: 11)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationSelectionView(),
                            ),
                          );
                          if (result != null && result is String) {
                            setState(() {
                              currentAddress = result;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: TColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TColor.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: TColor.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(currentAddress,
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: TColor.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StatefulBuilder(
                    builder: (context, setSearchState) {
                      return RoundTextfield(
                        hintText: "Search medicines, vitamins, brands...",
                        controller: txtSearch,
                        left: Container(
                          alignment: Alignment.center,
                          width: 30,
                          child: Image.asset("assets/img/search.png",
                              width: 20, height: 20),
                        ),
                        right: txtSearch.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _clearSearch();
                                  setSearchState(() {});
                                },
                                icon: Icon(Icons.clear, size: 20, color: TColor.secondaryText),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Loading indicator
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                else if (isSearching) ...[
                  // Search Results
                  _buildSearchResults()
                ] else ...[
                  // Normal home content
                  _buildHomeContent()
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                "Search Results",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "(${searchResults.length} found)",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        if (searchResults.isEmpty)
          // No results found
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No medicines found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try searching with different keywords",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Search results list
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              var product = searchResults[index];
              return _buildProductCard(product);
            },
          ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHomeContent() {
    if (allProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.medical_services, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No products available",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please check your connection and try again",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHomeData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Categories
        Container(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: catArr.length,
            itemBuilder: (context, index) {
              var cObj = catArr[index] as Map? ?? {};
              return CategoryCell(
                cObj: cObj, 
                onTap: () {
                  // Navigate to category products
                  _navigateToCategory(cObj['category'] ?? '');
                }
              );
            },
          ),
        ),

        // Featured Medicines Section
        if (featuredMedicines.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Featured Medicines", 
              onView: () => _navigateToProducts('', 'All Products')
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: featuredMedicines.length,
              itemBuilder: (context, index) {
                var product = featuredMedicines[index];
                return _buildFeaturedMedicineCard(product);
              },
            ),
          ),
        ],

        const SizedBox(height: 30),

        // Groceries Highlights Section
        if (groceriesHighlights.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Groceries Highlights", 
              onView: () => _navigateToProducts('groceries', 'Groceries & Essentials')
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: groceriesHighlights.length,
              itemBuilder: (context, index) {
                var product = groceriesHighlights[index];
                return _buildGroceryCard(product);
              },
            ),
          ),
        ],

        const SizedBox(height: 30),

        // Special Offers Section
        if (specialOffers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Special Offers & Discounts", 
              onView: () => _navigateToProducts('offers', 'Special Offers')
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: specialOffers.length,
              itemBuilder: (context, index) {
                var product = specialOffers[index];
                return _buildSpecialOfferCard(product);
              },
            ),
          ),
        ],

        const SizedBox(height: 30),

        // Quick Links Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Links",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemCount: quickLinks.length,
                itemBuilder: (context, index) {
                  var link = quickLinks[index];
                  return _buildQuickLinkCard(link);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 100), // Bottom spacing
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.image ?? "assets/img/med.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.medical_services),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  product.description,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (product.requiresPrescription)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rx",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.categoryDisplayName,
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: product.inStock ? () => _addToCart(product) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: product.inStock ? TColor.primary : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              product.inStock ? "Add" : "Out",
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMedicineCard(ProductModel product) {
    return Container(
      width: 160,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              product.image ?? "assets/img/med.png",
              width: double.infinity,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 90,
                  color: Colors.blue[50],
                  child: Icon(Icons.medication, color: Colors.blue[600], size: 30),
                );
              },
            ),
          ),

          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.brand != null)
                  Text(
                    product.brand!,
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (product.rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
           
        
          
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.inStock ? () => _addToCart(product) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.inStock ? Colors.blue[600] : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Text(
                      product.inStock ? "Add" : "Out",
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryCard(ProductModel product) {
    return Container(
      width: 140,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              product.image ?? "assets/img/vitamins.png",
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.green[50],
                  child: Icon(Icons.shopping_basket, color: Colors.green[600], size: 30),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.inStock ? () => _addToCart(product) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.inStock ? Colors.green[600] : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: Text(
                      product.inStock ? "Add" : "Out",
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferCard(ProductModel product) {
    return Container(
      width: 160,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  product.image ?? "assets/img/med.png",
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.orange[50],
                      child: Icon(Icons.local_offer, color: Colors.orange[600], size: 35),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                                            if (product.rating != null && product.rating! >= 4.0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "⭐ ${product.rating!.toStringAsFixed(1)}",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: product.inStock ? () => _addToCart(product) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.inStock ? Colors.orange[600] : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: Text(
                          product.inStock ? "Add" : "Out",
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Rating badge
          if (product.rating != null && product.rating! >= 4.0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "⭐ ${product.rating!.toStringAsFixed(1)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkCard(Map link) {
    return InkWell(
      onTap: link['onTap'],
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: link['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: link['color'].withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: link['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                link['icon'],
                color: link['color'],
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              link['title'],
              style: TextStyle(
                color: link['color'],
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              link['subtitle'],
              style: TextStyle(
                color: link['color'].withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(String category) {
    String categoryName;
    switch (category) {
      case 'medicines':
        categoryName = 'Pain Relief Medicines';
        break;
      case 'vitamins':
        categoryName = 'Health Supplements';
        break;
      case 'first_aid':
        categoryName = 'First Aid & Wound Care';
        break;
      case 'prescription_drugs':
        categoryName = 'Prescription Medicines';
        break;
      default:
        categoryName = 'Products';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsView(
          category: category,
          categoryName: categoryName,
        ),
      ),
    );
  }
}