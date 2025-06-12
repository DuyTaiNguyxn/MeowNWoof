import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/user/edit_user_profile.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/user.dart';

class UserProfilePage extends StatelessWidget {
  final User userData;

  // Constructor giờ nhận đối tượng User
  const UserProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final avatarProvider = (userData.avatarURL != null &&
        userData.avatarURL!.isNotEmpty)
        ? NetworkImage(userData.avatarURL!)
        : const AssetImage('assets/images/avatar.png') as ImageProvider;

    String formattedBirthDate = '';
    if (userData.birth != null) {
      try {
        formattedBirthDate = DateFormat('dd/MM/yyyy').format(userData.birth!);
      } catch (e) {
        print('Lỗi định dạng ngày sinh trong UserProfilePage: ${userData.birth} - $e');
        formattedBirthDate = 'Không hợp lệ';
      }
    } else {
      formattedBirthDate = 'Chưa cập nhật';
    }

    final localizedRole = _getLocalizedRole(userData.role);

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
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: avatarProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userData.fullName ?? 'Chưa cập nhật',
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
                      _buildInfoTile(Icons.email, 'Email', userData.email),
                      _buildInfoTile(Icons.phone, 'Số điện thoại', userData.phone),
                      _buildInfoTile(Icons.cake, 'Ngày sinh', formattedBirthDate),
                      _buildInfoTile(Icons.location_on, 'Địa chỉ', userData.address),
                      _buildInfoTile(Icons.person, 'Tên đăng nhập', userData.username),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserProfilePage(userData: userData),
                          ),
                        );
                      },
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
                        // TODO: Chức năng đổi mật khẩu
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

  String _getLocalizedRole(String? role) {
    switch (role) {
      case 'staff':
        return 'Nhân viên y tế';
      case 'veterinarian':
        return 'Bác sĩ thú y';
      default:
        return 'Người dùng';
    }
  }
}