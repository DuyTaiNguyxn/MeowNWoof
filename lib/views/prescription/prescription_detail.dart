import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meow_n_woof/models/prescription.dart';
import 'package:meow_n_woof/services/prescription_service.dart';
import 'package:meow_n_woof/views/prescription/add_prescription_item.dart';
import 'package:provider/provider.dart';

class PrescriptionDetailPage extends StatefulWidget {
  final int medicalRecordId;

  const PrescriptionDetailPage({super.key, required this.medicalRecordId});

  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  Prescription? _prescription;
  bool _isLoading = true;
  bool _isEditingNote = false;
  late TextEditingController _noteController;
  late PrescriptionService _prescriptionService;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _prescriptionService = Provider.of<PrescriptionService>(context, listen: false);
      await _fetchPrescription();
    });
  }

  Future<void> _fetchPrescription() async {
    try {
      final data = await _prescriptionService.getPrescriptionByRecordId(widget.medicalRecordId);
      if (mounted) {
        setState(() {
          _prescription = data;
          _noteController.text = _prescription?.veterinarianNote ?? 'Không có';
        });
      }
    } catch (_) {
      setState(() => _prescription = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNote() async {
    if (_prescription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có đơn thuốc để cập nhật.')),
      );
      return;
    }

    try {
      final updatedPrescription = _prescription!.copyWith(
        veterinarianNote: _noteController.text,
      );

      await _prescriptionService.updatePrescription(updatedPrescription);

      if(!mounted) return;

      setState(() {
        _prescription = updatedPrescription;
        _isEditingNote = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật ghi chú')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
    }
  }

  void _onRemove(int itemId, String medicineName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá thuốc?'),
        content: Text('Bạn có chắc muốn xoá "$medicineName" khỏi đơn thuốc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      try {
        await _prescriptionService.removePrescriptionItem(itemId);
        if (!mounted) return;
        setState(() {
          _prescription!.items!.removeWhere((i) => i.itemId == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xoá "$medicineName"')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xoá: $e')),
        );
      }
    }
  }

  Future<void> _onDelete(int prescriptionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá thuốc?'),
        content: Text('Bạn có chắc muốn xoá đơn thuốc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      try {
        await _prescriptionService.deleteAllItemsByPrescriptionId(prescriptionId);
        await _prescriptionService.deletePrescription(prescriptionId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá đơn thuốc')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xoá: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _prescription?.items?.isEmpty ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn thuốc'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescription == null
          ? const Center(child: Text('Không tìm thấy đơn thuốc.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Ghi chú của bác sĩ:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (!_isEditingNote)
                              IconButton(
                                onPressed: () {
                                  setState(() => _isEditingNote = true);
                                },
                                icon: const Icon(Icons.edit, size: 20),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isEditingNote
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _noteController,
                                      autofocus: true,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập ghi chú...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _updateNote,
                                    icon: const Icon(Icons.check, color: Colors.green),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _noteController.text = _prescription?.veterinarianNote ?? '';
                                        _isEditingNote = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close, color: Colors.red),
                                  ),
                                ],
                              )
                            : Text(
                                _prescription?.veterinarianNote != null && _prescription!.veterinarianNote!.isNotEmpty
                                    ? _prescription!.veterinarianNote!
                                    : 'Không có',
                                style: const TextStyle(fontSize: 20, color: Colors.black87),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ..._prescription!.items!.map(
                  (item) => Slidable(
                key: ValueKey(item.itemId),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _onRemove(item.itemId!, item.medicineName ?? 'không rõ'),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Xoá',
                    ),
                  ],
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: item.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
                    )
                        : Image.asset('assets/images/logo_bg.png', width: 48, height: 48),
                    title: Text(item.medicineName ?? 'Tên thuốc không rõ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                            children: [
                              const TextSpan(text: 'Số lượng: '),
                              TextSpan(
                                text: '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                            children: [
                              const TextSpan(text: 'Liều dùng: '),
                              TextSpan(
                                text: item.dosage,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          ],
        ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isEmpty
              ? ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPrescriptionItemScreen(
                    prescriptionId: _prescription!.prescriptionId!,
                  ),
                ),
              );
              if (result == true) {
                await _fetchPrescription();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Thêm thuốc điều trị', style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
              : Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPrescriptionItemScreen(
                          prescriptionId: _prescription!.prescriptionId!,
                        ),
                      ),
                    );
                    if (result == true) {
                      await _fetchPrescription();
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Thêm thuốc', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _onDelete(_prescription!.prescriptionId!);
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Xoá đơn thuốc', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
