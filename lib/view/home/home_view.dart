import 'package:flutter/material.dart';
import 'dart:async';
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
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../products/category_products_view.dart';
import '../products/product_catalog_view.dart';
import '../orders/order_tracking_view.dart';
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

  // Promotions carousel
  final PageController _promoController = PageController(viewportFraction: 0.9);
  int _currentPromo = 0;
  Timer? _promoTimer;
  final List<String> _promoImages = const [
    'assets/img/offer_1.png',
    'assets/img/offer_2.png',
    'assets/img/offer_3.png',
  ];

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
  
  // Recent orders for quick access
  List<OrderModel> recentOrders = [];

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

    // start auto-scroll for promotions
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _promoImages.isEmpty) return;
      final next = (_currentPromo + 1) % _promoImages.length;
      _promoController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPromo = next;
      });
    });
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  /// Load all data for the home screen from MySQL API
  Future<void> _loadHomeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get all products from API with reduced limit for faster loading
      final productsResponse = await ProductService.getProducts(limit: 20);
      
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
        });
      } else {
        // Handle API error
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load products: ${productsResponse['message']}');
        return;
      }
      
      // Load recent orders in parallel for better performance
      _loadRecentOrders();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        isLoading = false;
      });
      _showError('Network error: Please check your connection and ensure the server is running.');
    }
  }

  /// Load recent orders for quick access
  Future<void> _loadRecentOrders() async {
    try {
      final result = await OrderService.getUserOrders(limit: 3);
      if (result['success'] == true) {
        setState(() {
          recentOrders = result['orders'] as List<OrderModel>;
        });
      }
    } catch (e) {
      print('Error loading recent orders: $e');
      // Don't show error for orders, just log it
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

  // Hero banner with metrics and CTAs, inspired by provided reference
  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/img/splash_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.teal, size: 16),
                    SizedBox(width: 6),
                    Text('Licensed & Certified Pharmacy', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Your Health',
            style: TextStyle(
              color: TColor.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
          ),
          Text(
            'Delivered Fast',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order medicines and healthcare products from licensed pharmacists with secure, fast delivery.',
            style: TextStyle(color: TColor.primaryText.withOpacity(0.8), fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToProducts('', 'All Products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.local_mall, color: Colors.white, size: 18),
                  label: const Text('Browse Medicines', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToProducts('prescription_drugs', 'Prescription Medicines'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white.withOpacity(0.85),
                  ),
                  icon: Icon(Icons.upload_file, color: Colors.blue[700], size: 18),
                  label: Text('Prescription Upload', style: TextStyle(color: Colors.blue[700])),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroMetric(Icons.star, '4.9', 'Trust Rating', Colors.pinkAccent),
              _buildHeroMetric(Icons.timer, '2hr', 'Avg Delivery', Colors.blueAccent),
              _buildHeroMetric(Icons.medical_services, '10K+', 'Medicines', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: TColor.primaryText)),
            Text(label, style: TextStyle(fontSize: 11, color: TColor.secondaryText)),
          ],
        )
      ],
    );
  }

  Widget _buildPromotionsCarousel() {
    return SizedBox(
      height: 140,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _promoController,
              itemCount: _promoImages.length,
              onPageChanged: (i) => setState(() => _currentPromo = i),
              itemBuilder: (context, index) {
                final img = _promoImages[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(img, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 14,
                          child: Text(
                            'Limited-time offers',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_promoImages.length, (i) {
              final active = i == _currentPromo;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 18 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? Colors.blue[700] : Colors.blue[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          )
        ],
      ),
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
        // Hero banner section with headline and CTAs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildHeroBanner(),
        ),
        const SizedBox(height: 20),

        // Promotions carousel
        _buildPromotionsCarousel(),
        const SizedBox(height: 20),
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
              title: "Top Picks For You", 
              onView: () => _navigateToProducts('', 'All Products')
            ),
          ),
          const SizedBox(height: 15),
          // Grid view to make products front and center
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: featuredMedicines.length.clamp(0, 6),
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

        // Recent Orders Section
        if (recentOrders.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Recent Orders", 
              onView: () => Navigator.pushNamed(context, '/orders')
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: recentOrders.length,
              itemBuilder: (context, index) {
                var order = recentOrders[index];
                return _buildRecentOrderCard(order);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],

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

  Widget _buildRecentOrderCard(OrderModel order) {
    return Container(
      width: 200,
      height: 120,
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingView(
                orderNumber: order.orderNumber,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getOrderStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getOrderStatusIcon(order.status),
                      color: _getOrderStatusColor(order.status),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  color: _getOrderStatusColor(order.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.formattedDate,
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.formattedTotal,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order.itemCountText,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.purple;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.pending;
    }
  }
}