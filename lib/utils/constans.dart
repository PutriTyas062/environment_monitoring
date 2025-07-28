import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF21CBF3);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );

  // Sensor Colors
  static const Color temperatureColor = Colors.orange;
  static const Color humidityColor = Colors.blue;
  static const Color phColor = Colors.green;

  // Status Colors
  static const Color normalColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color dangerColor = Colors.red;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // Sensor Ranges
  static const double minTemperature = 20.0;
  static const double maxTemperature = 30.0;

  static const double minHumidity = 40.0;
  static const double maxHumidity = 70.0;

  static const double minPH = 6.5;
  static const double maxPH = 7.5;

  // App Info
  static const String appName = 'Environment Monitor';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplikasi Environment Monitor adalah solusi monitoring lingkungan yang memungkinkan Anda untuk memantau kondisi suhu, kelembaban udara, dan kadar pH air secara real-time dengan tampilan grafik yang informatif.';
}
