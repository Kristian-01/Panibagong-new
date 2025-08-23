import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';
  static List<CartItem> _cartItems = [];
  static Function()? _onCartChanged;

  // Initialize cart service
  static Future<void> initialize() async {
    await _loadCartFromStorage();
  }

  // Set cart change callback
  static void setCartChangeCallback(Function() callback) {
    _onCartChanged = callback;
  }

  // Get all cart items
  static List<CartItem> getCartItems() {
    return List.from(_cartItems);
  }

  // Get cart item count
  static int getItemCount() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get cart total
  static double getCartTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get formatted cart total
  static String getFormattedTotal() {
    return '₱${getCartTotal().toStringAsFixed(2)}';
  }

  // Check if product is in cart
  static bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  static int getProductQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: 0,
          name: '',
          description: '',
          price: 0,
          category: '',
          stockQuantity: 0,
          isAvailable: false,
          requiresPrescription: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 0,
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  // Add product to cart
  static Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      // Check if product is available
      if (!product.isAvailable || product.outOfStock) {
        return false;
      }

      // Check if item already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final newQuantity = _cartItems[existingItemIndex].quantity + quantity;
        
        // Check stock availability
        if (newQuantity > product.stockQuantity) {
          return false;
        }

        _cartItems[existingItemIndex].quantity = newQuantity;
      } else {
        // Add new item to cart
        if (quantity > product.stockQuantity) {
          return false;
        }

        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        ));
      }

      await _saveCartToStorage();
      _notifyCartChanged();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove product from cart
  static Future<bool> removeFromCart(int productId) async {
    try {
      _cartItems.removeWhere((item) => item.product.id == productId);
      await _saveCartToStorage();
      _notifyCartChanged();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update product quantity in cart
  static Future<bool> updateQuantity(int productId, int quantity) async {
    try {
      if (quantity <= 0) {
        return removeFromCart(productId);
      }

      final itemIndex = _cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (itemIndex != -1) {
        final product = _cartItems[itemIndex].product;
        
        // Check stock availability
        if (quantity > product.stockQuantity) {
          return false;
        }

        _cartItems[itemIndex].quantity = quantity;
        await _saveCartToStorage();
        _notifyCartChanged();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Increase product quantity
  static Future<bool> increaseQuantity(int productId) async {
    final currentQuantity = getProductQuantity(productId);
    return updateQuantity(productId, currentQuantity + 1);
  }

  // Decrease product quantity
  static Future<bool> decreaseQuantity(int productId) async {
    final currentQuantity = getProductQuantity(productId);
    if (currentQuantity <= 1) {
      return removeFromCart(productId);
    }
    return updateQuantity(productId, currentQuantity - 1);
  }

  // Clear entire cart
  static Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartToStorage();
    _notifyCartChanged();
  }

  // Get cart items for checkout
  static List<Map<String, dynamic>> getCartItemsForOrder() {
    return _cartItems.map((item) => item.toOrderItem()).toList();
  }

  // Check if cart has prescription items
  static bool hasPrescriptionItems() {
    return _cartItems.any((item) => item.product.requiresPrescription);
  }

  // Get prescription items
  static List<CartItem> getPrescriptionItems() {
    return _cartItems.where((item) => item.product.requiresPrescription).toList();
  }

  // Get non-prescription items
  static List<CartItem> getNonPrescriptionItems() {
    return _cartItems.where((item) => !item.product.requiresPrescription).toList();
  }

  // Validate cart before checkout
  static Map<String, dynamic> validateCart() {
    List<String> errors = [];
    List<String> warnings = [];

    for (final item in _cartItems) {
      // Check availability
      if (!item.product.isAvailable) {
        errors.add('${item.product.name} is no longer available');
      }

      // Check stock
      if (item.quantity > item.product.stockQuantity) {
        errors.add('${item.product.name} - Only ${item.product.stockQuantity} items available');
      }

      // Check expiry
      if (item.product.isExpired) {
        errors.add('${item.product.name} has expired');
      } else if (item.product.isExpiringSoon) {
        warnings.add('${item.product.name} is expiring soon');
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }

  // Save cart to local storage
  static Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cartItems.map((item) => item.toJson()).toList();
      await prefs.setString(_cartKey, json.encode(cartJson));
    } catch (e) {
      // Handle storage error silently
    }
  }

  // Load cart from local storage
  static Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      
      if (cartString != null) {
        final cartJson = json.decode(cartString) as List;
        _cartItems = cartJson.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      // Handle loading error silently, start with empty cart
      _cartItems = [];
    }
  }

  // Notify cart change listeners
  static void _notifyCartChanged() {
    if (_onCartChanged != null) {
      _onCartChanged!();
    }
  }

  // Get cart summary
  static Map<String, dynamic> getCartSummary() {
    final total = getCartTotal();
    final itemCount = getItemCount();
    final uniqueItems = _cartItems.length;
    final hasPrescription = hasPrescriptionItems();

    return {
      'total': total,
      'formatted_total': getFormattedTotal(),
      'item_count': itemCount,
      'unique_items': uniqueItems,
      'has_prescription': hasPrescription,
      'is_empty': _cartItems.isEmpty,
    };
  }

  // Apply discount (for future use)
  static double applyDiscount(String discountCode) {
    // Placeholder for discount logic
    switch (discountCode.toUpperCase()) {
      case 'SAVE10':
        return getCartTotal() * 0.10;
      case 'SAVE15':
        return getCartTotal() * 0.15;
      case 'SAVE20':
        return getCartTotal() * 0.20;
      case 'WELCOME':
        return getCartTotal() * 0.05;
      default:
        return 0.0;
    }
  }

  // Get recommended products based on cart items
  static List<String> getRecommendedCategories() {
    final categories = _cartItems.map((item) => item.product.category).toSet().toList();
    
    // Add related categories
    List<String> recommended = [];
    for (final category in categories) {
      switch (category) {
        case 'medicines':
          recommended.addAll(['vitamins', 'first_aid']);
          break;
        case 'vitamins':
          recommended.addAll(['medicines', 'health_products']);
          break;
        case 'first_aid':
          recommended.addAll(['medicines', 'personal_care']);
          break;
        case 'prescription_drugs':
          recommended.addAll(['medicines', 'vitamins']);
          break;
      }
    }

    return recommended.toSet().toList();
  }
}
