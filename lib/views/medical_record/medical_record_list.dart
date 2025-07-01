import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:meow_n_woof/views/medical_record/create_medical_record.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_detail.dart';
import 'package:provider/provider.dart';

class MedicalRecordListPage extends StatefulWidget {
  final Pet selectedPet;

  const MedicalRecordListPage({super.key, required this.selectedPet});

  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Ngày';

  List<PetMedicalRecord> _allRecords = [];
  List<PetMedicalRecord> _filteredRecords = [];

  bool _isLoading = true;
  String? _errorMessage;

  late MedicalRecordService recordService;

  @override
  void initState() {
    super.initState();
    recordService = context.read<MedicalRecordService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedicalRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicalRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final records = await recordService.getMedicalRecordsByPetId(widget.selectedPet.petId!);
      if (mounted) {
        setState(() {
          _allRecords = records;
          _filteredRecords = List.from(_allRecords);
          _isLoading = false;
        });
      }
      _filterRecords(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải hồ sơ bệnh án: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _filterRecords(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    if (keyword.isEmpty) {
      setState(() {
        _filteredRecords = List.from(_allRecords);
      });
      return;
    }

    final result = _allRecords.where((record) {
      switch (selectedFilter) {
        case 'Ngày':
          final formattedDate = DateFormat('dd/MM/yyyy').format(record.recordDate.toLocal());
          return formattedDate.toLowerCase().contains(lowerKeyword);
        case 'Bác sĩ':
          return record.veterinarian?.fullName.toLowerCase().contains(lowerKeyword) ?? false;
        case 'Triệu chứng':
          return record.symptoms?.toLowerCase().contains(lowerKeyword) ?? false;
        case 'Chẩn đoán':
          return (record.finalDiagnosis?.toLowerCase().contains(lowerKeyword) ?? false) ||
              (record.preliminaryDiagnosis?.toLowerCase().contains(lowerKeyword) ?? false);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _filteredRecords = result;
    });
  }

  Future<void> _handleRecordSelect(PetMedicalRecord record) async {
    final bool? hasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalRecordDetailPage(
          pet: widget.selectedPet,
          record: record,
        ),
      ),
    );

    if (hasUpdated == true) {
      await _fetchMedicalRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Danh sách hồ sơ khám bệnh đã được làm mới!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ Sơ Khám Bệnh - ${widget.selectedPet.petName}'),
        centerTitle: true,
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
                    onChanged: _filterRecords,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      _filterRecords(_searchController.text);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _fetchMedicalRecords,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: _filteredRecords.isEmpty
                ? const Center(child: Text('Không có hồ sơ nào.'))
                : ListView.builder(
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];

                return InkWell(
                  onTap: () => _handleRecordSelect(record),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMedicalRecordScreen(
                petId: widget.selectedPet.petId!,
                petName: widget.selectedPet.petName
            )),
          );
          if (result == true) {
            _fetchMedicalRecords();
          }
        },
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}