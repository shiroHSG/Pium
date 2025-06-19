import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: AppTheme.primaryPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, '홈'),
          _buildNavItem(1, Icons.book, '육아일지'),
          _buildNavItem(2, Icons.chat, '채팅'),
          _buildNavItem(3, Icons.group, '커뮤니티'),
          _buildNavItem(4, Icons.person, '마이페이지'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final Color selectedColor = AppTheme.textPurple;
    final Color unselectedColor = Colors.white;

    final Color itemColor = selectedIndex == index ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: itemColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: itemColor,
              fontSize: 12,
              fontFamily: 'Jua',
            ),
          ),
        ],
      ),
    );
  }
}