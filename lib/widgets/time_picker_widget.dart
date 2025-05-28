import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class TimePickerWidget extends StatefulWidget {
  final DateTime? timeSelected;
  final Function(DateTime) onTimeSelected;

  const TimePickerWidget({
    Key? key,
    required this.timeSelected,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.timeSelected;
  }

  @override
  void didUpdateWidget(covariant TimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeSelected != widget.timeSelected) {
      setState(() {
        _selectedTime = widget.timeSelected;
      });
    }
  }

  void _showPicker() {
    picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (time) {
        setState(() {
          _selectedTime = time;
        });
        widget.onTimeSelected(time);
      },
      currentTime: _selectedTime ?? DateTime.now(),
      locale: picker.LocaleType.vi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Chọn Giờ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'Chọn giờ...'
                          : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}