import 'dart:convert';
import 'package:flutter/services.dart';

class AppContent {
  final Map<String, dynamic> raw;

  AppContent(this.raw);

  static Future<AppContent> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/app_content.json',
    );
    return AppContent(json.decode(jsonString) as Map<String, dynamic>);
  }

  Map<String, dynamic> get app => _map('app');
  Map<String, dynamic> get layout => _map('layout');
  Map<String, dynamic> get colors => _map('colors');
  Map<String, dynamic> get calendar => _map('calendar');
  Map<String, dynamic> get journal => _map('journal');
  Map<String, dynamic> get rosaryGuide => _map('rosaryGuide');
  Map<String, dynamic> get interactiveRosary => _map('interactiveRosary');
  Map<String, dynamic> get supplementalPrayers => _map('supplementalPrayers');
  Map<String, dynamic> get gospelStrings => _map('gospelStrings'); // 🆕

  Map<String, dynamic> _map(String key) =>
      Map<String, dynamic>.from(raw[key] as Map<String, dynamic>);

  List<String> stringListAt(Map<String, dynamic> source, String key) =>
      List<String>.from(source[key] as List<dynamic>);

  List<Map<String, dynamic>> mapListAt(
          Map<String, dynamic> source, String key) =>
      List<Map<String, dynamic>>.from(
        (source[key] as List<dynamic>).map(
          (dynamic item) => Map<String, dynamic>.from(item as Map),
        ),
      );

  Color colorAt(String key) => parseColor(colors[key] as String);

  Color parseColor(String value) {
    final String sanitized = value.replaceFirst('0x', '');
    return Color(int.parse(sanitized, radix: 16));
  }

  double doubleAt(Map<String, dynamic> source, String key) {
    final Object? value = source[key];
    if (value is int) {
      return value.toDouble();
    }
    return value as double;
  }

  int intAt(Map<String, dynamic> source, String key) => source[key] as int;
  bool boolAt(Map<String, dynamic> source, String key) => source[key] as bool;
  String stringAt(Map<String, dynamic> source, String key) =>
      source[key] as String;
}
