import 'package:flutter/material.dart';
import 'package:meow_n_woof/models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  void addNotification(NotificationItem item) {
    _notifications.add(item);
    notifyListeners();
  }

  void removeNotification(NotificationItem item) {
    _notifications.remove(item);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}