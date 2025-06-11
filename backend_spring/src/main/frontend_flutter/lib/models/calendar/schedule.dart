import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final String title;
  final String content;
  final DateTime startTime;
  final DateTime endTime;
  final String colorTag;

  Schedule({
    this.id,
    required this.title,
    required this.content,
    required this.startTime,
    required this.endTime,
    required this.colorTag,
  });

  // JSON -> Schedule
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['start_time'];
    final endTimeStr = json['end_time'];

    if (startTimeStr == null || endTimeStr == null) {
      throw Exception('start_time 또는 end_time이 null입니다.');
    }

    return Schedule(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      startTime: DateTime.parse(startTimeStr),
      endTime: DateTime.parse(endTimeStr),
      colorTag: json['color_tag'] as String? ?? '#FFFFFF',
    );
  }

  // Schedule -> JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "start_time": startTime.toIso8601String(),
      "end_time": endTime.toIso8601String(),
      "color_tag": colorTag,
    };
  }

  // Getter
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  String get time => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  Color get color => Color(int.parse(colorTag.replaceFirst('#', '0xFF')));
}
