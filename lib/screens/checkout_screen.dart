import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final double total;
  const CheckoutScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delivery Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Enter your address"),
            ),
            const SizedBox(height: 20),
            const Text("Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const ListTile(
              leading: Icon(Icons.delivery_dining),
              title: Text("Cash on Delivery"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₱$total",
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order placed successfully!")),
                  );
                },
                child: const Text("Place Order"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
