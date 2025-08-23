import 'dart:async';
import '../common/service_call.dart';
import '../common/globs.dart';
import '../models/product_model.dart';

class ProductService {
  // Get all products with filtering and pagination
  static Future<Map<String, dynamic>> getProducts({
    String? search,
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        parameters['search'] = search;
      }

      if (filters != null) {
        parameters.addAll(filters.toQueryParams());
      }

      final response = await _makeApiCall(
        '${SVKey.baseUrl}products',
        parameters,
        isToken: false, // Products can be viewed without authentication
      );

      if (response['success'] == true) {
        List<ProductModel> products = [];
        if (response['products'] != null) {
          products = (response['products'] as List)
              .map((productJson) => ProductModel.fromJson(productJson))
              .toList();
        }

        return {
          'success': true,
          'products': products,
          'total': response['total'] ?? 0,
          'currentPage': response['current_page'] ?? 1,
          'totalPages': response['total_pages'] ?? 1,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch products',
          'products': <ProductModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'products': <ProductModel>[],
      };
    }
  }

  // Get product details by ID
  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}products/$productId',
        {},
        isToken: false,
        method: 'GET',
      );

      if (response['success'] == true && response['product'] != null) {
        ProductModel product = ProductModel.fromJson(response['product']);
        return {
          'success': true,
          'product': product,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Product not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get products by category
  static Future<Map<String, dynamic>> getProductsByCategory({
    required String category,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    final filters = ProductFilters(
      category: category,
      sortBy: sortBy,
    );

    return getProducts(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  // Search products
  static Future<Map<String, dynamic>> searchProducts({
    required String query,
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    return getProducts(
      search: query,
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  // Get featured products
  static Future<Map<String, dynamic>> getFeaturedProducts({
    int limit = 10,
  }) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}products/featured',
        {'limit': limit},
        isToken: false,
      );

      if (response['success'] == true) {
        List<ProductModel> products = [];
        if (response['products'] != null) {
          products = (response['products'] as List)
              .map((productJson) => ProductModel.fromJson(productJson))
              .toList();
        }

        return {
          'success': true,
          'products': products,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch featured products',
          'products': <ProductModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'products': <ProductModel>[],
      };
    }
  }

  // Get product categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}categories',
        {},
        isToken: false,
      );

      if (response['success'] == true) {
        List<ProductCategory> categories = [];
        if (response['categories'] != null) {
          categories = (response['categories'] as List)
              .map((categoryJson) => ProductCategory.fromJson(categoryJson))
              .toList();
        }

        return {
          'success': true,
          'categories': categories,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch categories',
          'categories': <ProductCategory>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'categories': <ProductCategory>[],
      };
    }
  }

  // Get popular products
  static Future<Map<String, dynamic>> getPopularProducts({
    int limit = 10,
  }) async {
    final filters = ProductFilters(sortBy: 'rating_desc');
    
    return getProducts(
      filters: filters,
      limit: limit,
    );
  }

  // Get products on sale
  static Future<Map<String, dynamic>> getProductsOnSale({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}products/on-sale',
        {
          'page': page,
          'limit': limit,
        },
        isToken: false,
      );

      if (response['success'] == true) {
        List<ProductModel> products = [];
        if (response['products'] != null) {
          products = (response['products'] as List)
              .map((productJson) => ProductModel.fromJson(productJson))
              .toList();
        }

        return {
          'success': true,
          'products': products,
          'total': response['total'] ?? 0,
          'currentPage': response['current_page'] ?? 1,
          'totalPages': response['total_pages'] ?? 1,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch sale products',
          'products': <ProductModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'products': <ProductModel>[],
      };
    }
  }

  // Get product suggestions based on search
  static Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}products/suggestions',
        {'query': query},
        isToken: false,
      );

      if (response['success'] == true && response['suggestions'] != null) {
        return List<String>.from(response['suggestions']);
      }
    } catch (e) {
      // Ignore errors for suggestions
    }

    return [];
  }

  // Helper method to make API calls
  static Future<Map<String, dynamic>> _makeApiCall(
    String url,
    Map<String, dynamic> parameters, {
    bool isToken = false,
    String method = 'POST',
  }) async {
    final completer = Completer<Map<String, dynamic>>();

    ServiceCall.post(parameters, url, isToken: isToken,
      withSuccess: (responseObj) async {
        completer.complete(responseObj);
      },
      failure: (err) async {
        completer.complete({
          'success': false,
          'message': err.toString(),
        });
      }
    );

    return completer.future;
  }
}

