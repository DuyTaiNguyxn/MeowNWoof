import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/services/pet_service.dart'; // Đảm bảo import PetService
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/pet/edit_pet_profile.dart';
import 'package:url_launcher/url_launcher.dart';

// CHUYỂN TỪ StatelessWidget THÀNH StatefulWidget
class PetProfileDetail extends StatefulWidget {
  final int petId; // Chỉ nhận petId
  final String petName;

  const PetProfileDetail({
    super.key,
    required this.petId,
    this.petName = 'Đang tải...',
  });

  @override
  State<PetProfileDetail> createState() => _PetProfileDetailState();
}

class _PetProfileDetailState extends State<PetProfileDetail> {
  final PetService _petService = PetService(); // Khởi tạo PetService
  Pet? _currentPet; // Biến trạng thái để lưu đối tượng Pet đầy đủ
  bool _isLoading = true; // Biến trạng thái để quản lý loading indicator
  bool _hasDataChanged = false;

  @override
  void initState() {
    super.initState();
    _loadPetData(); // Gọi hàm tải dữ liệu khi trang khởi tạo
  }

  // HÀM _loadPetData CỦA BẠN (như bạn yêu cầu)
  Future<void> _loadPetData() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải, hiển thị loading indicator
    });
    try {
      // Gọi service để lấy dữ liệu pet đầy đủ dựa trên petId được truyền vào
      final fetchedPet = await _petService.getPetById(widget.petId);
      if (mounted) { // Đảm bảo widget vẫn còn tồn tại trước khi setState
        setState(() {
          _currentPet = fetchedPet; // Cập nhật pet đầy đủ vào biến trạng thái
        });
      }
    } catch (e) {
      if (mounted) {
        // Xử lý lỗi: hiển thị SnackBar hoặc thông báo trên UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải chi tiết thú cưng: ${e.toString()}')),
        );
        _currentPet = null; // Đặt về null nếu có lỗi tải
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Kết thúc tải
        });
      }
    }
  }

  // Hàm để điều hướng đến trang chỉnh sửa
  Future<void> _navigateToEditPetProfile() async {
    if (_currentPet == null) return; // Đảm bảo pet đã được tải trước khi chỉnh sửa

    final bool? hasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetProfilePage(pet: _currentPet!),
      ),
    );

    if (hasUpdated == true) {
      await _loadPetData();
      _hasDataChanged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = _currentPet?.owner?.ownerName ?? 'Chưa cập nhật';
    final ownerPhone = _currentPet?.owner?.phone ?? 'Chưa cập nhật';
    final ownerEmail = _currentPet?.owner?.email ?? 'Chưa cập nhật';
    final ownerAddress = _currentPet?.owner?.address ?? 'Chưa cập nhật';

    final speciesName = _currentPet?.species?.speciesName ?? 'Chưa cập nhật';
    final breedName = _currentPet?.breed?.breedName ?? 'Chưa cập nhật';

    print('Pet ID: ${widget.petId} (Passed), Current Pet ID: ${_currentPet?.petId} (Loaded)');

    return Scaffold(
      appBar: AppBar(
        // Hiển thị tên pet nếu đã tải xong, hoặc 'Đang tải...' / 'Chi tiết thú cưng'
        title: Text('Chi tiết thú cưng - ${_currentPet?.petName ?? widget.petName}'),
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton( // Thêm nút back tùy chỉnh để kiểm soát giá trị trả về
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Khi nhấn nút back, pop trang và truyền giá trị _hasDataChanged
            Navigator.pop(context, _hasDataChanged);
          },
        ),
      ),
      body: _isLoading // Kiểm tra trạng thái tải
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi đang tải
          : _currentPet == null
          ? const Center(child: Text('Không thể tải thông tin thú cưng.')) // Xử lý trường hợp lỗi tải và _currentPet là null
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPetImage(_currentPet!), // Truyền _currentPet! vào hàm buildPetImage
            const SizedBox(height: 20),
            const Text('Thông tin thú cưng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Tên:', _currentPet!.petName),
            _buildDetailRow('Loài:', speciesName),
            _buildDetailRow('Giống:', breedName),
            _buildDetailRow('Giới tính:', _currentPet!.gender ?? 'Chưa cập nhật'),
            _buildDetailRow('Tuổi:', _currentPet!.age != null ? '${_currentPet!.age} tuổi' : 'Chưa cập nhật'),
            _buildDetailRow('Cân nặng:', _currentPet!.weight != null ? '${_currentPet!.weight!.toStringAsFixed(2)} kg' : 'Chưa cập nhật'),
            const SizedBox(height: 20),
            const Text('Thông tin chủ nuôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow('Họ tên:', ownerName),
            _buildDetailRow('SĐT:', ownerPhone),
            _buildDetailRow('Email:', ownerEmail),
            _buildDetailRow('Địa chỉ:', ownerAddress),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _currentPet == null ? null : _navigateToEditPetProfile, // Disable khi đang tải
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 25, 81),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Cập nhật thông tin',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _currentPet == null // Disable khi đang tải hoặc pet là null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicalRecordListPage(
                              selectedPet: _currentPet!,
                            ), // Truyền _currentPet!
                          ),
                        );
                      },
                      icon: const Icon(Icons.medical_services, color: Colors.white),
                      label: const Text('Hồ sơ khám bệnh', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _currentPet == null // Disable khi đang tải hoặc pet là null
                          ? null
                          : () async {
                        if (ownerPhone.isNotEmpty && ownerPhone != 'Chưa cập nhật') {
                          final phoneUri = Uri(scheme: 'tel', path: ownerPhone);
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không thể mở trình gọi điện')),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Không có số điện thoại để gọi')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text('Gọi chủ nuôi', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm _buildPetImage bây giờ nhận một đối tượng Pet
  Widget _buildPetImage(Pet petToDisplay) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: petToDisplay.imageURL != null && petToDisplay.imageURL!.isNotEmpty
          ? Image.network(petToDisplay.imageURL!, height: 300, width: double.infinity, fit: BoxFit.cover)
          : Image.asset('assets/images/logo_bg.png', height: 300, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Tăng kích thước font cho nhãn
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '(Không có thông tin)',
              style: const TextStyle(
                fontSize: 20, // Tăng kích thước font cho giá trị
              ),
            ),
          ),
        ],
      ),
    );
  }
}