import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Kiểm tra và xin quyền vị trí
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra GPS có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Lấy tọa độ hiện tại
  Future<Position> getCurrentLocation() async {
    // Đảm bảo quyền đã được cấp trước khi gọi hàm này
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Đổi tọa độ sang tên thành phố (Reverse Geocoding)
  Future<String> getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        // Ưu tiên lấy Locality (Thành phố/Quận), nếu không có thì lấy SubAdministrativeArea
        return placemarks[0].locality ??
            placemarks[0].subAdministrativeArea ??
            'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}