// Mock data for testing (remove when backend is ready)
class MockProductService {
  static List<ProductModel> getMockProducts() {
    return [
      ProductModel(
        id: 1,
        name: 'Biogesic 500mg',
        description: 'Paracetamol 500mg tablet for fever and pain relief. Fast-acting formula for headaches, muscle pain, and fever reduction.',
        price: 50.00,
        image: 'assets/img/biogesic.jpg',
        category: 'medicines',
        brand: 'Unilab',
        sku: 'BIO-500-20',
        stockQuantity: 150,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '500mg',
        activeIngredient: 'Paracetamol',
        manufacturer: 'Unilab',
        rating: 4.5,
        reviewCount: 128,
        tags: ['pain relief', 'fever', 'headache'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 2,
        name: 'Vitamin C 500mg',
        description: 'High-potency Vitamin C supplement for immune system support. Helps boost immunity and fight infections.',
        price: 15.00,
        image: 'assets/img/vitamin-c.jpg',
        category: 'vitamins',
        brand: 'Centrum',
        sku: 'VIT-C-500-30',
        stockQuantity: 200,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '500mg',
        activeIngredient: 'Ascorbic Acid',
        manufacturer: 'Pfizer',
        rating: 4.3,
        reviewCount: 89,
        tags: ['vitamin', 'immunity', 'antioxidant'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 3,
        name: 'Betadine Solution 60ml',
        description: 'Antiseptic solution for wound cleaning and disinfection. Effective against bacteria, viruses, and fungi.',
        price: 85.00,
        image: 'assets/img/betadine.jpg',
        category: 'first_aid',
        brand: 'Betadine',
        sku: 'BET-SOL-60',
        stockQuantity: 75,
        isAvailable: true,
        requiresPrescription: false,
        activeIngredient: 'Povidone Iodine',
        manufacturer: 'Mundipharma',
        rating: 4.7,
        reviewCount: 156,
        tags: ['antiseptic', 'wound care', 'disinfectant'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 4,
        name: 'Amoxicillin 500mg',
        description: 'Antibiotic capsule for bacterial infections. Effective treatment for respiratory and urinary tract infections.',
        price: 25.00,
        image: 'assets/img/amoxicillin.jpg',
        category: 'prescription_drugs',
        brand: 'Generics',
        sku: 'AMX-500-21',
        stockQuantity: 100,
        isAvailable: true,
        requiresPrescription: true,
        dosage: '500mg',
        activeIngredient: 'Amoxicillin',
        manufacturer: 'Generics Pharmacy',
        rating: 4.2,
        reviewCount: 67,
        tags: ['antibiotic', 'infection', 'prescription'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 5,
        name: 'Centrum Multivitamins',
        description: 'Complete multivitamin and mineral supplement. Daily nutrition support for adults with essential vitamins and minerals.',
        price: 450.00,
        image: 'assets/img/centrum.jpg',
        category: 'vitamins',
        brand: 'Centrum',
        sku: 'CEN-MULTI-30',
        stockQuantity: 50,
        isAvailable: true,
        requiresPrescription: false,
        manufacturer: 'Pfizer',
        rating: 4.6,
        reviewCount: 234,
        tags: ['multivitamin', 'daily nutrition', 'minerals'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<ProductCategory> getMockCategories() {
    return ProductCategories.getCategories();
  }
}
