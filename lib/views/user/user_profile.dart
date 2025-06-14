// meow_n_woof/lib/views/user/user_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/views/user/edit_user_profile.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/user.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToEditUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dữ liệu người dùng chưa sẵn sàng để chỉnh sửa.')),
      );
      return;
    }

    final User? updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserProfilePage(userData: authService.currentUser!),
      ),
    );

    if (updatedUser != null) {
      authService.updateCurrentUser(updatedUser);
    }
  }

  Widget _buildUserImage(User? userToDisplay) {
    if (userToDisplay == null) {
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      );
    }

    return CircleAvatar(
      radius: 70,
      backgroundImage: userToDisplay.avatarURL != null && userToDisplay.avatarURL!.isNotEmpty
          ? NetworkImage(userToDisplay.avatarURL!) as ImageProvider
          : const AssetImage('assets/images/avatar.png') as ImageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi của AuthService để cập nhật UI
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser; // Lấy user từ AuthService

        if (currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        String formattedBirthDate = 'Chưa cập nhật';
        if (currentUser.birth != null) {
          try {
            formattedBirthDate = DateFormat('dd/MM/yyyy').format(currentUser.birth!);
          } catch (e) {
            print('Lỗi định dạng ngày sinh trong UserProfilePage: ${currentUser.birth} - $e');
            formattedBirthDate = 'Ngày không hợp lệ';
          }
        }

        final String localizedRole = _getLocalizedRole(currentUser.role);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F6FD),
          appBar: AppBar(
            title: const Text('Trang cá nhân'),
            backgroundColor: Colors.lightBlueAccent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: const BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      _buildUserImage(currentUser),
                      const SizedBox(height: 12),
                      Text(
                        currentUser.fullName ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        localizedRole,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Card thông tin cá nhân
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.email, 'Email', currentUser.email),
                          _buildInfoTile(Icons.phone, 'Số điện thoại', currentUser.phone),
                          _buildInfoTile(Icons.cake, 'Ngày sinh', formattedBirthDate),
                          _buildInfoTile(Icons.location_on, 'Địa chỉ', currentUser.address),
                          _buildInfoTile(Icons.person, 'Tên đăng nhập', currentUser.username),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToEditUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Chỉnh sửa',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Chức năng đổi mật khẩu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.lock, color: Colors.white),
                          label: const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlueAccent),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedRole(String? roleName) {
    switch (roleName) {
      case 'staff':
        return 'Nhân viên y tế';
      case 'veterinarian':
        return 'Bác sĩ thú y';
      case 'admin': // Thêm case cho admin nếu có
        return 'Quản trị viên';
      default:
        return 'Người dùng';
    }
  }
}