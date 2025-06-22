import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/views/vaccination_schedule/edit_vaccination.dart';
import 'package:provider/provider.dart';

import 'package:meow_n_woof/models/vaccination.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';

class VaccinationDetailPage extends StatefulWidget {
  final Vaccination vaccination;

  const VaccinationDetailPage({
    super.key,
    required this.vaccination,
  });

  @override
  State<VaccinationDetailPage> createState() => _VaccinationDetailPageState();
}

class _VaccinationDetailPageState extends State<VaccinationDetailPage> {
  Vaccination? _currentVaccination;
  bool _isLoading = true;
  bool _hasDataChanged = false;

  late VaccinationService _vaccinationService;

  @override
  void initState() {
    super.initState();
    _currentVaccination = widget.vaccination;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vaccinationService = Provider.of<VaccinationService>(context, listen: false);
      _loadVaccinationData();
    });
  }

  Future<void> _loadVaccinationData() async {
    setState(() => _isLoading = true);
    try {
      if (_currentVaccination?.vaccinationId == null) {
        throw Exception('vaccination_id = null. Không thể fetch data.');
      }

      final fetched = await _vaccinationService.getVaccinationById(_currentVaccination!.vaccinationId!);

      if (mounted) setState(() => _currentVaccination = fetched);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải chi tiết lịch tiêm: ${e.toString()}')),
        );
        setState(() => _currentVaccination = null);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
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
        displayText = 'Đã tiêm xong';
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            displayText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelVaccination(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận huỷ?'),
          content: Text('Bạn có chắc muốn huỷ lịch tiêm của ${_currentVaccination?.pet?.petName ?? 'thú cưng này'} không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldCancel != true) return;

    try {
      if (_currentVaccination?.vaccinationId == null) {
        throw Exception('Không thể huỷ lịch tiêm vì không có ID.');
      }

      await _vaccinationService.updateVaccinationStatus(_currentVaccination!.vaccinationId!, 'cancelled');
      setState(() {
        _currentVaccination = _currentVaccination!.copyWith(status: 'cancelled');
        _hasDataChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã huỷ lịch tiêm của ${_currentVaccination?.pet?.petName ?? 'thú cưng'} thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi huỷ lịch tiêm: $e')),
      );
    }
  }

  Future<void> _confirmCompleteVaccination(BuildContext context) async {
    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hoàn tất?'),
          content: Text('Bạn có chắc muốn xác nhận lịch tiêm của ${_currentVaccination?.pet?.petName ?? 'thú cưng này'} đã hoàn tất không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Huỷ',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldComplete != true) return;

    try {
      if (_currentVaccination?.vaccinationId == null) {
        throw Exception('Không thể xác nhận hoàn tất vì không có ID.');
      }

      await _vaccinationService.updateVaccinationStatus(_currentVaccination!.vaccinationId!, 'done');
      setState(() {
        _currentVaccination = _currentVaccination!.copyWith(status: 'done');
        _hasDataChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xác nhận lịch tiêm của ${_currentVaccination?.pet?.petName ?? 'thú cưng'} hoàn tất!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xác nhận lịch tiêm: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch tiêm'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentVaccination == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch tiêm'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: Text('Không thể tải thông tin lịch tiêm. Vui lòng thử lại.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch tiêm - ${_currentVaccination!.pet?.petName}'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _hasDataChanged);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Ngày - Giờ tiêm:',
                      DateFormat('dd/MM/yyyy - HH:mm').format(_currentVaccination!.vaccinationDatetime.toLocal()),
                    ),
                    _buildVaccinationDetailRow('Bệnh tiêm phòng:', _currentVaccination!.diseasePrevented),
                    _buildStatusRow(_currentVaccination!.status),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _currentVaccination!.pet?.imageURL?.isNotEmpty == true
                          ? NetworkImage(_currentVaccination!.pet!.imageURL!)
                          : const AssetImage('assets/images/logo_bg.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thú cưng:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            _currentVaccination!.pet?.petName ?? 'Không rõ',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _currentVaccination!.vaccine?.imageURL?.isNotEmpty == true
                          ? NetworkImage(_currentVaccination!.vaccine!.imageURL!)
                          : const AssetImage('assets/images/logo_bg.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vaccine sử dụng:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            _currentVaccination!.vaccine?.medicineName ?? 'Không rõ',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (_currentVaccination!.status == 'confirmed')
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmCompleteVaccination(context),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Xác nhận đã tiêm', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _currentVaccination == null ? null : () async {
                        final bool? hasUpdated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditVaccinationScreen(vaccination: widget.vaccination),
                          ),
                        );
                        if (hasUpdated == true) {
                          await _loadVaccinationData();
                          _hasDataChanged = true;
                        }
                      },
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      label: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _currentVaccination == null ? null : () => _confirmCancelVaccination(context),
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('Hủy lịch tiêm', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}