import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/policy/PolicyResponse.dart';
import 'package:frontend_flutter/models/policy/policy_service.dart';

class PolicyDetailPage extends StatefulWidget {
  final int policyId;

  const PolicyDetailPage({
    Key? key,
    required this.policyId,
  }) : super(key: key);

  @override
  State<PolicyDetailPage> createState() => _PolicyDetailPageState();
}

class _PolicyDetailPageState extends State<PolicyDetailPage> {
  PolicyResponse? policy;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPolicyDetail();
  }

  Future<void> _fetchPolicyDetail() async {
    try {
      final result = await PolicyService.fetchPolicyDetail(widget.policyId);
      setState(() {
        policy = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정책 정보를 불러올 수 없습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '정책 상세정보',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : policy == null
          ? const Center(child: Text('정책 정보를 불러올 수 없습니다.'))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              policy!.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.textPurple,
              ),
            ),
            const SizedBox(height: 16),
            // 등록일, 조회수
            Row(
              children: [
                Text(
                  '등록일: ${policy!.createdAt.substring(0, 10)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Text(
                  '조회수: ${policy!.viewCount}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 본문 내용
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  policy!.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
