import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

import '../../models/baby_profile.dart';

class AddBabyRecordAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCancel;
  final VoidCallback onNotification;
  final VoidCallback onMenu;

  const AddBabyRecordAppBar({
    super.key,
    required this.onCancel,
    required this.onNotification,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryPurple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: onCancel,
      ),
      title: const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: onNotification,
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenu,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BabyNameDropdown extends StatelessWidget {
  final BabyProfile? selectedChild;
  final List<BabyProfile> children;
  final void Function(BabyProfile?) onChanged;

  const BabyNameDropdown({
    super.key,
    required this.selectedChild,
    required this.children,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.primaryPurple,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BabyProfile>(
          isDense: true, // 옵션 (텍스트 높이도 조금 줄어듦)
          isExpanded: true, // ✅ 텍스트가 Container 너비에 맞게 감싸지도록 유지
          value: selectedChild,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: AppTheme.primaryPurple,
          style: const TextStyle(color: Colors.white),
          items: children.map((child) {
            return DropdownMenuItem<BabyProfile>(
              value: child,
              child: Text(child.name ?? '이름 없음',
                overflow: TextOverflow.ellipsis, // ✅ 말줄임표 처리
                maxLines: 1,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PublicPrivateSwitch extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onSwitchChanged;

  const PublicPrivateSwitch({
    super.key,
    required this.isPublic,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isPublic ? '공개' : '비공개',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPurple,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isPublic,
          onChanged: onSwitchChanged,
          activeColor: AppTheme.primaryPurple,
          inactiveTrackColor: Colors.grey[300],
          inactiveThumbColor: Colors.grey[500],
        ),
      ],
    );
  }
}

class TitleInputField extends StatelessWidget {
  final TextEditingController titleController;

  const TitleInputField({super.key, required this.titleController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: titleController,
        decoration: const InputDecoration(
          hintText: '제목을 입력하세요',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class PublicContentInputField extends StatelessWidget {
  final TextEditingController publicContentController;

  const PublicContentInputField({super.key, required this.publicContentController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: publicContentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: '내용을 입력하세요',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class PrivateContentInputField extends StatelessWidget {
  final TextEditingController privateContentController;

  const PrivateContentInputField({super.key, required this.privateContentController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: privateContentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: '내 아이 일기 내용을 입력하세요',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onAttachPhoto;
  final VoidCallback onComplete;

  const ActionButtons({
    super.key,
    required this.onAttachPhoto,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onAttachPhoto,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          ),
          child: const Text(
            '사진 첨부',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          ),
          child: const Text(
            '완료',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}