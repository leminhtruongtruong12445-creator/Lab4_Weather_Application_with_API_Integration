import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';

class WeatherService {
  // Lấy thời tiết hiện tại theo tên thành phố
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.currentWeather, {'q': cityName});

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thành phố này');
      } else {
        throw Exception('Lỗi kết nối: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Lấy thời tiết hiện tại theo tọa độ (GPS)
  Future<WeatherModel> getCurrentWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.currentWeather, {
        'lat': lat.toString(),
        'lon': lon.toString(),
      });

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không thể tải dữ liệu thời tiết');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Lấy dự báo 5 ngày
  Future<List<ForecastModel>> getForecast(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(ApiConfig.forecast, {'q': cityName});

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        return list.map((item) => ForecastModel.fromJson(item)).toList();
      } else {
        throw Exception('Không thể tải dữ liệu dự báo');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
