import 'package:flutter/material.dart';
import '../view/cart/shopping_cart_view.dart';
import '../services/cart_service.dart';

class CartIcon extends StatefulWidget {
  final double size; // optional size of the icon

  const CartIcon({super.key, this.size = 28});

  @override
  State<CartIcon> createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCartCount();
    CartService.setCartChangeCallback(() {
      if (mounted) {
        _updateCartCount();
      }
    });
  }

  void _updateCartCount() {
    setState(() {
      cartItemCount = CartService.getItemCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShoppingCartView(),
              ),
            );
          },
          icon: Image.asset(
            "assets/img/shopping_cart.png",
            width: widget.size,
            height: widget.size,
          ),
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                cartItemCount > 99 ? "99+" : "$cartItemCount",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
