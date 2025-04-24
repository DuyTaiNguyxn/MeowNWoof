import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // Thêm controller này
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Thêm key này

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form( // Bao bọc Column bằng Form
              key: _formKey, // Gán key vào Form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Tên App
                  Image.asset('assets/images/logo.png', width: 200, height: 200),
                  const SizedBox(height: 12),
                  const Text(
                    'Đăng Ký',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Họ và tên
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) { // Thêm validator
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) { // Thêm validator
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      // Có thể thêm kiểm tra định dạng email ở đây
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) { // Thêm validator
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nhập lại mật khẩu
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nhập lại mật khẩu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) { // Thêm validator
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (value != passwordController.text) {
                        return 'Mật khẩu không trùng khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút đăng ký
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Thêm xử lý đăng ký ở đây
                        if (_formKey.currentState!.validate()) { // Kiểm tra form trước khi xử lý
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final confirmPassword = confirmPasswordController.text.trim();
                          final name = nameController.text.trim();
                          print("Đăng ký với Email: $email, Mật khẩu: $password, Họ tên: $name");
                          if (password == confirmPassword) {
                            // Thực hiện đăng ký
                            print('Mật khẩu trùng khớp, có thể thực hiện đăng ký');
                            // Ở đây bạn sẽ gọi các hàm để tạo tài khoản mới (ví dụ: gọi API)
                            // Sau khi đăng ký thành công, có thể chuyển người dùng đến màn hình đăng nhập hoặc trang chủ
                            Navigator.of(context).pushReplacementNamed('/login'); // Ví dụ chuyển đến trang đăng nhập
                          } else {
                            // Hiện thông báo lỗi (đã chuyển vào validator của confirmPasswordController)
                            print('Mật khẩu không trùng khớp. Vui lòng kiểm tra lại.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chuyển qua đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản?"),
                      TextButton(
                        onPressed: () {
                          // TODO: Chuyển sang màn hình đăng nhập
                          Navigator.of(context).pushReplacementNamed('/login'); // Chuyển đến trang đăng nhập
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.lightBlue,
                        ),
                        child: const Text("Đăng nhập"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
