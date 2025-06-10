import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/medicine/medicine_list.dart';
import 'package:meow_n_woof/views/pet/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet/pet_profile_detail.dart';
import 'package:meow_n_woof/views/user/user_profile.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/models/user.dart'; // <-- Import model User

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // GIỮ NGUYÊN DANH SÁCH PET GIẢ
  final List<Pet> _allPets = List.generate(
    20,
        (index) => Pet(
      id: index + 1,
      name: 'Pet ${index + 1}',
      ownerName: 'Nguyễn Văn A',
      ownerPhone: '0123456789',
      // Sửa đổi speciesId và breedId để khớp với model Pet (nếu có)
          species: 'Dog',
          breed: 'Poodle',// Thay bằng ID giống thực tế
      age: 2,
      gender: 'Đực',
      weight: 4.5,
      // Các trường ownerAddress và ownerEmail không có trong model Pet hiện tại của bạn
      // imageUrl: '', // Nếu bạn có ảnh, hãy thêm vào đây
      // createdAt: DateTime.now(), // Thêm nếu muốn
      // updatedAt: DateTime.now(), // Thêm nếu muốn
          ownerAddress: '',
          ownerEmail: '',
          imageUrl: '',
    ),
  );

  List<Pet> _filteredPets = [];
  TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thú cưng';

  // THAY ĐỔI KIỂU DỮ LIỆU TỪ Map<String, dynamic>? SANG User?
  User? _currentUserData;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _filteredPets = List.from(_allPets);
    _searchController.addListener(_onSearch);
    _loadUserData();
  }

  // Hàm tải thông tin user từ AuthService (giờ trả về User object)
  Future<void> _loadUserData() async {
    final user = await _authService.getUser(); // Nhận User object
    if (mounted) {
      setState(() {
        _currentUserData = user; // Gán User object
      });
    }
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

  Widget _buildUserHeader() {
    // TRUY CẬP THUỘC TÍNH TRỰC TIẾP TỪ USER OBJECT
    final userName = _currentUserData?.fullName ?? 'Guest';
    final userRole = _getLocalizedRole(_currentUserData?.role);
    final userAvatarUrl = _currentUserData?.avatarURL;

    return InkWell(
      onTap: () {
        if (_currentUserData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfilePage(
                userData: _currentUserData!, // TRUYỀN TRỰC TIẾP USER OBJECT
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể hiển thị thông tin người dùng. Vui lòng thử lại.')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                  ? NetworkImage(userAvatarUrl) as ImageProvider<Object>
                  : const AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào,',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userRole,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
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
              style: const TextStyle(fontSize: 14),
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
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm kiếm hồ sơ pet...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                ? const Center(child: Text('Không tìm thấy hồ sơ pet nào.'))
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
                    leading: const Icon(Icons.pets, size: 32),
                    title: Text(
                      pet.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${pet.ownerName} - ${pet.ownerPhone}',
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