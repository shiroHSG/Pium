import 'dart:math'; // min 함수
import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/policy/PolicyResponse.dart';
import 'package:frontend_flutter/models/policy/policy_service.dart';
import 'package:frontend_flutter/pages/policy_page/policy_detail_page.dart';

class PolicyPageUI extends StatefulWidget {
  final String dropdownValue;
  final void Function(String) onDropdownChanged;
  final TextEditingController searchController;
  final int currentPage;
  final void Function(int) onPageChanged;

  const PolicyPageUI({
    Key? key,
    required this.dropdownValue,
    required this.onDropdownChanged,
    required this.searchController,
    required this.currentPage,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<PolicyPageUI> createState() => _PolicyPageUIState();
}

class _PolicyPageUIState extends State<PolicyPageUI> {
  List<PolicyResponse> _policies = [];
  bool _isLoading = false;
  int _totalPages = 1;

  // 페이지네이션 블록 변수
  static const int blockSize = 5;

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
  }

  void _fetchPolicies({String? keyword}) async {
    setState(() => _isLoading = true);
    try {
      String sortBy;
      switch (widget.dropdownValue) {
        case '오래된순':
          sortBy = 'oldest';
          break;
        case '인기순':
          sortBy = 'views';
          break;
        default:
          sortBy = 'latest';
      }

      Map<String, dynamic> result;
      if (keyword != null && keyword.isNotEmpty) {
        result = await PolicyService.searchPolicies(
          keyword: keyword,
          page: widget.currentPage,
          size: 10,
        );
      } else {
        result = await PolicyService.fetchPolicies(
          page: widget.currentPage,
          size: 10,
          sortBy: sortBy,
        );
      }

      setState(() {
        _policies = result['content'] ?? [];
        _totalPages = result['totalPages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('정책 데이터 불러오기 실패: $e');
    }
  }

  @override
  void didUpdateWidget(PolicyPageUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dropdownValue != oldWidget.dropdownValue ||
        widget.currentPage != oldWidget.currentPage) {
      _fetchPolicies(keyword: widget.searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 페이지네이션 블록 계산
    int currentBlock = ((widget.currentPage - 1) / blockSize).floor();
    int startPage = currentBlock * blockSize + 1;
    int endPage = min(startPage + blockSize - 1, _totalPages);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      children: [
        // 드롭다운 + 검색창
        Padding(
          padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
          child: Row(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: AppTheme.primaryPurple,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        widget.onDropdownChanged(newValue);
                        _fetchPolicies(keyword: widget.searchController.text);
                      }
                    },
                    items: <String>['최신순', '오래된순', '인기순']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'jua')),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: widget.searchController,
                    decoration: const InputDecoration(
                      hintText: '정책명 또는 내용 검색',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 1),
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textPurple),
                onPressed: () {
                  _fetchPolicies(keyword: widget.searchController.text);
                },
              ),
            ],
          ),
        ),

        // 정책 카드 목록
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _policies.isEmpty
            ? const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('정책이 없습니다.'),
            ))
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _policies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final policy = _policies[index];
            String summary = '';
            try {
              if (policy.content.isNotEmpty) {
                summary = policy.content.length > 60
                    ? '${policy.content.substring(0, 60)}...'
                    : policy.content;
              }
            } catch (e) {
              print('[에러] summary substring에서 예외 발생: $e');
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PolicyDetailPage(policy: policy),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        summary,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('조회수: ${policy.viewCount}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('등록일: ${policy.createdAt.substring(0, 10)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // 페이지네이션 블록 (< 6 7 8 9 10 > 이런식)
        Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (startPage > 1)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    // 이전 블록의 마지막 페이지로 이동
                    int prevBlockPage = startPage - 1;
                    widget.onPageChanged(prevBlockPage);
                    _fetchPolicies(keyword: widget.searchController.text);
                  },
                ),
              ...List.generate(endPage - startPage + 1, (idx) {
                final pageNum = startPage + idx;
                final isSelected = pageNum == widget.currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      widget.onPageChanged(pageNum);
                      _fetchPolicies(keyword: widget.searchController.text);
                    },
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryPurple : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
              if (endPage < _totalPages)
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    int nextBlockPage = endPage + 1;
                    widget.onPageChanged(nextBlockPage);
                    _fetchPolicies(keyword: widget.searchController.text);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
