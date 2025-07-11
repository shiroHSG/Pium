import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_flutter/models/sharing_item.dart';
import 'package:frontend_flutter/models/sharing_page/sharing_api_service.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';
import 'package:frontend_flutter/screens/sharing_page/write_sharing_page_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sharing_page.dart';

class WriteSharingPostPage extends StatefulWidget {
  final bool isEdit;
  final SharingItem? item;

  const WriteSharingPostPage({
    Key? key,
    this.isEdit = false,
    this.item,
  }) : super(key: key);

  @override
  State<WriteSharingPostPage> createState() => _WriteSharingPostPageState();
}

class _WriteSharingPostPageState extends State<WriteSharingPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _selectedImage;
  bool _imageRemoved = false;

  int _selectedIndex = 0;
  bool _isLoggedIn = true;
  String _selectedCategory = '나눔';

  // ✅ 주소정보 변수
  String address = '';
  String get userAddressDisplay => address.isNotEmpty ? address : '주소 정보 없음';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.item != null) {
      _titleController.text = widget.item!.name;
      _detailsController.text = widget.item!.content;
      _selectedCategory = widget.item!.category;
    }
    _fetchMyAddress();
  }

  Future<void> _fetchMyAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/member'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // address: "서울특별시 강남구 역삼동" 이런 형식 그대로 노출!
          address = data['address'] ?? '';
        });
        print('내 주소: $address');
      } else {
        print('주소 불러오기 실패 (status): ${response.statusCode}');
      }
    } catch (e) {
      print('내 주소 불러오기 실패: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLoginStatusChanged(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  void _handleCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCategory = newValue;
      });
    }
  }

  Future<void> _handleAttachPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _imageRemoved = false;
      });
      print('선택된 이미지 경로: ${picked.path}');
    }
  }

  void _handleRemoveImage() {
    setState(() {
      _selectedImage = null;
      _imageRemoved = true;
    });
  }

  Future<void> _handleComplete() async {
    final title = _titleController.text.trim();
    final content = _detailsController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')),
      );
      return;
    }

    try {
      if (widget.isEdit && widget.item != null) {
        await SharingApiService.updateShare(
          id: widget.item!.id,
          title: title,
          content: content,
          category: _selectedCategory,
          imageFile: _imageRemoved ? null : _selectedImage,
        );
      } else {
        await SharingApiService.createShare(
          title: title,
          content: content,
          category: _selectedCategory,
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '글이 수정되었습니다.' : '글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      print('글 등록/수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글 등록/수정에 실패했습니다.')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Row(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleRemoveImage,
            tooltip: '이미지 삭제',
          ),
        ],
      );
    } else if (widget.isEdit && widget.item?.imageUrl != null && !_imageRemoved) {
      return Row(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.item!.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _handleRemoveImage,
            tooltip: '이미지 삭제',
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WriteSharingAppBar(),
      endDrawer: CustomDrawer(
        onItemSelected: _onItemSelected,
        onLoginStatusChanged: _onLoginStatusChanged,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 제목 입력 + 주소 노출
            WriteSharingTitleInputWithAddress(
              titleController: _titleController,
              addressDisplay: userAddressDisplay, // "서울특별시 강남구 역삼동" 식으로 뜸
            ),
            const SizedBox(height: 10),
            WriteSharingCategoryDropdown(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _handleCategoryChanged,
            ),
            const SizedBox(height: 14),
            WriteSharingDetailsInput(detailsController: _detailsController),
            const SizedBox(height: 20),
            _buildImagePreview(),
            WriteSharingActionButtons(
              onAttachPhotoPressed: _handleAttachPhoto,
              onCompletePressed: _handleComplete,
            ),
          ],
        ),
      ),
    );
  }
}
