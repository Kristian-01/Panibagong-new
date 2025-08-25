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
  List<ProductModel> popularVitamins = [];
  List<ProductModel> firstAidItems = [];
  List<ProductModel> prescriptionDrugs = [];
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

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
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
          
          // Featured Medicines - pain relief medicines with high ratings
          featuredMedicines = products
              .where((p) => p.category == 'medicines' && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          featuredMedicines = featuredMedicines.take(5).toList();
          
          // Popular Vitamins - vitamins and supplements
          popularVitamins = products
              .where((p) => p.category == 'vitamins' && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          popularVitamins = popularVitamins.take(4).toList();
          
          // First Aid Items - wound care and antiseptics
          firstAidItems = products
              .where((p) => p.category == 'first_aid' && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          firstAidItems = firstAidItems.take(4).toList();
          
          // Prescription Drugs - require prescription
          prescriptionDrugs = products
              .where((p) => p.category == 'prescription_drugs' && p.isAvailable)
              .toList()
              ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          prescriptionDrugs = prescriptionDrugs.take(3).toList();
          
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
        SizedBox(
          height: 120,
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

        // Pain Relief Medicines
        if (featuredMedicines.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Pain Relief Medicines", 
              onView: () => _navigateToCategory('medicines')
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: featuredMedicines.length,
            itemBuilder: (context, index) {
              var product = featuredMedicines[index];
              return _buildMedicineRow(product);
            },
          ),
        ],

        // Health Supplements (Vitamins)
        if (popularVitamins.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Health Supplements", 
              onView: () => _navigateToCategory('vitamins')
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: popularVitamins.length,
              itemBuilder: (context, index) {
                var product = popularVitamins[index];
                return _buildVitaminCard(product);
              },
            ),
          ),
        ],

        // First Aid & Wound Care
        if (firstAidItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "First Aid & Wound Care", 
              onView: () => _navigateToCategory('first_aid')
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: firstAidItems.length,
              itemBuilder: (context, index) {
                var product = firstAidItems[index];
                return _buildFirstAidCard(product);
              },
            ),
          ),
        ],

        // Prescription Medicines
        if (prescriptionDrugs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ViewAllTitleRow(
              title: "Prescription Medicines", 
              onView: () => _navigateToCategory('prescription_drugs')
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: prescriptionDrugs.length,
            itemBuilder: (context, index) {
              var product = prescriptionDrugs[index];
              return _buildPrescriptionRow(product);
            },
          ),
        ],

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

  Widget _buildMedicineRow(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.blue[50],
                  child: Icon(Icons.medication, color: Colors.blue[600], size: 30),
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
                if (product.brand != null)
                  Text(
                    "by ${product.brand}",
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                    const SizedBox(width: 8),
                    if (product.rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: product.inStock ? () => _addToCart(product) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: product.inStock ? Colors.blue[600] : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              product.inStock ? "Add to Cart" : "Out of Stock",
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminCard(ProductModel product) {
    return Container(
      width: 200,
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
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.green[50],
                  child: Icon(Icons.health_and_safety, color: Colors.green[600], size: 40),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 14,
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
                      color: Colors.green[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 8),
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
                      backgroundColor: product.inStock ? Colors.green[600] : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      product.inStock ? "Add" : "Out",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
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

  Widget _buildFirstAidCard(ProductModel product) {
    return Container(
      width: 180,
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
              product.image ?? "assets/img/first aid.png",
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.red[50],
                  child: Icon(Icons.medical_services, color: Colors.red[600], size: 35),
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
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: product.inStock ? () => _addToCart(product) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.inStock ? Colors.red[600] : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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

  Widget _buildPrescriptionRow(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.image ?? "assets/img/med.png",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.orange[50],
                  child: Icon(Icons.local_pharmacy, color: Colors.orange[600], size: 20),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Rx Required",
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: product.inStock ? () => _addToCart(product) : null,
            child: Text(
              product.inStock ? "Add" : "Out",
              style: TextStyle(
                color: product.inStock ? Colors.orange[600] : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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