import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:provider/provider.dart';

class MedicalRecordSelectionWidget extends StatefulWidget {
  final Pet pet;
  final PetMedicalRecord? selectedRecord;

  const MedicalRecordSelectionWidget({
    super.key,
    required this.pet,
    this.selectedRecord,
  });

  @override
  State<MedicalRecordSelectionWidget> createState() => _MedicalRecordSelectionWidgetState();
}

class _MedicalRecordSelectionWidgetState extends State<MedicalRecordSelectionWidget> {
  List<PetMedicalRecord> _allRecords = [];
  List<PetMedicalRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Ngày';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = context.read<MedicalRecordService>();
      final records = await service.getMedicalRecordsByPetId(widget.pet.petId!);

      setState(() {
        _allRecords = records;
        _filteredRecords = List.from(_allRecords);
        _isLoading = false;
      });

      _onSearch(); // Apply filter immediately
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải hồ sơ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.toLowerCase();

    final filtered = _allRecords.where((record) {
      switch (selectedFilter) {
        case 'Ngày':
          final dateStr = DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal());
          return dateStr.toLowerCase().contains(keyword);
        case 'Bác sĩ':
          return record.veterinarian?.fullName.toLowerCase().contains(keyword) ?? false;
        case 'Triệu chứng':
          return record.symptoms?.toLowerCase().contains(keyword) ?? false;
        case 'Chẩn đoán':
          return record.finalDiagnosis?.toLowerCase().contains(keyword) ?? false;
        default:
          return false;
      }
    }).toList();

    setState(() {
      _filteredRecords = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn hồ sơ - ${widget.pet.petName}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      value: 'Ngày',
                      checked: selectedFilter == 'Ngày',
                      child: const Text('Ngày'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Bác sĩ',
                      checked: selectedFilter == 'Bác sĩ',
                      child: const Text('Bác sĩ'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Triệu chứng',
                      checked: selectedFilter == 'Triệu chứng',
                      child: const Text('Triệu chứng'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Chẩn đoán',
                      checked: selectedFilter == 'Chẩn đoán',
                      child: const Text('Chẩn đoán'),
                    ),
                  ],
                )
              ],
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _errorMessage != null
              ? Expanded(
            child: Center(
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          )
              : Expanded(
            child: _filteredRecords.isEmpty
                ? const Center(child: Text('Không có hồ sơ nào.'))
                : ListView.builder(
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];
                final isSelected = widget.selectedRecord?.id == record.id;

                return GestureDetector(
                  onTap: () => Navigator.pop(context, record),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    color: isSelected ? Colors.teal[100] : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📅 Ngày: ${DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal())}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(text: '👨‍⚕️ Bác sĩ thú y: '),
                                TextSpan(
                                  text: record.veterinarian?.fullName ?? 'Không rõ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('🤒 Triệu chứng: ${record.symptoms ?? 'Chưa cập nhật'}'),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(text: '📝 Chẩn đoán: '),
                                TextSpan(
                                  text: record.finalDiagnosis?.isNotEmpty == true
                                      ? record.finalDiagnosis!
                                      : 'Chưa có',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
