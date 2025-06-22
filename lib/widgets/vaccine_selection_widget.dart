import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/services/medicine_service.dart';

class VaccineSelectionWidget extends StatefulWidget {
  final Medicine? selectedVaccine;
  final Function(Medicine) onVaccineSelected;

  const VaccineSelectionWidget({
    super.key,
    required this.selectedVaccine,
    required this.onVaccineSelected,
  });

  @override
  State<VaccineSelectionWidget> createState() => _VaccineSelectionWidgetState();
}

class _VaccineSelectionWidgetState extends State<VaccineSelectionWidget> {
  List<Medicine> _allVaccines = [];
  List<Medicine> _filteredVaccines = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  late MedicineService _medicineService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _medicineService = Provider.of<MedicineService>(context, listen: false);
      _fetchVaccines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVaccines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allMedicines = await _medicineService.getAllMedicines();
      _allVaccines = allMedicines.where((medicine) => medicine.type?.typeName == 'Vaccine').toList();

      setState(() {
        _filteredVaccines = List.from(_allVaccines);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách vaccine: $e';
        _isLoading = false;
        print('Lỗi tải vaccine: $e');
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVaccines = _allVaccines.where((vaccine) {
        final name = vaccine.medicineName.toLowerCase();
        final manufacturer = vaccine.manufacturer?.toLowerCase() ?? '';
        final speciesUse = vaccine.speciesUse?.toLowerCase() ?? '';

        return name.contains(query) ||
            manufacturer.contains(query) ||
            speciesUse.contains(query);
      }).toList();
    });
  }

  Widget _buildDetailRow(String label, String value){
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Vaccine'),
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
                hintText: 'Tìm vaccine theo tên, nhà sản xuất hoặc loài...',
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
                  : _filteredVaccines.isEmpty
                  ? const Center(child: Text('Không tìm thấy vaccine nào.'))
                  : ListView.builder(
                itemCount: _filteredVaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = _filteredVaccines[index];
                  final isSelected = widget.selectedVaccine?.medicineId == vaccine.medicineId;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected ? const BorderSide(color: Colors.lightBlue, width: 2) : BorderSide.none,
                    ),
                    color: isSelected ? Colors.lightBlueAccent : null,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: vaccine.imageURL != null && vaccine.imageURL!.isNotEmpty
                            ? NetworkImage(vaccine.imageURL!) as ImageProvider<Object>
                            : const AssetImage('assets/images/default_medicine_avatar.png'),
                      ),
                      title: Text(
                        vaccine.medicineName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildDetailRow('Hãng: ', vaccine.manufacturer ?? 'Chưa cập nhật'),
                          const SizedBox(height: 12),
                          if (vaccine.speciesUse != null && vaccine.speciesUse!.isNotEmpty)
                            _buildDetailRow('Dùng cho: ', vaccine.speciesUse ?? 'Chưa cập nhật'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Số lượng còn: ', vaccine.stockQuantity.toString()),
                          const SizedBox(height: 12),
                          if (vaccine.expiryDate != null)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: 'HSD: '),
                                  TextSpan(
                                    text: DateFormat('dd/MM/yyyy').format(vaccine.expiryDate!),
                                    style: TextStyle(
                                      color: (vaccine.expiryDate!.isBefore(DateTime.now())) ? Colors.red : Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, vaccine);
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