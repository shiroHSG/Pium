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
    return Schedule(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      colorTag: json['color_tag'],
    );
  }

  // Schedule -> JSON (POST용)
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
