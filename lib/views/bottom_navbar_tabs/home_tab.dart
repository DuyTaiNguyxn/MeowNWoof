import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/medicine/medicine_list.dart';
import 'package:meow_n_woof/views/pet/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet/pet_profile_detail.dart';
import 'package:meow_n_woof/views/user/user_profile.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';

class HomeTab extends StatefulWidget {
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Pet> _allPets = List.generate(
    20,
        (index) => Pet(
      name: 'Pet ${index + 1}',
      ownerName: 'Nguyễn Văn A',
      ownerPhone: '0123456789',
      species: 'Dog',
      breed: 'Poodle',
      age: 2,
      gender: 'Đực',
      weight: 4.5,
      ownerAddress: '',
      ownerEmail: '',
      imageUrl: '',
    ),
  );

  List<Pet> _filteredPets = [];
  TextEditingController _searchController = TextEditingController();

  String selectedFilter = 'Tên thú cưng';

  @override
  void initState() {
    super.initState();
    _filteredPets = List.from(_allPets);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredPets = _allPets.where((pet) {
        switch (selectedFilter) {
          case 'Tên thú cưng':
            return pet.name.toLowerCase().contains(keyword);
          case 'Chủ nuôi':
            return pet.ownerName.toLowerCase().contains(keyword);
          case 'Số điện thoại':
            return pet.ownerPhone.contains(keyword);
          default:
            return pet.name.toLowerCase().contains(keyword);
        }
      }).toList();
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

  void _navigateToCreateMedicalRecord() async {
    final selectedPet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(
        builder: (_) => PetSelectionWidget(
          selectedPet: null,
          onPetSelected: (pet) {
            Navigator.pop(context, pet);
          },
        ),
      ),
    );

    if (selectedPet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalRecordListPage(pet: selectedPet),
        ),
      );
    }
  }

  void _navigateToCreatePrescriptions() async {
    final selectedPet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(
        builder: (_) => PetSelectionWidget(
          selectedPet: null,
          onPetSelected: (pet) {
            Navigator.pop(context, pet);
          },
        ),
      ),
    );

    if (selectedPet != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => CreatePrescriptionsScreen(selectedPet: selectedPet),
      //   ),
      // );
    }
  }

  void _navigateToMedicineList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineListPage()),
    );
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
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton(
          Icons.pets,
          'Tạo Hồ sơ Pet',
          Colors.yellowAccent[100]!,
          _navigateToCreatePetProfile,
        ),
        _buildActionButton(
          Icons.medical_services,
          'Tạo Hồ sơ khám bệnh',
          Colors.lightBlueAccent[100]!,
          _navigateToCreateMedicalRecord,
        ),
        _buildActionButton(
          Icons.note_alt,
          'Lên đơn thuốc',
          Colors.greenAccent[100]!,
          _navigateToCreatePrescriptions,
        ),
        _buildActionButton(
          Icons.medication,
          'Tra cứu thuốc',
          Colors.orangeAccent[100]!,
          _navigateToMedicineList,
        ),
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
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
            ),
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

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Tìm kiếm hồ sơ pet...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Thêm lựa chọn vào dropdown filter
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    selectedFilter = value;
                    _onSearch();
                  });
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: 'Tên thú cưng',
                    checked: selectedFilter == 'Tên thú cưng',
                    child: const Text('Tên thú cưng'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'Chủ nuôi',
                    checked: selectedFilter == 'Chủ nuôi',
                    child: const Text('Chủ nuôi'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'Số điện thoại',
                    checked: selectedFilter == 'Số điện thoại',
                    child: const Text('Số điện thoại'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Expanded(
            child: _filteredPets.isEmpty
                ? Center(child: Text('Không tìm thấy hồ sơ pet nào.'))
                : ListView.builder(
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                final pet = _filteredPets[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.pets, size: 32),
                    title: Text(
                      pet.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${pet.ownerName} - 0123456789', // có thể thay bằng data thật nếu có
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetProfileDetail(pet: pet),
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
