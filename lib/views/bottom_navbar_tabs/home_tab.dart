import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/medical_record/select_pet_page.dart';
import 'package:meow_n_woof/views/medicine/medicine_list.dart';
import 'package:meow_n_woof/views/pet/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet/pet_profile_detail.dart';
import 'package:meow_n_woof/views/user/user_profile.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/models/user.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Pet> _allPets = [];
  List<Pet> _filteredPets = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thú cưng';

  final PetService _petService = PetService();

  bool _isLoadingPets = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoadingPets = true;
      _errorMessage = null;
    });
    try {
      final pets = await _petService.getPets();
      if (mounted) {
        setState(() {
          _allPets = pets;
          _allPets.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!); // Sắp xếp giảm dần
          });
          _filteredPets = List.from(_allPets);
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingPets = false;
        });
      }
    }
  }

  Future<void> _handlePetSelect(Pet pet) async {
    final bool? hasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileDetail(
          petId: pet.petId!,
          petName: pet.petName,
        ),
      ),
    );

    if (hasUpdated == true) {
      await _loadPets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Danh sách thú cưng đã được làm mới!')),
        );
      }
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredPets = _allPets.where((pet) {
        // Truy cập thông tin owner từ Pet object. Cần kiểm tra null.
        final ownerName = pet.owner?.ownerName.toLowerCase() ?? '';
        final ownerPhone = pet.owner?.phone.toLowerCase() ?? '';

        switch (selectedFilter) {
          case 'Tên thú cưng':
            return pet.petName.toLowerCase().contains(keyword);
          case 'Chủ nuôi':
            return ownerName.contains(keyword);
          case 'Số điện thoại':
            return ownerPhone.contains(keyword);
          default:
            return pet.petName.toLowerCase().contains(keyword);
        }
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreatePetProfile() async {
    // Chờ kết quả từ CreatePetProfilePage
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePetProfilePage()),
    );
    if (result == true) {
      _loadPets();
    }
  }

  void _navigateToCreateMedicalRecord() async {
    final selectedPet = await Navigator.push<Pet>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectPetPage(
          selectedPet: null,
          onPetSelected: (pet) {
            Navigator.pop(context, pet);
          },
        ),
      ),
    );

    // Cần kiểm tra 'mounted' trước khi sử dụng context
    if (!mounted) return;

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
        builder: (_) => SelectPetPage(
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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        final userName = currentUser?.fullName ?? 'Guest';
        final userRole = _getLocalizedRole(currentUser?.role);
        final userAvatarUrl = currentUser?.avatarURL;

        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserProfilePage(),
              ),
            );
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
      },
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
          // Hiển thị trạng thái tải hoặc lỗi
          _isLoadingPets
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: $_errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadPets, // Thử tải lại
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
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
                    leading: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(pet.imageUrl!),
                      radius: 24,
                    )
                        : const Icon(Icons.pets, size: 48),
                    title: Text(
                      pet.petName, // Đã đổi từ pet.name
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      // Truy cập thông tin chủ nuôi từ PetOwner object bên trong Pet
                      '${pet.owner?.ownerName ?? 'N/A'} - ${pet.owner?.phone ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onTap: () => _handlePetSelect(pet),
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