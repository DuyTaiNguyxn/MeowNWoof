import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class DateTimePickerWidget extends StatefulWidget {
  final DateTime? dateTimeSelected;
  final Function(DateTime) onDateTimeSelected;

  const DateTimePickerWidget({
    Key? key,
    required this.dateTimeSelected,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.dateTimeSelected != null) {
      _selectedDate = widget.dateTimeSelected;
      _selectedTime = TimeOfDay.fromDateTime(widget.dateTimeSelected!);
    }
  }

  void _combineDateTimeIfReady() {
    if (_selectedDate != null && _selectedTime != null) {
      final combined = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      widget.onDateTimeSelected(combined);
    }
  }

  void _showDatePicker() {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (date) {
        setState(() {
          _selectedDate = date;
        });
        _combineDateTimeIfReady();
      },
      currentTime: _selectedDate ?? DateTime.now(),
      locale: picker.LocaleType.vi,
    );
  }

  void _showTimePicker() {
    picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (time) {
        setState(() {
          _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
        });
        _combineDateTimeIfReady();
      },
      currentTime: _selectedDate ?? DateTime.now(),
      locale: picker.LocaleType.vi,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Chọn ngày...'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

    final timeText = _selectedTime == null
        ? 'Chọn giờ...'
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Chọn Ngày & Giờ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showTimePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      timeText,
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