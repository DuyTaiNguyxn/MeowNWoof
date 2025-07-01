import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/medicine.dart';
import 'package:meow_n_woof/models/prescription_item.dart';
import 'package:meow_n_woof/services/prescription_service.dart';
import 'package:meow_n_woof/widgets/medicine_selection_widget.dart';
import 'package:provider/provider.dart';

class AddPrescriptionItemScreen extends StatefulWidget {
  final int prescriptionId;

  const AddPrescriptionItemScreen({super.key, required this.prescriptionId});

  @override
  State<AddPrescriptionItemScreen> createState() => _AddPrescriptionItemScreenState();
}

class _AddPrescriptionItemScreenState extends State<AddPrescriptionItemScreen> {
  final _formKey = GlobalKey<FormState>();

  Medicine? _selectedMedicine;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  bool _isLoading = false;

  late PrescriptionService _prescriptionService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prescriptionService = Provider.of<PrescriptionService>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _navigateToMedicineSelection() async {
    final Medicine? selectedMedicine = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineSelectionWidget(
          selectedMedicine: _selectedMedicine,
          onMedicineSelected: (Medicine medicine) {
            Navigator.pop(context, medicine);
          },
        ),
      ),
    );

    if (selectedMedicine != null) {
      setState(() {
        _selectedMedicine = selectedMedicine;
      });
    }
  }

  Future<void> _submitPrescriptionItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMedicine == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thuốc.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final newPrescriptionItem = PrescriptionItem(
          prescriptionId: widget.prescriptionId,
          medicineId: _selectedMedicine!.medicineId,
          quantity: int.parse(_quantityController.text.trim()),
          dosage: _dosageController.text.trim(),
        );

        await _prescriptionService.addPrescriptionItem(newPrescriptionItem);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm thuốc vào đơn thành công!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('[AddPrescriptionItem] Lỗi thêm thuốc vào đơn: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thêm thuốc vào đơn: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      String? Function(String?)? validator,
      {int maxLines = 1, bool isRequired = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $labelText';
          }
          return null;
        }
            : validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thuốc vào đơn'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(
                    _selectedMedicine == null
                        ? 'Chọn Thuốc'
                        : _selectedMedicine!.medicineName,
                    style: TextStyle(
                      color: _selectedMedicine == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToMedicineSelection,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                _quantityController,
                'Số lượng',
                    (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Số lượng phải là số nguyên dương';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                _dosageController,
                'Liều dùng',
                    (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập liều dùng';
                  }
                  return null;
                },
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _submitPrescriptionItem,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Thêm thuốc vào đơn',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}