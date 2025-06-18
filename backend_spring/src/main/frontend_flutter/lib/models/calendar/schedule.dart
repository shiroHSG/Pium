import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final String title;
  final String content;
  final DateTime startTime;
  final String colorTag;

  Schedule({
    this.id,
    required this.title,
    required this.content,
    required this.startTime,
    required this.colorTag,
  });

  // JSON -> Schedule
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['startTime'];

    if (startTimeStr == null) {
      throw Exception('start_time이 null입니다.');
    }

    return Schedule(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      startTime: DateTime.parse(startTimeStr),
      colorTag: json['colorTag'] as String? ?? '#FFFFFF',
    );
  }

  // Schedule -> JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "startTime": startTime.toIso8601String(),
      "colorTag": colorTag,
    };
  }

  // Getter
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  String get time => '${startTime.hour.toString().padLeft(2, '0')}시 ${startTime.minute.toString().padLeft(2, '0')}분';

  Color get color => Color(int.parse(colorTag.replaceFirst('#', '0xFF')));
}
