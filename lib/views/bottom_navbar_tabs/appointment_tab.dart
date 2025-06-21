import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:meow_n_woof/views/appointment/create_appointment.dart';
import 'package:meow_n_woof/models/appointment.dart';
import 'package:meow_n_woof/services/appointment_service.dart';
import 'package:meow_n_woof/views/appointment/appointment_detail.dart';

class AppointmentTab extends StatefulWidget {
  const AppointmentTab({super.key});

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Appointment> allAppointments = [];
  List<Appointment> filteredAppointments = [];

  bool _isLoading = true;
  String? _errorMessage;

  String selectedFilter = 'Tên thú cưng';

  late AppointmentService _appointmentService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appointmentService = Provider.of<AppointmentService>(context, listen: false);
      _fetchAppointments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm lấy dữ liệu từ API
  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedAppointments = await _appointmentService.getAllAppointments();
      setState(() {
        allAppointments = fetchedAppointments;
        _filterAppointments(_searchController.text);
      });
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAppointments(String keyword) {
    final lowerKeyword = keyword.toLowerCase().trim();

    final result = allAppointments.where((appointment) {
      final petName = appointment.pet?.petName.toLowerCase() ?? '';
      final veterinarianName = appointment.veterinarian?.fullName.toLowerCase() ?? '';

      final DateTime appointmentDate = appointment.appointmentDatetime.toLocal();
      final String day = DateFormat('dd').format(appointmentDate);
      final String month = DateFormat('MM').format(appointmentDate);
      final String year = DateFormat('yyyy').format(appointmentDate);
      final String fullDate = DateFormat('dd/MM/yyyy').format(appointmentDate);

      switch (selectedFilter) {
        case 'Tên thú cưng':
          return petName.contains(lowerKeyword);
        case 'Bác sĩ thú y':
          return veterinarianName.contains(lowerKeyword);
        case 'Ngày':
          return day.contains(lowerKeyword) ||
              month.contains(lowerKeyword) ||
              year.contains(lowerKeyword) ||
              fullDate.contains(lowerKeyword);
        default:
          return petName.contains(lowerKeyword) ||
              veterinarianName.contains(lowerKeyword) ||
              day.contains(lowerKeyword) ||
              month.contains(lowerKeyword) ||
              year.contains(lowerKeyword) ||
              fullDate.contains(lowerKeyword);
      }
    }).toList();

    result.sort((a, b) {
      if (a.status == 'confirmed' && b.status != 'confirmed') {
        return -1;
      } else if (a.status != 'confirmed' && b.status == 'confirmed') {
        return 1;
      } else {
        return a.appointmentDatetime.compareTo(b.appointmentDatetime);
      }
    });

    setState(() {
      filteredAppointments = result;
    });
  }

  void _handleAppointmentClick(Appointment appointment) async {
    final bool? hasDataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(appointment: appointment),
      ),
    );

    if (hasDataChanged == true) {
      _fetchAppointments();
    }
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
                      value: 'Bác sĩ thú y',
                      checked: selectedFilter == 'Bác sĩ thú y',
                      child: const Text('Bác sĩ thú y'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Ngày',
                      checked: selectedFilter == 'Ngày',
                      child: const Text('Ngày'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text('Lỗi: $_errorMessage'))
                : filteredAppointments.isEmpty
                ? const Center(child: Text('Không tìm thấy lịch khám nào.'))
                : ListView.builder(
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = filteredAppointments[index];

                return GestureDetector(
                  onTap: () => _handleAppointmentClick(appointment),
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
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '🐾 Tên thú cưng: '),
                                  TextSpan(
                                    text: appointment.pet?.petName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '👨‍⚕️ Bác sĩ thú y: '),
                                  TextSpan(
                                    text: appointment.veterinarian?.fullName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  const TextSpan(text: '📅 Ngày - Giờ: '),
                                  TextSpan(
                                    text: DateFormat('dd/MM/yyyy - HH:mm').format(appointment.appointmentDatetime.toLocal()),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusRow(appointment.status),
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
            MaterialPageRoute(builder: (context) => const CreateAppointmentScreen()),
          );
          if (result == true) {
            _fetchAppointments();
          }
        },
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 6.0,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusRow(String value) {
    String displayText;
    Color? valueColor;

    switch (value) {
      case 'confirmed':
        displayText = 'Đã hẹn';
        valueColor = Colors.blue[800];
        break;
      case 'cancelled':
        displayText = 'Đã hủy';
        valueColor = Colors.grey[600];
        break;
      case 'done':
        displayText = 'Đã khám xong';
        valueColor = Colors.green;
        break;
      case 'overdue':
        displayText = 'Đã quá hạn';
        valueColor = Colors.red;
        break;
      default:
        displayText = value;
        valueColor = Colors.black;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          const TextSpan(text: '🔄 Trạng thái: '),
          TextSpan(
            text: displayText,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}