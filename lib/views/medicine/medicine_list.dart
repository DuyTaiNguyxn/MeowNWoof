import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/medicine/medicine_detail.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({Key? key}) : super(key: key);

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thuốc';

  final List<Map<String, String>> allMedicines = [
    {
      'name': 'Paravet',
      'type': 'Kháng sinh',
      'expiryDate': '30/12/2025',
      'image': '',
    },
    {
      'name': 'Fipronil Spray',
      'type': 'Trị ve rận',
      'expiryDate': '15/08/2024',
      'image': '',
    },
    {
      'name': 'Vaccine ABC',
      'type': 'Vaccine',
      'expiryDate': '01/01/2026',
      'image': '',
    },
  ];

  List<Map<String, String>> filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    filteredMedicines = List.from(allMedicines);
  }

  void _filterMedicines(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    final result = allMedicines.where((med) {
      switch (selectedFilter) {
        case 'Tên thuốc':
          return med['name']!.toLowerCase().contains(lowerKeyword);
        case 'Loại':
          return med['type']!.toLowerCase().contains(lowerKeyword);
        case 'Hạn sử dụng':
          return med['expiryDate']!.toLowerCase().contains(lowerKeyword);
        default:
          return false;
      }
    }).toList();

    setState(() {
      filteredMedicines = result;
    });
  }

  bool _isExpired(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;

    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final expiryDate = DateTime(year, month, day);
      final now = DateTime.now();

      return expiryDate.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thuốc'),
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
                    onChanged: _filterMedicines,
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
                      _filterMedicines(_searchController.text);
                    });
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'Tên thuốc',
                      checked: selectedFilter == 'Tên thuốc',
                      child: const Text('Tên thuốc'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Loại',
                      checked: selectedFilter == 'Loại',
                      child: const Text('Loại'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Hạn sử dụng',
                      checked: selectedFilter == 'Hạn sử dụng',
                      child: const Text('Hạn sử dụng'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredMedicines.isEmpty
                ? const Center(child: Text('Không tìm thấy thuốc nào.'))
                : ListView.builder(
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final med = filteredMedicines[index];
                final imageWidget = (med['image'] != null && med['image']!.isNotEmpty)
                    ? Image.network(med['image']!, fit: BoxFit.cover)
                    : Image.asset('assets/images/logo_bg.png', fit: BoxFit.cover);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: imageWidget,
                      ),
                    ),
                    title: Text(
                      med['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Loại: ${med['type']}'),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              const TextSpan(text: 'Hạn sử dụng: '),
                              TextSpan(
                                text: med['expiryDate'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isExpired(med['expiryDate']) ? Colors.red : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetailPage(
                            name: 'Paravet',
                            description: 'Thuốc trị nhiễm khuẩn hiệu quả cho chó mèo.',
                            type: 'Kháng sinh',
                            unit: 'Viên',
                            speciesUse: 'Chó, Mèo',
                            stockQuantity: 50,
                            receiptDate: DateTime(2023, 12, 10),
                            expiryDate: DateTime(2024, 12, 30),
                            manufacturer: 'Vemedim',
                            price: 25000,
                            imageUrl: '',
                          ),
                        ),
                      );
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