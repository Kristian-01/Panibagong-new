import 'package:flutter/material.dart';
import '../../common/globs.dart';
import '../../common/color_extension.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<int>(
          valueListenable: cartCount,
          builder: (context, value, _) {
            return Text("My Cart ($value items)");
          },
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cart cleared!"),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 100, left: 16, right: 16),
                  ),
                );
              },
              icon: const Icon(Icons.clear_all),
              tooltip: "Clear Cart",
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add some items to get started!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var item = cartItems[index];
                int quantity = item["quantity"] ?? 1;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item["image"] ?? "assets/img/placeholder.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"] ?? "Unknown Item",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["price"] ?? "₱0.00",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrease button
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: quantity > 1 ? () {
                                  setState(() {
                                    decreaseQuantity(index);
                                  });
                                } : () {
                                  // Show confirmation dialog for removing item
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Remove Item"),
                                      content: Text("Remove ${item["name"]} from cart?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              removeItemCompletely(index);
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("${item["name"]} removed from cart"),
                                                behavior: SnackBarBehavior.floating,
                                                margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                                              ),
                                            );
                                          },
                                          child: const Text("Remove"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(
                                  quantity > 1 ? Icons.remove : Icons.delete_outline,
                                  size: 20,
                                  color: quantity > 1 ? TColor.primary : Colors.red,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),

                            // Quantity display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Increase button
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    increaseQuantity(index);
                                  });
                                },
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: TColor.primary,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
