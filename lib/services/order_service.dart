import 'dart:async';
import '../common/service_call.dart';
import '../common/globs.dart';
import '../models/order_model.dart';

class OrderService {
  // Get all orders for the current user
  static Future<Map<String, dynamic>> getUserOrders({
    String? status,
    String? orderType,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) {
        parameters['status'] = status;
      }
      if (orderType != null && orderType.isNotEmpty) {
        parameters['order_type'] = orderType;
      }
      if (category != null && category.isNotEmpty) {
        parameters['category'] = category;
      }

      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders',
        parameters,
        isToken: true,
        method: 'GET',
      );

      if (response['success'] == true) {
        List<OrderModel> orders = [];
        if (response['orders'] != null) {
          orders = (response['orders'] as List)
              .map((orderJson) => OrderModel.fromJson(orderJson))
              .toList();
        }

        return {
          'success': true,
          'orders': orders,
          'total': response['total'] ?? 0,
          'currentPage': response['current_page'] ?? 1,
          'totalPages': response['total_pages'] ?? 1,
        };
      } else {
        // Fallback to mock data if API fails
        return _getMockOrders(status: status, limit: limit);
      }
    } catch (e) {
      // Fallback to mock data on network error
      return _getMockOrders(status: status, limit: limit);
    }
  }

  // Get order details by ID
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders/$orderId',
        {},
        isToken: true,
        method: 'GET',
      );

      if (response['success'] == true && response['order'] != null) {
        OrderModel order = OrderModel.fromJson(response['order']);
        return {
          'success': true,
          'order': order,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Order not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create new order
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
    String orderType = 'regular',
    Function(String orderNumber)? onOrderCreated,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        'items': items,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'order_type': orderType,
        'notes': notes,
      };

      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders',
        parameters,
        isToken: true,
      );

      if (response['success'] == true && response['order'] != null) {
        OrderModel order = OrderModel.fromJson(response['order']);

        // Trigger notification callback if provided
        if (onOrderCreated != null) {
          onOrderCreated(order.orderNumber);
        }

        return {
          'success': true,
          'order': order,
          'message': response['message'] ?? 'Order created successfully',
        };
      } else {
        // Fallback to mock order creation if API fails
        return _createMockOrder(
          items: items,
          totalAmount: totalAmount,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
          notes: notes,
          orderType: orderType,
          onOrderCreated: onOrderCreated,
        );
      }
    } catch (e) {
      // Fallback to mock order creation on network error
      return _createMockOrder(
        items: items,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        notes: notes,
        orderType: orderType,
        onOrderCreated: onOrderCreated,
      );
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder(int orderId, String reason) async {
    try {
      Map<String, dynamic> parameters = {
        'reason': reason,
      };

      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders/$orderId/cancel',
        parameters,
        isToken: true,
      );

      return {
        'success': response['success'] == true,
        'message': response['message'] ?? 
                  (response['success'] == true ? 'Order cancelled successfully' : 'Failed to cancel order'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Reorder (create new order from existing order)
  static Future<Map<String, dynamic>> reorder(int orderId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders/$orderId/reorder',
        {},
        isToken: true,
      );

      if (response['success'] == true && response['order'] != null) {
        OrderModel order = OrderModel.fromJson(response['order']);
        return {
          'success': true,
          'order': order,
          'message': response['message'] ?? 'Order placed successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to reorder',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Track order status
  static Future<Map<String, dynamic>> trackOrder(String orderNumber) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}orders/track/$orderNumber',
        {},
        isToken: true,
        method: 'GET',
      );

      if (response['success'] == true && response['order'] != null) {
        OrderModel order = OrderModel.fromJson(response['order']);
        return {
          'success': true,
          'order': order,
          'tracking_info': response['tracking_info'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Order not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ========================================
  // STAFF ORDER MANAGEMENT METHODS
  // ========================================

  // Get all orders for staff management
  static Future<Map<String, dynamic>> getStaffOrders({
    String? status,
    String? orderType,
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) {
        parameters['status'] = status;
      }
      if (orderType != null && orderType.isNotEmpty) {
        parameters['order_type'] = orderType;
      }
      if (category != null && category.isNotEmpty) {
        parameters['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        parameters['search'] = search;
      }

      final response = await _makeApiCall(
        '${SVKey.baseUrl}staff/orders',
        parameters,
        isToken: true,
        method: 'GET',
      );

      if (response['success'] == true) {
        List<OrderModel> orders = [];
        if (response['orders'] != null) {
          orders = (response['orders'] as List)
              .map((orderJson) => OrderModel.fromJson(orderJson))
              .toList();
        }

        return {
          'success': true,
          'orders': orders,
          'total': response['total'] ?? 0,
          'currentPage': response['current_page'] ?? 1,
          'totalPages': response['total_pages'] ?? 1,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch orders',
          'orders': <OrderModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'orders': <OrderModel>[],
      };
    }
  }

  // Start processing order (pending → processing)
  static Future<Map<String, dynamic>> startProcessing(int orderId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}staff/orders/$orderId/start-processing',
        {},
        isToken: true,
        method: 'POST',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Order processing started',
          'order': response['order'] != null 
              ? OrderModel.fromJson(response['order']) 
              : null,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to start processing',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Mark order as shipped (processing → shipped)
  static Future<Map<String, dynamic>> markAsShipped(int orderId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}staff/orders/$orderId/mark-shipped',
        {},
        isToken: true,
        method: 'POST',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Order marked as shipped',
          'order': response['order'] != null 
              ? OrderModel.fromJson(response['order']) 
              : null,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to mark as shipped',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Mark order as delivered (shipped → delivered)
  static Future<Map<String, dynamic>> markAsDelivered(int orderId) async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}staff/orders/$orderId/mark-delivered',
        {},
        isToken: true,
        method: 'POST',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Order marked as delivered',
          'order': response['order'] != null 
              ? OrderModel.fromJson(response['order']) 
              : null,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to mark as delivered',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get order statistics for staff dashboard
  static Future<Map<String, dynamic>> getStaffStatistics() async {
    try {
      final response = await _makeApiCall(
        '${SVKey.baseUrl}staff/orders/statistics',
        {},
        isToken: true,
        method: 'GET',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'statistics': response['statistics'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch statistics',
          'statistics': {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'statistics': {},
      };
    }
  }

  // Helper method to make API calls
  static Future<Map<String, dynamic>> _makeApiCall(
    String url,
    Map<String, dynamic> parameters, {
    bool isToken = false,
    String method = 'POST',
  }) async {
    final completer = Completer<Map<String, dynamic>>();

    if (method == 'GET') {
      ServiceCall.get(url, parameters, isToken: isToken,
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
    } else {
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
    }

    return completer.future;
  }

  // Create mock order for offline/demo mode
  static Map<String, dynamic> _createMockOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
    String orderType = 'regular',
    Function(String orderNumber)? onOrderCreated,
  }) {
    // Generate a unique order number
    final orderNumber = 'ORD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    // Create order items
    List<OrderItem> orderItems = items.map((item) => OrderItem(
      id: DateTime.now().millisecondsSinceEpoch,
      orderId: DateTime.now().millisecondsSinceEpoch,
      productName: item['product_name'] ?? 'Product',
      productPrice: double.tryParse(item['product_price'].toString()) ?? 0.0,
      quantity: item['quantity'] ?? 1,
      productImage: item['product_image'],
      productDescription: item['product_description'],
      productCategory: item['product_category'],
    )).toList();

    // Create the order
    OrderModel order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch,
      orderNumber: orderNumber,
      status: 'pending',
      orderType: orderType,
      category: _determineCategory(items),
      totalAmount: totalAmount,
      itemsCount: items.length,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: orderItems,
    );

    // Trigger notification callback if provided
    if (onOrderCreated != null) {
      onOrderCreated(orderNumber);
    }

    return {
      'success': true,
      'order': order,
      'message': 'Order created successfully (Demo Mode)',
    };
  }

  // Helper method to determine order category
  static String _determineCategory(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 'medicines';
    
    // Check if any item is prescription
    bool hasPrescription = items.any((item) => 
      (item['product_category'] ?? '').toString().toLowerCase().contains('prescription'));
    
    if (hasPrescription) return 'prescription_drugs';
    
    // Check for vitamins
    bool hasVitamins = items.any((item) => 
      (item['product_category'] ?? '').toString().toLowerCase().contains('vitamin'));
    
    if (hasVitamins) return 'vitamins';
    
    // Check for first aid
    bool hasFirstAid = items.any((item) => 
      (item['product_category'] ?? '').toString().toLowerCase().contains('first_aid'));
    
    if (hasFirstAid) return 'first_aid';
    
    return 'medicines';
  }

  // Mock data for offline/demo mode
  static Map<String, dynamic> _getMockOrders({
    String? status,
    int limit = 20,
  }) {
    List<OrderModel> mockOrders = [
      OrderModel(
        id: 1,
        orderNumber: 'ORD-2024-001',
        status: 'delivered',
        orderType: 'regular',
        category: 'medicines',
        totalAmount: 150.00,
        itemsCount: 3,
        deliveryAddress: '123 Main St, City',
        paymentMethod: 'cash_on_delivery',
        notes: 'Please deliver in the afternoon',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          OrderItem(
            id: 1,
            orderId: 1,
            productName: 'Biogesic 500mg',
            productPrice: 50.00,
            quantity: 2,
            productImage: 'assets/img/med.png',
            productDescription: 'Paracetamol for fever and pain relief',
            productCategory: 'medicines',
          ),
          OrderItem(
            id: 2,
            orderId: 1,
            productName: 'Advil 200mg',
            productPrice: 50.00,
            quantity: 1,
            productImage: 'assets/img/med.png',
            productDescription: 'Ibuprofen for pain relief',
            productCategory: 'medicines',
          ),
        ],
      ),
      OrderModel(
        id: 2,
        orderNumber: 'ORD-2024-002',
        status: 'processing',
        orderType: 'prescription',
        category: 'prescription_drugs',
        totalAmount: 280.00,
        itemsCount: 2,
        deliveryAddress: '456 Oak Ave, Town',
        paymentMethod: 'credit_card',
        notes: 'Prescription attached',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        items: [
          OrderItem(
            id: 3,
            orderId: 2,
            productName: 'Amoxicillin 500mg',
            productPrice: 140.00,
            quantity: 2,
            productImage: 'assets/img/med.png',
            productDescription: 'Antibiotic capsule',
            productCategory: 'prescription_drugs',
          ),
        ],
      ),
      OrderModel(
        id: 3,
        orderNumber: 'ORD-2024-003',
        status: 'pending',
        orderType: 'regular',
        category: 'vitamins',
        totalAmount: 95.00,
        itemsCount: 1,
        deliveryAddress: '789 Pine Rd, Village',
        paymentMethod: 'cash_on_delivery',
        notes: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        items: [
          OrderItem(
            id: 4,
            orderId: 3,
            productName: 'Vitamin C 500mg',
            productPrice: 95.00,
            quantity: 1,
            productImage: 'assets/img/vitamins.png',
            productDescription: 'Vitamin C supplement',
            productCategory: 'vitamins',
          ),
        ],
      ),
      OrderModel(
        id: 4,
        orderNumber: 'ORD-2024-004',
        status: 'cancelled',
        orderType: 'regular',
        category: 'first_aid',
        totalAmount: 75.00,
        itemsCount: 2,
        deliveryAddress: '321 Elm St, Borough',
        paymentMethod: 'credit_card',
        notes: 'Cancelled due to stock unavailability',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        items: [
          OrderItem(
            id: 5,
            orderId: 4,
            productName: 'Betadine Solution',
            productPrice: 75.00,
            quantity: 1,
            productImage: 'assets/img/first aid.png',
            productDescription: 'Antiseptic solution',
            productCategory: 'first_aid',
          ),
        ],
      ),
      OrderModel(
        id: 5,
        orderNumber: 'ORD-2024-005',
        status: 'delivered',
        orderType: 'regular',
        category: 'medicines',
        totalAmount: 120.00,
        itemsCount: 4,
        deliveryAddress: '654 Maple Dr, District',
        paymentMethod: 'cash_on_delivery',
        notes: 'Fast delivery requested',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        items: [
          OrderItem(
            id: 6,
            orderId: 5,
            productName: 'Tylenol 500mg',
            productPrice: 30.00,
            quantity: 4,
            productImage: 'assets/img/med.png',
            productDescription: 'Acetaminophen tablets',
            productCategory: 'medicines',
          ),
        ],
      ),
    ];

    // Filter by status if specified
    if (status != null && status != 'all') {
      mockOrders = mockOrders.where((order) => order.status == status).toList();
    }

    // Limit the number of orders
    if (limit < mockOrders.length) {
      mockOrders = mockOrders.take(limit).toList();
    }

    return {
      'success': true,
      'orders': mockOrders,
      'total': mockOrders.length,
      'currentPage': 1,
      'totalPages': 1,
    };
  }
}
