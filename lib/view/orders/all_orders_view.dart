import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../common_widget/order_row.dart';
import 'order_details_view.dart';

class AllOrdersView extends StatefulWidget {
  const AllOrdersView({super.key});

  @override
  State<AllOrdersView> createState() => _AllOrdersViewState();
}

class _AllOrdersViewState extends State<AllOrdersView> {
  List<OrderModel> orders = [];
  List<OrderModel> filteredOrders = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Filter options
  String selectedStatus = 'all';
  String selectedType = 'all';
  String selectedCategory = 'all';
  
  // Search
  final TextEditingController searchController = TextEditingController();
  
  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        errorMessage = null;
        currentPage = 1;
      });
    }

    try {
      String? statusFilter = selectedStatus == 'all' ? null : selectedStatus;
      String? typeFilter = selectedType == 'all' ? null : selectedType;
      String? categoryFilter = selectedCategory == 'all' ? null : selectedCategory;

      final result = await OrderService.getUserOrders(
        status: statusFilter,
        orderType: typeFilter,
        category: categoryFilter,
        page: loadMore ? currentPage + 1 : 1,
        limit: 20,
      );

      if (result['success'] == true) {
        List<OrderModel> newOrders = result['orders'] as List<OrderModel>;
        
        setState(() {
          if (loadMore) {
            orders.addAll(newOrders);
            currentPage++;
            isLoadingMore = false;
          } else {
            orders = newOrders;
            isLoading = false;
          }
          totalPages = result['totalPages'] ?? 1;
          _applyFilters();
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load orders';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _applyFilters() {
    String searchTerm = searchController.text.toLowerCase();
    
    filteredOrders = orders.where((order) {
      bool matchesSearch = searchTerm.isEmpty ||
          order.orderNumber.toLowerCase().contains(searchTerm) ||
          order.items.any((item) => 
              item.productName.toLowerCase().contains(searchTerm));
      
      return matchesSearch;
    }).toList();
    
    // Sort by date (newest first)
    filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _onSearchChanged() {
    _applyFilters();
    setState(() {});
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  void _onFilterChanged() {
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 46, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: TColor.primaryText),
                ),
                Expanded(
                  child: Text(
                    "All Orders",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoundTextfield(
              hintText: "Search orders or medicines...",
              controller: searchController,
              left: Container(
                alignment: Alignment.center,
                width: 30,
                child: Image.asset(
                  "assets/img/search.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Filter Options
          Container(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterDropdown(
                    'Status',
                    selectedStatus,
                    ['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'],
                    (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    'Type',
                    selectedType,
                    ['all', 'regular', 'prescription'],
                    (value) {
                      setState(() {
                        selectedType = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    'Category',
                    selectedCategory,
                    ['all', 'medicines', 'vitamins', 'first aid', 'health products'],
                    (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                      _onFilterChanged();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshOrders,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      : filteredOrders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No orders found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Try adjusting your search or filters",
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
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: filteredOrders.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredOrders.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final order = filteredOrders[index];
                                
                                // Load more when reaching near end
                                if (index == filteredOrders.length - 3 && 
                                    currentPage < totalPages && 
                                    !isLoadingMore) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _loadOrders(loadMore: true);
                                  });
                                }

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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option == 'all' ? 'All ${label}s' : option.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
