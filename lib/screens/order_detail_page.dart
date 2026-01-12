import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderDetailPage extends StatelessWidget {
  final int orderId;
  final ApiService apiService = ApiService();

  OrderDetailPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Order #$orderId')),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getOrderItems(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Item tidak ditemukan'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text(
                    'Harga: Rp ${item['price']}\n'
                        'Jumlah: ${item['quantity']}',
                  ),
                  trailing: Text(
                    'Rp ${item['sub_total']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
