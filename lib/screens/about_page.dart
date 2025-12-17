import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'AgroOrder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Aplikasi pemesanan hasil tani berbasis client-admin.',
            ),
            SizedBox(height: 20),
            Text(
              'Public API yang digunakan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'OpenWeatherMap\n'
                  'https://api.openweathermap.org/data/2.5/weather',
            ),
          ],
        ),
      ),
    );
  }
}
