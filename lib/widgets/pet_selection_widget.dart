import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:provider/provider.dart';

class PetSelectionWidget extends StatefulWidget {
  final Pet? selectedPet;
  final Function(Pet) onPetSelected;

  const PetSelectionWidget({
    super.key,
    required this.selectedPet,
    required this.onPetSelected,
  });

  @override
  State<PetSelectionWidget> createState() => _PetSelectionWidgetState();
}

class _PetSelectionWidgetState extends State<PetSelectionWidget> {
  List<Pet> _allPets = [];
  List<Pet> _filteredPets = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thú cưng';

  bool _isLoadingPets = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPets();
    });
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoadingPets = true;
      _errorMessage = null;
    });
    try {
      final petService = context.read<PetService>();
      final pets = await petService.getPets();

      if (mounted) {
        setState(() {
          _allPets = pets;
          _filteredPets = List.from(_allPets);
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải danh sách thú cưng: ${e.toString()}';
          _isLoadingPets = false;
        });
      }
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.toLowerCase();

    setState(() {
      _filteredPets = _allPets.where((pet) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn thú cưng'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _isLoadingPets
                ? const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
                : _errorMessage != null
                ? Expanded(
              child: Center(
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
                        onPressed: _loadPets,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : Expanded(
              child: _filteredPets.isEmpty
                  ? const Center(child: Text('Không tìm thấy thú cưng nào.'))
                  : ListView.builder(
                itemCount: _filteredPets.length,
                itemBuilder: (context, index) {
                  final pet = _filteredPets[index];
                  final isSelected = widget.selectedPet?.petId == pet.petId;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isSelected ? Colors.lightBlueAccent : null,
                    child: ListTile(
                      leading: pet.imageURL != null && pet.imageURL!.isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(pet.imageURL!),
                        radius: 24,
                      )
                          : const Icon(Icons.pets, size: 48),
                      title: Text(
                        pet.petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${pet.owner?.ownerName ?? 'Không rõ'} - ${pet.owner?.phone ?? 'Không rõ'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      onTap: () {
                        Navigator.pop(context, pet);
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