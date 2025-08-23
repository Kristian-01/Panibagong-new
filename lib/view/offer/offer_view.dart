import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/order_row.dart';
import '../../common_widget/cart_icon.dart';


class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  TextEditingController txtSearch = TextEditingController();

  List ordersArr = [
    {
      "order_number": "Order #12345",
      "status": "Delivered",
      "item_count": "3 items",
      "order_type": "Prescription",
      "category": "Medicines & Vitamins",
      "date": "Dec 20, 2024",
      "total": "₱1,250.00"
    },
    {
      "order_number": "Order #12344",
      "status": "Processing",
      "item_count": "5 items",
      "order_type": "Regular",
      "category": "Health Products",
      "date": "Dec 22, 2024",
      "total": "₱890.50"
    },
    {
      "order_number": "Order #12343",
      "status": "Delivered",
      "item_count": "2 items",
      "order_type": "Prescription",
      "category": "Prescription Drugs",
      "date": "Dec 18, 2024",
      "total": "₱2,100.00"
    },
    {
      "order_number": "Order #12342",
      "status": "Delivered",
      "item_count": "7 items",
      "order_type": "Regular",
      "category": "Vitamins & Supplements",
      "date": "Dec 15, 2024",
      "total": "₱3,450.75"
    },
    {
      "order_number": "Order #12341",
      "status": "Cancelled",
      "item_count": "1 item",
      "order_type": "Regular",
      "category": "Health Device",
      "date": "Dec 10, 2024",
      "total": "₱750.00"
    },
    {
      "order_number": "Order #12340",
      "status": "Delivered",
      "item_count": "4 items",
      "order_type": "Prescription",
      "category": "Prescription Drugs",
      "date": "Dec 8, 2024",
      "total": "₱1,680.25"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
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
    const CartIcon(), // ✅ reusable cart with badge
  ],
),

              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Track your orders, view history,\nand reorder your medicines easily!",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 140,
                  height: 30,
                  child: RoundButton(title: "View All Orders", fontSize: 12 , onPressed: () {}),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All", true),
                      const SizedBox(width: 8),
                      _buildFilterChip("Delivered", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("Processing", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("Prescription", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("Regular", false),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: ordersArr.length,
                itemBuilder: ((context, index) {
                  var orderObj = ordersArr[index] as Map? ?? {};
                  return OrderRow(
                    orderObj: orderObj,
                    onTap: () {
                      // Navigate to order details
                      print("Tapped on ${orderObj["order_number"]}");
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? TColor.primary : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? TColor.primary : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : TColor.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
