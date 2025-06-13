import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meow_n_woof/views/appointment/create_appointment.dart';

class AppointmentTab extends StatefulWidget {
  const AppointmentTab({super.key});

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> allAppointments = [
    {
      'petName': 'Mimi',
      'owner': 'Nguyễn Văn A - 0123456789',
      'veterinarian': 'Trần Thị B',
      'datetime': '20/05/2025 - 10:00',
    },
    {
      'petName': 'Tommy',
      'owner': 'Trần Văn C - 0987654321',
      'veterinarian': 'Lê Văn D',
      'datetime': '21/05/2025 - 14:30',
    },
    {
      'petName': 'Luna',
      'owner': 'Phạm Thị E - 0901234567',
      'veterinarian': 'Nguyễn Văn F',
      'datetime': '22/05/2025 - 09:00',
    },{
      'petName': 'Mimi',
      'owner': 'Nguyễn Văn A - 0123456789',
      'veterinarian': 'Trần Thị B',
      'datetime': '20/05/2025 - 10:00',
    },
  ];

  List<Map<String, String>> filteredAppointments = [];

  String selectedFilter = 'Tên thú cưng';

  @override
  void initState() {
    super.initState();
    filteredAppointments = List.from(allAppointments);
  }

  void _filterAppointments(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    final result = allAppointments.where((appointment) {
      switch (selectedFilter) {
        case 'Tên thú cưng':
          return appointment['petName']!.toLowerCase().contains(lowerKeyword);
        case 'Chủ nuôi':
          return appointment['owner']!.toLowerCase().contains(lowerKeyword);
        case 'Bác sĩ thú y':
          return appointment['veterinarian']!.toLowerCase().contains(lowerKeyword);
        case 'Ngày - Giờ':
          return appointment['datetime']!.toLowerCase().contains(lowerKeyword);
        default:
          return appointment['petName']!.toLowerCase().contains(lowerKeyword) ||
              appointment['owner']!.toLowerCase().contains(lowerKeyword) ||
              appointment['veterinarian']!.toLowerCase().contains(lowerKeyword) ||
              appointment['datetime']!.toLowerCase().contains(lowerKeyword);
      }
    }).toList();

    setState(() {
      filteredAppointments = result;
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
                      onChanged: _filterAppointments,
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
                        _filterAppointments(_searchController.text);
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
                        value: 'Bác sĩ thú y',
                        checked: selectedFilter == 'Bác sĩ thú y',
                        child: const Text('Bác sĩ thú y'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'Ngày - Giờ',
                        checked: selectedFilter == 'Ngày - Giờ',
                        child: const Text('Ngày - Giờ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredAppointments.isEmpty
                  ? Center(child: Text('Không tìm thấy lịch khám nào.'))
                  : ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = filteredAppointments[index];

                  return Slidable(
                    key: ValueKey(appointment['petName']! + appointment['datetime']!),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _confirmDelete(context, appointment, index);
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
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(text: '🐾 Tên thú cưng: '),
                                    TextSpan(
                                      text: appointment['petName'],
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
                                '👤 Chủ nuôi: ${appointment['owner']}',
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(text: '👨‍⚕️ Bác sĩ thú y: '),
                                    TextSpan(
                                      text: appointment['veterinarian'],
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
                                    const TextSpan(text: '📅 Ngày - Giờ: '),
                                    TextSpan(
                                      text: appointment['datetime'],
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
            MaterialPageRoute(builder: (context) => CreateAppointmentScreen()),
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
          title: const Text('Xác nhận huỷ?'),
          content: Text('Bạn có chắc muốn huỷ lịch khám của ${appointment['petName']} không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Không',
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
                'Có',
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
        allAppointments.remove(appointment);
        filteredAppointments.removeAt(index);
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Đã huỷ lịch khám của ${appointment['petName']}')),
      );
    }
  }
}
