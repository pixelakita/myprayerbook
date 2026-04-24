import 'package:flutter/material.dart';

import 'models/app_content.dart';
import 'models/daily_gospel.dart';
import 'prayer_book_home_page.dart';
import 'services/gospel_service.dart';
import 'services/remote_gospel_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppContent content = await AppContent.load();

  final GospelService gospelService = RemoteGospelService(
    readingsUrl: 'http://myprayerbook.pixelakita.co/gospels.json',
  );
  final DailyGospel? todaysGospel = await gospelService.fetchGospel(
    DateTime.now(),
  );

  runApp(
    PrayerBookApp(
      content: content,
      gospelService: gospelService,
      initialGospel: todaysGospel,
    ),
  );
}

class PrayerBookApp extends StatelessWidget {
  final AppContent content;
  final GospelService gospelService;
  final DailyGospel? initialGospel;

  const PrayerBookApp({
    super.key,
    required this.content,
    required this.gospelService,
    this.initialGospel, // ← nullable, no required
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> app = content.app;
    final Map<String, dynamic> theme =
        Map<String, dynamic>.from(app['theme'] as Map);

    return MaterialApp(
      debugShowCheckedModeBanner:
          app['debugShowCheckedModeBanner'] as bool? ?? false,
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
      home: PrayerBookHomePage(
        content: content,
        gospelService: gospelService,
        initialGospel: initialGospel,
      ),
    );
  }
}
