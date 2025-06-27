import 'package:flutter/material.dart';

import 'notification_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final int unreadCount;
  final Future<void> Function() onReloadNotificationCount;

  const CustomAppBar({
    Key? key,
    required this.onMenuPressed,
    required this.unreadCount,
    required this.onReloadNotificationCount,
  }) : super(key: key);

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
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: unreadCount > 0 ? Colors.amber : Colors.white,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
                await onReloadNotificationCount();
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4, // 더 오른쪽으로
                top: 4,   // 더 위쪽으로
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10, // ✅ 숫자 더 작게
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuPressed,
        ),
      ],
    );
  }
}
