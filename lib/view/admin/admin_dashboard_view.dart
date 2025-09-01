import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedTabIndex = 0;
  List<OrderModel> _orders = [];
  List<ProductModel> _products = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load orders
      final ordersResult = await OrderService.getStaffOrders(limit: 100);
      if (ordersResult['success']) {
        setState(() {
          _orders = ordersResult['orders'] as List<OrderModel>;
        });
      }

      // Load products
      final productsResult = await ProductService.getProducts(limit: 100);
      if (productsResult['success']) {
        setState(() {
          _products = productsResult['products'] as List<ProductModel>;
        });
      }

      // Load statistics
      await _loadStatistics();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load dashboard data: ${e.toString()}');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final result = await OrderService.getStaffStatistics();
      if (result['success']) {
        setState(() {
          _statistics = result['statistics'] ?? {};
        });
      }
    } catch (e) {
      // Handle error silently for statistics
    }
  }

  void _filterOrders() {
    List<OrderModel> filtered = _orders;

    if (_selectedFilter != 'all') {
      filtered = filtered.where((order) => 
        order.status.toLowerCase() == _selectedFilter.toLowerCase()
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) =>
        order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (order.deliveryAddress != null && order.deliveryAddress!.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    setState(() {
      _orders = filtered;
    });
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    EasyLoading.show(status: 'Updating order status...');

    try {
      Map<String, dynamic> result;
      
      switch (newStatus) {
        case 'processing':
          result = await OrderService.startProcessing(order.id);
          break;
        case 'shipped':
          result = await OrderService.markAsShipped(order.id);
          break;
        case 'delivered':
          result = await OrderService.markAsDelivered(order.id);
          break;
        default:
          return;
      }

      EasyLoading.dismiss();

      if (result['success']) {
        // Update the order in the list
        setState(() {
          final index = _orders.indexWhere((o) => o.id == order.id);
          if (index != -1 && result['order'] != null) {
            _orders[index] = result['order'];
          }
        });

        // Reload statistics
        _loadStatistics();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Order status updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update order status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      _showError('Network error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: TColor.primary,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.local_pharmacy, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        "Nine27 Pharmacy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: Column(
                    children: [
                      _buildNavItem(0, Icons.dashboard, "Dashboard"),
                      _buildNavItem(1, Icons.shopping_cart, "Orders"),
                      _buildNavItem(2, Icons.inventory, "Products"),
                      _buildNavItem(3, Icons.local_shipping, "Delivery"),
                      _buildNavItem(4, Icons.analytics, "Analytics"),
                      _buildNavItem(5, Icons.settings, "Settings"),
                    ],
                  ),
                ),
                
                // User Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin User",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "Administrator",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      Text(
                        _getTabTitle(),
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadDashboardData,
                        icon: Icon(Icons.refresh, color: TColor.primary),
                      ),
                    ],
                  ),
                ),
                
                // Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTabContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? TColor.primary : Colors.white.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? TColor.primary : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }

  String _getTabTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return "Dashboard Overview";
      case 1:
        return "Order Management";
      case 2:
        return "Product Management";
      case 3:
        return "Delivery Management";
      case 4:
        return "Analytics & Reports";
      case 5:
        return "Settings";
      default:
        return "Dashboard";
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardOverview();
      case 1:
        return _buildOrderManagement();
      case 2:
        return _buildProductManagement();
      case 3:
        return _buildDeliveryManagement();
      case 4:
        return _buildAnalytics();
      case 5:
        return _buildSettings();
      default:
        return _buildDashboardOverview();
    }
  }

  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Orders", _statistics['total']?.toString() ?? '0', Icons.shopping_cart, Colors.blue)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard("Pending Orders", _statistics['pending']?.toString() ?? '0', Icons.pending, Colors.orange)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard("Processing", _statistics['processing']?.toString() ?? '0', Icons.access_time, Colors.blue)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard("Delivered Today", _statistics['delivered_today']?.toString() ?? '0', Icons.check_circle, Colors.green)),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Recent Orders
          Text(
            "Recent Orders",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          
          Container(
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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order #')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _orders.take(10).map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order.orderNumber)),
                    DataCell(Text('Customer Name')), // You can add customer name to order model
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(order.formattedTotal)),
                    DataCell(Text(order.formattedDate)),
                    DataCell(
                      Row(
                        children: [
                          if (order.status.toLowerCase() == 'pending')
                            TextButton(
                              onPressed: () => _updateOrderStatus(order, 'processing'),
                              child: const Text('Process'),
                            ),
                          if (order.status.toLowerCase() == 'processing')
                            TextButton(
                              onPressed: () => _updateOrderStatus(order, 'shipped'),
                              child: const Text('Ship'),
                            ),
                          if (order.status.toLowerCase() == 'shipped')
                            TextButton(
                              onPressed: () => _updateOrderStatus(order, 'delivered'),
                              child: const Text('Deliver'),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterOrders();
                  },
                  decoration: InputDecoration(
                    hintText: "Search orders...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              DropdownButton<String>(
                value: _selectedFilter,
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All Orders')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'processing', child: Text('Processing')),
                  DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                  DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  _filterOrders();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Orders Table
          Container(
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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order #')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Items')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order.orderNumber)),
                    DataCell(Text('Customer Name')),
                    DataCell(Text(order.itemCountText)),
                    DataCell(Text(order.formattedTotal)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(order.formattedDate)),
                    DataCell(
                      Row(
                        children: [
                          if (order.status.toLowerCase() == 'pending')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order, 'processing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Process'),
                            ),
                          if (order.status.toLowerCase() == 'processing')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order, 'shipped'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Ship'),
                            ),
                          if (order.status.toLowerCase() == 'shipped')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order, 'delivered'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Deliver'),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Management",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text(product.name)),
                    DataCell(Text(product.categoryDisplayName)),
                    DataCell(Text(product.formattedPrice)),
                    DataCell(Text(product.stockQuantity.toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.inStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.inStock ? 'IN STOCK' : 'OUT OF STOCK',
                          style: TextStyle(
                            color: product.inStock ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Edit product
                            },
                            icon: const Icon(Icons.edit, size: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              // Delete product
                            },
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryManagement() {
    final shippedOrders = _orders.where((order) => order.status.toLowerCase() == 'shipped').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Management",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order #')),
                DataColumn(label: Text('Delivery Address')),
                DataColumn(label: Text('Items')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Actions')),
              ],
              rows: shippedOrders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order.orderNumber)),
                    DataCell(Text(order.deliveryAddress ?? 'N/A')),
                    DataCell(Text(order.itemCountText)),
                    DataCell(Text(order.formattedTotal)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _updateOrderStatus(order, 'delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mark Delivered'),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analytics & Reports",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          // Analytics content would go here
          Container(
            padding: const EdgeInsets.all(20),
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
            child: const Text("Analytics dashboard coming soon..."),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          // Settings content would go here
          Container(
            padding: const EdgeInsets.all(20),
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
            child: const Text("Settings panel coming soon..."),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
