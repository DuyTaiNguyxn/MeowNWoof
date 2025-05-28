import 'package:flutter/material.dart';

class SelectDateTimePage extends StatefulWidget {
  final String selectedPet;
  final String selectedDoctor;

  SelectDateTimePage({
    required this.selectedPet,
    required this.selectedDoctor,
  });

  @override
  State<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  DateTime? selectedDateTime;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 9, minute: 0),
      );
      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitAppointment() {
    if (selectedDateTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Lịch hẹn cho ${widget.selectedPet} với ${widget.selectedDoctor} lúc $selectedDateTime đã được tạo.'),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chọn ngày giờ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text('Chọn ngày giờ'),
            ),
            if (selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Đã chọn: ${selectedDateTime.toString()}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _submitAppointment,
              icon: Icon(Icons.check),
              label: Text('Xác nhận lịch hẹn'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
