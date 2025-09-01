import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../common/color_extension.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class StaffOrderManagementView extends StatefulWidget {
  const StaffOrderManagementView({super.key});

  @override
  State<StaffOrderManagementView> createState() => _StaffOrderManagementViewState();
}

class _StaffOrderManagementViewState extends State<StaffOrderManagementView> {
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadStatistics();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await OrderService.getStaffOrders(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        page: _currentPage,
        limit: 20,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (result['success']) {
        setState(() {
          _orders = result['orders'] ?? [];
          _filteredOrders = _orders;
          _totalPages = result['totalPages'] ?? 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load orders')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            _filteredOrders = _orders;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesStatus = _selectedStatus == 'all' || order.status == _selectedStatus;
        final matchesSearch = _searchQuery.isEmpty || 
            order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.items.any((item) => 
                item.productName.toLowerCase().contains(_searchQuery.toLowerCase()));
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Order Management'),
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),
          
          // Filters
          _buildFilters(),
          
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              _statistics['pending_orders']?.toString() ?? '0',
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Processing',
              _statistics['processing_orders']?.toString() ?? '0',
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Shipped',
              _statistics['shipped_orders']?.toString() ?? '0',
              Colors.purple,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Delivered',
              _statistics['delivered_orders']?.toString() ?? '0',
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search orders...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterOrders();
            },
          ),
          const SizedBox(height: 12),
          
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Orders'),
                _buildFilterChip('pending', 'Pending'),
                _buildFilterChip('processing', 'Processing'),
                _buildFilterChip('shipped', 'Shipped'),
                _buildFilterChip('delivered', 'Delivered'),
                _buildFilterChip('cancelled', 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
          });
          _filterOrders();
        },
        selectedColor: TColor.primary.withOpacity(0.2),
        checkmarkColor: TColor.primary,
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Order Details
            Text(
              '${order.itemsCount} items • ${order.formattedTotal}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            if (order.deliveryAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                'Delivery: ${order.deliveryAddress}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(order),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Processing';
        break;
      case 'shipped':
        color = Colors.purple;
        label = 'Shipped';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    return Row(
      children: [
        if (order.status.toLowerCase() == 'pending') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(order, 'processing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Processing'),
            ),
          ),
        ] else if (order.status.toLowerCase() == 'processing') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(order, 'shipped'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Shipped'),
            ),
          ),
        ] else if (order.status.toLowerCase() == 'shipped') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(order, 'delivered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Delivered'),
            ),
          ),
        ] else ...[
          Expanded(
            child: Text(
              'Order ${order.status}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        
        const SizedBox(width: 8),
        
        // View Details Button
        OutlinedButton(
          onPressed: () => _showOrderDetails(order),
          child: const Text('View Details'),
        ),
      ],
    );
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildOrderDetailsSheet(order),
    );
  }

  Widget _buildOrderDetailsSheet(OrderModel order) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const Divider(),
            
            // Order Info
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Status', order.status.toUpperCase()),
                    _buildDetailRow('Date', order.formattedDate),
                    _buildDetailRow('Total', order.formattedTotal),
                    _buildDetailRow('Items', order.itemCountText),
                    _buildDetailRow('Payment', order.paymentMethod ?? 'N/A'),
                    _buildDetailRow('Type', order.orderType),
                    _buildDetailRow('Category', order.category),
                    
                    if (order.deliveryAddress != null)
                      _buildDetailRow('Delivery Address', order.deliveryAddress!),
                    
                    if (order.notes != null)
                      _buildDetailRow('Notes', order.notes!),
                    
                    const SizedBox(height: 16),
                    
                    // Order Items
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ...order.items.map((item) => _buildOrderItem(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (item.productImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.productImage!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity} × ₱${item.productPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            '₱${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}




