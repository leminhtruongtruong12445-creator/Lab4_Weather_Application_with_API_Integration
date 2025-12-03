import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class StorageService {
  static const String _weatherKey = 'cached_weather';
  static const String _lastUpdateKey = 'last_update';

  // Lưu dữ liệu thời tiết
  Future<void> saveWeatherData(WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherKey, json.encode(weather.toJson()));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Lấy dữ liệu đã lưu
  Future<WeatherModel?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = prefs.getString(_weatherKey);

    if (weatherJson != null) {
      return WeatherModel.fromJson(json.decode(weatherJson));
    }
    return null;
  }
}
