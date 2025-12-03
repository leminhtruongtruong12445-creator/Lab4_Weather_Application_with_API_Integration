import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';
import 'search_screen.dart'; // <--- 1. Đã bỏ dấu comment ở đây

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động lấy thời tiết theo vị trí khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // <--- 2. Code chuyển màn hình ở đây
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          // 1. Trạng thái đang tải
          if (provider.state == WeatherState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi
          if (provider.state == WeatherState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => provider.fetchWeatherByLocation(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Trạng thái chưa có dữ liệu
          if (provider.currentWeather == null) {
            return const Center(child: Text('Chưa có dữ liệu thời tiết'));
          }

          // 4. Trạng thái đã có dữ liệu (Giao diện chính hoàn chỉnh)
          return RefreshIndicator(
            onRefresh: () => provider.refreshWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Phần 1: Thời tiết hiện tại ---
                  CurrentWeatherCard(weather: provider.currentWeather!),

                  const SizedBox(height: 25),

                  // --- Phần 2: Dự báo 24h tới (List ngang) ---
                  const Text(
                    "Dự báo 24h tới",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Gọi widget hiển thị list ngang
                  HourlyForecastList(forecast: provider.forecast),

                  const SizedBox(height: 25),

                  // --- Phần 3: Dự báo 5 ngày tới (List dọc) ---
                  // Gọi widget hiển thị list dọc
                  DailyForecastCard(forecast: provider.forecast),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
