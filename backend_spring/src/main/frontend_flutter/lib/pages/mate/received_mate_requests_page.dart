import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/models/mate/mate_api.dart';

class ReceivedMateRequestsPage extends StatefulWidget {
  const ReceivedMateRequestsPage({Key? key}) : super(key: key);

  @override
  State<ReceivedMateRequestsPage> createState() => _ReceivedMateRequestsPageState();
}

class _ReceivedMateRequestsPageState extends State<ReceivedMateRequestsPage> {
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final results = await MateApi.fetchReceivedRequests();
      setState(() => _requests = results);
    } catch (e) {
      print("불러오기 실패: $e");
    }
  }

  String formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("받은 메이트 요청")),
      body: _requests.isEmpty
          ? const Center(child: Text("받은 요청이 없습니다"))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(req['senderNickname']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("메시지: ${req['message']}"),
                  Text("요청일시: ${formatDateTime(req['updatedAt'])}"),
                  Text("상태: ${req['status']}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      await MateApi.respondMateRequest(req['requestId'], true);
                      _loadRequests();
                    },
                    child: const Text("수락"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await MateApi.respondMateRequest(req['requestId'], false);
                      _loadRequests();
                    },
                    child: const Text("거절"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
