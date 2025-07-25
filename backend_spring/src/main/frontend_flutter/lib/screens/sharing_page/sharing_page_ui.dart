import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import '../../widgets/notification_page.dart';
import '../../widgets/protected_image.dart';

class SharingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharingAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryPurple,
      title: const Text('나눔 품앗이', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
        ),
      ],
    );
  }
}

/// ⭐️ 카테고리 드롭다운 위젯
class SharingCategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const SharingCategoryDropdown({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          style: const TextStyle(
            color: AppTheme.textPurple,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: ['전체', '나눔', '품앗이', '요청'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Jua',
                ),
              ),
            );
          }).toList(),
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }
}

class SharingListItem extends StatefulWidget {
  final SharingItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const SharingListItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onFavoriteTap,
  }) : super(key: key);

  @override
  State<SharingListItem> createState() => _SharingListItemState();
}

class _SharingListItemState extends State<SharingListItem> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.item.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ 여기 반드시 fullImageUrl
    final imageUrl = widget.item.fullImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) ...[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProtectedImage(imageUrl: imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // 글 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(widget.item.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    // ✅ 주소 표시
                    if (widget.item.addressCity.isNotEmpty || widget.item.addressDistrict.isNotEmpty || widget.item.addressDong.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          '주소 : ${widget.item.addressCity} ${widget.item.addressDistrict} ${widget.item.addressDong}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    // 상세/조회수/작성일 등
                    Text(widget.item.details, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // 좋아요 영역
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.thumb_up_off_alt,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${widget.item.likeCount}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SharingActionButtons extends StatelessWidget {
  final VoidCallback onWriteTap;

  const SharingActionButtons({
    Key? key,
    required this.onWriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                print('임시 테스트 버튼 클릭됨');
                onWriteTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('글 작성', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
