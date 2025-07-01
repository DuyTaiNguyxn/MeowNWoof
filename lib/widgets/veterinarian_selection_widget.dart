import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/user.dart';
import 'package:meow_n_woof/services/user_service.dart';

class VeterinarianSelectionWidget extends StatefulWidget {
  final User? selectedVet;
  final Function(User) onVeterinarianSelected;

  const VeterinarianSelectionWidget({
    super.key,
    required this.selectedVet,
    required this.onVeterinarianSelected,
  });

  @override
  State<VeterinarianSelectionWidget> createState() => _VeterinarianSelectionWidgetState();
}

class _VeterinarianSelectionWidgetState extends State<VeterinarianSelectionWidget> {
  List<User> _allVeterinarians = [];
  List<User> _filteredVeterinarians = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVeterinarians();
    });
  }

  Future<void> _fetchVeterinarians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final vets = await userService.getVeterinarianUsers();

      setState(() {
        _allVeterinarians = vets;
        _filteredVeterinarians = List.from(vets);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách bác sĩ: $e';
        _isLoading = false;
        print('Lỗi tải bác sĩ: $e');
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVeterinarians = _allVeterinarians.where((vet) {
        final name = vet.fullName.toLowerCase();
        final sdt = vet.phone.toLowerCase();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Bác Sĩ Thú Y'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm bác sĩ theo tên hoặc SĐT...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
                  : _filteredVeterinarians.isEmpty
                  ? const Center(child: Text('Không tìm thấy bác sĩ nào.'))
                  : ListView.builder(
                itemCount: _filteredVeterinarians.length,
                itemBuilder: (context, index) {
                  final vet = _filteredVeterinarians[index];
                  final name = vet.fullName;
                  final sdt = vet.phone;
                  final avatarUrl = vet.avatarURL ?? '';
                  final isSelected = widget.selectedVet?.employeeId == vet.employeeId;

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
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl) as ImageProvider<Object>
                            : const AssetImage('assets/images/default_avatar.png'),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('SĐT: $sdt', style: TextStyle(color: Colors.grey[700])),
                      onTap: () {
                        Navigator.pop(context, vet);
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