import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitNewPassword() {
    if (newPasswordController.text == confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildEnterInfoPage(),
              _buildOtpPage(),
              _buildNewPasswordPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterInfoPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhập email hoặc tên đăng nhập:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Email / Tên đăng nhập',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Vui lòng nhập thông tin' : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Gửi OTP
              _nextPage();
            }
          },
          child: const Text('Tiếp tục'),
        ),
      ],
    );
  }

  Widget _buildOtpPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhập mã xác nhận được gửi tới email của bạn:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        TextFormField(
          controller: otpController,
          decoration: const InputDecoration(
            labelText: 'Mã xác nhận',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Vui lòng nhập mã xác nhận' : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(onPressed: _prevPage, child: const Text('Quay lại')),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Kiểm tra mã OTP
                  _nextPage();
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPasswordPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhập mật khẩu mới:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        TextFormField(
          controller: newPasswordController,
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
            ),
          ),
          validator: (value) => value!.length < 6 ? 'Tối thiểu 6 ký tự' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
          ),
          validator: (value) => value != newPasswordController.text ? 'Mật khẩu không khớp' : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(onPressed: _prevPage, child: const Text('Quay lại')),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitNewPassword();
                }
              },
              child: const Text('Đặt lại mật khẩu'),
            ),
          ],
        ),
      ],
    );
  }
}
