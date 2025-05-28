import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/appointment/create_appointment.dart';
import 'package:meow_n_woof/views/pet/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet/pet_profile_detail.dart';
import 'package:meow_n_woof/views/user_profile.dart';

class HomeTab extends StatefulWidget {
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> _allPets = List.generate(20, (index) => 'Pet ${index + 1}');
  List<String> _filteredPets = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredPets = List.from(_allPets);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    setState(() {
      _filteredPets = _allPets
          .where((pet) =>
          pet.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreatePetProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePetProfilePage()),
    );
  }

  void _navigateToCreateAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAppointmentScreen()),
    );
  }

  void _navigateToCreateVaccinationSchedule() {
    // Navigator.push
  }

  void _navigateToMedicineList() {
    // Navigator.push
  }

  Widget _buildUserHeader() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfilePage(
              userData: {
                'full_name': 'Nguyễn Văn A',
                'email': 'a@example.com',
                'phone': '0123456789',
                'birth': '1995-06-15',
                'address': '123 Đường ABC, TP.HCM',
                'role': 'Nhân viên y tế',
                'avatarURL': '',
                'username': 'nguyenvana',
              },
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Xin chào,',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton(Icons.pets, 'Tạo hồ sơ pet', Colors.yellowAccent[100]!, _navigateToCreatePetProfile),
        _buildActionButton(Icons.event, 'Tạo lịch khám', Colors.greenAccent[100]!, _navigateToCreateAppointment),
        _buildActionButton(Icons.vaccines, 'Tạo lịch tiêm chủng', Colors.lightBlueAccent[100]!, _navigateToCreateVaccinationSchedule),
        _buildActionButton(Icons.medication, 'Quản lý Thuốc', Colors.orangeAccent[100]!, _navigateToMedicineList),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 20),
          _buildActionGrid(),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm hồ sơ pet...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredPets.isEmpty
                ? Center(child: Text('Không tìm thấy hồ sơ pet nào.'))
                : ListView.builder(
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.pets, size: 32),
                    title: Text(
                      _filteredPets[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Nguyễn Văn A - 0123456789', // có thể thay bằng data thật nếu có
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetProfileDetail(
                            petName: 'Tom',
                            species: 'Mèo',
                            breed: 'Mèo Anh lông ngắn',
                            age: 2,
                            gender: 'Đực',
                            weight: 4.5,
                            imageUrl: '',
                            ownerName: 'Nguyễn Văn A',
                            ownerPhone: '0123456789',
                            ownerEmail: 'a@gmail.com',
                            ownerAddress: '123 Đường ABC, Quận 1, TP.HCM',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
