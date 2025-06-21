import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/views/appointment/edit_appointment.dart';
import 'package:provider/provider.dart';
import 'package:meow_n_woof/models/appointment.dart';
import 'package:meow_n_woof/services/appointment_service.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailPage({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  Appointment? _currentAppointment;
  bool _isLoading = true;
  bool _hasDataChanged = false;

  late AppointmentService _appointmentService;

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appointmentService = Provider.of<AppointmentService>(context, listen: false);
      _loadAppointmentData();
    });
  }

  Future<void> _loadAppointmentData() async {
    setState(() => _isLoading = true);
    try {
      if (_currentAppointment?.id == null) {
        throw Exception('appointment_id = null. Không thể fetch data.');
      }

      final fetched = await _appointmentService.getAppointmentById(_currentAppointment!.id!);

      if (mounted) setState(() => _currentAppointment = fetched);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải chi tiết lịch khám: ${e.toString()}')),
        );
        setState(() => _currentAppointment = null);
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

  Future<void> _confirmCancelAppointment(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận huỷ?'),
          content: Text('Bạn có chắc muốn huỷ lịch khám của ${_currentAppointment?.pet?.petName ?? 'thú cưng này'} không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Không',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Có',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldCancel != true) return;

    try {
      if (_currentAppointment?.id == null) {
        throw Exception('Không thể huỷ lịch hẹn vì không có ID.');
      }

      await _appointmentService.updateAppointmentStatus(_currentAppointment!.id!, 'cancelled');
      setState(() {
        _currentAppointment = _currentAppointment!.copyWith(status: 'cancelled');
        _hasDataChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã huỷ lịch khám của ${_currentAppointment?.pet?.petName ?? 'thú cưng'} thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi huỷ lịch khám: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch khám'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentAppointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch khám'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(child: Text('Không thể tải thông tin lịch khám. Vui lòng thử lại.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch khám - ${_currentAppointment!.pet?.petName}'),
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
                      'Ngày - Giờ khám:',
                      DateFormat('dd/MM/yyyy - HH:mm').format(_currentAppointment!.appointmentDatetime.toLocal()),
                    ),
                    _buildStatusRow(_currentAppointment!.status),
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
                      backgroundImage: _currentAppointment!.veterinarian?.avatarURL?.isNotEmpty == true
                          ? NetworkImage(_currentAppointment!.veterinarian!.avatarURL!)
                          : const AssetImage('assets/images/avatar.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bác sĩ phụ trách:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            _currentAppointment!.veterinarian?.fullName ?? 'Không rõ',
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
      bottomNavigationBar: (_currentAppointment!.status == 'confirmed')
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
                    onPressed: () async {
                      try {
                        await _appointmentService.updateAppointmentStatus(_currentAppointment!.id!, 'done');
                        setState(() {
                          _currentAppointment = _currentAppointment!.copyWith(status: 'done');
                          _hasDataChanged = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xác nhận lịch khám hoàn tất!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi khi xác nhận lịch khám: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Xác nhận đã khám', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      onPressed: _isLoading || _currentAppointment == null ? null : () async {
                        final bool? hasUpdated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditAppointmentScreen(appointment: widget.appointment),
                          ),
                        );
                        if (hasUpdated == true) {
                          await _loadAppointmentData();
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
                      onPressed: _isLoading || _currentAppointment == null ? null : () => _confirmCancelAppointment(context),
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('Hủy lịch khám', style: TextStyle(color: Colors.white)),
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
