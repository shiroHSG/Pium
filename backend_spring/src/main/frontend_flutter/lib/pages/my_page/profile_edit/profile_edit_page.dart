import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../screens/auth/address_search/address_search_page.dart';
import '../../../screens/my_page/profile_edit/profile_edit_page_ui.dart';
import '../../../models/mate/mate_api.dart';
import '../../../theme/app_theme.dart';

class ProfileEditPage extends StatefulWidget {
  final bool openMateModal;

  const ProfileEditPage({Key? key, this.openMateModal = false}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _originalNickname;
  String? _originalPhoneNumber;
  String? _originalAddress;

  bool isLoading = true;
  bool isEditing = false;

  String? _profileImageUrl;
  File? _selectedImage;

  String? mateName;
  String? mateNickname;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      if (widget.openMateModal) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showMateRequestsModal(context);
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('https://pium.store/api/member'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = json.decode(utf8.decode(response.bodyBytes));
        final birthList = user['birth'];
        final mateId = user['mateInfo'];

        if (mateId != null) {
          final mateResponse = await http.get(
            Uri.parse('https://pium.store/api/member/users/$mateId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          if (mateResponse.statusCode == 200) {
            final mateUser = json.decode(utf8.decode(mateResponse.bodyBytes));
            setState(() {
              mateName = mateUser['username'];
              mateNickname = mateUser['nickname'];
            });
          }
        }

        final birthFormatted = birthList is List
            ? '${birthList[0]}-${birthList[1].toString().padLeft(2, '0')}-${birthList[2].toString().padLeft(2, '0')}'
            : '';

        setState(() {
          emailController.text = user['email'] ?? '';
          usernameController.text = user['username'] ?? '';
          nicknameController.text = user['nickname'] ?? '';
          phoneController.text = user['phoneNumber'] ?? '';
          birthController.text = birthFormatted;
          genderController.text = (user['gender'] == 'M') ? '남성' : '여성';
          addressController.text = user['address'] ?? '';

          final imagePath = user['profileImageUrl'];
          _profileImageUrl = (imagePath != null && imagePath.isNotEmpty)
              ? 'https://pium.store${imagePath.startsWith('/') ? imagePath : '/$imagePath'}'
              : null;

          _originalNickname = user['nickname'];
          _originalPhoneNumber = user['phoneNumber'];
          _originalAddress = user['address'];

          isLoading = false;
        });
      } else {
        print('회원 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final uri = Uri.parse('https://pium.store/api/member');
    final request = http.MultipartRequest('PATCH', uri);

    final memberData = {
      "nickname": nicknameController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "address": addressController.text.trim(),
    };

    request.fields['memberData'] = jsonEncode(memberData);
    request.headers['Authorization'] = 'Bearer $token';

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정이 완료되었습니다.')),
        );

        _originalNickname = nicknameController.text.trim();
        _originalPhoneNumber = phoneController.text.trim();
        _originalAddress = addressController.text.trim();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류')),
      );
    }
  }

  Future<void> _disconnectMate(BuildContext context) async {
    try {
      await MateApi.disconnectMate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mate 연결이 해제되었습니다.")),
      );
      setState(() {
        mateName = null;
        mateNickname = null;
      });
    } catch (e) {
      print("❌ 연결 해제 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("연결 해제에 실패했습니다.")),
      );
    }
  }

  void _showMateRequestsModal(BuildContext context) async {
    final received = await MateApi.fetchReceivedRequests();
    final sent = await MateApi.fetchSentRequests();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: '받은 요청'),
                  Tab(text: '보낸 요청'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildRequestList(received, isReceived: true),
                    _buildRequestList(sent, isReceived: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests, {required bool isReceived}) {
    if (requests.isEmpty) {
      return const Center(child: Text("요청이 없습니다."));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];

        return ListTile(
          title: Text(isReceived
              ? '${req['senderUsername']}(${req['senderNickname']})'
              : '${req['receiverUsername']}(${req['receiverNickname']})'),
          subtitle: Text(req['message'] ?? ''),
          trailing: isReceived
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  await MateApi.respondMateRequest(req['requestId'], true);
                  Navigator.pop(context);
                  _loadUserData();
                },
                child: const Text("수락"),
              ),
              TextButton(
                onPressed: () async {
                  await MateApi.respondMateRequest(req['requestId'], false);
                  Navigator.pop(context);
                  _loadUserData();
                },
                child: const Text("거절"),
              ),
            ],
          )
              : TextButton(
            onPressed: () async {
              await MateApi.cancelMateRequest(req['requestId']);
              Navigator.pop(context);
              _loadUserData();
            },
            child: const Text("취소", style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ProfileEditPageUI(
        emailController: emailController,
        usernameController: usernameController,
        nameController: nicknameController,
        phoneController: phoneController,
        birthController: birthController,
        genderController: genderController,
        addressController: addressController,
        isEditing: isEditing,
        profileImageUrl: _profileImageUrl,
        selectedImage: _selectedImage,
        onPickImage: _pickImage,
        onToggleEdit: () async {
          if (!isEditing) {
            setState(() => isEditing = true);
            return;
          }

          final isUnchanged =
              nicknameController.text.trim() == _originalNickname?.trim() &&
                  phoneController.text.trim() == _originalPhoneNumber?.trim() &&
                  addressController.text.trim() == _originalAddress?.trim() &&
                  _selectedImage == null;

          if (isUnchanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('변경사항이 없습니다!')),
            );
          } else {
            await _updateUserInfo();
            Navigator.pop(context, 'updated');
            return;
          }

          setState(() => isEditing = false);
        },
        onAddressSearch: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressSearchPage()),
          );
          if (result != null && result is String) {
            setState(() {
              addressController.text = result;
            });
          }
        },
        onMateRequestPressed: _showMateRequestsModal,
        onMateDisconnectPressed: _disconnectMate,
        mateName: mateName,
        mateNickname: mateNickname,
      ),
    );
  }
}