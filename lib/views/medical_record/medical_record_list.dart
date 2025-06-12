import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/views/medical_record/create_medical_record.dart';

class MedicalRecordListPage extends StatefulWidget {
  final Pet pet;

  const MedicalRecordListPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<MedicalRecordListPage> createState() => _MedicalRecordListPageState();
}

class _MedicalRecordListPageState extends State<MedicalRecordListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Ngày';

  List<Map<String, String>> allRecords = [
    {
      'date': '2025-05-28',
      'veterinarian': 'Trần Văn B',
      'symptoms': 'Sốt cao, bỏ ăn',
      'diagnosis': 'Viêm họng cấp',
    },
    {
      'date': '2025-05-14',
      'veterinarian': 'Lê Thị C',
      'symptoms': 'Tiêu chảy nhẹ',
      'diagnosis': 'Nhiễm khuẩn đường ruột',
    },
  ];

  List<Map<String, String>> filteredRecords = [];

  @override
  void initState() {
    super.initState();
    filteredRecords = List.from(allRecords);
  }

  void _filterRecords(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    final result = allRecords.where((record) {
      switch (selectedFilter) {
        case 'Ngày':
          return record['date']!.toLowerCase().contains(lowerKeyword);
        case 'Bác sĩ':
          return record['veterinarian']!.toLowerCase().contains(lowerKeyword);
        case 'Triệu chứng':
          return record['symptoms']!.toLowerCase().contains(lowerKeyword);
        case 'Chẩn đoán':
          return record['diagnosis']!.toLowerCase().contains(lowerKeyword);
        default:
          return false;
      }
    }).toList();

    setState(() {
      filteredRecords = result;
    });
  }

  void _confirmDelete(BuildContext context, int index) async {
    final record = filteredRecords[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xoá?'),
          content: Text('Bạn có chắc muốn xoá hồ sơ ngày ${record['date']} không?'),
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
      setState(() {
        allRecords.remove(record);
        filteredRecords.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xoá hồ sơ ngày ${record['date']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ Sơ Khám Bệnh - ${widget.pet.petName}'),
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
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(child: Text('Không có hồ sơ nào.'))
                : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];

                return Slidable(
                  key: ValueKey(record['date']),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(context, index),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xoá',
                      ),
                    ],
                  ),
                  child: Container(
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
                            Text('📅 Ngày: ${record['date']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '👨‍⚕️ Bác sĩ thú y: '),
                                  TextSpan(
                                    text: record['veterinarian'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('🤒 Triệu chứng: ${record['symptoms']}'),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '📝 Chẩn đoán: '),
                                  TextSpan(
                                    text: record['diagnosis'],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMedicalRecordScreen(selectedPet: widget.pet)),
          );
        },
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
