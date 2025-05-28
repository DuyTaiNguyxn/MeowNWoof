import 'package:flutter/material.dart';

class PetSelectionWidget extends StatefulWidget {
  final String? selectedPet;
  final Function(String) onPetSelected;

  const PetSelectionWidget({
    Key? key,
    required this.selectedPet,
    required this.onPetSelected,
  }) : super(key: key);

  @override
  State<PetSelectionWidget> createState() => _PetSelectionWidgetState();
}

class _PetSelectionWidgetState extends State<PetSelectionWidget> {
  final List<String> _allPets = List.generate(20, (index) => 'Pet ${index + 1}');
  List<String> _filteredPets = [];
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Chọn Thú Cưng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Tìm thú cưng...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
                      pet,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Nguyễn Văn A - 0123456789',
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
    );
  }
}