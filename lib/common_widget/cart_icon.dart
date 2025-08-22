import 'package:flutter/material.dart';
import '../common/globs.dart';
import '../view/more/my_order_view.dart';

class CartIcon extends StatelessWidget {
  final double size; // optional size of the icon

  const CartIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: cartCount,
      builder: (context, value, _) {
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyOrderView(),
                  ),
                );
              },
              icon: Image.asset(
                "assets/img/shopping_cart.png",
                width: size,
                height: size,
              ),
            ),
            if (value > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$value",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
