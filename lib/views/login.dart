import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/forgot_password.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeData();
  }

  void _loadRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMeSaved = prefs.getBool('remember_me') ?? false;
    setState(() {
      _rememberMe = rememberMeSaved;
    });

    if (rememberMeSaved) {
      final savedUsername = prefs.getString('saved_username');
      if (savedUsername != null) {
        usernameController.text = savedUsername;
      }
    }
  }

  void _login() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await authService.login(username, password, _rememberMe);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setString('saved_username', username);
      } else {
        await prefs.remove('saved_username');
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Đăng nhập thành công!'),
          backgroundColor: Colors.lightGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng nhập: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Tên App
                Image.asset('assets/images/logo.png', width: 200, height: 200,),

                const SizedBox(height: 32),

                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _rememberMe = newValue ?? false;
                            });
                          },
                        ),
                        const Text('Ghi nhớ tôi'),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}