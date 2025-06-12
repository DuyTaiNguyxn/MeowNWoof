import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImagePickerWidget {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<File?> showImageSourceSelectionSheet(BuildContext context) async {
    // Nếu chúng không static, bạn cần khởi tạo một instance:
    final ImagePickerWidget ipwidget = ImagePickerWidget();

    return showModalBottomSheet<File?>( // <-- Đảm bảo kiểu trả về là File?
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () async {
                  final File? image = await ipwidget.pickImageFromCamera(); // Chụp ảnh
                  Navigator.pop(bc, image); // <-- Truyền ảnh trực tiếp khi đóng bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  final File? image = await ipwidget.pickImageFromGallery(); // Chọn ảnh
                  Navigator.pop(bc, image); // <-- Truyền ảnh trực tiếp khi đóng bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }
}