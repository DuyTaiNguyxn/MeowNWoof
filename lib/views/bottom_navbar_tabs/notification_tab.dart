import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationTab extends StatefulWidget {
  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<NotificationItem> notifications = [
    NotificationItem(
      icon: Icons.pets,
      title: 'Đã tiêm phòng',
      message: 'Bé Mèo nhà bạn vừa được tiêm phòng dại.',
      time: '2 giờ trước',
    ),
    NotificationItem(
      icon: Icons.healing,
      title: 'Lịch khám định kỳ',
      message: 'Đừng quên đưa bé Cún đi khám ngày mai.',
      time: 'Hôm qua',
    ),
    NotificationItem(
      icon: Icons.local_hospital,
      title: 'Kết quả xét nghiệm',
      message: 'Bé Vàng có kết quả xét nghiệm âm tính.',
      time: '3 ngày trước',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notifications.isEmpty
          ? Center(
        child: Text(
          'Không có thông báo nào',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Slidable(
            key: ValueKey(item.title + item.time),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Đã xoá thông báo')),
                    );
                    setState(() {
                      notifications.removeAt(index);
                    });
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Xoá',
                ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.lightBlue[100],
                  child: Icon(item.icon, color: Colors.blueAccent),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.message),
                    const SizedBox(height: 4),
                    Text(item.time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  // Có thể show chi tiết ở đây
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });
}
