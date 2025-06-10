import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/settings.dart';
import 'package:meow_n_woof/services/auth_service.dart'; // Import AuthService
import '../views/login.dart';

class PopupMenuWidget extends StatelessWidget {
  PopupMenuWidget({super.key});

  // Khởi tạo AuthService một lần để sử dụng (BỎ 'const' ở đây)
  final AuthService _authService = AuthService(); // <-- Sửa đổi tại đây

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng xuất thành công"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) {
        if (result == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        } else if (result == 'logout') {
          _logout(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8.0), // Thêm SizedBox bị thiếu ở đây
              Text('Cài đặt'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              SizedBox(width: 8.0),
              Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}