import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:meow_n_woof/models/pet.dart';

class EditPetProfilePage extends StatefulWidget {
  final Pet pet;

  const EditPetProfilePage({super.key, required this.pet});

  @override
  State<EditPetProfilePage> createState() => _EditPetProfilePageState();
}

class _EditPetProfilePageState extends State<EditPetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final picker = ImagePicker();

  late TextEditingController petNameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController ownerNameController;
  late TextEditingController ownerPhoneController;
  late TextEditingController ownerEmailController;
  late TextEditingController ownerAddressController;

  String? gender;
  String? speciesId;
  String? breedId;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    if (widget.pet.imageUrl != null && widget.pet.imageUrl.startsWith('/')) {
      _selectedImage = File(widget.pet.imageUrl);
    }
    petNameController = TextEditingController(text: pet.name);
    ageController = TextEditingController(text: pet.age.toString() ?? '');
    weightController = TextEditingController(text: pet.weight.toString() ?? '');
    ownerNameController = TextEditingController(text: pet.ownerName);
    ownerPhoneController = TextEditingController(text: pet.ownerPhone);
    ownerEmailController = TextEditingController(text: pet.ownerEmail ?? '');
    ownerAddressController = TextEditingController(text: pet.ownerAddress ?? '');
    gender = pet.gender;
    speciesId = pet.species ?? '';
    breedId = pet.breed ?? '';
  }

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

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      // final updatedPet = widget.pet.copyWith(
      //   name: petNameController.text,
      //   gender: gender!,
      //   age: ageController.text,
      //   weight: weightController.text,
      //   speciesId: speciesId!,
      //   breedId: breedId!,
      //   ownerName: ownerNameController.text,
      //   ownerPhone: ownerPhoneController.text,
      //   ownerEmail: ownerEmailController.text,
      //   ownerAddress: ownerAddressController.text,
      //   image: _selectedImage,
      // );

      // TODO: Gửi updatedPet lên server hoặc xử lý tiếp
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hồ sơ thú cưng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ thú cưng'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              _buildDropdownField('Giới tính', gender, ['Đực', 'Cái'], (val) => setState(() => gender = val)),
              _buildTextField('Tuổi (năm)', ageController, isNumber: true),
              _buildTextField('Cân nặng (kg)', weightController, isNumber: true),

              _buildDropdownField('Loài', speciesId, ['Dog', 'Cat', 'Bird'], (val) => setState(() => speciesId = val)),
              _buildDropdownField('Giống', breedId, ['Golden', 'Poodle', 'Persian'], (val) => setState(() => breedId = val)),

              const Divider(height: 32),
              const Text('Thông tin chủ nuôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              _buildTextField('Tên', ownerNameController),
              _buildTextField('SĐT', ownerPhoneController, isNumber: true),
              _buildTextField('Email', ownerEmailController, isRequired: false),
              _buildTextField('Địa chỉ', ownerAddressController, isRequired: false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _savePet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 6, 25, 81),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: isRequired
            ? (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập $label' : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      List<String> items,
      void Function(String?) onChanged,
      ) {
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
