import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:environment_monitoring/widgets/sensor_data.dart';
import 'package:environment_monitoring/widgets/sensor_card.dart';
import 'package:environment_monitoring/widgets/chart_widget.dart';
import 'package:environment_monitoring/utils/constans.dart';

class MonitoringScreen extends StatefulWidget {
  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _refreshController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _refreshAnimation;

  // Data management
  late SensorHistory _sensorHistory;
  late Timer _dataUpdateTimer;
  bool _isConnected = true;
  bool _isRefreshing = false;

  // Current sensor data
  SensorData? _currentData;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _startDataUpdates();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.elasticOut),
    );
  }

  void _initializeData() {
    // Initialize with some sample data
    _sensorHistory = SensorHistory(
      temperatureData: [24.1, 24.5, 25.0, 25.5, 25.8, 26.0, 25.5],
      humidityData: [60.0, 62.0, 64.0, 65.0, 66.0, 65.5, 65.0],
      phData: [7.0, 7.1, 7.15, 7.2, 7.18, 7.2, 7.2],
      timestamps: _generateSampleTimestamps(),
    );

    _currentData = _sensorHistory.latestData;
  }

  List<DateTime> _generateSampleTimestamps() {
    final now = DateTime.now();
    return List.generate(
        7, (index) => now.subtract(Duration(minutes: (6 - index) * 10)));
  }

  void _startDataUpdates() {
    _dataUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted && _isConnected) {
        _generateNewSensorData();
      }
    });
  }

  void _generateNewSensorData() {
    final random = Random();
    final newData = SensorData(
      temperature: 23.0 + random.nextDouble() * 6, // 23-29°C
      humidity: 55.0 + random.nextDouble() * 20, // 55-75%
      phLevel: 6.5 + random.nextDouble() * 1.5, // 6.5-8.0
      timestamp: DateTime.now(),
    );

    setState(() {
      _sensorHistory.addData(newData);
      _currentData = newData;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshController.dispose();
    _dataUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppConstants.primaryColor,
        child: ListView(
          padding: EdgeInsets.all(16),
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            _buildConnectionStatus(),
            SizedBox(height: 16),
            _buildSensorCards(),
            SizedBox(height: 24),
            _buildChartsSection(),
            SizedBox(height: 20),
            _buildLastUpdateInfo(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Environment Monitoring'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.circle,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 12,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: _showSettingsDialog,
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isConnected
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.wifi : Icons.wifi_off,
            color: _isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            _isConnected ? 'Terhubung ke sensor' : 'Tidak terhubung',
            style: TextStyle(
              color: _isConnected ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (_isConnected) ...[
            Icon(
              Icons.circle,
              color: Colors.green,
              size: 8,
            ),
            SizedBox(width: 4),
            Text(
              'Live',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorCards() {
    if (_currentData == null) {
      return _buildLoadingSensorCards();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SensorCard(
                title: 'Suhu',
                value: _currentData!.temperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat,
                color: AppConstants.temperatureColor,
                status: _currentData!.temperatureStatusText,
                onTap: () => _showSensorDetail('temperature'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SensorCard(
                title: 'Kelembaban',
                value: _currentData!.humidity.toStringAsFixed(1),
                unit: '%',
                icon: Icons.water_drop,
                color: AppConstants.humidityColor,
                status: _currentData!.humidityStatusText,
                onTap: () => _showSensorDetail('humidity'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SensorCard(
          title: 'pH Air',
          value: _currentData!.phLevel.toStringAsFixed(1),
          unit: '',
          icon: Icons.science,
          color: AppConstants.phColor,
          status: _currentData!.phStatusText,
          isWide: true,
          onTap: () => _showSensorDetail('ph'),
        ),
      ],
    );
  }

  Widget _buildLoadingSensorCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SensorCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: SensorCardSkeleton()),
          ],
        ),
        SizedBox(height: 16),
        SensorCardSkeleton(isWide: true),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Grafik Monitoring',
              style: AppConstants.headingStyle.copyWith(fontSize: 20),
            ),
            Spacer(),
            TextButton.icon(
              onPressed: _showChartOptions,
              icon: Icon(Icons.filter_list, size: 18),
              label: Text('Filter'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ChartWidget(
          title: 'Suhu (°C)',
          data: _sensorHistory.temperatureData,
          color: AppConstants.temperatureColor,
          unit: '°C',
          minValue: AppConstants.minTemperature,
          maxValue: AppConstants.maxTemperature,
        ),
        SizedBox(height: 16),
        ChartWidget(
          title: 'Kelembaban (%)',
          data: _sensorHistory.humidityData,
          color: AppConstants.humidityColor,
          unit: '%',
          minValue: AppConstants.minHumidity,
          maxValue: AppConstants.maxHumidity,
        ),
        SizedBox(height: 16),
        ChartWidget(
          title: 'pH Air',
          data: _sensorHistory.phData,
          color: AppConstants.phColor,
          minValue: AppConstants.minPH,
          maxValue: AppConstants.maxPH,
        ),
      ],
    );
  }

  Widget _buildLastUpdateInfo() {
    if (_currentData == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Text(
            'Terakhir diperbarui: ${_formatTime(_currentData!.timestamp)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Spacer(),
          if (_isRefreshing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _handleManualRefresh,
      backgroundColor: AppConstants.primaryColor,
      child: AnimatedBuilder(
        animation: _refreshController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _refreshAnimation.value * 2 * pi,
            child: Icon(Icons.refresh, color: Colors.white),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Generate new data
    _generateNewSensorData();

    setState(() => _isRefreshing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data berhasil diperbarui'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleManualRefresh() {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    _handleRefresh();
  }

  void _showSensorDetail(String sensorType) {
    String title;
    List<double> data;
    Color color;
    String unit;

    switch (sensorType) {
      case 'temperature':
        title = 'Detail Suhu';
        data = _sensorHistory.temperatureData;
        color = AppConstants.temperatureColor;
        unit = '°C';
        break;
      case 'humidity':
        title = 'Detail Kelembaban';
        data = _sensorHistory.humidityData;
        color = AppConstants.humidityColor;
        unit = '%';
        break;
      case 'ph':
        title = 'Detail pH Air';
        data = _sensorHistory.phData;
        color = AppConstants.phColor;
        unit = '';
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSensorDetailSheet(title, data, color, unit),
    );
  }

  Widget _buildSensorDetailSheet(
      String title, List<double> data, Color color, String unit) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppConstants.headingStyle,
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ChartWidget(
                    title: 'Grafik 7 Data Terakhir',
                    data: data,
                    color: color,
                    unit: unit,
                  ),
                  SizedBox(height: 20),
                  _buildStatistics(data, unit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<double> data, String unit) {
    if (data.isEmpty) return SizedBox.shrink();

    final double min = data.reduce((a, b) => a < b ? a : b);
    final double max = data.reduce((a, b) => a > b ? a : b);
    final double avg = data.reduce((a, b) => a + b) / data.length;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
            style: AppConstants.subHeadingStyle,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    'Minimum', '${min.toStringAsFixed(1)}$unit', Colors.blue),
              ),
              Expanded(
                child: _buildStatItem(
                    'Maksimum', '${max.toStringAsFixed(1)}$unit', Colors.red),
              ),
              Expanded(
                child: _buildStatItem('Rata-rata',
                    '${avg.toStringAsFixed(1)}$unit', Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            title == 'Minimum'
                ? Icons.trending_down
                : title == 'Maksimum'
                    ? Icons.trending_up
                    : Icons.analytics,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pengaturan Monitoring'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Auto Refresh'),
              subtitle: Text('Perbarui data otomatis'),
              value: _isConnected,
              onChanged: (value) {
                setState(() => _isConnected = value);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Interval Update'),
              subtitle: Text('Setiap 3 detik'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showIntervalDialog();
              },
            ),
            ListTile(
              title: Text('Kalibrasi Sensor'),
              subtitle: Text('Atur ulang sensor'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showCalibrationDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showIntervalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Interval Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('1 detik'),
              leading: Radio(value: 1, groupValue: 3, onChanged: null),
            ),
            ListTile(
              title: Text('3 detik'),
              leading: Radio(value: 3, groupValue: 3, onChanged: null),
            ),
            ListTile(
              title: Text('5 detik'),
              leading: Radio(value: 5, groupValue: 3, onChanged: null),
            ),
            ListTile(
              title: Text('10 detik'),
              leading: Radio(value: 10, groupValue: 3, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kalibrasi Sensor'),
        content: Text(
            'Apakah Anda yakin ingin melakukan kalibrasi sensor? Proses ini akan memakan waktu beberapa menit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startCalibration();
            },
            child: Text('Mulai Kalibrasi'),
          ),
        ],
      ),
    );
  }

  void _startCalibration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Kalibrasi Sensor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang melakukan kalibrasi...'),
          ],
        ),
      ),
    );

    // Simulate calibration process
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kalibrasi sensor berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showChartOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opsi Grafik',
              style: AppConstants.subHeadingStyle,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.timeline),
              title: Text('Tampilkan 24 jam terakhir'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur akan segera tersedia')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Tampilkan 7 hari terakhir'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fitur akan segera tersedia')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                _exportData();
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Bagikan Grafik'),
              onTap: () {
                Navigator.pop(context);
                _shareChart();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text(
            'Data akan diekspor dalam format CSV dan disimpan di penyimpanan perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Data berhasil diekspor ke Downloads/sensor_data.csv'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _shareChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grafik berhasil dibagikan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} detik yang lalu';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
