import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

// Các trạng thái của màn hình: Ban đầu, Đang tải, Đã tải xong, Lỗi
enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';

  // Getters để lấy dữ liệu từ bên ngoài
  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;

  // 1. Lấy thời tiết theo tên thành phố
  Future<void> fetchWeatherByCity(String cityName) async {
    _state = WeatherState.loading;
    notifyListeners(); // Báo cho giao diện biết là "đang tải"

    try {
      _currentWeather = await _weatherService.getCurrentWeatherByCity(cityName);
      _forecast = await _weatherService.getForecast(cityName);

      // Lưu lại để dùng khi offline
      await _storageService.saveWeatherData(_currentWeather!);

      _state = WeatherState.loaded;
      _errorMessage = '';
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners(); // Báo cho giao diện cập nhật kết quả
  }

  // 2. Lấy thời tiết theo vị trí hiện tại (GPS)
  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    notifyListeners();

    try {
      // Kiểm tra quyền và lấy tọa độ
      bool hasPermission = await _locationService.checkPermission();
      if (!hasPermission) {
        throw Exception('Vui lòng cấp quyền vị trí để sử dụng tính năng này');
      }

      final position = await _locationService.getCurrentLocation();

      // Gọi API lấy thời tiết bằng tọa độ
      _currentWeather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      // Lấy tên thành phố từ tọa độ để tìm dự báo 5 ngày
      final cityName = await _locationService.getCityName(
        position.latitude,
        position.longitude,
      );
      _forecast = await _weatherService.getForecast(cityName);

      // Lưu cache
      await _storageService.saveWeatherData(_currentWeather!);

      _state = WeatherState.loaded;
      _errorMessage = '';
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');

      // Nếu lỗi mạng, thử tải dữ liệu cũ (Offline)
      await loadCachedWeather();
    }
    notifyListeners();
  }

  // 3. Tải dữ liệu đã lưu (Offline support)
  Future<void> loadCachedWeather() async {
    final cachedWeather = await _storageService.getCachedWeather();
    if (cachedWeather != null) {
      _currentWeather = cachedWeather;
      _state = WeatherState.loaded;
      notifyListeners();
    }
  }

  // 4. Làm mới dữ liệu (Pull-to-refresh)
  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      // Nếu đang xem thành phố nào thì load lại thành phố đó
      await fetchWeatherByCity(_currentWeather!.cityName);
    } else {
      await fetchWeatherByLocation();
    }
  }
}
