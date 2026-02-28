import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/temp_conv.dart';

void main() async {
  await dotenv.load();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature',
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: TemperatureConverterScreen(),
          ),
        ),
      ),
    );
  }
}
