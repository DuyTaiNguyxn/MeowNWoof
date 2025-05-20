import 'package:flutter/material.dart';
import 'package:meow_n_woof/views/bottom_navbar_tabs/appointment_tab.dart';
import 'package:meow_n_woof/views/bottom_navbar_tabs/home_tab.dart';
import 'package:meow_n_woof/views/bottom_navbar_tabs/vaccination_schedule_tab.dart';
import 'package:meow_n_woof/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeTab(),
    AppointmentTab(),
    VaccinationScheduleTab(),
    Center(child: Text('Thông báo')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Meow & Woof',
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Lịch khám',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines),
            label: 'Lịch tiêm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }
}
