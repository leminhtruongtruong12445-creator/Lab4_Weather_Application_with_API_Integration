import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Lấy key từ file .env
  static String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';

  // Hàm tạo URL đầy đủ với các tham số cần thiết
  static String buildUrl(String endpoint, Map<String, dynamic> params) {
    // Thêm các tham số bắt buộc
    params['appid'] = apiKey;
    params['units'] = 'metric'; // Dùng độ C
    params['lang'] = 'vi'; // Tiếng Việt

    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
    return uri.toString();
  }
}
