import 'package:flutter/material.dart';

import 'models/app_content.dart';
import 'models/daily_gospel.dart';
import 'screens/interactive_rosary_screen.dart';
import 'screens/supplemental_prayers_screen.dart';
import 'services/gospel_service.dart';
import 'widgets/calendar_section.dart';
import 'widgets/daily_journal_section.dart';
import 'widgets/gospel_section.dart';
import 'widgets/rosary_guide_section.dart';
import 'widgets/supplemental_prayers_section.dart';
import 'services/journal_storage_service.dart';

class PrayerBookHomePage extends StatefulWidget {
  final AppContent content;
  final GospelService gospelService;
  final DailyGospel? initialGospel;

  const PrayerBookHomePage({
    super.key,
    required this.content,
    required this.gospelService,
    required this.initialGospel,
  });

  @override
  State<PrayerBookHomePage> createState() => _PrayerBookHomePageState();
}

class _PrayerBookHomePageState extends State<PrayerBookHomePage> {
  late DateTime displayedMonth;
  late DateTime selectedDate;
  final TextEditingController journalController = TextEditingController();

  final JournalStorageService journalStorageService = JournalStorageService();
  bool isJournalLoading = false;
  bool isJournalSaving = false;

  DailyGospel? _currentGospel;
  bool _isGospelLoading = false;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month);
    selectedDate = now;
    _currentGospel = widget.initialGospel;

    _loadJournalForSelectedDate();
  }

  List<Map<String, String>> get supplementalPrayers {
    return widget.content
        .mapListAt(widget.content.supplementalPrayers, 'items')
        .map(
          (Map<String, dynamic> item) => <String, String>{
            'title': item['title'] as String,
            'text': item['text'] as String,
          },
        )
        .toList();
  }

  List<String> getMysteriesForTitle(String title) {
    final Map<String, dynamic> configuredMysteries = Map<String, dynamic>.from(
      widget.content.interactiveRosary['mysteriesByTitleKeyword'] as Map,
    );
    final String normalizedTitle = title.toLowerCase();

    for (final MapEntry<String, dynamic> entry in configuredMysteries.entries) {
      if (entry.key == 'default') continue;

      if (normalizedTitle.contains(entry.key.toLowerCase())) {
        return List<String>.from(entry.value as List<dynamic>);
      }
    }

    return List<String>.from(configuredMysteries['default'] as List<dynamic>);
  }

  Map<String, dynamic> getRosaryGuide(DateTime date) {
    final Map<String, dynamic> guideConfig = widget.content.rosaryGuide;
    final Map<String, dynamic> guidesByWeekday =
        Map<String, dynamic>.from(guideConfig['guidesByWeekday'] as Map);
    final String weekday = weekdayNameFromDate(date);
    final String defaultWeekday = guideConfig['defaultWeekday'] as String;
    final Map<String, dynamic> guide = Map<String, dynamic>.from(
      (guidesByWeekday[weekday] ?? guidesByWeekday[defaultWeekday]) as Map,
    );
    final String title = guide['title'] as String;

    return <String, dynamic>{
      'weekday': weekday,
      'title': title,
      'focus': guide['focus'],
      'steps': widget.content.stringListAt(guideConfig, 'steps'),
      'mysteries': getMysteriesForTitle(title),
    };
  }

  String weekdayNameFromDate(DateTime date) {
    final List<String> weekdays =
        widget.content.stringListAt(widget.content.rosaryGuide, 'weekdayNames');
    return weekdays[date.weekday - 1];
  }

  DateTime previousMonth(DateTime month) =>
      DateTime(month.year, month.month - 1);

  DateTime nextMonth(DateTime month) => DateTime(month.year, month.month + 1);

  Future<void> _loadGospelForSelectedDate() async {
    setState(() => _isGospelLoading = true);

    try {
      final DailyGospel? gospel =
          await widget.gospelService.fetchGospel(selectedDate);

      if (!mounted) return;

      setState(() => _currentGospel = gospel);
    } catch (e, st) {
      debugPrint('Failed to load gospel: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      setState(() => _currentGospel = null);
    } finally {
      if (!mounted) return;
      setState(() => _isGospelLoading = false);
    }
  }

  Future<void> _loadJournalForSelectedDate() async {
    setState(() {
      isJournalLoading = true;
    });

    try {
      final DateTime dateToLoad = selectedDate;
      final String content = await journalStorageService.loadEntry(dateToLoad);

      if (!mounted) return;

      setState(() {
        journalController.text = content;
      });
    } catch (e, st) {
      debugPrint('Failed to load journal: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      setState(() {
        journalController.text = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load journal entry.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isJournalLoading = false;
      });
    }
  }

  Future<void> _saveJournalForSelectedDate() async {
    setState(() {
      isJournalSaving = true;
    });

    try {
      await journalStorageService.saveEntry(
        date: selectedDate,
        content: journalController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved.')),
      );
    } catch (e, st) {
      debugPrint('Failed to save journal: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save journal entry.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isJournalSaving = false;
      });
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      selectedDate = date;
      displayedMonth = DateTime(date.year, date.month);
    });

    await Future.wait(<Future<void>>[
      _loadJournalForSelectedDate(),
      _loadGospelForSelectedDate(),
    ]);
  }

  void _openSupplementalPrayersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupplementalPrayersScreen(
          content: widget.content,
          prayers: supplementalPrayers,
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'prayer_list':
        _openSupplementalPrayersScreen();
        break;
    }
  }

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> layout = widget.content.layout;
    final Map<String, dynamic> rosaryGuide = getRosaryGuide(selectedDate);
    final List<String> steps =
        List<String>.from(rosaryGuide['steps'] as List<dynamic>);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prayerbook'),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'prayer_list',
                child: Text('Prayer List'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >=
                widget.content.doubleAt(layout, 'wideHomeBreakpoint');

            return SingleChildScrollView(
              padding: EdgeInsets.all(
                widget.content.doubleAt(layout, 'pagePadding'),
              ),
              child: isWide
                  ? _buildWideLayout(layout, rosaryGuide, steps)
                  : _buildMobileLayout(layout, rosaryGuide, steps),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarSection(Map<String, dynamic> layout) {
    return CalendarSection(
      content: widget.content,
      displayedMonth: displayedMonth,
      selectedDate: selectedDate,
      onPreviousMonth: () {
        setState(() => displayedMonth = previousMonth(displayedMonth));
      },
      onNextMonth: () {
        setState(() => displayedMonth = nextMonth(displayedMonth));
      },
      onDateSelected: _onDateSelected,
    );
  }

  Widget _buildRosarySection(
    Map<String, dynamic> layout,
    Map<String, dynamic> rosaryGuide,
    List<String> steps,
  ) {
    return RosaryGuideSection(
      content: widget.content,
      rosaryGuide: rosaryGuide,
      onOpenInteractiveRosary: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InteractiveRosaryScreen(
              content: widget.content,
              title: rosaryGuide['title'] as String,
              weekday: rosaryGuide['weekday'] as String,
              steps: steps,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGospelSection() {
    return GospelSection(
      content: widget.content,
      gospel: _currentGospel,
      selectedDate: selectedDate,
      isLoading: _isGospelLoading,
    );
  }

  Widget _buildJournalSection() {
    return DailyJournalSection(
      content: widget.content,
      controller: journalController,
      selectedDate: selectedDate,
      onSave: _saveJournalForSelectedDate,
      isSaving: isJournalSaving,
      isLoading: isJournalLoading,
    );
  }

  Widget _buildWideLayout(
    Map<String, dynamic> layout,
    Map<String, dynamic> rosaryGuide,
    List<String> steps,
  ) {
    final double gap = widget.content.doubleAt(layout, 'largeGap');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Column(
            children: <Widget>[
              _buildCalendarSection(layout),
              SizedBox(height: gap),
              _buildRosarySection(layout, rosaryGuide, steps),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: 4,
          child: Column(
            children: <Widget>[
              _buildGospelSection(),
              SizedBox(height: gap),
              _buildJournalSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    Map<String, dynamic> layout,
    Map<String, dynamic> rosaryGuide,
    List<String> steps,
  ) {
    final double gap = widget.content.doubleAt(layout, 'largeGap');

    return Column(
      children: <Widget>[
        _buildCalendarSection(layout),
        SizedBox(height: gap),
        _buildRosarySection(layout, rosaryGuide, steps),
        SizedBox(height: gap),
        _buildGospelSection(),
        SizedBox(height: gap),
        _buildJournalSection(),
      ],
    );
  }
}
