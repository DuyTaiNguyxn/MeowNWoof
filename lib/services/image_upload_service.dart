// lib/services/image_upload_service.dart (tên có thể đổi thành generic hơn)
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String CLOUD_NAME = 'dvo63y0r0';

  Future<String> uploadImage({
    required File imageFile,
    required String uploadPreset, // Nhận preset làm tham số
    String? folder, // Thêm tùy chọn thư mục nếu cần
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload');

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset; // Sử dụng preset truyền vào

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder; // Đặt thư mục nếu có
      }

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final result = json.decode(utf8.decode(responseData));

        if (result['secure_url'] != null) {
          return result['secure_url'];
        } else {
          throw Exception('Không tìm thấy URL ảnh trong phản hồi Cloudinary.');
        }
      } else {
        final errorData = await response.stream.toBytes();
        final errorString = utf8.decode(errorData);
        throw Exception('Lỗi khi tải ảnh lên Cloudinary: ${response.statusCode} - $errorString');
      }
    } catch (e) {
      print('Lỗi upload ảnh Cloudinary: $e');
      throw Exception('Không thể tải ảnh lên Cloudinary: $e');
    }
  }
}