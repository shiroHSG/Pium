import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chatroom.dart';
import 'chatroom_member.dart';
import 'message.dart';

const _baseUrl = 'https://pium.store'; // 또는 네트워크 환경에 따라 조정

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

// 채팅방 생성 (DIRECT)
Future<ChatRoom> createOrGetDirectChatRoom(int receiverId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  // 요청 데이터 구성
  final requestDto = {
    'type': 'DIRECT',
    'receiverId': receiverId,
  };

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$_baseUrl/api/chatroom'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['chatRoomData'] = jsonEncode(requestDto);

  final response = await request.send();

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ChatRoom.fromJson(json); // 모델 맞춰서 수정
  } else {
    throw Exception('채팅방 생성 실패: ${response.statusCode}');
  }
}

// 채팅방 생성 share
Future<ChatRoom> createOrGetShareChatRoom({
  required int receiverId,
  required int sharePostId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  // 요청 DTO 구성
  final requestDto = {
    'type': 'SHARE',
    'receiverId': receiverId,
    'shareId': sharePostId,
  };

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$_baseUrl/api/chatroom'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['chatRoomData'] = jsonEncode(requestDto);

  final response = await request.send();

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ChatRoom.fromJson(json); // 모델 구조에 맞춰 파싱
  } else {
    throw Exception('SHARE 채팅방 생성 실패: ${response.statusCode}');
  }
}

// 채팅방 생성 group
Future<ChatRoom> createGroupChatRoom({
  required String chatRoomName,
  String? password,
  File? imageFile,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) throw Exception('토큰이 없습니다.');

  final requestDto = {
    'type': 'GROUP',
    'chatRoomName': chatRoomName,
    if (password != null && password.isNotEmpty) 'password': password,
  };

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$_baseUrl/api/chatroom'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['chatRoomData'] = jsonEncode(requestDto);

  if (imageFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );
  }

  final response = await request.send();

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ChatRoom.fromJson(json);
  } else {
    throw Exception('GROUP 채팅방 생성 실패: ${response.statusCode}');
  }
}

// 멤버 불러오기
Future<List<Map<String, dynamic>>> fetchChatRoomMembers(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  final response = await http.get(
    Uri.parse('https://pium.store/api/chatroom/$chatRoomId/members'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('멤버 불러오기 실패: ${response.statusCode}');
  }
}

// 채팅방 수정, 그룹 채팅방일때만
Future<void> updateGroupChatRoom({
  required int chatRoomId,
  required String chatRoomName,
  String? password,
  File? imageFile,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final requestDto = {
    'type': 'GROUP',
    'chatRoomName': chatRoomName,
    if (password != null && password.isNotEmpty) 'password': password,
  };

  final request = http.MultipartRequest(
    'PATCH',
    Uri.parse('$_baseUrl/api/chatroom/$chatRoomId'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['chatRoomData'] = jsonEncode(requestDto);

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    print('✅ 채팅방 수정 성공');
  } else {
    final error = await response.stream.bytesToString();
    print('❌ 채팅방 수정 실패: ${response.statusCode} - $error');
    throw Exception('채팅방 수정 실패: ${response.statusCode}');
  }
}

// 채팅방 나가기, 그룹채팅방에서 방장일때만 모달창 다르게
Future<void> leaveChatRoom(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final uri = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId/leave');

  final response = await http.delete(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print('✅ 채팅방 나가기 성공');
  } else {
    print('❌ 채팅방 나가기 실패: ${response.statusCode}');
    throw Exception('채팅방 나가기 실패: ${response.statusCode}');
  }
}

// 채팅방 삭제, 그룹채팅방일때 방장만 삭제
Future<void> deleteGroupChatRoom(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final uri = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId');

  final response = await http.delete(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print('✅ 채팅방 삭제 성공');
  } else {
    final body = await response.body;
    print('❌ 채팅방 삭제 실패: ${response.statusCode} - $body');
    throw Exception('채팅방 삭제 실패: ${response.statusCode}');
  }
}

// 방장 위임 요청
Future<void> delegateAdmin(int chatRoomId, int newAdminId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final url = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId/members/$newAdminId/delegate');

  final response = await http.patch(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode != 200) {
    throw Exception('방장 위임 실패: ${response.statusCode}');
  } else {
    print('✅ 방장 위임 성공');
  }
}

// 초대 링크 조회
Future<Map<String, String>> fetchInviteLink(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) throw Exception('토큰이 없습니다.');

  final uri = Uri.parse('$_baseUrl/api/chatroom/$chatRoomId/invite-link');

  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return {
      'inviteCode': json['inviteCode'],
      'inviteLink': json['inviteLink'],
    };
  } else {
    throw Exception('초대 링크 조회 실패: ${response.statusCode}');
  }
}

// 초대 링크 정보 조회
Future<Map<String, dynamic>> checkInviteCode(String inviteCode) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) throw Exception('토큰이 없습니다.');

  final uri = Uri.parse('$_baseUrl/api/chatroom/invite/$inviteCode');

  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return {
      'chatRoomName': json['chatRoomName'],
      'alreadyJoined': json['alreadyJoined'],
      'requirePassword': json['requirePassword'],
    };
  } else {
    throw Exception('초대 코드 확인 실패: ${response.statusCode}');
  }
}

// 초대 링크 입장
Future<int> enterChatRoomViaInvite({
  required String inviteCode,
  String? password,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) throw Exception('토큰이 없습니다.');

  final uri = Uri.parse('$_baseUrl/api/chatroom/invite/$inviteCode')
      .replace(queryParameters: {
    if (password != null && password.isNotEmpty) 'password': password,
  });

  final response = await http.post(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return int.parse(response.body); // chatRoomId
  } else {
    throw Exception('초대 링크 입장 실패: ${response.statusCode}');
  }
}

/*// ✅ 채팅방 멤버 리스트 조회 함수
Future<List<ChatRoomMember>> fetchChatRoomMembers(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final uri = Uri.parse('https://pium.store/api/chatroom/$chatRoomId/members');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => ChatRoomMember.fromJson(json)).toList();
  } else {
    throw Exception('채팅방 멤버 조회 실패: ${response.statusCode}');
  }
}*/

// 멤버 밴
Future<void> banChatRoomMember({
  required int chatRoomId,
  required int memberId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) {
    throw Exception('토큰이 없습니다.');
  }

  final uri = Uri.parse(
      'https://pium.store/api/chatroom/$chatRoomId/member/$memberId/ban');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print('✅ 사용자 추방 성공');
  } else {
    throw Exception('사용자 추방 실패: ${response.statusCode}');
  }
}

Future<ChatRoom> fetchChatRoomDetail(int chatRoomId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) throw Exception('토큰이 없습니다.');

  final response = await http.get(
    Uri.parse('$_baseUrl/api/chatroom/$chatRoomId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return ChatRoom.fromJson(json);
  } else {
    throw Exception('채팅방 상세 정보 불러오기 실패: ${response.statusCode}');
  }
}

