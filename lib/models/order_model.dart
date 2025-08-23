class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final String orderType;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final String? deliveryAddress;
  final String? paymentMethod;
  final String? notes;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    required this.orderType,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.deliveryAddress,
    this.paymentMethod,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      itemsCount: json['items_count'] ?? 0,
      orderType: json['order_type'] ?? 'regular',
      category: json['category'] ?? 'medicines',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      deliveryAddress: json['delivery_address'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'total_amount': totalAmount,
      'items_count': itemsCount,
      'order_type': orderType,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }

  // Helper methods
  String get formattedTotal => '₱${totalAmount.toStringAsFixed(2)}';
  
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  String get itemCountText => itemsCount == 1 ? '1 item' : '$itemsCount items';

  bool get canReorder => status.toLowerCase() == 'delivered';
  bool get canCancel => ['pending', 'processing'].contains(status.toLowerCase());
  bool get isDelivered => status.toLowerCase() == 'delivered';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProcessing => status.toLowerCase() == 'processing';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class OrderItem {
  final int id;
  final int orderId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String? productImage;
  final String? productDescription;
  final String? productCategory;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    this.productImage,
    this.productDescription,
    this.productCategory,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productPrice: double.tryParse(json['product_price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
      productImage: json['product_image'],
      productDescription: json['product_description'],
      productCategory: json['product_category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'product_image': productImage,
      'product_description': productDescription,
      'product_category': productCategory,
    };
  }

  double get totalPrice => productPrice * quantity;
  String get formattedPrice => '₱${productPrice.toStringAsFixed(2)}';
  String get formattedTotal => '₱${totalPrice.toStringAsFixed(2)}';
}

// Order Status Enum
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

// Order Type Enum
enum OrderType {
  regular,
  prescription;

  String get displayName {
    switch (this) {
      case OrderType.regular:
        return 'Regular';
      case OrderType.prescription:
        return 'Prescription';
    }
  }

  static OrderType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return OrderType.prescription;
      default:
        return OrderType.regular;
    }
  }
}

// Order Category Enum
enum OrderCategory {
  medicines,
  vitamins,
  firstAid,
  healthProducts,
  prescriptionDrugs,
  supplements;

  String get displayName {
    switch (this) {
      case OrderCategory.medicines:
        return 'Medicines';
      case OrderCategory.vitamins:
        return 'Vitamins & Supplements';
      case OrderCategory.firstAid:
        return 'First Aid';
      case OrderCategory.healthProducts:
        return 'Health Products';
      case OrderCategory.prescriptionDrugs:
        return 'Prescription Drugs';
      case OrderCategory.supplements:
        return 'Supplements';
    }
  }

  static OrderCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'vitamins':
      case 'vitamins & supplements':
        return OrderCategory.vitamins;
      case 'first aid':
        return OrderCategory.firstAid;
      case 'health products':
        return OrderCategory.healthProducts;
      case 'prescription drugs':
        return OrderCategory.prescriptionDrugs;
      case 'supplements':
        return OrderCategory.supplements;
      default:
        return OrderCategory.medicines;
    }
  }
}
