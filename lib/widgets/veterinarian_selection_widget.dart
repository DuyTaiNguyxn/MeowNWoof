import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/providers/veterinarian_provider.dart';

class VeterinarianSelectionWidget extends StatefulWidget {
  final Function(String) onVeterinarianSelected;

  const VeterinarianSelectionWidget({
    Key? key,
    required this.onVeterinarianSelected,
  }) : super(key: key);

  @override
  State<VeterinarianSelectionWidget> createState() => _VeterinarianSelectionWidgetState();
}

class _VeterinarianSelectionWidgetState extends State<VeterinarianSelectionWidget> {
  final List<Map<String, String?>> _allVeterinarians = List.generate(
    20,
        (index) => {
      'name': 'Bác sĩ thú y ${index + 1}',
      'avatar': '',
    },
  );

  List<Map<String, String?>> _filteredVeterinarians = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredVeterinarians = List.from(_allVeterinarians);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    setState(() {
      _filteredVeterinarians = _allVeterinarians
          .where((vet) => vet['name']!
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
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
    final vetProvider = Provider.of<VeterinarianProvider>(context);
    final selectedVet = vetProvider.selectedVeterinarian;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Chọn Bác Sĩ Thú Y',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm bác sĩ thú y...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredVeterinarians.isEmpty
                ? const Center(child: Text('Không tìm thấy bác sĩ nào.'))
                : ListView.builder(
              itemCount: _filteredVeterinarians.length,
              itemBuilder: (context, index) {
                final vet = _filteredVeterinarians[index];
                final name = vet['name']!;
                final avatarPath = vet['avatar'];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: name == selectedVet ? Colors.lightBlueAccent : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    minVerticalPadding: 20,
                    leading: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(
                        (avatarPath != null && avatarPath.isNotEmpty)
                            ? avatarPath
                            : 'assets/images/avatar.png',
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      vetProvider.selectVeterinarian(name);
                      widget.onVeterinarianSelected(name);
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
