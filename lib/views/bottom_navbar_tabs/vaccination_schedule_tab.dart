import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meow_n_woof/views/vaccination_schedule/create_vaccination_schedule.dart';

class VaccinationScheduleTab extends StatefulWidget {
  const VaccinationScheduleTab({super.key});

  @override
  State<VaccinationScheduleTab> createState() => _VaccinationScheduleTabState();
}

class _VaccinationScheduleTabState extends State<VaccinationScheduleTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> allSchedules = [
    {
      'petName': 'Mimi',
      'owner': 'Nguyễn Văn A - 0123456789',
      'vaccine': 'Dại',
      'date': '10/05/2025',
    },
    {
      'petName': 'Tommy',
      'owner': 'Trần Văn C - 0987654321',
      'vaccine': '5 bệnh phổ biến',
      'date': '12/05/2025',
    },
    {
      'petName': 'Luna',
      'owner': 'Phạm Thị E - 0901234567',
      'vaccine': 'Parvo',
      'date': '15/05/2025',
    },
  ];

  List<Map<String, String>> filteredSchedules = [];

  String selectedFilter = 'Tên thú cưng';

  @override
  void initState() {
    super.initState();
    filteredSchedules = List.from(allSchedules);
  }

  void _filterSchedules(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    final result = allSchedules.where((schedule) {
      switch (selectedFilter) {
        case 'Tên thú cưng':
          return schedule['petName']!.toLowerCase().contains(lowerKeyword);
        case 'Chủ nuôi':
          return schedule['owner']!.toLowerCase().contains(lowerKeyword);
        case 'Bệnh tiêm phòng':
          return schedule['vaccine']!.toLowerCase().contains(lowerKeyword);
        case 'Ngày - Giờ':
          return schedule['date']!.toLowerCase().contains(lowerKeyword);
        default:
          return schedule['petName']!.toLowerCase().contains(lowerKeyword) ||
              schedule['owner']!.toLowerCase().contains(lowerKeyword) ||
              schedule['vaccine']!.toLowerCase().contains(lowerKeyword) ||
              schedule['date']!.toLowerCase().contains(lowerKeyword);
      }
    }).toList();

    setState(() {
      filteredSchedules = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSchedules,
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
                        _filterSchedules(_searchController.text);
                      });
                    },
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'Tên thú cưng',
                        checked: selectedFilter == 'Tên thú cưng',
                        child: const Text('Tên thú cưng'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'Chủ nuôi',
                        checked: selectedFilter == 'Chủ nuôi',
                        child: const Text('Chủ nuôi'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'Bệnh tiêm phòng',
                        checked: selectedFilter == 'Bệnh tiêm phòng',
                        child: const Text('Bệnh tiêm phòng'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'Ngày',
                        checked: selectedFilter == 'Ngày',
                        child: const Text('Ngày - Giờ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredSchedules.isEmpty
                  ? Center(child: Text('Không tìm thấy lịch tiêm phòng nào.'))
                  : ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = filteredSchedules[index];

                  return Slidable(
                    key: ValueKey(schedule['petName']! + schedule['date']!),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _confirmDelete(context, schedule, index);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Huỷ',
                        ),
                      ],
                    ),
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
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black), // style mặc định
                                  children: [
                                    const TextSpan(text: '🐾 Tên thú cưng: '),
                                    TextSpan(
                                      text: schedule['petName'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '👤 Chủ nuôi: ${schedule['owner']}',
                                style: TextStyle(
                                    color: Colors.black
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black), // style mặc định
                                  children: [
                                    const TextSpan(text: '💉 Bệnh tiêm phòng: '),
                                    TextSpan(
                                      text: schedule['vaccine'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(text: '📅 Ngày tiêm: '),
                                    TextSpan(
                                      text: schedule['date'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
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
      floatingActionButton: FloatingActionButton( // Add FAB here
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateVaccinationScheduleScreen()),
          );
        },
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, String> appointment, int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận huỷ'),
          content: Text('Bạn có chắc muốn huỷ lịch tiêm của ${appointment['petName']} không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        allSchedules.remove(appointment);
        filteredSchedules.removeAt(index);
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Đã huỷ lịch tiêm của ${appointment['petName']}')),
      );
    }
  }
}
