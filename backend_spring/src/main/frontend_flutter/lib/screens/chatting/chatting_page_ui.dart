import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class ChattingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedMode;  //선택모드 ->  type
  final List<String> modeOptions;
  final ValueChanged<String> onModeSelected;  //나눔, 메시지

  const ChattingAppBar({
    Key? key,
    required this.selectedMode,
    required this.modeOptions,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        '채팅',
        style: TextStyle(color: AppTheme.textPurple, fontWeight: FontWeight.bold),
      ),
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onSelected: onModeSelected,
          itemBuilder: (BuildContext context) {
            return modeOptions.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: AppTheme.textPurple),
                ),
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  selectedMode,
                  style: const TextStyle(
                    color: AppTheme.textPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChattingListItem extends StatelessWidget {
  final int index;
  final String selectedMode;
  final VoidCallback onTap;

  const ChattingListItem({
    Key? key,
    required this.index,
    required this.selectedMode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '제목',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPurple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '내용 요약',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChattingFloatingActionButton extends StatelessWidget {
  final String selectedMode;
  final VoidCallback onPressed;

  const ChattingFloatingActionButton({
    Key? key,
    required this.selectedMode,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryPurple,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}