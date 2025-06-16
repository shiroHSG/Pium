import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/widgets/custom_drawer.dart';

import '../../screens/policy_page/policy_page_ui.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({Key? key}) : super(key: key);

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  int _selectedIndex = 3;
  int _currentPage = 1;
  String _dropdownValue = '최신순';
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: 탭에 따라 다른 페이지로 이동하는 로직
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: CustomDrawer(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onLoginStatusChanged: (isLoggedIn) {
          // TODO: 로그아웃 처리
        },
      ),
      body: Builder(
        builder: (context) => Column(
          children: [
            // 커스텀 헤더
            Container(
              padding: const EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 8),
              color: AppTheme.primaryPurple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // 본문 스크롤 영역
            Expanded(
              child: PolicyPageUI(
                dropdownValue: _dropdownValue,
                onDropdownChanged: (value) {
                  setState(() {
                    _dropdownValue = value;
                  });
                },
                searchController: _searchController,
                currentPage: _currentPage,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
