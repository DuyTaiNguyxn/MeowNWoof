import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCare Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chào mừng bạn đến với PetCare!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quản lý thú cưng của bạn dễ dàng hơn bao giờ hết.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Danh sách thú cưng (tạm thời là 3 mục giả)
            const Text(
              'Danh sách thú cưng:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Danh sách thú cưng
            Expanded(
              child: ListView(
                children: [
                  _buildPetCard('Charlie', 'Chó', '3 tuổi'),
                  _buildPetCard('Milo', 'Mèo', '2 tuổi'),
                  _buildPetCard('Bella', 'Chó', '5 tuổi'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chuyển sang màn hình thêm thú cưng
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm thú cưng',
      ),
    );
  }

  // Widget hiển thị thông tin thú cưng
  Widget _buildPetCard(String name, String species, String age) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.pets, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text('$species, $age'),
        onTap: () {
          // TODO: Chuyển đến trang chi tiết thú cưng
        },
      ),
    );
  }
}
