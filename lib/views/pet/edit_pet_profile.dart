import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/species.dart';
import 'package:meow_n_woof/models/breed.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/services/species_breed_service.dart';
import 'package:meow_n_woof/widgets/image_picker_widget.dart';
import 'package:meow_n_woof/services/image_upload_service.dart';

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

  final PetService _petService = PetService();
  final SpeciesBreedService _speciesBreedService = SpeciesBreedService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;

    _currentImageUrl = pet.imageUrl;

    petNameController = TextEditingController(text: pet.petName);
    ageController = TextEditingController(text: pet.age?.toString() ?? '');
    weightController = TextEditingController(text: pet.weight?.toStringAsFixed(2) ?? '');

    gender = pet.gender;
    _selectedSpeciesId = pet.species?.speciesId;
    _selectedBreedId = pet.breed?.breedId;

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingDropdowns = true;
      _dropdownErrorMessage = null;
    });

    try {
      _availableSpecies = await _speciesBreedService.getSpecies();

      if (_selectedSpeciesId != null) {
        _availableBreeds = await _speciesBreedService.getBreedsBySpeciesId(_selectedSpeciesId!);
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
        print('Đang tải giống cho Species ID: $newSpeciesId');
        _speciesBreedService.getBreedsBySpeciesId(newSpeciesId).then((breeds) {
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

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Đang lưu hồ sơ thú cưng...');

      String? finalImageUrl = _currentImageUrl;
      try {
        if (_selectedImage != null) {
          finalImageUrl = await _imageUploadService.uploadImage(
            imageFile: _selectedImage!,
            uploadPreset: 'pet_unsigned_upload',
            folder: 'pet_images',
          );
          _showSnackBar('Đã tải ảnh mới lên Cloudinary thành công.');
        }
      } on SocketException {
        _showSnackBar('Không có kết nối Internet khi tải ảnh. Vui lòng kiểm tra lại mạng của bạn.');
        return;
      } on http.ClientException catch (e) {
        _showSnackBar('Lỗi kết nối server khi tải ảnh: ${e.message}');
        print('Cloudinary upload error: $e');
        return;
      } catch (e) {
        _showSnackBar('Lỗi khi tải ảnh lên Cloudinary: ${e.toString()}');
        print('Cloudinary upload error: $e');
        return;
      }

      final updatedPet = Pet(
        petId: widget.pet.petId,
        petName: petNameController.text,
        speciesId: _selectedSpeciesId,
        breedId: _selectedBreedId,
        age: int.tryParse(ageController.text),
        gender: gender,
        weight: double.tryParse(weightController.text),
        imageUrl: finalImageUrl,
        ownerId: widget.pet.ownerId,
      );

      try {
        await _petService.updatePet(updatedPet);

        if (mounted) {
          _showSnackBar('Đã cập nhật hồ sơ thú cưng thành công!');
          Navigator.pop(context, true);
        }
      } on SocketException {
        _showSnackBar('Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.');
      } on http.ClientException {
        _showSnackBar('Không thể kết nối đến server. Vui lòng thử lại sau.');
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
                  child: (_selectedImage == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white70)
                      : null,
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

              // Dropdown cho Giống
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

  // Các phương thức _buildTextField và _buildDropdownField giữ nguyên
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