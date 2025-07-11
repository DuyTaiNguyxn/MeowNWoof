import 'package:flutter/material.dart';
import 'dart:io';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/species.dart';
import 'package:meow_n_woof/models/breed.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/services/species_breed_service.dart';
import 'package:meow_n_woof/widgets/image_picker_widget.dart';
import 'package:meow_n_woof/services/image_upload_service.dart';
import 'package:provider/provider.dart';

class EditPetProfilePage extends StatefulWidget {
  final Pet pet;

  const EditPetProfilePage({super.key, required this.pet});

  @override
  State<EditPetProfilePage> createState() => _EditPetProfilePageState();
}

class _EditPetProfilePageState extends State<EditPetProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _currentImageUrl;

  late TextEditingController petNameController;
  late TextEditingController ageController;
  late TextEditingController weightController;

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
    final pet = widget.pet;

    _currentImageUrl = pet.imageURL;

    petNameController = TextEditingController(text: pet.petName);
    ageController = TextEditingController(text: pet.age?.toString() ?? '');
    weightController = TextEditingController(text: pet.weight?.toStringAsFixed(2) ?? '');

    gender = pet.gender;
    _selectedSpeciesId = pet.species?.speciesId;
    _selectedBreedId = pet.breed?.breedId;

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

      if (_selectedSpeciesId != null) {
        _availableBreeds = await speciesBreedService.getBreedsBySpeciesId(_selectedSpeciesId!);
        if (!_availableBreeds.any((b) => b.breedId == _selectedBreedId)) {
          _selectedBreedId = null;
        }
      } else {
        _availableBreeds = [];
      }

      if (mounted) {
        setState(() {
          _isLoadingDropdowns = false;
        });
      }
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
        print('Đang tải giống cho Species ID: $newSpeciesId');
        final speciesBreedService = context.read<SpeciesBreedService>();
        speciesBreedService.getBreedsBySpeciesId(newSpeciesId).then((breeds) {
          if (mounted) {
            setState(() {
              _availableBreeds = breeds;
              _isLoadingDropdowns = false;
              print('Đã tải ${breeds.length} giống cho Species ID: $newSpeciesId');
              for (var breed in breeds) {
                print('  - Giống: ${breed.breedName} (ID: ${breed.breedId}, Species ID: ${breed.speciesId})');
              }
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _dropdownErrorMessage = error.toString();
              _isLoadingDropdowns = false;
            });
            _showSnackBar('Không tải được giống: ${error.toString()}');
            print('Lỗi khi tải giống: $error');
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
        _currentImageUrl = null;
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

  Future<void> _submitEditPet() async {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Đang lưu hồ sơ thú cưng...');

      String? finalImageUrl = _currentImageUrl;
      try {
        if (_selectedImage != null) {
          final imageUploadService = context.read<ImageUploadService>();
          finalImageUrl = await imageUploadService.uploadImage(
            imageFile: _selectedImage!,
            uploadPreset: 'pet_unsigned_upload',
            folder: 'pet_images',
          );
          print('Đã tải ảnh mới lên Cloudinary thành công.');
        }
      } catch (e) {
        _showSnackBar('Lỗi khi tải ảnh lên Cloudinary: ${e.toString()}');
        print('Cloudinary upload error: $e');
        return;
      }
      if (!mounted) return;

      final updatedPetData = Pet(
        petId: widget.pet.petId,
        petName: petNameController.text,
        speciesId: _selectedSpeciesId,
        breedId: _selectedBreedId,
        age: int.tryParse(ageController.text),
        gender: gender,
        weight: double.tryParse(weightController.text),
        imageURL: finalImageUrl,
        owner: widget.pet.owner,
      );

      try {
        final petService = context.read<PetService>();
        await petService.updatePet(updatedPetData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin pet thành công!'),
              backgroundColor: Colors.lightGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showSnackBar('Lỗi khi cập nhật hồ sơ: ${e.toString()}');
        print('Error updating pet: $e');
      }
    }
  }

  @override
  void dispose() {
    petNameController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider petImageProvider;
    if (_selectedImage != null) {
      petImageProvider = FileImage(_selectedImage!);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      petImageProvider = NetworkImage(_currentImageUrl!);
    } else {
      petImageProvider = const AssetImage('assets/images/logo_bg.png');
    }

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
                  backgroundImage: petImageProvider,
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
                  'Giới tính',
                  gender,
                  ['Đực', 'Cái']
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                      (val) => setState(() => gender = val)),
              _buildTextField('Tuổi (năm)', ageController, isNumber: true),
              _buildTextField('Cân nặng (kg)', weightController, isNumber: true),

              // Dropdown cho Loài
              _isLoadingDropdowns
                  ? const Center(child: CircularProgressIndicator())
                  : _dropdownErrorMessage != null
                  ? Text('Lỗi tải dữ liệu: $_dropdownErrorMessage', style: const TextStyle(color: Colors.red))
                  : _buildDropdownField<int>(
                'Loài',
                _selectedSpeciesId,
                _availableSpecies
                    .map((s) => DropdownMenuItem(value: s.speciesId, child: Text(s.speciesName)))
                    .toList(),
                _onSpeciesChanged,
              ),

              if (_selectedSpeciesId != null)
                _isLoadingDropdowns
                    ? const Center(child: CircularProgressIndicator())
                    : _dropdownErrorMessage != null && _availableBreeds.isEmpty
                    ? Text('Lỗi tải giống: $_dropdownErrorMessage', style: const TextStyle(color: Colors.red))
                    : _buildDropdownField<int>(
                  'Giống',
                  _selectedBreedId,
                  _availableBreeds
                      .map((b) => DropdownMenuItem(value: b.breedId, child: Text(b.breedName)))
                      .toList(),
                      (val) => setState(() => _selectedBreedId = val),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              if (!_hasPetChange()) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không có thông tin nào thay đổi.')),
                );
                return;
              }
              await _submitEditPet();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: const Text(
              'Lưu thay đổi',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasPetChange() {
    final pet = widget.pet;

    if (_selectedImage != null) {
      return true;
    }

    if (petNameController.text != pet.petName) return true;
    if (ageController.text != (pet.age?.toString() ?? '')) return true;
    if (weightController.text != (pet.weight?.toStringAsFixed(2) ?? '')) return true;

    if (gender != pet.gender) return true;

    if (_selectedSpeciesId != pet.species?.speciesId) return true;
    if (_selectedBreedId != pet.breed?.breedId) return true;

    return false;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isRequired = true}) {
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
        ));
  }

  Widget _buildDropdownField<T>(
      String label,
      T? value,
      List<DropdownMenuItem<T>> items,
      void Function(T?)? onChanged,
      ) {
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
        validator: (value) => (value == null) ? 'Vui lòng chọn $label' : null,
      ),
    );
  }
}