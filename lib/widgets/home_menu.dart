import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../views/login.dart';

class PopupHomeMenu extends StatelessWidget {
  const PopupHomeMenu({super.key});

  Future<void> _logout(BuildContext context) async {
    // Hiển thị toast message
    Fluttertoast.showToast(
      msg: "Đăng xuất thành công",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Thực hiện đăng xuất
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) async {
        if (result == 'settings') {
          // Điều hướng đến trang cài đặt
          print('Đã chọn Cài đặt');
        } else if (result == 'logout') {
          Fluttertoast.showToast(
            msg: "Đăng xuất thành công",
            toastLength: Toast.LENGTH_SHORT, // Thời gian hiển thị toast
            gravity: ToastGravity.BOTTOM, // Vị trí hiển thị toast
            timeInSecForIosWeb: 1, // Thời gian hiển thị trên iOS và Web (giây)
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          print('Đã chọn Đăng xuất');
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8.0),
              Text('Cài đặt')
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red),
              SizedBox(width: 8.0),
              const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red, // Đổi màu chữ thành đỏ
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}