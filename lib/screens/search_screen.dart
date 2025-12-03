import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _cityController = TextEditingController();
  bool _isLoading = false;

  // 1. Danh sách các thành phố mẫu (Bạn có thể thêm tùy thích)
  final List<String> _allCities = [
    "Ha Noi",
    "Ho Chi Minh City",
    "Da Nang",
    "Hai Phong",
    "Can Tho",
    "Hue",
    "Nha Trang",
    "Vung Tau",
    "Da Lat",
    "Sa Pa",
    "Ha Long",
    "Buon Ma Thuot",
    "Vinh",
    "Quy Nhon",
    "Phan Thiet",
    "Thu Dau Mot",
    "Binh Duong",
    "Bien Hoa",
    "Dong Nai",
    "Binh Thuan",
    "Binh Phuoc",
    "Bac Lieu",
    "Bac Ninh",
    "Ben Tre",
    "London",
    "Tokyo",
    "New York",
    "Paris",
    "Seoul",
    "Bangkok",
    "Singapore",
  ];

  // Danh sách kết quả gợi ý sẽ thay đổi khi gõ
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    // Ban đầu không hiện gợi ý gì
    _filteredCities = [];
  }

  // 2. Hàm lọc danh sách khi người dùng gõ
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // Nếu xóa hết chữ thì không hiện gì
      results = [];
    } else {
      // Lọc các thành phố có chứa từ khóa (không phân biệt hoa thường)
      results = _allCities
          .where(
            (city) => city.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    }

    // Cập nhật giao diện
    setState(() {
      _filteredCities = results;
    });
  }

  // 3. Hàm thực hiện tìm kiếm
  Future<void> _searchCity(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    _cityController.text = cityName; // Điền tên vào ô nhập

    final provider = context.read<WeatherProvider>();
    await provider.fetchWeatherByCity(cityName);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (provider.state == WeatherState.loaded) {
      Navigator.pop(context);
    } else if (provider.state == WeatherState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm thành phố")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô nhập liệu
            TextField(
              controller: _cityController,
              // Gọi hàm lọc mỗi khi gõ chữ
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Nhập tên thành phố...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: _cityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cityController.clear();
                          _runFilter(''); // Xóa danh sách gợi ý
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _searchCity(_cityController.text),
            ),

            const SizedBox(height: 10),

            if (_isLoading)
              const LinearProgressIndicator()
            else if (_filteredCities.isNotEmpty)
              // Hiển thị danh sách gợi ý
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = _filteredCities[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: const Icon(
                          Icons.location_city,
                          color: Colors.blue,
                        ),
                        title: Text(city),
                        trailing: const Icon(Icons.north_west, size: 16),
                        onTap: () {
                          // Khi bấm vào gợi ý thì tìm kiếm luôn
                          _searchCity(city);
                        },
                      ),
                    );
                  },
                ),
              )
            else if (_cityController.text.isNotEmpty)
              // Nếu nhập mà không khớp gợi ý nào
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Không tìm thấy gợi ý phù hợp trong danh sách mẫu.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
