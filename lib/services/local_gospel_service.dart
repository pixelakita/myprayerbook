import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/daily_gospel.dart';
import 'gospel_service.dart';

class LocalGospelService implements GospelService {
  Map<String, dynamic>? _cache;

  @override
  Future<DailyGospel?> fetchGospel(DateTime date) async {
    _cache ??= await _loadJson();

    final String key = _formatDate(date);
    final Object? entry = _cache![key];

    if (entry == null) {
      return null;
    }

    return DailyGospel.fromJson(entry as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _loadJson() async {
    final String raw = await rootBundle.loadString(
      'assets/data/gospels.json',
    );
    return json.decode(raw) as Map<String, dynamic>;
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
