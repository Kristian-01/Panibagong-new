import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common_widget/cart_icon.dart';
import '../../common_widget/round_button.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../common/service_call.dart';
import '../../common_widget/order_row.dart';
import 'order_details_view.dart';
import 'all_orders_view.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'all'; // all, pending, processing, delivered, cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? statusFilter = selectedFilter == 'all' ? null : selectedFilter;
      final result = await OrderService.getUserOrders(
        status: statusFilter,
        limit: 5, // Show only recent 5 orders on main view
      );

      if (result['success'] == true) {
        setState(() {
          orders = result['orders'] as List<OrderModel>;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  void _onFilterChanged(String filter) {
    if (selectedFilter != filter) {
      setState(() {
        selectedFilter = filter;
      });
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 46),
                
                // Header with Cart Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Orders",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const CartIcon(),
                    ],
                  ),
                ),

                // Greeting and Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello ${ServiceCall.userPayload['name'] ?? 'there'}! 👋",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Track your orders, view history,\nand reorder your medicines easily!",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // View All Orders Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: 140,
                    height: 30,
                    child: RoundButton(
                      title: "View All Orders",
                      fontSize: 12,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllOrdersView(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('pending', 'Pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('processing', 'Processing'),
                        const SizedBox(width: 8),
                        _buildFilterChip('delivered', 'Delivered'),
                        const SizedBox(width: 8),
                        _buildFilterChip('cancelled', 'Cancelled'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Orders List
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOrders,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (orders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedFilter == 'all' 
                                ? "No orders yet"
                                : "No ${selectedFilter} orders",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedFilter == 'all'
                                ? "Start shopping to see your orders here!"
                                : "Try changing the filter to see other orders.",
                            textAlign: TextAlign.center,
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
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderRow(
                        orderObj: {
                          "order_number": order.orderNumber,
                          "status": order.status,
                          "item_count": order.itemCountText,
                          "order_type": order.orderType,
                          "category": order.category,
                          "date": order.formattedDate,
                          "total": order.formattedTotal,
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsView(order: order),
                            ),
                          );
                        },
                      );
                    },
                  ),

                // Show more button if there are more orders
                if (!isLoading && orders.length >= 5)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllOrdersView(),
                            ),
                          );
                        },
                        child: Text(
                          "View All Orders",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TColor.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TColor.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
