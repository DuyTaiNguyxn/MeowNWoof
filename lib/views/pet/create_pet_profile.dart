import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/pet_owner.dart';
import 'package:meow_n_woof/models/species.dart';
import 'package:meow_n_woof/models/breed.dart';
import 'package:meow_n_woof/services/image_upload_service.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/services/species_breed_service.dart';
import 'package:meow_n_woof/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';

class CreatePetProfilePage extends StatefulWidget {
  const CreatePetProfilePage({super.key});

  @override
  State<CreatePetProfilePage> createState() => _CreatePetProfilePageState();
}

class _CreatePetProfilePageState extends State<CreatePetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  final TextEditingController petNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController ownerAddressController = TextEditingController();

  String? gender;
  int? _selectedSpeciesId;
  int? _selectedBreedId;

  List<Species> _availableSpecies = [];
  List<Breed> _availableBreeds = [];
  bool _isLoadingDropdowns = true;
  String? _dropdownErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDropdownData();
    });
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingDropdowns = true;
      _dropdownErrorMessage = null;
    });

    try {
      final speciesBreedService = context.read<SpeciesBreedService>();
      _availableSpecies = await speciesBreedService.getSpecies();
      _availableBreeds = [];
      if (mounted) {
        setState(() {
          _isLoadingDropdowns = false;
        });
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          _dropdownErrorMessage = 'Không có kết nối Internet.';
          _isLoadingDropdowns = false;
        });
      }
      _showSnackBar('Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.');
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          _dropdownErrorMessage = 'Lỗi kết nối server: ${e.message}';
          _isLoadingDropdowns = false;
        });
      }
      _showSnackBar('Không thể kết nối đến server. Vui lòng thử lại sau.');
    } catch (e) {
      if (mounted) {
        setState(() {
          _dropdownErrorMessage = 'Lỗi tải dữ liệu ban đầu: ${e.toString()}';
          _isLoadingDropdowns = false;
        });
      }
      _showSnackBar('Lỗi tải dữ liệu ban đầu: ${e.toString()}');
    }
  }

  void _onSpeciesChanged(int? newSpeciesId) {
    setState(() {
      _selectedSpeciesId = newSpeciesId;
      _selectedBreedId = null;
      _availableBreeds.clear();
      _dropdownErrorMessage = null;

      if (newSpeciesId != null) {
        _isLoadingDropdowns = true;
        final speciesBreedService = context.read<SpeciesBreedService>();
        speciesBreedService.getBreedsBySpeciesId(newSpeciesId).then((breeds) {
          if (mounted) {
            setState(() {
              _availableBreeds = breeds;
              _isLoadingDropdowns = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _dropdownErrorMessage = error.toString();
              _isLoadingDropdowns = false;
            });
          }
          if (error is SocketException) {
            _showSnackBar('Không có kết nối Internet khi tải giống. Vui lòng kiểm tra lại mạng của bạn.');
          } else if (error is http.ClientException) {
            _showSnackBar('Lỗi kết nối server khi tải giống. Vui lòng thử lại sau.');
          } else {
            _showSnackBar('Không tải được giống: ${error.toString()}');
          }
        });
      } else {
        _isLoadingDropdowns = false;
        _availableBreeds = [];
      }
    });
  }

  Future<void> _pickImage() async {
    final File? pickedImage = await ImagePickerWidget.showImageSourceSelectionSheet(context);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _createPet() async {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Đang tạo hồ sơ thú cưng...');

      final newOwner = PetOwner(
        ownerName: ownerNameController.text,
        phone: ownerPhoneController.text,
        email: ownerEmailController.text.isNotEmpty ? ownerEmailController.text : null,
        address: ownerAddressController.text.isNotEmpty ? ownerAddressController.text : null,
      );

      String? imageUrlToSave;
      try {
        if (_selectedImage != null) {
          final imageUploadService = context.read<ImageUploadService>();
          imageUrlToSave = await imageUploadService.uploadImage(
            imageFile: _selectedImage!,
            uploadPreset: 'pet_unsigned_upload',
            folder: 'pet_images',
          );
          print('Đã tải ảnh lên Cloudinary thành công.');
        }
      } catch (e) {
        print('Cloudinary upload error: $e');
        _showSnackBar('Lỗi khi tải ảnh lên Cloudinary: ${e.toString()}');
        return;
      }
      if (!mounted) return;

      final newPet = Pet(
        petName: petNameController.text,
        speciesId: _selectedSpeciesId,
        breedId: _selectedBreedId,
        age: int.tryParse(ageController.text),
        gender: gender,
        weight: double.tryParse(weightController.text),
        imageURL: imageUrlToSave,
        owner: newOwner,
      );

      try {
        final petService = context.read<PetService>();
        await petService.createPet(newPet);

        if (mounted) {
          _showSnackBar('Đã tạo hồ sơ thú cưng thành công!');
          Navigator.pop(context, true);
        }
      } on SocketException {
        _showSnackBar('Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.');
      } on http.ClientException {
        _showSnackBar('Không thể kết nối đến server. Vui lòng thử lại sau.');
      } catch (e) {
        _showSnackBar('Lỗi khi tạo hồ sơ: ${e.toString()}');
        print('Error creating pet: $e');
      }
    }
  }

  @override
  void dispose() {
    petNameController.dispose();
    ageController.dispose();
    weightController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerEmailController.dispose();
    ownerAddressController.dispose();
    super.dispose();
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
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : const AssetImage('assets/images/logo_bg.png') as ImageProvider,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo, size: 30, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField('Tên thú cưng', petNameController),
              _buildDropdownField<String>(
                label: 'Giới tính',
                value: gender,
                items: ['Đực', 'Cái']
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val),
              ),
              _buildTextField('Tuổi (năm)', ageController, isNumber: true),
              _buildTextField('Cân nặng (kg)', weightController, isNumber: true),

              _isLoadingDropdowns
                  ? const Center(child: CircularProgressIndicator())
                  : _dropdownErrorMessage != null
                  ? Text('Lỗi tải dữ liệu: $_dropdownErrorMessage', style: const TextStyle(color: Colors.red))
                  : _buildDropdownField<int>(
                label: 'Loài',
                value: _selectedSpeciesId,
                items: _availableSpecies
                    .map((s) => DropdownMenuItem(value: s.speciesId, child: Text(s.speciesName)))
                    .toList(),
                onChanged: _onSpeciesChanged,
              ),

              if (_selectedSpeciesId != null)
                _isLoadingDropdowns
                    ? const Center(child: CircularProgressIndicator())
                    : _dropdownErrorMessage != null && _availableBreeds.isEmpty
                    ? Text('Lỗi tải giống: $_dropdownErrorMessage', style: const TextStyle(color: Colors.red))
                    : _buildDropdownField<int>(
                  label: 'Giống',
                  value: _selectedBreedId,
                  items: _availableBreeds
                      .map((b) => DropdownMenuItem(value: b.breedId, child: Text(b.breedName)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBreedId = val),
                ),

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
            onPressed: _createPet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text(
              'Tạo hồ sơ',
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

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items,
        onChanged: onChanged,
        validator: (value) => (value == null) ? 'Chọn $label' : null,
      ),
    );
  }
}