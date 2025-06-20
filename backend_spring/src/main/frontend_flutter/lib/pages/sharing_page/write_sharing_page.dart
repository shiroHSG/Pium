import 'package:flutter/material.dart';
import '../../models/sharing_page/sharing_request.dart';
import '../../models/sharing_page/sharing_api_services.dart';
import '../../screens/sharing_page/write_sharing_page_ui.dart';

class WriteSharingPage extends StatefulWidget {
  final String? token;
  final SharingRequest? initialData; // (수정 용도, 기본 null)

  const WriteSharingPage({Key? key, this.token, this.initialData}) : super(key: key);

  @override
  State<WriteSharingPage> createState() => _WriteSharingPageState();
}

class _WriteSharingPageState extends State<WriteSharingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String _selectedCategory = '나눔';
  String? _imgUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!.title;
      _detailsController.text = widget.initialData!.content;
      _selectedCategory = widget.initialData!.category;
      _imgUrl = widget.initialData!.imgUrl;
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목과 내용을 모두 입력하세요.')));
      return;
    }
    setState(() => _isSubmitting = true);

    final request = SharingRequest(
      title: _titleController.text.trim(),
      content: _detailsController.text.trim(),
      category: _selectedCategory,
      imgUrl: _imgUrl,
    );
    print('[WriteSharingPage] widget.token: ${widget.token}');

    bool success = await SharingApiServices.createSharing(
        request: request, token: widget.token ?? '');
    setState(() => _isSubmitting = false);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('등록에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WriteSharingAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  WriteSharingCategoryDropdown(
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(width: 8),
                  WriteSharingTitleInput(titleController: _titleController),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                  child: WriteSharingDetailsInput(detailsController: _detailsController)),
              const SizedBox(height: 12),
              WriteSharingActionButtons(
                onAttachPhotoPressed: () {
                  // 이미지 첨부 기능 필요시 여기에 추가(현재는 미구현)
                },
                onCompletePressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
