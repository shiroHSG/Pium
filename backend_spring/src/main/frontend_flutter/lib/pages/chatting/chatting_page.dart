import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({Key? key}) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  String _selectedMode = '나눔/품앗이'; // 기본 선택
  final List<String> _modeOptions = ['나눔/품앗이', '채팅'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            onSelected: (String value) {
              setState(() {
                _selectedMode = value;
              });
              print('선택된 모드: $_selectedMode');
            },
            itemBuilder: (BuildContext context) {
              return _modeOptions.map((String option) {
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
                    _selectedMode,
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
      ),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          color: AppTheme.textPurple,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              print('$_selectedMode 채팅방 $index 클릭됨');
            },
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('새 $_selectedMode 시작');
        },
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}