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

  // **XÓA CÁC DÒNG KHỞI TẠO CỤC BỘ NÀY:**
  // final PetService _petService = PetService();
  // final SpeciesBreedService _speciesBreedService = SpeciesBreedService();
  // final ImageUploadService _imageUploadService = ImageUploadService();

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

    // **ĐẢM BẢO GỌI _loadDropdownData SAU KHI CONTEXT SẴN SÀNG**
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
      // **TRUY CẬP SpeciesBreedService QUA PROVIDER**
      final speciesBreedService = context.read<SpeciesBreedService>();

      _availableSpecies = await speciesBreedService.getSpecies();

      if (_selectedSpeciesId != null) {
        _availableBreeds = await speciesBreedService.getBreedsBySpeciesId(_selectedSpeciesId!);
        // Kiểm tra lại _selectedBreedId có hợp lệ với loài mới không
        if (!_availableBreeds.any((b) => b.breedId == _selectedBreedId)) {
          _selectedBreedId = null; // Đặt về null nếu giống không thuộc loài mới
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
      _selectedBreedId = null; // Reset giống khi loài thay đổi
      _availableBreeds.clear();
      _dropdownErrorMessage = null;

      if (newSpeciesId != null) {
        _isLoadingDropdowns = true;
        print('Đang tải giống cho Species ID: $newSpeciesId');
        // **TRUY CẬP SpeciesBreedService QUA PROVIDER TRONG HÀM NÀY**
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
        _currentImageUrl = null; // Xóa URL ảnh hiện tại khi chọn ảnh mới
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
          // **TRUY CẬP ImageUploadService QUA PROVIDER**
          final imageUploadService = context.read<ImageUploadService>();
          finalImageUrl = await imageUploadService.uploadImage(
            imageFile: _selectedImage!,
            uploadPreset: 'pet_unsigned_upload',
            folder: 'pet_images',
          );
          print('Đã tải ảnh mới lên Cloudinary thành công.');
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

      final updatedPetData = Pet(
        petId: widget.pet.petId, // Giữ nguyên petId của pet đang chỉnh sửa
        petName: petNameController.text,
        speciesId: _selectedSpeciesId,
        breedId: _selectedBreedId,
        age: int.tryParse(ageController.text),
        gender: gender,
        weight: double.tryParse(weightController.text),
        imageURL: finalImageUrl,
        // Các trường khác như owner, createdAt, updatedAt không cần thiết khi update
        // hoặc bạn có thể muốn lấy chúng từ widget.pet nếu API yêu cầu
        owner: widget.pet.owner, // Giữ lại thông tin owner nếu không chỉnh sửa
        createdAt: widget.pet.createdAt,
        updatedAt: DateTime.now(), // Cập nhật thời gian chỉnh sửa
      );

      try {
        // **TRUY CẬP PetService QUA PROVIDER**
        final petService = context.read<PetService>();
        await petService.updatePet(updatedPetData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin pet thành công!'),
              backgroundColor: Colors.lightGreen,
            ),
          );
          Navigator.pop(context, true); // Báo hiệu đã có thay đổi dữ liệu
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

              // Dropdown cho Giống
              if (_selectedSpeciesId != null) // Chỉ hiển thị nếu đã chọn loài
                _isLoadingDropdowns
                    ? const Center(child: CircularProgressIndicator())
                    : _dropdownErrorMessage != null && _availableBreeds.isEmpty // Hiển thị lỗi nếu không tải được giống
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