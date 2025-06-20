import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medicine.dart'; // Import model Medicine
import 'package:meow_n_woof/services/medicine_service.dart'; // Import MedicineService
import 'package:meow_n_woof/views/medicine/medicine_detail.dart'; // Đảm bảo đường dẫn này đúng

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thuốc';

  // Thay thế allMedicines tĩnh bằng một Future để lấy dữ liệu từ service
  late Future<List<Medicine>> _medicinesFuture;
  List<Medicine> _allMedicines = []; // Lưu trữ tất cả thuốc đã tải về
  List<Medicine> _filteredMedicines = []; // Danh sách thuốc đã lọc

  final MedicineService _medicineService = MedicineService(); // Khởi tạo service

  @override
  void initState() {
    super.initState();
    _fetchMedicines(); // Gọi hàm để tải thuốc khi khởi tạo widget
  }

  // Hàm tải dữ liệu thuốc từ API
  Future<void> _fetchMedicines() async {
    setState(() {
      _medicinesFuture = _medicineService.fetchAllMedicines();
    });
    try {
      _allMedicines = await _medicinesFuture;
      _filterMedicines(_searchController.text); // Áp dụng bộ lọc ban đầu sau khi tải
    } catch (e) {
      // Xử lý lỗi khi tải dữ liệu (ví dụ: hiển thị thông báo lỗi)
      print('Failed to load medicines: $e');
      setState(() {
        _allMedicines = []; // Đảm bảo danh sách rỗng nếu có lỗi
        _filteredMedicines = [];
      });
    }
  }

  void _filterMedicines(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    final result = _allMedicines.where((med) {
      switch (selectedFilter) {
        case 'Tên thuốc':
          return med.medicineName.toLowerCase().contains(lowerKeyword);
        case 'Loại':
        // Cần kiểm tra type.typeName nếu type là đối tượng MedicineType
          return med.type?.typeName.toLowerCase().contains(lowerKeyword) ?? false;
        case 'Hạn sử dụng':
        // Chuyển đổi DateTime sang chuỗi để so sánh
          return med.expiryDate.toLocal().toString().split(' ')[0].contains(lowerKeyword);
        default:
          return false;
      }
    }).toList();

    setState(() {
      _filteredMedicines = result;
    });
  }

  // Hàm kiểm tra thuốc hết hạn
  bool _isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expirationDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expirationDay.isBefore(today);
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
            child: FutureBuilder<List<Medicine>>(
              future: _medicinesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi khi tải dữ liệu: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: _fetchMedicines,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || _filteredMedicines.isEmpty) {
                  return const Center(child: Text('Không tìm thấy thuốc nào.'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final med = _filteredMedicines[index];
                      final String? imageUrl = med.imageURL;
                      final Widget imageWidget = (imageUrl != null && imageUrl.isNotEmpty)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/logo_bg.png', fit: BoxFit.cover),
                            )
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
                            med.medicineName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                med.type?.typeName ?? 'Chưa cập nhật',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Hạn sử dụng: '),
                                    TextSpan(
                                      text: med.expiryDate.toLocal().toString().split(' ')[0],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isExpired(med.expiryDate) ? Colors.red : Colors.teal[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineDetailPage(medicine: med),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}