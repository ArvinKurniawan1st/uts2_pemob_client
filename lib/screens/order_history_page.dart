import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  final int userId;
  final ApiService apiService = ApiService();

  OrderHistoryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getOrderHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pesanan'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    'Status: ${order['status']}\n'
                        'Tanggal: ${order['created_at']}',
                  ),
                  trailing: Text(
                    'Rp ${order['total']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(
                          orderId: order['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
