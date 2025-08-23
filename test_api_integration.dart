// Test script to verify Laravel API integration
// Run this in your Flutter project to test the API endpoints

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTester {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static String? authToken;

  static Future<void> runTests() async {
    print('🚀 Starting API Integration Tests...\n');

    try {
      // Test 1: Health Check
      await testHealthCheck();

      // Test 2: User Registration
      await testUserRegistration();

      // Test 3: User Login
      await testUserLogin();

      // Test 4: Get Orders
      await testGetOrders();

      // Test 5: Create Order
      await testCreateOrder();

      // Test 6: Get Order Details
      await testGetOrderDetails();

      print('\n✅ All tests completed successfully!');
    } catch (e) {
      print('\n❌ Test failed: $e');
    }
  }

  static Future<void> testHealthCheck() async {
    print('📡 Testing Health Check...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Health Check: ${data['status']}');
      } else {
        print('❌ Health Check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Health Check error: $e');
    }
    print('');
  }

  static Future<void> testUserRegistration() async {
    print('👤 Testing User Registration...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': 'Test User',
          'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
          'mobile': '09123456789',
          'address': '123 Test Street, Test City',
          'password': 'password123',
          'password_confirmation': 'password123',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          authToken = data['token'];
          print('✅ Registration successful');
          print('   User: ${data['user']['name']}');
          print('   Email: ${data['user']['email']}');
        } else {
          print('❌ Registration failed: ${data['message']}');
        }
      } else {
        print('❌ Registration failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Registration error: $e');
    }
    print('');
  }

  static Future<void> testUserLogin() async {
    print('🔐 Testing User Login...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': 'test@nine27pharmacy.com', // From seeder
          'password': 'password123',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          authToken = data['token'];
          print('✅ Login successful');
          print('   User: ${data['user']['name']}');
          print('   Token: ${authToken?.substring(0, 20)}...');
        } else {
          print('❌ Login failed: ${data['message']}');
        }
      } else {
        print('❌ Login failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Login error: $e');
    }
    print('');
  }

  static Future<void> testGetOrders() async {
    print('📋 Testing Get Orders...');
    
    if (authToken == null) {
      print('❌ No auth token available');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final orders = data['orders'] as List;
          print('✅ Orders retrieved successfully');
          print('   Total orders: ${data['total']}');
          print('   Current page: ${data['current_page']}');
          
          if (orders.isNotEmpty) {
            final firstOrder = orders.first;
            print('   First order: ${firstOrder['order_number']}');
            print('   Status: ${firstOrder['status']}');
            print('   Total: ${firstOrder['formatted_total']}');
          }
        } else {
          print('❌ Get orders failed: ${data['message']}');
        }
      } else {
        print('❌ Get orders failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Get orders error: $e');
    }
    print('');
  }

  static Future<void> testCreateOrder() async {
    print('🛒 Testing Create Order...');
    
    if (authToken == null) {
      print('❌ No auth token available');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'items': [
            {
              'product_name': 'Test Medicine',
              'product_price': 50.00,
              'quantity': 2,
              'product_description': 'Test medicine for API testing',
              'product_category': 'medicines',
            }
          ],
          'total_amount': 100.00,
          'delivery_address': '123 Test Street, Test City',
          'payment_method': 'Cash on Delivery',
          'order_type': 'regular',
          'notes': 'Test order from API integration test',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final order = data['order'];
          print('✅ Order created successfully');
          print('   Order Number: ${order['order_number']}');
          print('   Status: ${order['status']}');
          print('   Total: ${order['formatted_total']}');
          print('   Items: ${order['items_count']}');
        } else {
          print('❌ Create order failed: ${data['message']}');
        }
      } else {
        print('❌ Create order failed: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Create order error: $e');
    }
    print('');
  }

  static Future<void> testGetOrderDetails() async {
    print('📄 Testing Get Order Details...');
    
    if (authToken == null) {
      print('❌ No auth token available');
      return;
    }

    try {
      // First get orders to get an order ID
      final ordersResponse = await http.get(
        Uri.parse('$baseUrl/orders?limit=1'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (ordersResponse.statusCode == 200) {
        final ordersData = json.decode(ordersResponse.body);
        if (ordersData['success'] == true && ordersData['orders'].isNotEmpty) {
          final orderId = ordersData['orders'][0]['id'];
          
          // Now get order details
          final response = await http.get(
            Uri.parse('$baseUrl/orders/$orderId'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              final order = data['order'];
              print('✅ Order details retrieved successfully');
              print('   Order Number: ${order['order_number']}');
              print('   Status: ${order['status']}');
              print('   Items count: ${order['items']?.length ?? 0}');
              print('   Can cancel: ${order['can_cancel']}');
              print('   Can reorder: ${order['can_reorder']}');
            } else {
              print('❌ Get order details failed: ${data['message']}');
            }
          } else {
            print('❌ Get order details failed: ${response.statusCode}');
          }
        } else {
          print('❌ No orders available for testing details');
        }
      }
    } catch (e) {
      print('❌ Get order details error: $e');
    }
    print('');
  }
}

// Run the tests
void main() async {
  await ApiTester.runTests();
}
