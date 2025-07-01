import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/views/vaccination_schedule/create_vaccination_schedule.dart';
import 'package:meow_n_woof/views/vaccination_schedule/vaccination_detail.dart';
import 'package:provider/provider.dart';

import 'package:meow_n_woof/models/vaccination.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';

class VaccinationScheduleTab extends StatefulWidget {
  const VaccinationScheduleTab({super.key});

  @override
  State<VaccinationScheduleTab> createState() => _VaccinationScheduleTabState();
}

class _VaccinationScheduleTabState extends State<VaccinationScheduleTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Vaccination> allVaccinations = [];
  List<Vaccination> filteredVaccinations = [];

  bool _isLoading = true;
  String? _errorMessage;
  String selectedFilter = 'Tên thú cưng';

  late VaccinationService _vaccinationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vaccinationService = Provider.of<VaccinationService>(context, listen: false);
      _fetchVaccinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVaccinations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedVaccinations = await _vaccinationService.getAllVaccinations();
      setState(() {
        allVaccinations = fetchedVaccinations;
        _filterVaccinations(_searchController.text);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterVaccinations(String keyword) {
    final lowerKeyword = keyword.toLowerCase().trim();
    final result = allVaccinations.where((vaccination) {
      final petName = vaccination.pet?.petName.toLowerCase() ?? '';
      final disease = vaccination.diseasePrevented.toLowerCase();
      final dateStr = DateFormat('dd/MM/yyyy').format(vaccination.vaccinationDatetime.toLocal());

      switch (selectedFilter) {
        case 'Tên thú cưng':
          return petName.contains(lowerKeyword);
        case 'Bệnh':
          return disease.contains(lowerKeyword);
        case 'Ngày':
          return dateStr.contains(lowerKeyword);
        default:
          return petName.contains(lowerKeyword) || disease.contains(lowerKeyword) || dateStr.contains(lowerKeyword);
      }
    }).toList();

    result.sort((a, b) {
      if (a.status == 'confirmed' && b.status != 'confirmed') return -1;
      if (a.status != 'confirmed' && b.status == 'confirmed') return 1;
      return a.vaccinationDatetime.compareTo(b.vaccinationDatetime);
    });

    setState(() {
      filteredVaccinations = result;
    });
  }

  Widget _buildStatusRow(String value) {
    String displayText;
    Color? valueColor;

    switch (value) {
      case 'confirmed':
        displayText = 'Đã hẹn';
        valueColor = Colors.blue[800];
        break;
      case 'done':
        displayText = 'Đã tiêm';
        valueColor = Colors.green;
        break;
      case 'overdue':
        displayText = 'Quá hạn';
        valueColor = Colors.red;
        break;
      case 'cancelled':
        displayText = 'Đã huỷ';
        valueColor = Colors.grey[600];
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
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _handleVaccinationClick(Vaccination vaccination) async {
    final bool? hasDataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationDetailPage(vaccination: vaccination),
      ),
    );

    if (hasDataChanged == true) {
      _fetchVaccinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterVaccinations,
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
                      _filterVaccinations(_searchController.text);
                    });
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'Tên thú cưng',
                      checked: selectedFilter == 'Tên thú cưng',
                      child: const Text('Tên thú cưng'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'Bệnh',
                      checked: selectedFilter == 'Bệnh',
                      child: const Text('Bệnh'),
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
                : filteredVaccinations.isEmpty
                ? const Center(child: Text('Không có lịch tiêm nào.'))
                : ListView.builder(
              itemCount: filteredVaccinations.length,
              itemBuilder: (context, index) {
                final vaccination = filteredVaccinations[index];
                return GestureDetector(
                  onTap: () => _handleVaccinationClick(vaccination),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  text: vaccination.pet?.petName ?? 'Không rõ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(text: '💉 Bệnh tiêm phòng: '),
                                TextSpan(
                                  text: vaccination.diseasePrevented,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
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
                                const TextSpan(text: '📅 Ngày tiêm: '),
                                TextSpan(
                                  text: DateFormat('dd/MM/yyyy - HH:mm').format(vaccination.vaccinationDatetime.toLocal()),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatusRow(vaccination.status),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateVaccinationScreen()),
          );
          if (result == true) {
            _fetchVaccinations();
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