import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/models/baby_profile.dart';

class BabyProfileUI extends StatelessWidget {
  final List<BabyProfile> babyProfiles;
  final Function(BabyProfile) onEdit;
  final VoidCallback onAdd;

  const BabyProfileUI({
    Key? key,
    required this.babyProfiles,
    required this.onEdit,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _Header(onAdd: onAdd),
          const SizedBox(height: 20),
          ...babyProfiles.map((baby) => GestureDetector(
            onTap: () => onEdit(baby),
            child: _BabyCard(baby: baby),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;

  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '등록된 아이 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPurple,
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _BabyCard extends StatelessWidget {
  final BabyProfile baby;

  const _BabyCard({required this.baby});

  String formatDate(DateTime? date) {
    if (date == null) return '미입력';
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }

  String genderToKorean(Gender? gender) {
    if (gender == null) return '미입력';
    return gender == Gender.MALE ? '남자' : '여자';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.lightPink,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryPurple,
              backgroundImage: (baby.profileImageUrl != null && baby.profileImageUrl!.isNotEmpty)
                  ? NetworkImage(baby.profileImageUrl!)
                  : null,
              child: (baby.profileImageUrl == null || baby.profileImageUrl!.isEmpty)
                  ? const Icon(Icons.child_care, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Info(label: '이름', value: baby.name),
                  _Info(label: '생년월일', value: formatDate(baby.birthDate)),
                  _Info(label: '성별', value: genderToKorean(baby.gender)),
                  if (baby.height != null)
                    _Info(label: '키', value: '${baby.height!.toStringAsFixed(1)} cm'),
                  if (baby.weight != null)
                    _Info(label: '몸무게', value: '${baby.weight!.toStringAsFixed(1)} kg'),
                  if (baby.allergy?.isNotEmpty ?? false)
                    _Info(label: '알러지', value: baby.allergy!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, color: AppTheme.textPurple),
      ),
    );
  }
}
