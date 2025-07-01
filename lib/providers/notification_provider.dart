import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/models/notification_item.dart';
import 'package:meow_n_woof/services/appointment_service.dart';
import 'package:meow_n_woof/services/medicine_service.dart';
import 'package:meow_n_woof/services/vaccination_service.dart';
import 'package:provider/provider.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _isLoaded = false;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoaded => _isLoaded;

  void addNotification(NotificationItem item) {
    _notifications.add(item);
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  void removeNotification(NotificationItem item) {
    _notifications.removeWhere((n) => n.timestamp == item.timestamp && n.title == item.title && n.message == item.message);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void markLoaded() {
    _isLoaded = true;
  }

  void resetLoadedState() {
    _isLoaded = false;
  }

  Future<void> loadNotifications(BuildContext context) async {
    if (_isLoaded) {
      clearNotifications();
    }

    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    final vaccinationService = Provider.of<VaccinationService>(context, listen: false);
    final medicineService = Provider.of<MedicineService>(context, listen: false);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final appointments = await appointmentService.getAllAppointments();
      final vaccinations = await vaccinationService.getAllVaccinations();
      final medicines = await medicineService.getAllMedicines();

      final appointmentsToday = appointments.where((a) {
        final aDate = a.appointmentDatetime.toLocal();
        return a.status == 'confirmed' &&
            aDate.year == today.year &&
            aDate.month == today.month &&
            aDate.day == today.day;
      });
      for (var appt in appointmentsToday) {
        addNotification(NotificationItem(
          title: 'Lịch khám cho: 🐾 ${appt.pet?.petName ?? 'Thú cưng của bạn'}',
          message: 'Khám lúc ${formatDateTime(appt.appointmentDatetime)} với bác sĩ ${appt.veterinarian?.fullName ?? 'không rõ'}.',
          timestamp: appt.appointmentDatetime,
          type: NotificationType.todayAppointment,
        ));
      }

      final vaccinationsToday = vaccinations.where((v) {
        final vDate = v.vaccinationDatetime.toLocal();
        return v.status == 'confirmed' &&
            vDate.year == today.year &&
            vDate.month == today.month &&
            vDate.day == today.day;
      });
      for (var vac in vaccinationsToday) {
        addNotification(NotificationItem(
          title: 'Lịch tiêm cho: 🐾 ${vac.pet?.petName ?? 'Thú cưng của bạn'}',
          message: '💉 ${vac.vaccine?.medicineName ?? 'Thuốc'} lúc ${formatDateTime(vac.vaccinationDatetime)}.',
          timestamp: vac.vaccinationDatetime,
          type: NotificationType.todayVaccination,
        ));
      }

      final appointmentsUpcoming = appointments.where((a) =>
      a.status == 'confirmed' && a.appointmentDatetime.isAfter(today.add(const Duration(days: 1))));
      for (var appt in appointmentsUpcoming) {
        addNotification(NotificationItem(
          title: 'Lịch khám sắp tới cho: 🐾 ${appt.pet?.petName ?? 'Thú cưng của bạn'}',
          message: 'Khám lúc ${formatDateTime(appt.appointmentDatetime)} với BS ${appt.veterinarian?.fullName ?? 'không rõ'}.',
          timestamp: appt.appointmentDatetime,
          type: NotificationType.upcomingAppointment,
        ));
      }

      final vaccinationsUpcoming = vaccinations.where((v) =>
      v.status == 'confirmed' && v.vaccinationDatetime.isAfter(today.add(const Duration(days: 1))));
      for (var vac in vaccinationsUpcoming) {
        addNotification(NotificationItem(
          title: 'Lịch tiêm sắp tới cho: 🐾 ${vac.pet?.petName ?? 'Thú cưng của bạn'}',
          message: '💉 ${vac.vaccine?.medicineName ?? 'Thuốc'} lúc ${formatDateTime(vac.vaccinationDatetime)}.',
          timestamp: vac.vaccinationDatetime,
          type: NotificationType.upcomingVaccination,
        ));
      }

      for (var med in medicines) {
        final expiry = med.expiryDate;
        if (expiry != null && expiry.isBefore(now)) {
          addNotification(NotificationItem(
            title: '💊 ${med.medicineName}',
            message: 'đã hết hạn từ ${formatDate(expiry)}.',
            timestamp: expiry,
            type: NotificationType.expiredMedicine,
          ));
        }
      }
      markLoaded();
    } catch (e) {
      debugPrint('Lỗi khi tải thông báo: $e');
    }
  }

  String formatDateTime(DateTime dt, {String locale = 'vi'}) {
    return DateFormat('HH:mm - dd/MM/yyyy', locale).format(dt.toLocal());
  }

  String formatDate(DateTime dt, {String locale = 'vi'}) {
    return DateFormat('dd/MM/yyyy', locale).format(dt.toLocal());
  }
}