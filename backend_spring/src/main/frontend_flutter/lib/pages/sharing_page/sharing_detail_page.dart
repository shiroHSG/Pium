import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/sharing_item.dart';

import '../../screens/sharing_page/sharing_detail_page_ui.dart';

class SharingDetailPage extends StatelessWidget {
  final SharingItem item;

  const SharingDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SharingDetailPageUI(context, item); // UI 함수 호출
  }
}
