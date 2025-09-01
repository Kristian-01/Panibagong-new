import 'dart:async';
import 'dart:convert';
import '../common/service_call.dart';
import '../common/globs.dart';
import '../models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductService {
  // Get all products with filtering and pagination
  static Future<Map<String, dynamic>> getProducts({
    String? search,
    ProductFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build API URL with parameters
      String url = '${SVKey.svProducts}?page=$page&limit=$limit';
      
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      
      if (filters?.category != null) {
        url += '&category=${Uri.encodeComponent(filters!.category!)}';
      }
      
      // Make API call using http package directly for simplicity
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final productsData = jsonData['products'] as List;
          final products = productsData.map((json) => ProductModel.fromJson(json)).toList();
          
          return {
            'success': true,
            'products': products,
            'total': jsonData['total'] ?? products.length,
            'currentPage': jsonData['current_page'] ?? page,
            'totalPages': jsonData['total_pages'] ?? 1,
          };
        }
      }
      
      // Fallback to mock data if API fails
      return _getFilteredMockProducts(search: search, filters: filters, limit: limit);
    } catch (e) {
      // Fallback to mock data on error
      return _getFilteredMockProducts(search: search, filters: filters, limit: limit);
    }
  }

  // Get product details by ID
  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    try {
      // Try to get product details from API
      final url = '${SVKey.svProductDetails}$productId';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final product = ProductModel.fromJson(jsonData['product']);
          
          return {
            'success': true,
            'product': product,
          };
        }
      }
      
      // Fallback to mock data if API fails
      final mockProducts = MockProductService.getMockProducts();
      final product = mockProducts.firstWhere((p) => p.id == productId);
      
      return {
        'success': true,
        'product': product,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Product not found',
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
      // Try to get featured products from API
      final url = '${SVKey.svFeaturedProducts}?limit=$limit';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final productsData = jsonData['products'] as List;
          final products = productsData.map((json) => ProductModel.fromJson(json)).toList();
          
          return {
            'success': true,
            'products': products,
          };
        }
      }
      
      // Fallback to mock data if API fails
      final mockProducts = MockProductService.getMockProducts();
      final featured = mockProducts.where((p) => (p.rating ?? 0) >= 4.0).take(limit).toList();
      
      return {
        'success': true,
        'products': featured,
      };
    } catch (e) {
      // Fallback to mock data on error
      final mockProducts = MockProductService.getMockProducts();
      final featured = mockProducts.where((p) => (p.rating ?? 0) >= 4.0).take(limit).toList();
      
      return {
        'success': true,
        'products': featured,
      };
    }
  }

  // Get product categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final categories = ProductCategories.getCategories();
      
      return {
        'success': true,
        'categories': categories,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'categories': <ProductCategory>[],
      };
    }
  }

  // Helper method to get filtered mock products
  static Map<String, dynamic> _getFilteredMockProducts({
    String? search,
    ProductFilters? filters,
    int limit = 20,
  }) {
    final mockProducts = MockProductService.getMockProducts();
    List<ProductModel> filteredProducts = mockProducts;
    
    if (search != null && search.isNotEmpty) {
      filteredProducts = mockProducts.where((product) {
        return product.name.toLowerCase().contains(search.toLowerCase()) ||
               product.description.toLowerCase().contains(search.toLowerCase()) ||
               (product.brand ?? "").toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    
    if (filters?.category != null) {
      filteredProducts = filteredProducts.where((p) => p.category == filters!.category).toList();
    }
    
    // Apply limit
    if (limit < filteredProducts.length) {
      filteredProducts = filteredProducts.take(limit).toList();
    }
    
    return {
      'success': true,
      'products': filteredProducts,
      'total': filteredProducts.length,
      'currentPage': 1,
      'totalPages': 1,
    };
  }
}

// Enhanced mock data with more products
class MockProductService {
  static List<ProductModel> getMockProducts() {
    return [
      // Medicines
      ProductModel(
        id: 1,
        name: 'Biogesic 500mg',
        description: 'Paracetamol 500mg tablet for fever and pain relief',
        price: 50.00,
        image: 'assets/img/med.png',
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
        name: 'Advil 200mg',
        description: 'Ibuprofen tablets for pain relief and inflammation',
        price: 75.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Pfizer',
        sku: 'ADV-200-20',
        stockQuantity: 120,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '200mg',
        activeIngredient: 'Ibuprofen',
        manufacturer: 'Pfizer',
        rating: 4.4,
        reviewCount: 95,
        tags: ['pain relief', 'inflammation', 'fever'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 3,
        name: 'Tylenol 500mg',
        description: 'Acetaminophen tablets for fever and pain relief',
        price: 65.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Johnson & Johnson',
        sku: 'TYL-500-24',
        stockQuantity: 80,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '500mg',
        activeIngredient: 'Acetaminophen',
        manufacturer: 'Johnson & Johnson',
        rating: 4.6,
        reviewCount: 142,
        tags: ['pain relief', 'fever', 'safe'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 4,
        name: 'Aspirin 325mg',
        description: 'Low-dose aspirin for heart health and pain relief',
        price: 35.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Bayer',
        sku: 'ASP-325-100',
        stockQuantity: 200,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '325mg',
        activeIngredient: 'Acetylsalicylic Acid',
        manufacturer: 'Bayer',
        rating: 4.3,
        reviewCount: 78,
        tags: ['heart health', 'pain relief', 'blood thinner'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 5,
        name: 'Mefenamic Acid 500mg',
        description: 'Anti-inflammatory medicine for pain and fever',
        price: 45.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Generics',
        sku: 'MEF-500-10',
        stockQuantity: 90,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '500mg',
        activeIngredient: 'Mefenamic Acid',
        manufacturer: 'Generics Pharmacy',
        rating: 4.2,
        reviewCount: 67,
        tags: ['pain relief', 'inflammation', 'menstrual pain'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      
      // Additional Medicines from Your List
      ProductModel(
        id: 6,
        name: 'ASCORBIC ACID (MYREVIT C) 120 ML',
        description: 'Vitamin C syrup for immune system support',
        price: 85.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Myrevit',
        sku: 'VIT-C-120',
        stockQuantity: 100,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '120ml',
        activeIngredient: 'Ascorbic Acid',
        manufacturer: 'Myrevit',
        rating: 4.6,
        reviewCount: 95,
        tags: ['vitamin c', 'immune system', 'antioxidant'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 7,
        name: 'Ceelin Chewable 30s/bot (Ascorbic)',
        description: 'Chewable Vitamin C tablets for children',
        price: 75.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Ceelin',
        sku: 'CEL-CHEW-30',
        stockQuantity: 150,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '30 tablets',
        activeIngredient: 'Ascorbic Acid',
        manufacturer: 'Ceelin',
        rating: 4.7,
        reviewCount: 203,
        tags: ['vitamin c', 'children', 'chewable'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 8,
        name: 'ASCOF 600mg 120ml Syrup',
        description: 'Herbal cough syrup with lagundi extract',
        price: 75.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'ASCOF',
        sku: 'ASCOF-600-120',
        stockQuantity: 100,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '600mg/5ml',
        activeIngredient: 'Lagundi Extract',
        manufacturer: 'ASCOF',
        rating: 4.6,
        reviewCount: 156,
        tags: ['cough', 'herbal', 'lagundi'],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 9,
        name: 'Bioflu Tablet',
        description: 'Combination medicine for flu symptoms',
        price: 55.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Unilab',
        sku: 'BIOFLU-20',
        stockQuantity: 140,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '1 tablet as needed',
        activeIngredient: 'Paracetamol + Phenylephrine + Chlorphenamine',
        manufacturer: 'Unilab',
        rating: 4.5,
        reviewCount: 189,
        tags: ['flu', 'cold', 'fever'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 10,
        name: 'Vicks Vaporub 10g',
        description: 'Topical ointment for cough and cold relief',
        price: 35.00,
        image: 'assets/img/med.png',
        category: 'medicines',
        brand: 'Vicks',
        sku: 'VICKS-10G',
        stockQuantity: 200,
        isAvailable: true,
        requiresPrescription: false,
        dosage: 'Apply to chest and throat',
        activeIngredient: 'Menthol + Camphor + Eucalyptus',
        manufacturer: 'Vicks',
        rating: 4.6,
        reviewCount: 289,
        tags: ['cough', 'cold', 'topical'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now(),
      ),

      // Vitamins
      ProductModel(
        id: 11,
        name: 'Vitamin C 500mg',
        description: 'High-potency Vitamin C supplement for immune system support',
        price: 15.00,
        image: 'assets/img/vitamins.png',
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
        id: 12,
        name: 'Multivitamins Complete',
        description: 'Complete daily multivitamin with minerals',
        price: 450.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Centrum',
        sku: 'MUL-COM-30',
        stockQuantity: 60,
        isAvailable: true,
        requiresPrescription: false,
        manufacturer: 'Pfizer',
        rating: 4.5,
        reviewCount: 203,
        tags: ['multivitamin', 'daily nutrition', 'minerals'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 13,
        name: 'Vitamin D3 1000IU',
        description: 'High-potency Vitamin D3 for bone health',
        price: 320.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Nature Made',
        sku: 'VIT-D3-1000-60',
        stockQuantity: 90,
        isAvailable: true,
        requiresPrescription: false,
        dosage: '1000IU',
        activeIngredient: 'Cholecalciferol',
        manufacturer: 'Nature Made',
        rating: 4.7,
        reviewCount: 156,
        tags: ['vitamin d', 'bone health', 'immunity'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 14,
        name: 'Omega-3 Fish Oil',
        description: 'Premium fish oil capsules for heart and brain health',
        price: 680.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Nordic Naturals',
        sku: 'OME-3-120',
        stockQuantity: 45,
        isAvailable: true,
        requiresPrescription: false,
        manufacturer: 'Nordic Naturals',
        rating: 4.8,
        reviewCount: 234,
        tags: ['omega 3', 'heart health', 'brain health'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 15,
        name: 'Calcium + Vitamin D',
        description: 'Calcium supplement with Vitamin D for bone strength',
        price: 280.00,
        image: 'assets/img/vitamins.png',
        category: 'vitamins',
        brand: 'Caltrate',
        sku: 'CAL-VD-60',
        stockQuantity: 75,
        isAvailable: true,
        requiresPrescription: false,
        manufacturer: 'Pfizer',
        rating: 4.4,
        reviewCount: 112,
        tags: ['calcium', 'bone health', 'vitamin d'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),

      // First Aid
      ProductModel(
        id: 16,
        name: 'Betadine Solution 60ml',
        description: 'Antiseptic solution for wound cleaning and disinfection',
        price: 85.00,
        image: 'assets/img/first aid.png',
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
        id: 17,
        name: 'Alcohol 70% 500ml',
        description: 'Isopropyl alcohol for disinfection and cleaning',
        price: 45.00,
        image: 'assets/img/first aid.png',
        category: 'first_aid',
        brand: 'Green Cross',
        sku: 'ALC-70-500',
        stockQuantity: 150,
        isAvailable: true,
        requiresPrescription: false,
        activeIngredient: 'Isopropyl Alcohol',
        manufacturer: 'Green Cross',
        rating: 4.2,
        reviewCount: 67,
        tags: ['disinfectant', 'cleaning', 'antiseptic'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 18,
        name: 'Band-Aid Adhesive Bandages',
        description: 'Sterile adhesive bandages for wound protection',
        price: 125.00,
        image: 'assets/img/first aid.png',
        category: 'first_aid',
        brand: 'Band-Aid',
        sku: 'BND-AID-50',
        stockQuantity: 200,
        isAvailable: true,
        requiresPrescription: false,
        manufacturer: 'Johnson & Johnson',
        rating: 4.6,
        reviewCount: 189,
        tags: ['bandages', 'wound care', 'first aid'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 19,
        name: 'Hydrogen Peroxide 3%',
        description: 'Antiseptic solution for wound cleaning',
        price: 35.00,
        image: 'assets/img/first aid.png',
        category: 'first_aid',
        brand: 'Generic',
        sku: 'HYD-PER-250',
        stockQuantity: 100,
        isAvailable: true,
        requiresPrescription: false,
        activeIngredient: 'Hydrogen Peroxide',
        manufacturer: 'Generic Pharma',
        rating: 4.1,
        reviewCount: 45,
        tags: ['antiseptic', 'wound cleaning', 'disinfectant'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),

      // Prescription Drugs
      ProductModel(
        id: 20,
        name: 'Amoxicillin 500mg',
        description: 'Antibiotic capsule for bacterial infections',
        price: 25.00,
        image: 'assets/img/med.png',
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
        id: 21,
        name: 'Losartan 50mg',
        description: 'ACE inhibitor for high blood pressure',
        price: 180.00,
        image: 'assets/img/med.png',
        category: 'prescription_drugs',
        brand: 'Generics',
        sku: 'LOS-50-30',
        stockQuantity: 60,
        isAvailable: true,
        requiresPrescription: true,
        dosage: '50mg',
        activeIngredient: 'Losartan Potassium',
        manufacturer: 'Generics Pharmacy',
        rating: 4.4,
        reviewCount: 89,
        tags: ['blood pressure', 'hypertension', 'prescription'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: 22,
        name: 'Metformin 500mg',
        description: 'Diabetes medication for blood sugar control',
        price: 95.00,
        image: 'assets/img/med.png',
        category: 'prescription_drugs',
        brand: 'Generics',
        sku: 'MET-500-30',
        stockQuantity: 80,
        isAvailable: true,
        requiresPrescription: true,
        dosage: '500mg',
        activeIngredient: 'Metformin HCl',
        manufacturer: 'Generics Pharmacy',
        rating: 4.3,
        reviewCount: 112,
        tags: ['diabetes', 'blood sugar', 'prescription'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<ProductCategory> getMockCategories() {
    return ProductCategories.getCategories();
  }
}