class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final String? brand;
  final String? sku;
  final int stockQuantity;
  final bool isAvailable;
  final bool requiresPrescription;
  final String? dosage;
  final String? activeIngredient;
  final String? manufacturer;
  final DateTime? expiryDate;
  final double? rating;
  final int? reviewCount;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.category,
    this.brand,
    this.sku,
    required this.stockQuantity,
    required this.isAvailable,
    required this.requiresPrescription,
    this.dosage,
    this.activeIngredient,
    this.manufacturer,
    this.expiryDate,
    this.rating,
    this.reviewCount,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'],
      category: json['category'] ?? '',
      brand: json['brand'],
      sku: json['sku'],
      stockQuantity: json['stock_quantity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      requiresPrescription: json['requires_prescription'] ?? false,
      dosage: json['dosage'],
      activeIngredient: json['active_ingredient'],
      manufacturer: json['manufacturer'],
      expiryDate: json['expiry_date'] != null 
          ? DateTime.tryParse(json['expiry_date']) 
          : null,
      rating: json['rating'] != null 
          ? double.tryParse(json['rating'].toString()) 
          : null,
      reviewCount: json['review_count'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'brand': brand,
      'sku': sku,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
      'requires_prescription': requiresPrescription,
      'dosage': dosage,
      'active_ingredient': activeIngredient,
      'manufacturer': manufacturer,
      'expiry_date': expiryDate?.toIso8601String(),
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedPrice => '₱${price.toStringAsFixed(2)}';
  
  bool get inStock => stockQuantity > 0 && isAvailable;
  
  bool get lowStock => stockQuantity <= 10 && stockQuantity > 0;
  
  bool get outOfStock => stockQuantity <= 0;
  
  String get stockStatus {
    if (outOfStock) return 'Out of Stock';
    if (lowStock) return 'Low Stock';
    return 'In Stock';
  }

  String get formattedRating {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} ⭐';
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'medicines':
        return 'Medicines';
      case 'vitamins':
        return 'Vitamins & Supplements';
      case 'first_aid':
        return 'First Aid';
      case 'health_products':
        return 'Health Products';
      case 'prescription_drugs':
        return 'Prescription Drugs';
      case 'baby_care':
        return 'Baby Care';
      case 'personal_care':
        return 'Personal Care';
      default:
        return category;
    }
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String displayName;
  final String? description;
  final String? icon;
  final String? image;
  final int productCount;
  final bool isActive;

  ProductCategory({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.icon,
    this.image,
    required this.productCount,
    required this.isActive,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      image: json['image'],
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'icon': icon,
      'image': image,
      'product_count': productCount,
      'is_active': isActive,
    };
  }
}

class CartItem {
  final ProductModel product;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;
  String get formattedTotal => '₱${totalPrice.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      addedAt: DateTime.tryParse(json['added_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert to order item format
  Map<String, dynamic> toOrderItem() {
    return {
      'product_name': product.name,
      'product_price': product.price,
      'quantity': quantity,
      'product_image': product.image,
      'product_description': product.description,
      'product_category': product.category,
    };
  }
}

// Product search filters
class ProductFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? brand;
  final bool? requiresPrescription;
  final bool? inStockOnly;
  final String? sortBy; // price_asc, price_desc, name_asc, name_desc, rating_desc
  final List<String>? tags;

  ProductFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.brand,
    this.requiresPrescription,
    this.inStockOnly,
    this.sortBy,
    this.tags,
  });

  Map<String, dynamic> toQueryParams() {
    Map<String, dynamic> params = {};
    
    if (category != null) params['category'] = category;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (brand != null) params['brand'] = brand;
    if (requiresPrescription != null) params['requires_prescription'] = requiresPrescription;
    if (inStockOnly != null) params['in_stock_only'] = inStockOnly;
    if (sortBy != null) params['sort_by'] = sortBy;
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    
    return params;
  }
}

// Predefined categories
class ProductCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'medicines',
      'display_name': 'Medicines',
      'icon': 'assets/img/medicine_icon.png',
      'description': 'Over-the-counter medicines and treatments',
    },
    {
      'name': 'vitamins',
      'display_name': 'Vitamins & Supplements',
      'icon': 'assets/img/vitamin_icon.png',
      'description': 'Vitamins, minerals, and dietary supplements',
    },
    {
      'name': 'first_aid',
      'display_name': 'First Aid',
      'icon': 'assets/img/first_aid_icon.png',
      'description': 'First aid supplies and emergency care',
    },
    {
      'name': 'health_products',
      'display_name': 'Health Products',
      'icon': 'assets/img/health_icon.png',
      'description': 'Health monitoring and wellness products',
    },
    {
      'name': 'prescription_drugs',
      'display_name': 'Prescription Drugs',
      'icon': 'assets/img/prescription_icon.png',
      'description': 'Prescription medications (requires valid prescription)',
    },
    {
      'name': 'baby_care',
      'display_name': 'Baby Care',
      'icon': 'assets/img/baby_icon.png',
      'description': 'Baby health and care products',
    },
    {
      'name': 'personal_care',
      'display_name': 'Personal Care',
      'icon': 'assets/img/personal_care_icon.png',
      'description': 'Personal hygiene and care products',
    },
  ];

  static List<ProductCategory> getCategories() {
    return categories.map((cat) => ProductCategory(
      id: categories.indexOf(cat) + 1,
      name: cat['name'],
      displayName: cat['display_name'],
      description: cat['description'],
      icon: cat['icon'],
      productCount: 0, // Will be updated from API
      isActive: true,
    )).toList();
  }
}
