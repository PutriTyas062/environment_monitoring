# Environment Monitoring App

Aplikasi monitoring lingkungan untuk memantau suhu, kelembaban udara, dan kadar pH air secara real-time dengan tampilan yang cantik dan interaktif.

🚀 Fitur Utama

🔐 Authentication: Login/Register dengan validasi form
📊 Real-time Monitoring: Data sensor yang update otomatis
📈 Interactive Charts: Grafik data historis dengan animasi
📱 Responsive UI: Desain modern dengan Material Design
🎨 Beautiful Animations: Smooth transitions dan micro-interactions
⚙️ Settings: Konfigurasi interval update dan kalibrasi sensor

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── screens/                     # Layar utama aplikasi
│   ├── main_screen.dart        # Navigation dengan Bottom Nav Bar
│   ├── profile_screen.dart     # Login/Register & Profile Management
│   ├── monitoring_screen.dart  # Dashboard monitoring sensor
│   └── about_screen.dart       # Informasi aplikasi
├── widgets/                     # Komponen reusable
│   ├── sensor_card.dart        # Card untuk menampilkan data sensor
│   ├── chart_widget.dart       # Widget grafik dengan animasi
│   └── profile_menu_item.dart  # Menu item untuk profile
├── models/                      # Data models
│   └── sensor_data.dart        # Model data sensor dan history
└── utils/                       # Utilities dan
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
