import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/sharing_page/sharing_response.dart';

/// 상단 앱바
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
          onPressed: () {},
        ),
      ],
    );
  }
}

/// 카테고리 드롭다운 위젯
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
              fontWeight: FontWeight.w500),
          items: ['나눔', '품앗이'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Jua'),
              ),
            );
          }).toList(),
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }
}

/// 나눔/품앗이 리스트 아이템 위젯 (카드형)
class SharingListItem extends StatefulWidget {
  final SharingResponse item;
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
  void didUpdateWidget(covariant SharingListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isLiked != widget.item.isLiked) {
      _isFavorited = widget.item.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.item.imgUrl != null && widget.item.imgUrl!.isNotEmpty
                      ? Image.network(
                    widget.item.imgUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFf9d9e7),
                        child: const Center(
                          child: Text('이미지 없음', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: const Color(0xFFf9d9e7),
                    child: const Center(
                      child: Text('제품 이미지', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.item.category,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(widget.item.author,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),
                        const Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text('${widget.item.viewCount}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: AppTheme.primaryPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorited = !_isFavorited;
                      });
                      widget.onFavoriteTap();
                    },
                  ),
                  Text('${widget.item.likeCount}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 액션 버튼(나눔 요청, 글쓰기)
class SharingActionButtons extends StatelessWidget {
  final VoidCallback onRequestTap;
  final VoidCallback onWriteTap;

  const SharingActionButtons({
    Key? key,
    required this.onRequestTap,
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
              onPressed: onRequestTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('나눔 요청하기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onWriteTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('나눔 글 작성', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
