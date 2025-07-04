import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WriteSharingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WriteSharingAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryPurple,
      title: const Text('나눔품앗이', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

// 🟣 제목 입력 + 주소 표시 Row
class WriteSharingTitleInputWithAddress extends StatelessWidget {
  final TextEditingController titleController;
  final String addressDisplay;

  const WriteSharingTitleInputWithAddress({
    Key? key,
    required this.titleController,
    required this.addressDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: '제목',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ✅ 주소 읽기전용 표기
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
            ),
            child: Text(
              addressDisplay.isNotEmpty ? addressDisplay : '주소 정보 없음',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Jua',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class WriteSharingCategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const WriteSharingCategoryDropdown({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          dropdownColor: AppTheme.primaryPurple,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          items: ['나눔', '품앗이', '요청'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Jua'),
              ),
            );
          }).toList(),
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }
}

class WriteSharingDetailsInput extends StatelessWidget {
  final TextEditingController detailsController;

  const WriteSharingDetailsInput({Key? key, required this.detailsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: detailsController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: '상세 내용',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class WriteSharingActionButtons extends StatelessWidget {
  final VoidCallback onAttachPhotoPressed;
  final VoidCallback onCompletePressed;

  const WriteSharingActionButtons({
    Key? key,
    required this.onAttachPhotoPressed,
    required this.onCompletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onAttachPhotoPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf9d9e7),
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('사진 첨부'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onCompletePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}
