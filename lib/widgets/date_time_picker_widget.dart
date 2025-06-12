// File: lib/widgets/date_time_picker_widget.dart (hoặc tên bạn đã đặt)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatefulWidget { // Đổi tên class nếu bạn muốn dùng tên này
  final String label; // Nhãn cho input field
  final DateTime? dateTimeSelected; // Giá trị DateTime hiện tại
  final ValueChanged<DateTime?> onDateTimeSelected; // Callback khi ngày giờ thay đổi

  const DateTimePickerWidget({
    super.key,
    required this.label,
    this.dateTimeSelected, // Có thể null
    required this.onDateTimeSelected, // Bắt buộc
  });

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  final TextEditingController _dateTimeController = TextEditingController();
  DateTime? _internalSelectedDateTime; // Biến nội bộ để quản lý trạng thái

  @override
  void initState() {
    super.initState();
    _internalSelectedDateTime = widget.dateTimeSelected;
    if (_internalSelectedDateTime != null) {
      _dateTimeController.text = DateFormat('dd/MM/yyyy HH:mm').format(_internalSelectedDateTime!);
    }
  }

  @override
  void didUpdateWidget(covariant DateTimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật internalSelectedDateTime nếu giá trị bên ngoài thay đổi
    if (widget.dateTimeSelected != oldWidget.dateTimeSelected) {
      _internalSelectedDateTime = widget.dateTimeSelected;
      _dateTimeController.text = _internalSelectedDateTime != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(_internalSelectedDateTime!)
          : '';
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _internalSelectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _internalSelectedDateTime != null
            ? TimeOfDay.fromDateTime(_internalSelectedDateTime!)
            : TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _internalSelectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text = DateFormat('dd/MM/yyyy HH:mm').format(_internalSelectedDateTime!);
          widget.onDateTimeSelected(_internalSelectedDateTime); // GỌI CALLBACK ĐỂ TRUYỀN GIÁ TRỊ RA NGOÀI
        });
      }
    }
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => _selectDateTime(context),
        child: AbsorbPointer(
          child: TextFormField(
            controller: _dateTimeController,
            decoration: InputDecoration(
              labelText: widget.label, // Sử dụng label từ constructor
              hintText: 'dd/MM/yyyy HH:mm',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: const Icon(Icons.calendar_month),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn ngày và giờ';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}