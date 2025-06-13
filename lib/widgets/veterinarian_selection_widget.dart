import 'package:flutter/material.dart';

class VeterinarianSelectionWidget extends StatefulWidget {
  final String? selectedVet;
  final Function(String) onVeterinarianSelected;

  const VeterinarianSelectionWidget({
    super.key,
    required this.selectedVet,
    required this.onVeterinarianSelected,
  });

  @override
  State<VeterinarianSelectionWidget> createState() => _VeterinarianSelectionWidgetState();
}

class _VeterinarianSelectionWidgetState extends State<VeterinarianSelectionWidget> {
  final List<Map<String, String?>> _allVeterinarians = List.generate(
    20,
        (index) => {
      'name': 'Bác sĩ thú y ${index + 1}',
      'sdt': '01234567${(89 + index) % 100}',
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
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVeterinarians = _allVeterinarians.where((vet) {
        final name = vet['name']?.toLowerCase() ?? '';
        final sdt = vet['sdt']?.toLowerCase() ?? '';
        return name.contains(query) || sdt.contains(query);
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
              hintText: 'Tìm bác sĩ theo tên hoặc SĐT...',
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
                final name = vet['name'] ?? 'Không rõ';
                final sdt = vet['sdt'] ?? 'Không rõ';
                final avatarPath = vet['avatar'] ?? '';
                final isSelected = name == widget.selectedVet;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isSelected ? Colors.lightBlueAccent : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        avatarPath.isNotEmpty
                            ? avatarPath
                            : 'assets/images/avatar.png',
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('SĐT: $sdt', style: TextStyle(color: Colors.grey[700])),
                    onTap: () {
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
