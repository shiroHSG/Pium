import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFde95ba),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/logo2.png',
          height: 100,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white), // 알림 아이콘
          onPressed: () {
            // 알림 아이콘 클릭 시 동작
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // 메뉴 아이콘
          onPressed: () {
            // 메뉴 아이콘 클릭 시 동작
          },
        ),
      ],
    );
  }
}