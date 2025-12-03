import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class DailyForecastCard extends StatelessWidget {
  final List<ForecastModel> forecast;

  const DailyForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Lọc lấy dữ liệu đại diện các ngày (ví dụ lấy lúc 12:00 trưa)
    // Lưu ý: Danh sách API trả về 3h/lần, nên ta cần lọc.
    List<ForecastModel> dailyList = [];
    String? currentDay;

    for (var item in forecast) {
      String day = DateFormat('dd-MM').format(item.dateTime);
      // Nếu là ngày mới và chưa có trong list thì thêm vào
      if (day != currentDay) {
        // Ưu tiên lấy mốc giờ gần trưa (ví dụ 12h) hoặc lấy mốc đầu tiên của ngày
        if (item.dateTime.hour >= 11 && item.dateTime.hour <= 14) {
          dailyList.add(item);
          currentDay = day;
        } else if (currentDay == null && forecast.indexOf(item) > 0) {
          // Logic phụ để đảm bảo không bỏ sót ngày nếu dữ liệu không rơi vào khung giờ trên
        }
      }
    }

    // Nếu lọc không ra (do dữ liệu trả về ít), ta lấy tạm cứ 8 item lấy 1 cái
    if (dailyList.isEmpty || dailyList.length < 3) {
      dailyList = [];
      for (int i = 0; i < forecast.length; i += 8) {
        dailyList.add(forecast[i]);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "5 Ngày Tới",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true, // Quan trọng: để list nằm gọn trong Column
            physics:
                const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của list này
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = dailyList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Thứ ngày
                    SizedBox(
                      width: 100,
                      child: Text(
                        DateFormat('EEEE', 'vi').format(
                          item.dateTime,
                        ), // Cần set locale vi ở main nếu muốn tiếng Việt
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Icon và mô tả
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://openweathermap.org/img/wn/${item.icon}.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 5),
                        Text(item.description),
                      ],
                    ),
                    // Nhiệt độ
                    Text(
                      '${item.temperature.round()}°',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
