import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/medical_record.dart';
import 'package:meow_n_woof/models/notification_item.dart';
import 'package:meow_n_woof/models/pet.dart';
import 'package:meow_n_woof/models/prescription.dart';
import 'package:meow_n_woof/providers/notification_provider.dart';
import 'package:meow_n_woof/services/medicine_service.dart';
import 'package:meow_n_woof/views/medical_record/medical_record_list.dart';
import 'package:meow_n_woof/views/medicine/medicine_list.dart';
import 'package:meow_n_woof/views/pet/create_pet_profile.dart';
import 'package:meow_n_woof/views/pet/pet_profile_detail.dart';
import 'package:meow_n_woof/views/prescription/prescription_detail.dart';
import 'package:meow_n_woof/views/user/user_profile.dart';
import 'package:meow_n_woof/services/auth_service.dart';
import 'package:meow_n_woof/services/pet_service.dart';
import 'package:meow_n_woof/services/appointment_service.dart';
import 'package:meow_n_woof/services/prescription_service.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';
import 'package:meow_n_woof/widgets/med_record_selection_widget.dart';
import 'package:meow_n_woof/widgets/pet_selection_widget.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Pet> _allPets = [];
  List<Pet> _filteredPets = [];
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Tên thú cưng';

  bool _isLoadingPets = true;
  String? _errorMessage;

  String formatDateTime(DateTime dt, {String locale = 'vi'}) {
    final formatter = DateFormat('HH:mm - dd MMMM, yyyy', locale);
    return formatter.format(dt);
  }
  String formatDate(DateTime dt, {String locale = 'vi'}) {
    final formatter = DateFormat('dd MMMM, yyyy', locale);
    return formatter.format(dt);
  }


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPets();
      _loadTodayNotifications();
      _loadUpcomingNotifications();
      _loadExpiryMedicineNotifications();
    });
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoadingPets = true;
      _errorMessage = null;
    });
    try {
      final petService = context.read<PetService>();
      final pets = await petService.getPets();
      if (mounted) {
        setState(() {
          _allPets = pets;
          _filteredPets = List.from(_allPets);
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingPets = false;
        });
      }
    }
  }

  Future<void> _loadTodayNotifications() async {
    final appointmentService = context.read<AppointmentService>();
    final vaccinationService = context.read<VaccinationService>();
    final notificationProvider = context.read<NotificationProvider>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final appointments = await appointmentService.getAllAppointments();
      final vaccinations = await vaccinationService.getAllVaccinations();

      final appointmentsToday = appointments.where((a) {
        final aDate = a.appointmentDatetime.toLocal();
        return aDate.year == today.year &&
            aDate.month == today.month &&
            aDate.day == today.day &&
            a.status == 'confirmed';
      });

      for (var appt in appointmentsToday) {
        notificationProvider.addNotification(NotificationItem(
          title: 'Lịch khám cho: 🐾 ${appt.pet?.petName}',
          message: 'Khám lúc ${formatDateTime(appt.appointmentDatetime)} với bác sĩ ${appt.veterinarian?.fullName}',
          timestamp: DateTime.now(),
          type: NotificationType.todayAppointment,
        ));
      }

      final vaccinationsToday = vaccinations.where((v) {
        final vDate = v.vaccinationDatetime.toLocal();
        return vDate.year == today.year &&
            vDate.month == today.month &&
            vDate.day == today.day &&
            v.status == 'confirmed';
      });

      for (var vac in vaccinationsToday) {
        notificationProvider.addNotification(NotificationItem(
          title: 'Lịch tiêm cho: 🐾 ${vac.pet?.petName}',
          message: '💉 ${vac.vaccine?.medicineName} lúc ${formatDateTime(vac.vaccinationDatetime)}',
          timestamp: DateTime.now(),
          type: NotificationType.todayVaccination,
        ));
      }
    } catch (e) {
      debugPrint('Lỗi lấy lịch hôm nay: $e');
    }
  }

  Future<void> _loadUpcomingNotifications() async {
    final appointmentService = context.read<AppointmentService>();
    final vaccinationService = context.read<VaccinationService>();
    final notificationProvider = context.read<NotificationProvider>();

    final now = DateTime.now();

    try {
      final appointments = await appointmentService.getAllAppointments();
      final vaccinations = await vaccinationService.getAllVaccinations();

      for (var appt in appointments) {
        if (appt.appointmentDatetime.isAfter(now) && appt.status == 'confirmed') {
          notificationProvider.addNotification(NotificationItem(
            title: 'Lịch khám cho: 🐾 ${appt.pet?.petName}',
            message:
            'Khám lúc ${formatDateTime(appt.appointmentDatetime)} với BS ${appt.veterinarian?.fullName}',
            timestamp: DateTime.now(),
            type: NotificationType.upcomingAppointment,
          ));
        }
      }

      for (var vac in vaccinations) {
        if (vac.vaccinationDatetime.isAfter(now) && vac.status == 'confirmed') {
          notificationProvider.addNotification(NotificationItem(
            title: 'Lịch tiêm cho: 🐾 ${vac.pet?.petName}',
            message:
            '💉 ${vac.vaccine?.medicineName} lúc ${formatDateTime(vac.vaccinationDatetime)}',
            timestamp: DateTime.now(),
            type: NotificationType.upcomingVaccination,
          ));
        }
      }
    } catch (e) {
      debugPrint('[Upcoming Notification] Lỗi: $e');
    }
  }

  Future<void> _loadExpiryMedicineNotifications() async {
    final medicineService = context.read<MedicineService>();
    final notificationProvider = context.read<NotificationProvider>();

    final now = DateTime.now();

    try {
      final medicines = await medicineService.getAllMedicines();

      for (var med in medicines) {
        final expiry = med.expiryDate;
        if (expiry != null && expiry.isBefore(now)) {
          notificationProvider.addNotification(NotificationItem(
            title: '💊 ${med.medicineName}',
            message:
            'đã hết hạn từ ${formatDate(expiry)}',
            timestamp: DateTime.now(),
            type: NotificationType.expiredMedicine,
          ));
        }
      }
    } catch (e) {
      debugPrint('[Expired Medicine Notification] Lỗi: $e');
    }
  }

  Future<void> _handlePetSelect(Pet pet) async {
    final bool? hasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileDetail(
          petId: pet.petId!,
          petName: pet.petName,
        ),
      ),
    );

    if (hasUpdated == true) {
      await _loadPets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Danh sách thú cưng đã được làm mới!')),
        );
      }
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredPets = _allPets.where((pet) {
        final ownerName = pet.owner?.ownerName.toLowerCase() ?? '';
        final ownerPhone = pet.owner?.phone.toLowerCase() ?? '';

        switch (selectedFilter) {
          case 'Tên thú cưng':
            return pet.petName.toLowerCase().contains(keyword);
          case 'Chủ nuôi':
            return ownerName.contains(keyword);
          case 'Số điện thoại':
            return ownerPhone.contains(keyword);
          default:
            return pet.petName.toLowerCase().contains(keyword);
        }
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreatePetProfile() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePetProfilePage()),
    );
    if (result == true) {
      _loadPets();
    }
  }

  void _navigateToCreateMedicalRecord() async {
    final Pet? selectedPet = await Navigator.push<Pet?>(
      context,
      MaterialPageRoute<Pet?>(
        builder: (BuildContext context) {
          return PetSelectionWidget(
            selectedPet: null,
            onPetSelected: (pet) {
              Navigator.pop(context, pet);
            },
          );
        },
      ),
    );

    if (!mounted) return;

    if (selectedPet != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalRecordListPage(
            selectedPet: selectedPet,
          ),
        ),
      );
    }
  }

  void _navigateToCreatePrescriptions() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final prescriptionService = context.read<PrescriptionService>();

    if (authService.currentUser?.role != 'veterinarian') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ bác sĩ mới có thể tạo đơn thuốc.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 1. Chọn thú cưng
      final selectedPet = await Navigator.push<Pet>(
        context,
        MaterialPageRoute(
          builder: (_) => PetSelectionWidget(
            selectedPet: null,
            onPetSelected: (pet) {
              Navigator.pop(context, pet);
            },
          ),
        ),
      );

      if (selectedPet == null) return;

      // 2. Chọn hồ sơ y tế của thú cưng đó
      final selectedRecord = await Navigator.push<PetMedicalRecord>(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalRecordSelectionWidget(pet: selectedPet),
        ),
      );

      if (selectedRecord == null) return;

      final medicalRecordId = selectedRecord.id!;
      final employeeId = authService.currentUser?.employeeId;

      try {
        // 3. Kiểm tra xem đã có đơn thuốc chưa
        final existingPrescription = await prescriptionService.getPrescriptionByRecordId(medicalRecordId);

        // 3a. Nếu có đơn thuốc → chuyển đến chi tiết
        final hasPrescriptionChange = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PrescriptionDetailPage(medicalRecordId: existingPrescription.medicalRecordId),
          ),
        );

        if (hasPrescriptionChange == true) {
          // xử lý cập nhật nếu cần
        }
      } catch (e) {
        // 3b. Nếu chưa có đơn thuốc → tạo mới
        try {
          final newPrescription = Prescription(
            medicalRecordId: medicalRecordId,
            veterinarianId: employeeId!,
            veterinarianNote: '',
            prescriptionDate: DateTime.now(),
          );

          final created = await prescriptionService.createPrescription(newPrescription);

          final hasPrescriptionChange = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PrescriptionDetailPage(medicalRecordId: created.medicalRecordId),
            ),
          );

          if (hasPrescriptionChange == true) {
            // xử lý cập nhật nếu cần
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tạo đơn thuốc mới.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Có thể log nếu cần
      debugPrint('Lỗi khi tạo đơn thuốc: $e');
    }
  }

  void _navigateToMedicineList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineListPage()),
    );
  }

  String _getLocalizedRole(String? role) {
    switch (role) {
      case 'staff':
        return 'Nhân viên y tế';
      case 'veterinarian':
        return 'Bác sĩ thú y';
      default:
        return 'Người dùng';
    }
  }

  Widget _buildUserHeader() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        final userName = currentUser?.fullName ?? 'Guest';
        final userRole = _getLocalizedRole(currentUser?.role);
        final userAvatarUrl = currentUser?.avatarURL;

        print('Thông tin người dùng hiện tại:');
        print('ID: ${currentUser?.employeeId}');
        print('Tên đầy đủ: ${currentUser?.fullName}');
        print('Email: ${currentUser?.email}');
        print('Ngay sinh: ${currentUser?.birth}');
        print('Vai trò: ${currentUser?.role}');
        print('URL Avatar: ${currentUser?.avatarURL}');
        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserProfilePage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                      ? NetworkImage(userAvatarUrl) as ImageProvider<Object>
                      : const AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xin chào,',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userRole,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton(
          Icons.pets,
          'Tạo Hồ sơ Pet',
          Colors.yellowAccent[100]!,
          _navigateToCreatePetProfile,
        ),
        _buildActionButton(
          Icons.medical_services,
          'Tạo Hồ sơ khám bệnh',
          Colors.lightBlueAccent[100]!,
          _navigateToCreateMedicalRecord,
        ),
        _buildActionButton(
          Icons.note_alt,
          'Lên đơn thuốc',
          Colors.greenAccent[100]!,
          _navigateToCreatePrescriptions,
        ),
        _buildActionButton(
          Icons.medication,
          'Tra cứu thuốc',
          Colors.orangeAccent[100]!,
          _navigateToMedicineList,
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 20),
          _buildActionGrid(),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm kiếm hồ sơ pet...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    selectedFilter = value;
                    _onSearch();
                  });
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: 'Tên thú cưng',
                    checked: selectedFilter == 'Tên thú cưng',
                    child: const Text('Tên thú cưng'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'Chủ nuôi',
                    checked: selectedFilter == 'Chủ nuôi',
                    child: const Text('Chủ nuôi'),
                  ),
                  CheckedPopupMenuItem(
                    value: 'Số điện thoại',
                    checked: selectedFilter == 'Số điện thoại',
                    child: const Text('Số điện thoại'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          _isLoadingPets
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: $_errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadPets,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: _filteredPets.isEmpty
                ? const Center(child: Text('Không tìm thấy hồ sơ pet nào.'))
                : ListView.builder(
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                final pet = _filteredPets[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: pet.imageURL != null && pet.imageURL!.isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(pet.imageURL!),
                      radius: 24,
                    )
                        : const Icon(Icons.pets, size: 48),
                    title: Text(
                      pet.petName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${pet.owner?.ownerName ?? 'N/A'} - ${pet.owner?.phone ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onTap: () => _handlePetSelect(pet),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}