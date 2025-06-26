enum NotificationType {
  todayAppointment,
  upcomingAppointment,
  todayVaccination,
  upcomingVaccination,
  expiredMedicine,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}
