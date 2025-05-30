import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/login.dart';

class PopupMenuWidget extends StatelessWidget {
  const PopupMenuWidget({super.key});

  Future<void> _logout(BuildContext context) async {
    // Hiển thị snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng xuất thành công"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Đăng xuất và điều hướng về trang login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await Future.delayed(const Duration(seconds: 2)); // chờ snackbar hiển thị
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
              SizedBox(width: 8.0),
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
