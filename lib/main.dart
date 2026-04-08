import 'package:flutter/material.dart';

import 'models/app_content.dart';
import 'prayer_book_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppContent content = await AppContent.load();
  runApp(PrayerBookApp(content: content));
}

class PrayerBookApp extends StatelessWidget {
  final AppContent content;

  const PrayerBookApp({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> app = content.app;
    final Map<String, dynamic> theme = Map<String, dynamic>.from(app['theme'] as Map);

    return MaterialApp(
      debugShowCheckedModeBanner: app['debugShowCheckedModeBanner'] as bool? ?? false,
      title: app['title'] as String,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: content.parseColor(theme['seedColor'] as String),
        ),
        scaffoldBackgroundColor: content.parseColor(
          theme['scaffoldBackgroundColor'] as String,
        ),
        useMaterial3: theme['useMaterial3'] as bool,
      ),
      home: PrayerBookHomePage(content: content),
    );
  }
}
