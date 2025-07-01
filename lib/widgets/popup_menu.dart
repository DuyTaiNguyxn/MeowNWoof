import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/settings.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import '../views/login.dart';

class PopupMenuWidget extends StatelessWidget {
  PopupMenuWidget({super.key});

  final AuthService _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Đăng xuất thành công"),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
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