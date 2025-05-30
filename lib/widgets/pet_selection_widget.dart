import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';

class PetSelectionWidget extends StatefulWidget {
  final Pet? selectedPet;
  final Function(Pet) onPetSelected;

  const PetSelectionWidget({
    Key? key,
    required this.selectedPet,
    required this.onPetSelected,
  }) : super(key: key);

  @override
  State<PetSelectionWidget> createState() => _PetSelectionWidgetState();
}

class _PetSelectionWidgetState extends State<PetSelectionWidget> {
  final List<Pet> _allPets = List.generate(
    20,
        (index) => Pet(
      name: 'Pet ${index + 1}',
      ownerName: 'Nguyễn Văn A',
      ownerPhone: '0123456789',
      species: 'Mèo',
      breed: 'Mèo Anh lông ngắn',
      age: 2,
      gender: 'Đực',
      weight: 4.5,
      ownerAddress: '',
      ownerEmail: '',
      imageUrl: '',
    ),
  );

  List<Pet> _filteredPets = [];
  final TextEditingController _searchController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Chọn thú cưng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm thú cưng...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                  ? const Center(child: Text('Không tìm thấy thú cưng nào.'))
                  : ListView.builder(
                itemCount: _filteredPets.length,
                itemBuilder: (context, index) {
                  final pet = _filteredPets[index];
                  final isSelected = pet == widget.selectedPet;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isSelected ? Colors.lightBlueAccent : null,
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
                        widget.onPetSelected(pet);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}