import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uts2_client/screens/about_page.dart';
import 'package:uts2_client/screens/weather_page.dart';
import 'package:uts2_client/screens/login_page.dart';

import '../services/api_service.dart';
import '../models/cart_item.dart';
import 'cart_page.dart';
import 'order_page.dart';

class ProductPage extends StatefulWidget {
  final int userId;
  const ProductPage({super.key, required this.userId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<CartItem> cart = [];
  int _cartUpdateCounter = 0; // 👈 TAMBAHKAN COUNTER

  // ===== SAFE PRICE PARSER =====
  double parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String rupiah(num value) =>
      NumberFormat('#,##0', 'id_ID').format(value);

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade50,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER (ANTI OVERFLOW) =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Produk Kami',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih produk terbaik untuk Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _iconButton(
                      icon: Icons.cloud,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeatherPage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _iconButton(
                      icon: Icons.info,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutPage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _cartButton(context),
                    const SizedBox(width: 6),
                    _iconButton(
                      icon: Icons.logout,
                      onTap: () => logout(context),
                    ),
                  ],
                ),
              ),

              // ===== PRODUCT LIST =====
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FutureBuilder<List<dynamic>>(
                    future: ApiService.getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Produk tidak tersedia'),
                        );
                      }

                      final products = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final product = products[i];
                          return Card(
                            margin:
                            const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.blue.shade600,
                                        ],
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${rupiah(parsePrice(product['price_per_kg']))} / kg',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color:
                                            Colors.green.shade700,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // 👉 MASUK KE ORDER PAGE DENGAN CALLBACK
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderPage(
                                            product: product,
                                            cart: cart,
                                            userId: widget.userId,
                                            onCheckoutSuccess: () {
                                              // 🔥 CALLBACK UNTUK REFRESH BADGE
                                              if (mounted) {
                                                setState(() {
                                                  _cartUpdateCounter++;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      );

                                      // 🔥 REFRESH BADGE SETELAH BALIK
                                      if (mounted) setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Pesan'),
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }

  // ===== UI HELPERS =====
  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _cartButton(BuildContext context) {
    return Stack(
      key: ValueKey(_cartUpdateCounter),
      children: [
        _iconButton(
          icon: Icons.shopping_cart,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartPage(
                  userId: widget.userId,
                  cartItems: cart,
                  onCheckoutSuccess: () {
                    // 🔥 CALLBACK DIPANGGIL DARI DALAM DIALOG
                    // SEBELUM NAVIGATOR.POP
                    if (mounted) {
                      setState(() {
                        _cartUpdateCounter++;
                      });
                    }
                  },
                ),
              ),
            );

            // Refresh juga saat kembali normal (tanpa checkout)
            if (mounted) {
              setState(() {
                _cartUpdateCounter++;
              });
            }
          },
        ),
        if (cart.isNotEmpty)
          Positioned(
            right: 6,
            top: 6,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                cart.length.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}