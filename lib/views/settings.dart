import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          _settingRow(
            icon: Icons.dark_mode,
            label: 'Chế độ tối',
            trailing: Switch.adaptive(
              value: settings.isDarkMode,
              onChanged: settings.toggleDarkMode,
            ),
          ),

          _settingRow(
            icon: Icons.language,
            label: 'Ngôn ngữ',
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) {
                  settings.changeLanguage(val);
                }
              },
            ),
          ),

          _settingRow(
            icon: Icons.notifications_active,
            label: 'Thông báo đẩy',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          const Column(
            children: [
              Icon(Icons.info_outline, size: 30, color: Colors.grey),
              SizedBox(height: 6),
              Text('Phiên bản ứng dụng', style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 2),
              Text('v1.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}
