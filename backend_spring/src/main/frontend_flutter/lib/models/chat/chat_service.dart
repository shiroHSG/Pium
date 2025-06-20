@ -1,130 +0,0 @@
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chatroom.dart';
import 'message.dart';

const _baseUrl = 'http://10.0.2.2:8080'; // 또는 네트워크 환경에 따라 조정

Future<List<ChatRoom>> fetchChatRooms() async {
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');
print('🔐 accessToken: $token');
if (token == null) {
throw Exception('토큰이 존재하지 않습니다.');
}

final response = await http.get(
Uri.parse('$_baseUrl/api/chatroom'),
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer $token',
},
);

if (response.statusCode == 200) {
final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
return jsonList.map((json) => ChatRoom.fromJson(json)).toList();

} else {
throw Exception('채팅방 불러오기 실패: ${response.statusCode}');
}
}

// 메세지 조회
Future<List<ChatMessage>> fetchMessages({
required int chatRoomId,
required int currentUserId,
int? pivotId,
String direction = 'latest',
}) async {
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');

if (token == null) {
throw Exception('토큰이 존재하지 않습니다.');
}

final uri = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId/messages')
    .replace(queryParameters: {
if (pivotId != null) 'pivotId': pivotId.toString(),
'direction': direction,
});

final response = await http.get(
uri,
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer $token',
},
);

if (response.statusCode == 200) {
final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
return data.map((json) => ChatMessage.fromJson(json, currentUserId)).toList();
} else {
throw Exception('메시지 불러오기 실패: ${response.statusCode}');
}
}

// 메세지 전송
Future<ChatMessage> sendMessageToServer({
required int chatRoomId,
required String content,
required int senderId,
}) async {
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');

if (token == null) {
throw Exception('토큰이 없습니다.');
}

final uri = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId/messages');

final response = await http.post(
uri,
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer $token',
},
body: jsonEncode({
'content': content,
}),
);

if (response.statusCode == 200 || response.statusCode == 201) {
final json = jsonDecode(utf8.decode(response.bodyBytes));
return ChatMessage.fromJson(json, senderId); // ✅ 보낸 사람 ID 넘김
} else {
throw Exception('메시지 전송 실패: ${response.statusCode}');
}
}

// 안읽은 전체 메세지수 가져오기
Future<int> getUnreadCount() async {
try {
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');

final response = await http.get(
Uri.parse('$_baseUrl/api/chatroom/unread-count'), // ✅ 실제 URL로 교체
headers: {
'Authorization': 'Bearer $token',
},
);


if (response.statusCode == 200) {
return int.parse(response.body); // ✅ 여기서만 값 반환
} else {
print('❌ 안읽은 메시지 수 실패: ${response.statusCode}');
return 0; // 실패 시 기본값
}
} catch (e) {
print('❌ 예외 발생: $e');
return 0; // 예외 시 기본값
}
}