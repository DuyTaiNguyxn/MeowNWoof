import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/register.dart';
import 'package:meow_n_woof/views/login.dart';
import 'package:meow_n_woof/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meow & Woof',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(), // Định nghĩa route '/login'
        //'/register': (context) => const RegisterScreen(), // Định nghĩa route '/register'
        '/home' : (context) => const HomeScreen(),
      },
    );
  }
}
