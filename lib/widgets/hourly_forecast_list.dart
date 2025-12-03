import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class HourlyForecastList extends StatelessWidget {
  final List<ForecastModel> forecast;

  const HourlyForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Chỉ lấy 8 mốc thời gian đầu tiên (tương đương 24 giờ tới)
    final next24Hours = forecast.take(8).toList();

    return SizedBox(
      height: 140, // Chiều cao cố định cho list ngang
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: next24Hours.length,
        itemBuilder: (context, index) {
          final item = next24Hours[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Màu nền mờ
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Giờ
                Text(
                  DateFormat('HH:mm').format(item.dateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Icon
                CachedNetworkImage(
                  imageUrl:
                      'https://openweathermap.org/img/wn/${item.icon}.png',
                  width: 40,
                  height: 40,
                  placeholder: (context, url) => const SizedBox(height: 40),
                ),
                const SizedBox(height: 8),
                // Nhiệt độ
                Text(
                  '${item.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
