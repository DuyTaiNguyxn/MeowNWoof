import 'package:flutter/material.dart';
import 'package:meow_n_woof/widgets/popup_menu.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Widget? leading;
  final Widget? action;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.lightBlueAccent,
    this.leading,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.0,
      backgroundColor: backgroundColor,
      leading: leading,
      title: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 6, 25, 81),
              ),
            ),
            const Spacer(),
            action ?? PopupMenuWidget(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
