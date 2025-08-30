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
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
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
}
