import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          ...babyProfiles
              .map((baby) => GestureDetector(
            onTap: () => onEdit(baby),
            child: _BabyCard(baby: baby),
          ))
              .toList(),
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
            onTap: onAdd, // 변경 없음
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
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryPurple,
              child: Icon(Icons.child_care, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Info(label: '이름', value: baby.name),
                  _Info(label: '생년월일', value: baby.dob),
                  if (baby.gender?.isNotEmpty ?? false) _Info(label: '성별', value: baby.gender!),
                  if (baby.height?.isNotEmpty ?? false) _Info(label: '키', value: baby.height!),
                  if (baby.weight?.isNotEmpty ?? false) _Info(label: '몸무게', value: baby.weight!),
                  if (baby.allergies?.isNotEmpty ?? false) _Info(label: '알러지', value: baby.allergies!),
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
      child: Text('$label: $value',
          style: const TextStyle(fontSize: 14, color: AppTheme.textPurple)),
    );
  }
}