import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePetProfilePage extends StatefulWidget {
  @override
  State<CreatePetProfilePage> createState() => _CreatePetProfilePageState();
}

class _CreatePetProfilePageState extends State<CreatePetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final picker = ImagePicker();

  final TextEditingController petNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController ownerAddressController = TextEditingController();

  String? gender;
  String? speciesId;
  String? breedId;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() => _selectedImage = File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() => _selectedImage = File(pickedFile.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hồ sơ thú cưng'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ảnh thú cưng
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : const AssetImage('assets/images/pet.png') as ImageProvider,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField('Tên thú cưng', petNameController),
              _buildDropdownField(
                label: 'Giới tính',
                value: gender,
                items: ['Đực', 'Cái'],
                onChanged: (val) => setState(() => gender = val),
              ),
              _buildTextField('Tuổi (năm)', ageController, isNumber: true),
              _buildTextField('Cân nặng (kg)', weightController, isNumber: true),

              _buildDropdownField(
                label: 'Loài',
                value: speciesId,
                items: ['Dog', 'Cat', 'Bird'],
                onChanged: (val) => setState(() => speciesId = val),
              ),
              _buildDropdownField(
                label: 'Giống',
                value: breedId,
                items: ['Golden', 'Poodle', 'Persian'],
                onChanged: (val) => setState(() => breedId = val),
              ),

              const Divider(height: 32),
              const Text('Thông tin chủ nuôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              _buildTextField('Tên', ownerNameController),
              _buildTextField('SĐT', ownerPhoneController, isNumber: true),
              _buildTextField('Email', ownerEmailController),
              _buildTextField('Địa chỉ', ownerAddressController),

            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu hồ sơ thú cưng thành công')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 6, 25, 81),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Lưu hồ sơ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => (value == null || value.isEmpty) ? 'Chọn $label' : null,
      ),
    );
  }
}
