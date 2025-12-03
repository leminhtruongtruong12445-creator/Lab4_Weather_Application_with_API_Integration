import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _getWeatherGradient(weather.mainCondition),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tên thành phố
          Text(
            weather.cityName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          // Ngày tháng
          Text(
            DateFormat('EEEE, d MMMM').format(weather.dateTime),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          // Icon thời tiết và Nhiệt độ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 100,
                height: 100,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Text(
                '${weather.temperature.round()}°',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Trạng thái (Mưa, Nắng...)
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Cảm giác như
          Text(
            'Cảm giác như ${weather.feelsLike.round()}°',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 20),

          // Các thông số chi tiết (Gió, Độ ẩm)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(Icons.air, '${weather.windSpeed} m/s', 'Gió'),
              _buildDetailItem(
                Icons.water_drop,
                '${weather.humidity}%',
                'Độ ẩm',
              ),
              _buildDetailItem(
                Icons.speed,
                '${weather.pressure} hPa',
                'Áp suất',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con hiển thị thông số nhỏ
  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // Hàm chọn màu nền dựa trên thời tiết [cite: 59-60]
  LinearGradient _getWeatherGradient(String condition) {
    List<Color> colors;
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        colors = [const Color(0xFFA0AEC0), const Color(0xFFCBD5E0)]; // Xám mây
        break;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        colors = [const Color(0xFF4A5568), const Color(0xFF718096)]; // Xám mưa
        break;
      case 'clear':
        colors = [
          const Color(0xFFFDB813),
          const Color(0xFF87CEEB),
        ]; // Vàng xanh nắng
        break;
      default:
        colors = [
          const Color(0xFF4A90E2),
          const Color(0xFF87CEEB),
        ]; // Xanh mặc định
    }
    return LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
