import 'package:flutter/material.dart';

class Schedule {
  final String title;
  final DateTime date;
  final String time;
  final String? memo;
  final Color color;

  Schedule({
    required this.title,
    required this.date,
    required this.time,
    this.memo,
    required this.color,
  });
}