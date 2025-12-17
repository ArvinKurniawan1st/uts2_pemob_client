import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('cerah')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloud') || desc.contains('berawan')) {
      return Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('hujan')) {
      return Icons.water_drop;
    } else if (desc.contains('storm') || desc.contains('petir')) {
      return Icons.thunderstorm;
    } else if (desc.contains('snow') || desc.contains('salju')) {
      return Icons.ac_unit;
    } else if (desc.contains('mist') || desc.contains('fog') || desc.contains('kabut')) {
      return Icons.cloud_queue;
    }
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('cerah')) {
      return Colors.orange;
    } else if (desc.contains('cloud') || desc.contains('berawan')) {
      return Colors.grey;
    } else if (desc.contains('rain') || desc.contains('hujan')) {
      return Colors.blue;
    } else if (desc.contains('storm') || desc.contains('petir')) {
      return Colors.deepPurple;
    }
    return Colors.blueGrey;
  }

  List<Color> _getGradientColors(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('cerah')) {
      return [Colors.orange.shade400, Colors.deepOrange.shade600];
    } else if (desc.contains('cloud') || desc.contains('berawan')) {
      return [Colors.grey.shade600, Colors.grey.shade800];
    } else if (desc.contains('rain') || desc.contains('hujan')) {
      return [Colors.blue.shade700, Colors.indigo.shade900];
    } else if (desc.contains('storm') || desc.contains('petir')) {
      return [Colors.deepPurple.shade700, Colors.purple.shade900];
    }
    return [Colors.blueGrey.shade700, Colors.blueGrey.shade900];
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: ApiService.getWeather('Bandung'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red.shade400, Colors.red.shade700],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Gagal Memuat Data Cuaca',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final temp = data['main']['temp'];
          final description = data['weather'][0]['description'];
          final humidity = data['main']['humidity'];
          final windSpeed = data['wind']['speed'];
          final feelsLike = data['main']['feels_like'];
          final pressure = data['main']['pressure'];

          final gradientColors = _getGradientColors(description);
          final weatherIcon = _getWeatherIcon(description);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Informasi Cuaca',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance for back button
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Location
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['name'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Weather Icon
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              weatherIcon,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Temperature
                          Text(
                            '${temp.toStringAsFixed(0)}°C',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _capitalizeFirst(description),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Weather Details
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildWeatherDetail(
                                      Icons.thermostat,
                                      'Terasa Seperti',
                                      '${feelsLike.toStringAsFixed(0)}°C',
                                    ),
                                    _buildWeatherDetail(
                                      Icons.water_drop_outlined,
                                      'Kelembaban',
                                      '$humidity%',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildWeatherDetail(
                                      Icons.air,
                                      'Kec. Angin',
                                      '${windSpeed.toStringAsFixed(1)} m/s',
                                    ),
                                    _buildWeatherDetail(
                                      Icons.speed,
                                      'Tekanan',
                                      '$pressure hPa',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Last Update Info
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.update,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Data cuaca real-time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}