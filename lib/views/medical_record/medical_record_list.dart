import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/medical_record_service.dart';
import 'package:meow_n_woof/views/medical_record/create_medical_record.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_detail.dart';

class MedicalRecordListPage extends StatefulWidget {
  final Pet selectedPet;

  const MedicalRecordListPage({super.key, required this.selectedPet});

  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Ngày';
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  List<PetMedicalRecord> _allRecords = [];
  List<PetMedicalRecord> _filteredRecords = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('[RecordList] - trc khi fetch - petId: ${widget.selectedPet.petId}');
      final records = await _medicalRecordService.getMedicalRecordsByPetId(widget.selectedPet.petId!);
      print('[RecordList] records received from service: $records');
      setState(() {
        _allRecords = records;
        _filteredRecords = List.from(_allRecords);
        _isLoading = false;
      });
      _filterRecords(_searchController.text);
    } catch (e) {
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

    // THÊM ĐOẠN NÀY ĐỂ XỬ LÝ TRƯỜNG HỢP KHÔNG CÓ TỪ KHÓA TÌM KIẾM
    if (keyword.isEmpty) {
      setState(() {
        _filteredRecords = List.from(_allRecords); // Hiển thị tất cả bản ghi gốc
      });
      return; // Thoát hàm vì không cần lọc
    }

    final result = _allRecords.where((record) {
      switch (selectedFilter) {
        case 'Ngày':
          return record.recordDate.toIso8601String().toLowerCase().contains(lowerKeyword);
        case 'Bác sĩ':
          return record.veterinarian?.fullName?.toLowerCase().contains(lowerKeyword) ?? false;
        case 'Triệu chứng':
          return record.symptoms?.toLowerCase().contains(lowerKeyword) ?? false;
        case 'Chẩn đoán':
          return (record.finalDiagnosis.toLowerCase().contains(lowerKeyword)) ||
              (record.preliminaryDiagnosis?.toLowerCase().contains(lowerKeyword) ?? false);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _filteredRecords = result;
    });
  }

  void _confirmDelete(BuildContext context, PetMedicalRecord recordToDelete) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xoá?'),
          content: Text('Bạn có chắc muốn xoá hồ sơ ngày ${recordToDelete.recordDate.toLocal().toString().split(' ')[0]} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _medicalRecordService.deleteMedicalRecord(recordToDelete.id!);
        setState(() {
          _allRecords.removeWhere((record) => record.id == recordToDelete.id);
          _filteredRecords.removeWhere((record) => record.id == recordToDelete.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xoá hồ sơ ngày ${recordToDelete.recordDate.toLocal().toString().split(' ')[0]}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xoá hồ sơ: ${e.toString()}')),
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
                // print('[RecordList] _filteredRecords: ${record.veterinarian?.fullName}'); // Có thể xóa dòng debug này

                return Slidable(
                  key: ValueKey(record.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(context, record),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xoá',
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalRecordDetailPage(
                            pet: widget.selectedPet,
                            record: record
                          ),
                        ),
                      );
                    },
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
                              Text('🤒 Triệu chứng: ${record.symptoms ?? 'N/A'}'),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(text: '📝 Chẩn đoán ban đầu: '),
                                    TextSpan(
                                      text: record.preliminaryDiagnosis?.isNotEmpty == true
                                          ? record.preliminaryDiagnosis!
                                          : 'Chưa có',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
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
                petId: widget.selectedPet.petId,
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