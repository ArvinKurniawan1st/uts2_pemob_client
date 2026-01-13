import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final int orderId;
  final ApiService apiService = ApiService();

  OrderDetailPage({required this.orderId});

  // Fungsi untuk format harga ke format Indonesia
  String formatRupiah(dynamic amount) {
    double value = 0;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is num) {
      value = amount.toDouble();
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Detail Order #$orderId',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getOrderItems(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat detail pesanan...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Item Tidak Ditemukan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada item dalam pesanan ini',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Hitung total dengan pengecekan tipe data
          double totalAmount = 0;
          int totalItems = 0;
          double shippingCost = 0;

          for (var item in items) {
            // Konversi sub_total ke double dengan aman
            var subTotal = item['sub_total'];
            if (subTotal != null) {
              if (subTotal is String) {
                totalAmount += double.tryParse(subTotal) ?? 0;
              } else if (subTotal is num) {
                totalAmount += subTotal.toDouble();
              }
            }

            // Konversi quantity ke int dengan aman
            var quantity = item['quantity'];
            if (quantity != null) {
              if (quantity is String) {
                totalItems += int.tryParse(quantity) ?? 0;
              } else if (quantity is num) {
                totalItems += quantity.toInt();
              }
            }

            // Ambil shipping cost dari item pertama
            if (shippingCost == 0 && item['shipping_cost'] != null) {
              var shipping = item['shipping_cost'];
              if (shipping is String) {
                shippingCost = double.tryParse(shipping) ?? 0;
              } else if (shipping is num) {
                shippingCost = shipping.toDouble();
              }
            }
          }

          // Total akhir termasuk ongkir
          double grandTotal = totalAmount + shippingCost;

          return Column(
            children: [
              // Header Info Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[900]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalItems Item',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total Produk',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.payments,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(grandTotal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Label Daftar Produk
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daftar Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // List Items
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          // Konversi data dengan aman
                          String productName = item['product_name']?.toString() ?? 'Produk';
                          String price = item['price']?.toString() ?? '0';
                          String quantity = item['quantity']?.toString() ?? '0';
                          String subTotal = item['sub_total']?.toString() ?? '0';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon Produk
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Colors.blue[700],
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Detail Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              formatRupiah(price),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.inventory_2,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Jumlah: $quantity',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Subtotal: ${formatRupiah(subTotal)}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Summary Card dengan Shipping Cost yang lebih menonjol
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Subtotal Produk
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal Produk',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatRupiah(totalAmount),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Shipping Cost - Lebih menonjol dengan box berwarna
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping,
                                      size: 20,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ongkos Kirim',
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formatRupiah(shippingCost),
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),

                          // Grand Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatRupiah(grandTotal),
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}