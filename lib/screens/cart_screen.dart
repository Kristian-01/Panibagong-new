import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<CartProvider>().items; // using items from provider
    final total = context.watch<CartProvider>().totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Your cart is empty"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final Product item = cartItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text("Price: ₹${item.price} x ${item.qty}"),
                        trailing: Text("₹${item.price * item.qty}"),
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(total: total),
                      ),
                    );
                  },
                  child: const Text("Proceed to Checkout"),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}
