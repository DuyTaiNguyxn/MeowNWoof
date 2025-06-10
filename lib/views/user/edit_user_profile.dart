import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meow_n_woof/models/user.dart'; // <-- RẤT QUAN TRỌNG: Import model User
import 'package:intl/intl.dart'; // Import intl để định dạng ngày tháng

class EditUserProfilePage extends StatefulWidget {
  // THAY ĐỔI KIỂU DỮ LIỆU TỪ Map<String, dynamic> SANG User
  final User userData;

  const EditUserProfilePage({super.key, required this.userData});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthController; // Để hiển thị và nhập ngày sinh
  late TextEditingController addressController;

  // Biến để lưu trữ DateTime cho ngày sinh, giúp dễ dàng xử lý hơn
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'), // Đảm bảo hiển thị lịch bằng tiếng Việt
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
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

  @override
  Widget build(BuildContext context) {
    final avatarProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
    // Sử dụng widget.userData.avatarURL! để truy cập URL từ User object
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
              // SỬA ĐỔI: Sử dụng GestureDetector để mở DatePicker
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer( // Ngăn không cho bàn phím hiện ra khi chạm vào TextField
                    child: TextFormField(
                      controller: birthController,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng chọn ngày sinh' : null,
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TẠO ĐỐI TƯỢNG USER ĐÃ CẬP NHẬT
                final updatedUser = User(
                  employeeId: widget.userData.employeeId, // Giữ nguyên ID
                  username: widget.userData.username, // Giữ nguyên username
                  fullName: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  birth: _selectedBirthDate, // Sử dụng DateTime đã chọn
                  role: widget.userData.role, // Giữ nguyên vai trò
                  // Xử lý avatarURL: Nếu có _selectedImage mới, sử dụng nó, nếu không giữ nguyên cái cũ
                  avatarURL: _selectedImage != null
                      ? _selectedImage!.path // Đây sẽ là đường dẫn file cục bộ
                      : widget.userData.avatarURL,
                );

                // TODO: Gọi API để lưu updatedUser vào backend
                // Ví dụ: AuthService().updateUser(updatedUser);
                print('User đã cập nhật: ${updatedUser.toJson()}');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu thông tin thành công')),
                );
                // Quay lại trang trước sau khi lưu
                Navigator.pop(context);
              }
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