import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import 'cart_page.dart';

class OrderPage extends StatefulWidget {
  final Map product;
  final List<CartItem> cart;
  final int userId;
  final VoidCallback? onCheckoutSuccess; // 👈 TAMBAHKAN CALLBACK

  const OrderPage({
    super.key,
    required this.product,
    required this.cart,
    required this.userId,
    this.onCheckoutSuccess, // 👈 TAMBAHKAN CALLBACK
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int qty = 1;
  static const int maxQty = 100;

  double get pricePerKg {
    final p = widget.product['price_per_kg'];
    if (p is num) return p.toDouble();
    if (p is String) return double.tryParse(p) ?? 0.0;
    return 0.0;
  }

  int get subtotal => (pricePerKg * qty).round();

  String rupiah(num value) =>
      NumberFormat('#,##0', 'id_ID').format(value);

  void addToCartFromOrder() {
    final index = widget.cart.indexWhere(
          (item) => item.productId == widget.product['id'],
    );

    if (index == -1) {
      widget.cart.add(
        CartItem(
          productId: widget.product['id'],
          name: widget.product['name'],
          pricePerKg: pricePerKg,
          quantity: qty,
        ),
      );
    } else {
      widget.cart[index].quantity += qty;
    }

    // Get the navigator before popping
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Pop dulu sebelum show SnackBar
    navigator.pop();

    // ✨ SNACKBAR CANTIK - Tampilkan setelah pop
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Berhasil ditambahkan!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$qty kg ${widget.product['name']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            // 👇 KIRIM CALLBACK KE CARTPAGE
            navigator.push(
              MaterialPageRoute(
                builder: (context) => CartPage(
                  userId: widget.userId,
                  cartItems: widget.cart,
                  onCheckoutSuccess: widget.onCheckoutSuccess, // 👈 TERUSKAN CALLBACK
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ===== PRODUCT INFO =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.product['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${rupiah(pricePerKg)} / kg',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== QTY SELECTOR =====
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Jumlah Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: qty > 1
                                    ? () => setState(() => qty--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  '$qty kg',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: qty < maxQty
                                    ? () => setState(() => qty++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== PRICE PREVIEW =====
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Rp ${rupiah(subtotal)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ===== ADD TO CART BUTTON =====
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: addToCartFromOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Tambah ke Keranjang - Rp ${rupiah(subtotal)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}