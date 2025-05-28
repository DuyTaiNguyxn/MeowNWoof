import 'package:flutter/material.dart';

class DiseasePreventedWidget extends StatefulWidget {
  final String? diseasePrevented;
  final Function(String) onDiseaseChanged;

  const DiseasePreventedWidget({
    Key? key,
    required this.diseasePrevented,
    required this.onDiseaseChanged,
  }) : super(key: key);

  @override
  _DiseasePreventedWidgetState createState() => _DiseasePreventedWidgetState();
}

class _DiseasePreventedWidgetState extends State<DiseasePreventedWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.diseasePrevented ?? '', // Gán giá trị ban đầu từ Provider
    );
  }

  @override
  void didUpdateWidget(covariant DiseasePreventedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu dữ liệu thay đổi, cập nhật lại controller
    if (oldWidget.diseasePrevented != widget.diseasePrevented) {
      _controller.text = widget.diseasePrevented ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: "Nhập bệnh cần tiêm phòng ngừa",
          border: OutlineInputBorder(),
        ),
        onChanged: widget.onDiseaseChanged,
      ),
    );
  }
}