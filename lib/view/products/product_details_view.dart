import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/notification_service.dart';

class ProductDetailsView extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsView({super.key, required this.product});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int quantity = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    CartService.setCartChangeCallback(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _addToCart() async {
    if (!widget.product.inStock) return;

    setState(() {
      isLoading = true;
    });

    final success = await CartService.addToCart(widget.product, quantity: quantity);
    
    setState(() {
      isLoading = false;
    });

    if (success && mounted) {
      NotificationService.showInAppNotification(
        context,
        title: 'Added to Cart',
        message: '${widget.product.name} (${quantity}x) added to cart',
        type: 'success',
      );
    } else if (mounted) {
      NotificationService.showInAppNotification(
        context,
        title: 'Cannot Add to Cart',
        message: 'Product is out of stock or quantity exceeds available stock',
        type: 'error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInCart = CartService.isInCart(widget.product.id);
    final cartQuantity = CartService.getProductQuantity(widget.product.id);

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      widget.product.image != null
                          ? Image.asset(
                              widget.product.image!,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.medical_services,
                                      color: TColor.primary,
                                      size: 80,
                                    ),
                                  ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.medical_services,
                                color: TColor.primary,
                                size: 80,
                              ),
                            ),
                      
                      // Back Button
                      Positioned(
                        top: 46,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: TColor.primaryText,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Stock Status Badge
                      Positioned(
                        top: 46,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.product.inStock ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.product.stockStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            widget.product.formattedPrice,
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Brand and Category
                      Row(
                        children: [
                          if (widget.product.brand != null) ...[
                            Text(
                              'Brand: ${widget.product.brand}',
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                          Text(
                            widget.product.categoryDisplayName,
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Rating and Reviews
                      if (widget.product.rating != null) ...[
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < widget.product.rating!.floor()
                                    ? Icons.star
                                    : index < widget.product.rating!
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.formattedRating,
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.product.reviewCount != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(${widget.product.reviewCount} reviews)',
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Prescription Warning
                      if (widget.product.requiresPrescription) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This product requires a valid prescription',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Product Details
                      if (widget.product.dosage != null ||
                          widget.product.activeIngredient != null ||
                          widget.product.manufacturer != null) ...[
                        Text(
                          'Product Details',
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (widget.product.dosage != null)
                          _buildDetailRow('Dosage', widget.product.dosage!),
                        
                        if (widget.product.activeIngredient != null)
                          _buildDetailRow('Active Ingredient', widget.product.activeIngredient!),
                        
                        if (widget.product.manufacturer != null)
                          _buildDetailRow('Manufacturer', widget.product.manufacturer!),
                        
                        if (widget.product.sku != null)
                          _buildDetailRow('SKU', widget.product.sku!),

                        const SizedBox(height: 20),
                      ],

                      // Quantity Selector
                      if (widget.product.inStock) ...[
                        Text(
                          'Quantity',
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: TColor.primary),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.remove, color: TColor.primary),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (quantity < widget.product.stockQuantity) {
                                  setState(() {
                                    quantity++;
                                  });
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: TColor.primary),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.add, color: TColor.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${widget.product.stockQuantity} available',
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Buttons
          if (widget.product.inStock)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isInCart) ...[
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'In Cart: ${cartQuantity}x',
                              style: TextStyle(
                                color: TColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RoundButton(
                              title: "Add More",
                              onPressed: isLoading ? null : () { _addToCart(); },
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: RoundButton(
                          title: "Add to Cart",
                          onPressed: isLoading ? null : () { _addToCart(); },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
