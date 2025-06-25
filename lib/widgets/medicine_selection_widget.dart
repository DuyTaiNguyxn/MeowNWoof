import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/services/medicine_service.dart';

class MedicineSelectionWidget extends StatefulWidget {
  final Medicine? selectedMedicine;
  final Function(Medicine) onMedicineSelected;

  const MedicineSelectionWidget({
    super.key,
    required this.selectedMedicine,
    required this.onMedicineSelected,
  });

  @override
  State<MedicineSelectionWidget> createState() => _MedicineSelectionWidgetState();
}

class _MedicineSelectionWidgetState extends State<MedicineSelectionWidget> {
  List<Medicine> _allOtherMedicines = [];
  List<Medicine> _filteredOtherMedicines = [];

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
      _fetchOtherMedicines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allMedicines = await _medicineService.getAllMedicines();
      _allOtherMedicines = allMedicines.where((medicine) => medicine.type?.typeName != 'Vaccine').toList();

      setState(() {
        _filteredOtherMedicines = List.from(_allOtherMedicines);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách thuốc: $e';
        _isLoading = false;
        print('Lỗi tải thuốc: $e');
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOtherMedicines = _allOtherMedicines.where((medicine) {
        final name = medicine.medicineName.toLowerCase();
        final manufacturer = medicine.manufacturer?.toLowerCase() ?? 'Không rõ';
        final speciesUse = medicine.speciesUse?.toLowerCase() ?? 'Không rõ';

        return name.contains(query) ||
            manufacturer.contains(query) ||
            speciesUse.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Thuốc Khác'),
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
                hintText: 'Tìm thuốc theo tên, nhà sản xuất hoặc loài...',
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
                  : _filteredOtherMedicines.isEmpty
                  ? const Center(child: Text('Không tìm thấy thuốc nào.'))
                  : ListView.builder(
                itemCount: _filteredOtherMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = _filteredOtherMedicines[index];
                  final isSelected = widget.selectedMedicine?.medicineId == medicine.medicineId;

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
                        backgroundImage: medicine.imageURL != null && medicine.imageURL!.isNotEmpty
                            ? NetworkImage(medicine.imageURL!) as ImageProvider<Object>
                            : const AssetImage('assets/images/logo_bg.png'),
                      ),
                      title: Text(
                        medicine.medicineName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loại: ${medicine.type?.typeName ?? 'N/A'}'),
                          Text('Hãng: ${medicine.manufacturer ?? 'N/A'}'),
                          if (medicine.speciesUse != null && medicine.speciesUse!.isNotEmpty)
                            Text('Dùng cho: ${medicine.speciesUse}'),
                          if (medicine.expiryDate != null)
                            Text('HSD: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate!)}',
                              style: TextStyle(
                                color: (medicine.expiryDate!.isBefore(DateTime.now())) ? Colors.red : Colors.green[700],
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, medicine);
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