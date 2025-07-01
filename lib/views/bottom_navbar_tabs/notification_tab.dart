import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:meow_n_woof/providers/notification_provider.dart';
import 'package:meow_n_woof/models/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificationsOnce();
    });
  }

  Future<void> _loadNotificationsOnce() async {
    final provider = context.read<NotificationProvider>();
    if (provider.isLoaded) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await provider.loadNotifications(context);
    } catch (e) {
      debugPrint('Lỗi khi tải thông báo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông báo. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    try {
      context.read<NotificationProvider>().clearNotifications();
      context.read<NotificationProvider>().resetLoadedState();
      await context.read<NotificationProvider>().loadNotifications(context);
    } catch (e) {
      debugPrint('Lỗi khi làm mới thông báo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể làm mới thông báo. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return const Center(child: Text('Không có thông báo nào.'));
    }

    final now = DateTime.now();
    final formattedToday = DateFormat('dd/MM/yyyy').format(now);

    final today = _filterByTypes(notifications, [
      NotificationType.todayAppointment,
      NotificationType.todayVaccination,
    ]);
    final upcoming = _filterByTypes(notifications, [
      NotificationType.upcomingAppointment,
      NotificationType.upcomingVaccination,
    ]);
    final expired = _filterByTypes(notifications, [
      NotificationType.expiredMedicine,
    ]);

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (today.isNotEmpty)
            _buildSection('Hôm nay ($formattedToday)', today, context),
          if (upcoming.isNotEmpty) _buildSection('Sắp tới', upcoming, context),
          if (expired.isNotEmpty)
            _buildSection('Thuốc hết hạn', expired, context),
        ],
      ),
    );
  }

  List<NotificationItem> _filterByTypes(List<NotificationItem> list,
      List<NotificationType> types,) {
    return list.where((item) => types.contains(item.type)).toList();
  }

  Widget _buildSection(String title, List<NotificationItem> items,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => _buildNotificationCard(item, context)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey(item.timestamp.toIso8601String() + item.title + item.message),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (_) {
                context.read<NotificationProvider>().removeNotification(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa thông báo.')),
                );
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Xoá',
            ),
          ],
        ),
        child: Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            trailing: Text(
              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item
                  .timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}