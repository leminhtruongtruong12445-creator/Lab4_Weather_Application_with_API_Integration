import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import thêm cái này
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  // KHỞI TẠO DỮ LIỆU NGÔN NGỮ TIẾNG VIỆT
  await initializeDateFormatting('vi', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
