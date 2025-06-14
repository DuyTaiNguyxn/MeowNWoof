import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meow_n_woof/models/user.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/services/image_upload_service.dart';
import 'package:meow_n_woof/services/user_service.dart';
import 'package:meow_n_woof/widgets/image_picker_widget.dart'; // Import UserService

class EditUserProfilePage extends StatefulWidget {
  final User userData;

  const EditUserProfilePage({super.key, required this.userData});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _currentAvatarURL;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthController;
  late TextEditingController addressController;

  DateTime? _selectedBirthDate;

  final UserService _userService = UserService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    _currentAvatarURL = widget.userData.avatarURL;
    // Khởi tạo controllers với dữ liệu từ User object
    nameController = TextEditingController(text: widget.userData.fullName);
    emailController = TextEditingController(text: widget.userData.email);
    phoneController = TextEditingController(text: widget.userData.phone);
    addressController = TextEditingController(text: widget.userData.address);

    _selectedBirthDate = widget.userData.birth;
    birthController = TextEditingController(
      text: _selectedBirthDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
          : '',
    );
  }

  Future<void> _pickImage() async {
    final File? pickedImage = await ImagePickerWidget.showImageSourceSelectionSheet(context);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _currentAvatarURL = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null && pickedDate != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = pickedDate;
        birthController.text = DateFormat('dd/MM/yyyy').format(_selectedBirthDate!);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  bool _hasUserDataChanged() {
    // 1. Lấy dữ liệu hiện tại từ các controller và biến
    String newFullName = nameController.text;
    String newEmail = emailController.text;
    String newPhone = phoneController.text;
    String newAddress = addressController.text;
    DateTime? newBirthDate = _selectedBirthDate;
    String? newAvatarUrl = _currentAvatarURL; // Giữ URL hiện tại làm mặc định ban đầu

    // 2. So sánh dữ liệu mới với dữ liệu ban đầu (widget.userData)
    // Để so sánh DateTime, cần kiểm tra cả giá trị và định dạng nếu có.
    bool birthDateChanged = false;
    if (widget.userData.birth == null && newBirthDate != null) {
      birthDateChanged = true;
    } else if (widget.userData.birth != null && newBirthDate == null) {
      birthDateChanged = true;
    } else if (widget.userData.birth != null && newBirthDate != null) {
      // So sánh theo ngày (nếu chỉ quan tâm đến ngày tháng năm)
      birthDateChanged = widget.userData.birth!.year != newBirthDate.year ||
          widget.userData.birth!.month != newBirthDate.month ||
          widget.userData.birth!.day != newBirthDate.day;
      // Hoặc so sánh chi tiết hơn nếu cả giờ/phút/giây cũng quan trọng
      // birthDateChanged = widget.userData.birth != newBirthDate;
    }

    // Kiểm tra xem có ảnh mới được chọn không
    bool selectedImageChanged = _selectedImage != null;

    // Nếu không có _selectedImage, nhưng _currentAvatarURL (URL hiện tại) khác
    // với widget.userData.avatarURL (URL gốc), điều đó cũng có nghĩa là avatar đã thay đổi
    // (ví dụ: người dùng đã xóa ảnh đại diện hoặc thay đổi nó bằng cách khác)
    bool avatarUrlChanged = newAvatarUrl != widget.userData.avatarURL;


    // Kiểm tra tất cả các trường
    bool hasChanges = newFullName != widget.userData.fullName ||
        newEmail != widget.userData.email ||
        newPhone != widget.userData.phone ||
        newAddress != widget.userData.address ||
        birthDateChanged ||
        selectedImageChanged || // Nếu có ảnh mới được chọn, coi như có thay đổi
        avatarUrlChanged;       // Nếu không có ảnh mới nhưng URL khác

    return hasChanges;
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Đang lưu thông tin...');

      String? finalImageUrl = _currentAvatarURL;
      try {
        if (_selectedImage != null) {
          finalImageUrl = await _imageUploadService.uploadImage(
            imageFile: _selectedImage!,
            uploadPreset: 'user_unsigned_upload',
            folder: 'user_images',
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

      User updatedUserData = User(
        employeeId: widget.userData.employeeId,
        username: widget.userData.username,
        fullName: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
        birth: _selectedBirthDate,
        avatarURL: finalImageUrl,
      );
      print('finalImageUrl: $finalImageUrl');
      print('url in updatedUserData: ${updatedUserData.avatarURL}');

      try {
        final User responseUser = await _userService.updateUser(updatedUserData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thông tin thành công')),
        );
        // TRUYỀN ĐỐI TƯỢNG USER ĐÃ CẬP NHẬT TRỞ LẠI
        Navigator.pop(context, responseUser);
      } on SocketException {
        _showSnackBar('Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.');
      } on http.ClientException {
        _showSnackBar('Không thể kết nối đến server. Vui lòng thử lại sau.');
      } catch (e) {
        _showSnackBar('Lỗi khi cập nhật thông tin: ${e.toString()}');
        print('Error updating user(profile): $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (widget.userData.avatarURL != null && widget.userData.avatarURL!.isNotEmpty)
        ? NetworkImage(widget.userData.avatarURL!)
        : const AssetImage('assets/images/avatar.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
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
                  backgroundImage: avatarProvider,
                  child: _selectedImage == null &&
                      (widget.userData.avatarURL == null ||
                          widget.userData.avatarURL!.isEmpty)
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Họ tên', nameController),
              _buildTextField('Email', emailController),
              _buildTextField('Số điện thoại', phoneController, isNumber: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: birthController,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                      (value == null || value.isEmpty) ? 'Vui lòng chọn ngày sinh' : null,
                    ),
                  ),
                ),
              ),
              _buildTextField('Địa chỉ', addressController),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              // Gọi hàm kiểm tra mới
              if (!_hasUserDataChanged()) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không có thông tin nào thay đổi.')),
                );
                return;
              }

              // Nếu có thay đổi, thì gọi hàm _saveUser để xử lý việc lưu
              await _saveUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 6, 25, 81),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Lưu thay đổi',
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
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập $label' : null,
      ),
    );
  }
}