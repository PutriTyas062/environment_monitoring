class SensorData {
  final double temperature;
  final double humidity;
  final double phLevel;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.phLevel,
    required this.timestamp,
  });

  // Copy with method untuk update data
  SensorData copyWith({
    double? temperature,
    double? humidity,
    double? phLevel,
    DateTime? timestamp,
  }) {
    return SensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      phLevel: phLevel ?? this.phLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'phLevel': phLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      phLevel: json['phLevel']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'SensorData(temperature: $temperature, humidity: $humidity, phLevel: $phLevel, timestamp: $timestamp)';
  }
}

// Class untuk menyimpan data historis
class SensorHistory {
  final List<double> temperatureData;
  final List<double> humidityData;
  final List<double> phData;
  final List<DateTime> timestamps;

  SensorHistory({
    required this.temperatureData,
    required this.humidityData,
    required this.phData,
    required this.timestamps,
  });

  // Method untuk menambah data baru
  void addData(SensorData data) {
    temperatureData.add(data.temperature);
    humidityData.add(data.humidity);
    phData.add(data.phLevel);
    timestamps.add(data.timestamp);

    // Batasi jumlah data (misal maksimal 50 data)
    const maxDataPoints = 50;
    if (temperatureData.length > maxDataPoints) {
      temperatureData.removeAt(0);
      humidityData.removeAt(0);
      phData.removeAt(0);
      timestamps.removeAt(0);
    }
  }

  // Get latest data
  SensorData? get latestData {
    if (temperatureData.isEmpty) return null;

    return SensorData(
      temperature: temperatureData.last,
      humidity: humidityData.last,
      phLevel: phData.last,
      timestamp: timestamps.last,
    );
  }
}

// Enum untuk status sensor
enum SensorStatus {
  normal,
  warning,
  danger,
}

// Extension untuk mendapatkan status
extension SensorStatusExtension on SensorData {
  SensorStatus get temperatureStatus {
    if (temperature < 20) return SensorStatus.warning;
    if (temperature > 30) return SensorStatus.danger;
    return SensorStatus.normal;
  }

  SensorStatus get humidityStatus {
    if (humidity < 40) return SensorStatus.warning;
    if (humidity > 70) return SensorStatus.danger;
    return SensorStatus.normal;
  }

  SensorStatus get phStatus {
    if (phLevel < 6.5) return SensorStatus.warning;
    if (phLevel > 7.5) return SensorStatus.danger;
    return SensorStatus.normal;
  }

  String get temperatureStatusText {
    switch (temperatureStatus) {
      case SensorStatus.normal:
        return 'Normal';
      case SensorStatus.warning:
        return temperature < 20 ? 'Dingin' : 'Hangat';
      case SensorStatus.danger:
        return 'Panas';
    }
  }

  String get humidityStatusText {
    switch (humidityStatus) {
      case SensorStatus.normal:
        return 'Normal';
      case SensorStatus.warning:
        return humidity < 40 ? 'Kering' : 'Lembab';
      case SensorStatus.danger:
        return 'Sangat Lembab';
    }
  }

  String get phStatusText {
    switch (phStatus) {
      case SensorStatus.normal:
        return 'Normal';
      case SensorStatus.warning:
        return phLevel < 6.5 ? 'Asam' : 'Basa';
      case SensorStatus.danger:
        return phLevel < 6.5 ? 'Sangat Asam' : 'Sangat Basa';
    }
  }
}
