import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet_profile_detail.dart';

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
          .where((pet) => pet.toLowerCase().contains(_searchController.text.toLowerCase()))
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

  void _navigateToCreateMedicalRecord() {
    // Giả sử bro có một file tương tự cho tạo hồ sơ khám bệnh
    // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMedicalRecordPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Grid 2 nút lớn
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              InkWell(
                onTap: _navigateToCreatePetProfile,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.pets, size: 48),
                      SizedBox(height: 8),
                      Text('Tạo hồ sơ pet', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _navigateToCreateMedicalRecord,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.description, size: 48),
                      SizedBox(height: 8),
                      Text('Tạo hồ sơ khám bệnh', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm hồ sơ pet...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 12),

          // Danh sách hồ sơ pet
          Expanded(
            child: _filteredPets.isEmpty
                ? Center(child: Text('Không tìm thấy hồ sơ pet nào.'))
                : ListView.builder(
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.pets),
                    title: Text(_filteredPets[index]),
                    onTap: () {
                      // Truyền dữ liệu đến pet_profile_detail.dart
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
